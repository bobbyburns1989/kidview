import 'package:flutter/material.dart';
import 'package:kidview/data/models/video_model.dart';
import 'package:kidview/features/child_interface/widgets/related_video_item.dart';

class VideoInfoPanel extends StatelessWidget {
  final Video video;
  final List<Video> relatedVideos;
  final Color primaryColor;
  final String ageGroup;

  const VideoInfoPanel({
    super.key,
    required this.video,
    required this.relatedVideos,
    required this.primaryColor,
    required this.ageGroup,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Video title
            Text(
              video.title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            
            // View count and rating
            _buildMetadataRow(context),
            const SizedBox(height: 16),
            
            // Channel info
            _buildChannelInfo(context),
            const SizedBox(height: 16),
            
            // Description
            _buildDescriptionBox(context),
            const SizedBox(height: 24),
            
            // Skills & Learning Tags
            if (video.educationalTags.isNotEmpty) ...[              
              _buildEducationalTags(context),
              const SizedBox(height: 24),
            ],
            
            // Related videos
            if (relatedVideos.isNotEmpty) ...[              
              _buildRelatedVideos(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.visibility,
          color: Colors.grey[600],
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          '${_formatViewCount(video.viewCount)} views',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          Icons.star,
          color: Colors.amber,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          video.rating.toString(),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildChannelInfo(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: primaryColor,
          child: Text(
            video.creatorName[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              video.creatorName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              'Content Creator',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescriptionBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Description',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            video.description,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEducationalTags(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Learning Tags',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: video.educationalTags.map((tag) {
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: primaryColor.withAlpha(51), // Equivalent to opacity 0.2
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primaryColor.withAlpha(128), // Equivalent to opacity 0.5
                ),
              ),
              child: Text(
                '${tag.name} (${tag.subject})',
                style: TextStyle(
                  color: primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRelatedVideos(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'More Videos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 12),
        ...relatedVideos.map((video) => RelatedVideoItem(
          video: video,
          ageGroup: ageGroup,
          accentColor: primaryColor,
        )),
      ],
    );
  }

  String _formatViewCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    } else {
      return count.toString();
    }
  }
}
