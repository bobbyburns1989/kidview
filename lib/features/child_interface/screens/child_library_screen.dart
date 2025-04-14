import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kidview/config/themes.dart';
import 'package:kidview/core/constants/route_constants.dart';
import 'package:kidview/data/models/video_model.dart';
import 'package:kidview/data/services/video_service.dart';
import 'package:kidview/shared/widgets/error_view.dart';
import 'package:kidview/features/child_interface/widgets/video_card.dart';
import 'package:kidview/features/child_interface/widgets/child_bottom_nav_bar.dart';
import 'package:kidview/features/child_interface/widgets/category_filter_chip.dart';
import 'package:kidview/features/child_interface/widgets/search_bar_widget.dart';
import 'package:kidview/features/child_interface/widgets/empty_results_view.dart';

class ChildLibraryScreen extends StatefulWidget {
  final String ageGroup;

  const ChildLibraryScreen({
    super.key,
    required this.ageGroup,
  });

  @override
  State<ChildLibraryScreen> createState() => _ChildLibraryScreenState();
}

class _ChildLibraryScreenState extends State<ChildLibraryScreen> {
  final VideoService _videoService = VideoService();
  bool _isLoading = true;
  List<Video> _videos = [];
  String? _error;
  String _currentCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  List<Video> _filteredVideos = [];
  String _sortOption = 'newest';

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVideos() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Get all videos for the age group
      final videos = await _videoService.getRecommendedVideos(widget.ageGroup);
      
      setState(() {
        _videos = videos;
        _filteredVideos = videos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load videos: $e';
        _isLoading = false;
      });
    }
  }

  void _filterByCategory(String category) {
    setState(() {
      _currentCategory = category;
      _applyFiltersAndSort();
    });
  }

  void _searchVideos(String query) {
    setState(() {
      _applyFiltersAndSort(searchQuery: query);
    });
  }
  
  void _sortVideos(String sortOption) {
    setState(() {
      _sortOption = sortOption;
      _applyFiltersAndSort();
    });
  }
  
  void _applyFiltersAndSort({String? searchQuery}) {
    // Step 1: Apply category filter
    List<Video> categoryFiltered;
    if (_currentCategory == 'All') {
      categoryFiltered = _videos;
    } else {
      categoryFiltered = _videos.where((video) => 
        video.categories.contains(_currentCategory)
      ).toList();
    }
    
    // Step 2: Apply search filter if provided
    List<Video> searchFiltered;
    final query = searchQuery ?? _searchController.text;
    
    if (query.isEmpty) {
      searchFiltered = categoryFiltered;
    } else {
      searchFiltered = categoryFiltered.where((video) => 
        video.title.toLowerCase().contains(query.toLowerCase()) ||
        video.description.toLowerCase().contains(query.toLowerCase()) ||
        video.tags.any((tag) => tag.toLowerCase().contains(query.toLowerCase())) ||
        video.educationalTags.any((tag) => 
          tag.name.toLowerCase().contains(query.toLowerCase()) ||
          tag.subject.toLowerCase().contains(query.toLowerCase())
        )
      ).toList();
    }
    
    // Step 3: Apply sorting
    switch (_sortOption) {
      case 'newest':
        searchFiltered.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
        break;
      case 'popular':
        searchFiltered.sort((a, b) => b.viewCount.compareTo(a.viewCount));
        break;
      case 'rating':
        searchFiltered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'duration':
        searchFiltered.sort((a, b) => a.duration.compareTo(b.duration));
        break;
    }
    
    _filteredVideos = searchFiltered;
  }

  @override
  Widget build(BuildContext context) {
    final isYoungerChild = widget.ageGroup == 'younger';
    
    // Get age-appropriate colors
    final primaryColor = isYoungerChild 
        ? AppThemes.primaryYounger 
        : AppThemes.primaryOlder;
    final backgroundColor = isYoungerChild 
        ? AppThemes.backgroundYounger 
        : AppThemes.backgroundOlder;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Video Library',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('${Routes.childHome}?ageGroup=${widget.ageGroup}'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SearchBarWidget(
              controller: _searchController,
              onChanged: _searchVideos,
              hintText: 'Search videos...',
            ),
          ),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: primaryColor,
              ),
            )
          : _error != null
              ? ErrorView(
                  error: _error!,
                  onRetry: _loadVideos,
                )
              : Column(
                  children: [
                    // Category filter chips
                    _buildCategoryFilters(primaryColor),
                    
                    // Results count and sort options
                    _buildResultsHeader(primaryColor),
                    
                    // Videos grid
                    Expanded(
                      child: _filteredVideos.isEmpty
                          ? const EmptyResultsView()
                          : _buildVideosGrid(primaryColor),
                    ),
                  ],
                ),
      bottomNavigationBar: ChildBottomNavBar(
        ageGroup: widget.ageGroup,
        currentIndex: 1,
        onTap: _handleNavigation,
        primaryColor: primaryColor,
        isYoungerChild: isYoungerChild,
      ),
    );
  }

  Widget _buildCategoryFilters(Color primaryColor) {
    final categories = [
      'All',
      'Education',
      'Science',
      'Art',
      'Music',
      'Language',
      'Math',
      'Technology'
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: categories.map((category) {
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CategoryFilterChip(
                label: category,
                isSelected: _currentCategory == category,
                onSelected: (selected) => _filterByCategory(category),
                primaryColor: primaryColor,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildResultsHeader(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '${_filteredVideos.length} ${_filteredVideos.length == 1 ? 'video' : 'videos'} found',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          DropdownButton<String>(
            value: _sortOption,
            underline: const SizedBox(),
            icon: Icon(Icons.sort, color: primaryColor),
            items: const [
              DropdownMenuItem(
                value: 'newest',
                child: Text('Newest'),
              ),
              DropdownMenuItem(
                value: 'popular',
                child: Text('Most popular'),
              ),
              DropdownMenuItem(
                value: 'rating',
                child: Text('Highest rated'),
              ),
              DropdownMenuItem(
                value: 'duration',
                child: Text('Shortest first'),
              ),
            ],
            onChanged: (value) {
              if (value != null) {
                _sortVideos(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildVideosGrid(Color primaryColor) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredVideos.length,
      itemBuilder: (context, index) {
        final video = _filteredVideos[index];
        return VideoCard(
          video: video,
          ageGroup: widget.ageGroup,
          accentColor: primaryColor,
        );
      },
    );
  }

  void _handleNavigation(int index) {
    if (index == 0) {
      // Navigate to home
      context.go('${Routes.childHome}?ageGroup=${widget.ageGroup}');
    }
  }
}