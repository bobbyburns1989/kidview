import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kidview/config/themes.dart';
import 'package:kidview/core/constants/route_constants.dart';
import 'package:kidview/data/models/video_model.dart';
import 'package:kidview/data/services/video_service.dart';
import 'package:kidview/features/child_interface/screens/child_library_screen.dart';
import 'package:provider/provider.dart';
import 'package:kidview/data/providers/theme_provider.dart';
import 'package:kidview/features/child_interface/widgets/featured_video_card.dart';
import 'package:kidview/features/child_interface/widgets/video_card.dart';
import 'package:kidview/features/child_interface/widgets/category_button.dart';
import 'package:kidview/features/child_interface/widgets/child_bottom_nav_bar.dart';

class ChildHomeScreen extends StatefulWidget {
  final String ageGroup;

  const ChildHomeScreen({
    super.key,
    required this.ageGroup,
  });

  @override
  State<ChildHomeScreen> createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  final VideoService _videoService = VideoService();
  bool _isLoading = true;
  List<Video> _featuredVideos = [];
  List<Video> _recommendedVideos = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  Future<void> _loadVideos() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load featured and recommended videos in parallel
      final futureFeatures = _videoService.getFeaturedVideos(widget.ageGroup);
      final futureRecommended = _videoService.getRecommendedVideos(widget.ageGroup);

      final results = await Future.wait([futureFeatures, futureRecommended]);

      setState(() {
        _featuredVideos = results[0];
        _recommendedVideos = results[1];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load videos: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isYoungerChild = widget.ageGroup == 'younger';
    
    // Set the appropriate theme based on age group
    if (isYoungerChild) {
      themeProvider.setYoungerChildView(true);
    } else {
      themeProvider.setOlderChildView(true);
    }

    // Get age-appropriate colors
    final primaryColor = isYoungerChild 
        ? AppThemes.primaryYounger 
        : AppThemes.primaryOlder;
    final secondaryColor = isYoungerChild 
        ? AppThemes.secondaryYounger 
        : AppThemes.secondaryOlder;
    final backgroundColor = isYoungerChild 
        ? AppThemes.backgroundYounger 
        : AppThemes.backgroundOlder;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(primaryColor, isYoungerChild),
      body: _buildBody(primaryColor, secondaryColor, isYoungerChild),
      bottomNavigationBar: ChildBottomNavBar(
        ageGroup: widget.ageGroup,
        currentIndex: 0,
        onTap: _handleNavigation,
        primaryColor: primaryColor,
        isYoungerChild: isYoungerChild,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Color primaryColor, bool isYoungerChild) {
    final appBarHeight = isYoungerChild ? 70.0 : 56.0;
    final iconSize = isYoungerChild ? 32.0 : 24.0;

    return PreferredSize(
      preferredSize: Size.fromHeight(appBarHeight),
      child: AppBar(
        backgroundColor: primaryColor,
        elevation: 8,
        shape: isYoungerChild 
          ? const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(16),
              ),
            )
          : null,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo/bubble.png',
              height: isYoungerChild ? 40 : 32,
              width: isYoungerChild ? 40 : 32,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Text(
              isYoungerChild ? 'KidView Jr.' : 'KidView',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: isYoungerChild ? 24 : 20,
              ),
            ),
          ],
        ),
        actions: [
          // Exit button to return to parent mode
          Padding(
            padding: EdgeInsets.only(right: isYoungerChild ? 16.0 : 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(isYoungerChild ? 16 : 8),
              ),
              child: IconButton(
                icon: Icon(
                  Icons.home,
                  color: Colors.white,
                  size: iconSize,
                ),
                tooltip: 'Exit to Parent Mode',
                onPressed: () => _showExitDialog(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(Color primaryColor, Color secondaryColor, bool isYoungerChild) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: primaryColor,
          strokeWidth: 3,
        ),
      );
    }

    if (_error != null) {
      return _buildErrorView(primaryColor);
    }

    return RefreshIndicator(
      onRefresh: _loadVideos,
      color: primaryColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              _buildWelcomeMessage(primaryColor, isYoungerChild),
              const SizedBox(height: 24),

              // Featured videos carousel
              if (_featuredVideos.isNotEmpty) ...[
                _buildSectionTitle('Featured'),
                const SizedBox(height: 12),
                _buildFeaturedVideosCarousel(primaryColor),
                const SizedBox(height: 32),
              ],

              // Recommended videos grid
              if (_recommendedVideos.isNotEmpty) ...[
                _buildSectionTitle('Recommended for You'),
                const SizedBox(height: 16),
                _buildRecommendedVideosGrid(primaryColor),
              ],

              const SizedBox(height: 32),

              // Category buttons
              _buildSectionTitle('Categories'),
              const SizedBox(height: 16),
              _buildCategoryGrid(primaryColor, secondaryColor, isYoungerChild),
              
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(Color primaryColor) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong.',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(_error!),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadVideos,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage(Color primaryColor, bool isYoungerChild) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello, ${isYoungerChild ? 'Friend' : 'Explorer'}!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'What would you like to watch today?',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Widget _buildFeaturedVideosCarousel(Color primaryColor) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _featuredVideos.length,
        itemBuilder: (context, index) {
          final video = _featuredVideos[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: FeaturedVideoCard(
              video: video, 
              ageGroup: widget.ageGroup,
              accentColor: primaryColor,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendedVideosGrid(Color primaryColor) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _recommendedVideos.length,
      itemBuilder: (context, index) {
        final video = _recommendedVideos[index];
        return VideoCard(
          video: video, 
          ageGroup: widget.ageGroup,
          accentColor: primaryColor,
        );
      },
    );
  }

  Widget _buildCategoryGrid(Color primaryColor, Color secondaryColor, bool isYoungerChild) {
    final categories = [
      {'name': 'Education', 'icon': Icons.school},
      {'name': 'Science', 'icon': Icons.science},
      {'name': 'Art', 'icon': Icons.color_lens},
      {'name': 'Music', 'icon': Icons.music_note},
      {'name': 'Math', 'icon': Icons.calculate},
      {'name': 'Language', 'icon': Icons.language},
    ];
    
    // Younger children get a simpler 2-column layout with larger elements
    final crossAxisCount = isYoungerChild ? 2 : 3;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: isYoungerChild ? 1.0 : 1.1,
        crossAxisSpacing: isYoungerChild ? 20 : 12,
        mainAxisSpacing: isYoungerChild ? 20 : 12,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: isYoungerChild ? 24.0 : 16.0),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final color = index % 2 == 0 ? primaryColor : secondaryColor;
        
        return CategoryButton(
          name: category['name'] as String,
          icon: category['icon'] as IconData,
          color: color,
          isYoungerChild: isYoungerChild,
        );
      },
    );
  }

  void _handleNavigation(int index) {
    if (index == 1) {
      // Create slide transition to library screen
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => 
            ChildLibraryScreen(ageGroup: widget.ageGroup),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            var begin = const Offset(1.0, 0.0);
            var end = Offset.zero;
            var curve = Curves.easeInOut;
            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            return SlideTransition(position: animation.drive(tween), child: child);
          },
        ),
      );
    }
  }

  void _showExitDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        title: const Text('Exit Kid Mode?'),
        content: const Text('Do you want to return to parent mode?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Reset to parent view
              themeProvider.setParentView();
              Navigator.of(context).pop();
              context.go(Routes.parentHome);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }
}