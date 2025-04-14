import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:kidview/data/providers/auth_provider.dart';
import 'package:kidview/data/models/parent_model.dart';
import 'package:kidview/core/constants/route_constants.dart';
import 'package:kidview/data/models/video_model.dart';
import 'package:kidview/data/services/video_service.dart';
import 'package:kidview/features/parent_dashboard/widgets/section_header.dart';
import 'package:kidview/features/parent_dashboard/widgets/child_selector.dart';
import 'package:kidview/features/parent_dashboard/widgets/history_list_item.dart';
import 'package:kidview/features/parent_dashboard/widgets/empty_history_view.dart';

class ViewingHistoryScreen extends StatefulWidget {
  const ViewingHistoryScreen({super.key});

  @override
  State<ViewingHistoryScreen> createState() => _ViewingHistoryScreenState();
}

class _ViewingHistoryScreenState extends State<ViewingHistoryScreen> {
  final VideoService _videoService = VideoService();
  bool _isLoading = false;
  String? _error;
  Child? _selectedChild;
  List<Video> _watchHistory = [];
  final Map<String, Video> _videoCache = {};
  final DateTime _today = DateTime.now();
  final DateTime _yesterday = DateTime.now().subtract(const Duration(days: 1));
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final parent = Provider.of<AuthProvider>(context, listen: false).parent;
    if (parent != null && parent.children.isNotEmpty) {
      _selectChild(parent.children.first);
    }
  }

  Future<void> _selectChild(Child child) async {
    setState(() {
      _isLoading = true;
      _error = null;
      _selectedChild = child;
      _watchHistory = [];
    });

    try {
      // For demo: Use mocked data and populate with random videos
      // In a real app, we would fetch the actual watch history for the child
      await Future.delayed(const Duration(milliseconds: 800));
      
      // Get all videos
      final allVideos = _videoService.getMockVideos();
      
      // Create video cache for quick lookup
      for (final video in allVideos) {
        _videoCache[video.id] = video;
      }
      
      // Use video IDs from the child's watch history
      if (_selectedChild!.watchHistory.isEmpty) {
        // For demo, if no history, use 3-5 random videos
        final randomVideos = List<Video>.from(allVideos)..shuffle();
        final historyLength = randomVideos.length > 5 ? 5 : randomVideos.length;
        _watchHistory = randomVideos.take(historyLength).toList();
      } else {
        // Convert video IDs to Video objects
        _watchHistory = _selectedChild!.watchHistory
            .map((id) => _videoCache[id])
            .whereType<Video>()
            .toList();
      }
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load watch history: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final parent = Provider.of<AuthProvider>(context).parent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Viewing History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(Routes.parentHome),
        ),
      ),
      body: parent == null
          ? const Center(child: Text('No parent data available'))
          : parent.children.isEmpty
              ? const Center(child: Text('No children profiles found'))
              : _buildContent(parent),
    );
  }

  Widget _buildContent(Parent parent) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $_error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _selectedChild != null ? () => _selectChild(_selectedChild!) : null,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Child selector
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ChildSelector(
            children: parent.children,
            selectedChild: _selectedChild,
            onChildSelected: _selectChild,
          ),
        ),
        
        // History section
        Expanded(
          child: _selectedChild == null
              ? const Center(child: Text('Please select a child'))
              : _watchHistory.isEmpty
                  ? const EmptyHistoryView()
                  : _buildHistoryList(),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    // Group videos by date (today, yesterday, older)
    final todayVideos = _watchHistory.where((v) => 
      _isSameDay(v.uploadDate, _today)).toList();
    
    final yesterdayVideos = _watchHistory.where((v) => 
      _isSameDay(v.uploadDate, _yesterday)).toList();
    
    final olderVideos = _watchHistory.where((v) => 
      !_isSameDay(v.uploadDate, _today) && 
      !_isSameDay(v.uploadDate, _yesterday)).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      children: [
        if (todayVideos.isNotEmpty) ...[
          const SectionHeader(title: 'Today'),
          ...todayVideos.map((video) => HistoryListItem(video: video)),
          const SizedBox(height: 16),
        ],
        
        if (yesterdayVideos.isNotEmpty) ...[
          const SectionHeader(title: 'Yesterday'),
          ...yesterdayVideos.map((video) => HistoryListItem(video: video)),
          const SizedBox(height: 16),
        ],
        
        if (olderVideos.isNotEmpty) ...[
          const SectionHeader(title: 'Older'),
          ...olderVideos.map((video) => HistoryListItem(video: video)),
        ],
      ],
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }
}