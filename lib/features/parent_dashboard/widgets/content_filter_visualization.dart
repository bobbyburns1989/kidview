import 'package:flutter/material.dart';
import 'dart:math' as math;

class ContentFilterVisualization extends StatelessWidget {
  final Map<String, bool> filters;
  final Map<String, String> filterLabels;
  final Function(String, bool) onFilterChanged;

  const ContentFilterVisualization({
    super.key,
    required this.filters,
    required this.filterLabels,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFilterVisualization(context),
        const SizedBox(height: 24),
        _buildFilterSwitches(context),
      ],
    );
  }

  Widget _buildFilterVisualization(BuildContext context) {
    // Count active filters
    final int activeFilterCount = filters.values.where((isActive) => isActive).length;
    final int totalFilters = filters.length;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Content Filter Strength',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            
            Center(
              child: SizedBox(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: FilterStrengthPainter(
                    activeFilterCount: activeFilterCount,
                    totalFilters: totalFilters,
                    primaryColor: Theme.of(context).primaryColor,
                    secondaryColor: Theme.of(context).colorScheme.secondary,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$activeFilterCount/$totalFilters',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Filters Active',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            const Text(
              'Protection Level:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            
            // Protection level indicators
            _buildProtectionLevelIndicator(context, activeFilterCount, totalFilters),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProtectionLevelIndicator(BuildContext context, int active, int total) {
    String level = 'Low';
    Color color = Colors.orange;
    String description = 'Limited content filtering applied. More filtering is recommended.';
    
    if (active > total * 0.7) {
      level = 'High';
      color = Colors.green;
      description = 'Maximum content protection applied. Your children are well protected.';
    } else if (active > total * 0.3) {
      level = 'Medium';
      color = Colors.amber;
      description = 'Basic content protection applied. Consider enabling more filters.';
    }
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              level,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterSwitches(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filter Settings',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enable filters to restrict access to certain types of content',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            // Filter switches
            ...filterLabels.entries.map((entry) {
              final filterKey = entry.key;
              final filterLabel = entry.value;
              
              return SwitchListTile(
                title: Text(filterLabel),
                value: filters[filterKey] ?? false,
                onChanged: (bool value) => onFilterChanged(filterKey, value),
                secondary: Icon(
                  _getFilterIcon(filterKey),
                  color: filters[filterKey] ?? false
                      ? Theme.of(context).primaryColor
                      : Colors.grey,
                ),
              );
            }),
            
            const SizedBox(height: 8),
            const Text(
              'Note: Content filtering works best when multiple filters are enabled',
              style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'violence':
        return Icons.dangerous;
      case 'language':
        return Icons.chat_bubble;
      case 'fear':
        return Icons.mood_bad;
      case 'consumerism':
        return Icons.shopping_cart;
      default:
        return Icons.filter_list;
    }
  }
}

class FilterStrengthPainter extends CustomPainter {
  final int activeFilterCount;
  final int totalFilters;
  final Color primaryColor;
  final Color secondaryColor;
  
  FilterStrengthPainter({
    required this.activeFilterCount,
    required this.totalFilters,
    required this.primaryColor,
    required this.secondaryColor,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Draw background circle
    final bgPaint = Paint()
      ..color = Colors.grey[200]!
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);
    
    // Draw filled arc based on active filters
    if (activeFilterCount > 0) {
      final percentage = activeFilterCount / totalFilters;
      final sweepAngle = 360 * percentage * (math.pi / 180);
      
      final fillPaint = Paint()
        ..shader = SweepGradient(
          colors: [primaryColor, secondaryColor],
          startAngle: -math.pi / 2,
          endAngle: 3 * math.pi / 2,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start from top
        sweepAngle,
        true,
        fillPaint,
      );
    }
    
    // Draw inner circle for text background
    final innerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.7, innerPaint);
    
    // Draw decorative dots around the circle
    final dotPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    for (int i = 0; i < totalFilters; i++) {
      final angle = (i * 360 / totalFilters) * (math.pi / 180);
      final dotCenter = Offset(
        center.dx + (radius * 0.85) * math.cos(angle),
        center.dy + (radius * 0.85) * math.sin(angle),
      );
      
      // Make active dots larger and colored
      if (i < activeFilterCount) {
        final activeColor = HSLColor.fromColor(
          Color.lerp(primaryColor, secondaryColor, i / (totalFilters - 1))!,
        ).toColor();
        
        final activeDotPaint = Paint()
          ..color = activeColor
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(dotCenter, 6, activeDotPaint);
      } else {
        canvas.drawCircle(dotCenter, 4, dotPaint);
      }
    }
  }
  
  @override
  bool shouldRepaint(FilterStrengthPainter oldDelegate) {
    return oldDelegate.activeFilterCount != activeFilterCount ||
           oldDelegate.totalFilters != totalFilters ||
           oldDelegate.primaryColor != primaryColor ||
           oldDelegate.secondaryColor != secondaryColor;
  }
}