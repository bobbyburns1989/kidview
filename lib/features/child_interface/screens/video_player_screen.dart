import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';
import 'package:kidview/config/themes.dart';
import 'package:kidview/core/constants/route_constants.dart';
import 'package:kidview/data/models/video_model.dart';
import 'package:kidview/data/services/video_service.dart';
import 'package:kidview/data/services/analytics_service.dart';
import 'package:kidview/features/child_interface/widgets/video_controls.dart';
import 'package:kidview/features/child_interface/widgets/video_info_panel.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;
  final String ageGroup;

  const VideoPlayerScreen({
    super.key,
    required this.videoId,
    required this.ageGroup,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  final VideoService _videoService = VideoService();
  final AnalyticsService _analyticsService = AnalyticsService();
  late VideoPlayerController _controller;
  bool _isLoading = true;
  bool _isControlsVisible = true;
  bool _isPlaying = false;
  bool _isFullScreen = false;
  bool _isInitialized = false;
  String? _error;
  Video? _video;
  List<Video> _relatedVideos = [];
  DateTime? _videoStartTime;

  @override
  void initState() {
    super.initState();
    _loadVideo();
    
    // Automatically hide controls after a delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isControlsVisible = false;
        });
      }
    });
  }

  Future<void> _loadVideo() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load video data
      final video = await _videoService.getVideoById(widget.videoId);

      if (video == null) {
        setState(() {
          _error = 'Video not found';
          _isLoading = false;
        });
        return;
      }

      // Initialize video controller
      _controller = VideoPlayerController.networkUrl(Uri.parse(video.videoUrl));
      await _controller.initialize();
      _controller.addListener(_videoListener);
      
      // Auto-play when ready
      _controller.play();
      
      // Log the view using both service methods
      await _videoService.logVideoView(video.id, 'demo-child-id');
      
      // Track the view in analytics
      await _analyticsService.logVideoView(
        video: video,
        childId: 'demo-child-id',
      );
      
      // Store the start time for duration tracking
      _videoStartTime = DateTime.now();
      
      // Get related videos in parallel
      final futureRelated = _videoService.getRecommendedVideos(widget.ageGroup);
      
      final relatedVideos = await futureRelated;
      
      // Filter out the current video from related
      final filteredRelated = relatedVideos.where((v) => v.id != video.id).toList();
      
      setState(() {
        _video = video;
        _relatedVideos = filteredRelated;
        _isLoading = false;
        _isPlaying = true;
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load video: $e';
        _isLoading = false;
      });
    }
  }

  void _videoListener() {
    if (_controller.value.isInitialized) {
      setState(() {
        _isPlaying = _controller.value.isPlaying;
      });
    }
  }

  void _togglePlay() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
        
        // Auto-hide controls after playing
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && _isPlaying) {
            setState(() {
              _isControlsVisible = false;
            });
          }
        });
      }
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      
      if (_isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.landscapeRight,
          DeviceOrientation.landscapeLeft,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
  }

  void _seekForward() {
    final currentPosition = _controller.value.position;
    final targetPosition = currentPosition + const Duration(seconds: 10);
    _controller.seekTo(targetPosition);
  }

  void _seekBackward() {
    final currentPosition = _controller.value.position;
    final targetPosition = currentPosition - const Duration(seconds: 10);
    _controller.seekTo(targetPosition);
  }

  void _toggleControls() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    
    // Log screen time when leaving video
    if (_video != null && _videoStartTime != null) {
      final videoDuration = DateTime.now().difference(_videoStartTime!);
      final watchTimeSeconds = videoDuration.inSeconds;
      
      // Log screen time to analytics
      _analyticsService.logScreenTime(
        childId: 'demo-child-id',
        minutesUsed: (watchTimeSeconds / 60).ceil(),
        contentType: 'video',
      );
      
      // Log video watch duration
      _analyticsService.logVideoView(
        video: _video!,
        childId: 'demo-child-id',
        watchDurationSeconds: watchTimeSeconds,
      );
    }
    
    _controller.dispose();
    
    // Reset orientation when exiting
    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    
    super.dispose();
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
      appBar: _isFullScreen 
          ? null 
          : AppBar(
              backgroundColor: primaryColor,
              title: Text(
                _video?.title ?? 'Loading Video...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.go('${Routes.childHome}?ageGroup=${widget.ageGroup}'),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.white),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to favorites!')),
                    );
                  },
                ),
              ],
            ),
      body: _buildBody(primaryColor),
    );
  }

  Widget _buildBody(Color primaryColor) {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: primaryColor,
        ),
      );
    }

    if (_error != null) {
      return _buildErrorView(primaryColor);
    }

    if (_isFullScreen) {
      return VideoControls(
        controller: _controller,
        isControlsVisible: _isControlsVisible,
        isPlaying: _isPlaying,
        isFullScreen: _isFullScreen,
        onTogglePlay: _togglePlay,
        onToggleFullScreen: _toggleFullScreen,
        onToggleControls: _toggleControls,
        onSeekForward: _seekForward,
        onSeekBackward: _seekBackward,
        isFullScreenMode: true,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Video player
        AspectRatio(
          aspectRatio: 16 / 9,
          child: VideoControls(
            controller: _controller,
            isControlsVisible: _isControlsVisible,
            isPlaying: _isPlaying,
            isFullScreen: _isFullScreen,
            onTogglePlay: _togglePlay,
            onToggleFullScreen: _toggleFullScreen,
            onToggleControls: _toggleControls,
            onSeekForward: _seekForward,
            onSeekBackward: _seekBackward,
            isFullScreenMode: false,
            isInitialized: _isInitialized,
          ),
        ),
        
        // Video info and related videos
        if (_video != null)
          Expanded(
            child: VideoInfoPanel(
              video: _video!,
              relatedVideos: _relatedVideos,
              primaryColor: widget.ageGroup == 'younger' 
                ? AppThemes.primaryYounger 
                : AppThemes.primaryOlder,
              ageGroup: widget.ageGroup,
            ),
          ),
      ],
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
            onPressed: _loadVideo,
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
}