import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kidview/core/constants/route_constants.dart';
import 'package:kidview/data/models/video_model.dart';

class VideoCard extends StatelessWidget {
  final Video video;
  final String ageGroup;
  final Color accentColor;

  const VideoCard({
    super.key,
    required this.video,
    required this.ageGroup,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToVideoPlayer(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(26), // Equivalent to opacity 0.1
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildVideoDetails(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.network(
            video.thumbnailUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[300],
                child: Center(
                  child: CircularProgressIndicator(
                    color: accentColor,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: Center(
                  child: Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[600],
                  ),
                ),
              );
            },
          ),
        ),
        // Duration pill
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(179), // Equivalent to opacity 0.7
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              _formatDuration(video.duration),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        // Play button overlay
        Positioned.fill(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accentColor.withAlpha(204), // Equivalent to opacity 0.8
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          video.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          video.creatorName,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        // Rating
        Row(
          children: [
            const Icon(
              Icons.star,
              color: Colors.amber,
              size: 14,
            ),
            const SizedBox(width: 4),
            Text(
              video.rating.toString(),
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToVideoPlayer(BuildContext context) {
    context.go('${Routes.videoPlayer}/${video.id}?ageGroup=$ageGroup');
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}