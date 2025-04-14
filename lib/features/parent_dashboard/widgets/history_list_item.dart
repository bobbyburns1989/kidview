import 'package:flutter/material.dart';
import 'package:kidview/data/models/video_model.dart';

class HistoryListItem extends StatelessWidget {
  final Video video;
  final VoidCallback? onRemove;

  const HistoryListItem({
    super.key,
    required this.video,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // In a real app, navigate to a detailed view of the video,
          // where the parent can see exactly what their child watched
          // For the demo, we'll just show a snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Viewing details for ${video.title}')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 120,
                  height: 68,
                  child: Image.network(
                    video.thumbnailUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Video info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          video.creatorName,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.access_time,
                          size: 12,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 2),
                        Text(
                          _formatDuration(video.duration),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Display educational tags
                        if (video.educationalTags.isNotEmpty) ...[                          
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 2,
                              horizontal: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              video.educationalTags.first.subject,
                              style: TextStyle(
                                fontSize: 10,
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                        // Display age rating
                        Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 6,
                          ),
                          decoration: BoxDecoration(
                            color: _getAgeRatingColor(video.ageRating).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _formatAgeRating(video.ageRating),
                            style: TextStyle(
                              fontSize: 10,
                              color: _getAgeRatingColor(video.ageRating),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Remove button if provided
              if (onRemove != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: onRemove,
                  color: Colors.grey[600],
                  iconSize: 20,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatAgeRating(String ageRating) {
    switch (ageRating) {
      case 'younger':
        return '4-7 yrs';
      case 'older':
        return '8-12 yrs';
      case 'all':
        return 'All ages';
      default:
        return ageRating;
    }
  }

  Color _getAgeRatingColor(String ageRating) {
    switch (ageRating) {
      case 'younger':
        return Colors.blue;
      case 'older':
        return Colors.purple;
      case 'all':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}