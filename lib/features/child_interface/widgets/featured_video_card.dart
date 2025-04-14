import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kidview/core/constants/route_constants.dart';
import 'package:kidview/data/models/video_model.dart';

class FeaturedVideoCard extends StatelessWidget {
  final Video video;
  final String ageGroup;
  final Color accentColor;

  const FeaturedVideoCard({
    super.key,
    required this.video,
    required this.ageGroup,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final isYoungerChild = ageGroup == 'younger';
    final borderRadius = isYoungerChild ? 24.0 : 16.0;
    final titleFontSize = isYoungerChild ? 20.0 : 16.0;
    final playIconSize = isYoungerChild ? 48.0 : 32.0;
    final metadataSize = isYoungerChild ? 14.0 : 12.0;
    
    return Hero(
      tag: 'video-${video.id}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToVideoPlayer(context),
          borderRadius: BorderRadius.circular(borderRadius),
          child: Ink(
            width: MediaQuery.of(context).size.width * (isYoungerChild ? 0.9 : 0.85),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isYoungerChild ? 0.2 : 0.1),
                  blurRadius: isYoungerChild ? 12 : 8,
                  offset: Offset(0, isYoungerChild ? 4 : 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: Stack(
                children: [
                  _buildThumbnail(),
                  _buildGradientOverlay(),
                  _buildCardContent(titleFontSize, metadataSize),
                  _buildPlayButton(playIconSize),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Positioned.fill(
      child: Image.asset(
        'assets/images/placeholder.png', // Placeholder for now
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[300],
            child: Center(
              child: Icon(
                Icons.image_not_supported,
                color: Colors.grey[600],
                size: 40,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
            stops: const [0.6, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildCardContent(double titleFontSize, double metadataSize) {
    final isYoungerChild = ageGroup == 'younger';
    
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Padding(
        padding: EdgeInsets.all(isYoungerChild ? 16 : 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              video.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 2,
                    offset: const Offset(1, 1),
                  ),
                ],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isYoungerChild ? 8 : 4),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isYoungerChild ? 10 : 8, 
                    vertical: isYoungerChild ? 4 : 2,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: BorderRadius.circular(isYoungerChild ? 8 : 4),
                  ),
                  child: Text(
                    _formatDuration(video.duration),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: metadataSize,
                      fontWeight: isYoungerChild ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                SizedBox(width: isYoungerChild ? 12 : 8),
                Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: isYoungerChild ? 20 : 16,
                ),
                const SizedBox(width: 4),
                Text(
                  video.rating.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: metadataSize,
                    fontWeight: isYoungerChild ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton(double playIconSize) {
    return Positioned.fill(
      child: Center(
        child: TweenAnimationBuilder(
          tween: Tween<double>(begin: 0.9, end: 1.0),
          duration: const Duration(seconds: 2),
          curve: Curves.elasticOut,
          builder: (context, double value, child) {
            return Transform.scale(
              scale: value,
              child: Container(
                padding: EdgeInsets.all(ageGroup == 'younger' ? 16 : 12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.85),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withOpacity(0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/ui/icon_play_dark.png',
                  width: playIconSize,
                  height: playIconSize,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ),
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