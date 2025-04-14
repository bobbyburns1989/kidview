import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoControls extends StatelessWidget {
  final VideoPlayerController controller;
  final bool isControlsVisible;
  final bool isPlaying;
  final bool isFullScreen;
  final bool isFullScreenMode;
  final bool isInitialized;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleFullScreen;
  final VoidCallback onToggleControls;
  final VoidCallback onSeekForward;
  final VoidCallback onSeekBackward;

  const VideoControls({
    super.key,
    required this.controller,
    required this.isControlsVisible,
    required this.isPlaying,
    required this.isFullScreen,
    required this.onTogglePlay,
    required this.onToggleFullScreen,
    required this.onToggleControls,
    required this.onSeekForward,
    required this.onSeekBackward,
    required this.isFullScreenMode,
    this.isInitialized = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isInitialized) {
      return Container(
        color: Colors.black,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onToggleControls,
      child: isFullScreenMode ? _buildFullScreenPlayer() : _buildRegularPlayer(),
    );
  }

  Widget _buildRegularPlayer() {
    return Stack(
      children: [
        // Video
        Positioned.fill(
          child: VideoPlayer(controller),
        ),
        
        // Controls overlay
        if (isControlsVisible)
          Positioned.fill(
            child: Container(
              color: Colors.black.withAlpha(128), // Equivalent to opacity 0.5
              child: Stack(
                children: [
                  // Play/Pause button
                  Center(
                    child: IconButton(
                      onPressed: onTogglePlay,
                      iconSize: 64,
                      color: Colors.white,
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                      ),
                    ),
                  ),
                  
                  // Forward/Backward buttons
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: onSeekBackward,
                          iconSize: 40,
                          color: Colors.white,
                          icon: const Icon(Icons.replay_10),
                        ),
                        IconButton(
                          onPressed: onSeekForward,
                          iconSize: 40,
                          color: Colors.white,
                          icon: const Icon(Icons.forward_10),
                        ),
                      ],
                    ),
                  ),
                  
                  // Progress bar
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 16,
                    child: _buildProgressControls(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFullScreenPlayer() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Video
          Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: VideoPlayer(controller),
            ),
          ),
          
          // Controls overlay
          if (isControlsVisible)
            Positioned.fill(
              child: Container(
                color: Colors.black.withAlpha(128), // Equivalent to opacity 0.5
                child: Stack(
                  children: [
                    // Back button
                    Positioned(
                      top: 16,
                      left: 16,
                      child: IconButton(
                        onPressed: onToggleFullScreen,
                        iconSize: 32,
                        color: Colors.white,
                        icon: const Icon(Icons.arrow_back),
                      ),
                    ),
                    
                    // Play/Pause button
                    Center(
                      child: IconButton(
                        onPressed: onTogglePlay,
                        iconSize: 64,
                        color: Colors.white,
                        icon: Icon(
                          isPlaying ? Icons.pause : Icons.play_arrow,
                        ),
                      ),
                    ),
                    
                    // Forward/Backward buttons
                    Positioned(
                      left: 0,
                      right: 0,
                      top: 0,
                      bottom: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: onSeekBackward,
                            iconSize: 40,
                            color: Colors.white,
                            icon: const Icon(Icons.replay_10),
                          ),
                          IconButton(
                            onPressed: onSeekForward,
                            iconSize: 40,
                            color: Colors.white,
                            icon: const Icon(Icons.forward_10),
                          ),
                        ],
                      ),
                    ),
                    
                    // Progress bar
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: _buildProgressControls(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressControls() {
    return Row(
      children: [
        // Current position
        Text(
          _formatDuration(controller.value.position),
          style: const TextStyle(color: Colors.white),
        ),
        
        // Progress slider
        Expanded(
          child: Slider(
            value: controller.value.position.inSeconds.toDouble(),
            min: 0,
            max: controller.value.duration.inSeconds.toDouble(),
            onChanged: (value) {
              controller.seekTo(Duration(seconds: value.toInt()));
            },
          ),
        ),
        
        // Total duration
        Text(
          _formatDuration(controller.value.duration),
          style: const TextStyle(color: Colors.white),
        ),
        
        // Fullscreen button
        IconButton(
          onPressed: onToggleFullScreen,
          iconSize: 24,
          color: Colors.white,
          icon: Icon(
            isFullScreen 
                ? Icons.fullscreen_exit 
                : Icons.fullscreen,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
