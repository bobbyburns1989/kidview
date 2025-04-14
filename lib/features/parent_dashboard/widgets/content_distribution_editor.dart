import 'package:flutter/material.dart';

class ContentDistributionEditor extends StatelessWidget {
  final Map<String, int> distribution;
  final Function(String, int) onChange;

  const ContentDistributionEditor({
    super.key,
    required this.distribution,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    // Default categories if not provided
    final Map<String, int> allDistribution = {
      'Values & Social Skills': distribution['Values & Social Skills'] ?? 25,
      'STEM Topics': distribution['STEM Topics'] ?? 25,
      'Creative Arts': distribution['Creative Arts'] ?? 20,
      'Special Interests': distribution['Special Interests'] ?? 20,
      'Free Choice': distribution['Free Choice'] ?? 10,
    };

    // Color mapping
    final categoryColors = {
      'Values & Social Skills': Colors.blue,
      'STEM Topics': Colors.green,
      'Creative Arts': Colors.purple,
      'Special Interests': Colors.orange,
      'Free Choice': Colors.teal,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Legend
            _buildDistributionPieChart(allDistribution, categoryColors),
            const SizedBox(height: 24),
            
            // Distribution sliders
            ...allDistribution.entries.map((entry) {
              final category = entry.key;
              final value = entry.value;
              final color = categoryColors[category] ?? Colors.grey;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(category),
                          ],
                        ),
                        Text(
                          '$value%',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Slider(
                      value: value.toDouble(),
                      min: 0,
                      max: 100,
                      divisions: 20,
                      activeColor: color,
                      onChanged: (newValue) {
                        onChange(category, newValue.round());
                      },
                    ),
                  ],
                ),
              );
            }),
            
            // Total percentage indicator
            _buildTotalIndicator(allDistribution),
          ],
        ),
      ),
    );
  }

  Widget _buildDistributionPieChart(Map<String, int> distribution, Map<String, Color> colors) {
    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(180, 180),
            painter: PieChartPainter(distribution, colors),
          ),
          const Text(
            'Content\nBalance',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalIndicator(Map<String, int> distribution) {
    final total = distribution.values.fold<int>(0, (sum, value) => sum + value);
    final isValid = total == 100;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isValid ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: isValid ? Colors.green.shade200 : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.check_circle : Icons.warning,
            color: isValid ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isValid
                  ? 'Total: 100% (Perfect balance!)'  
                  : 'Total: $total% (Should add up to 100%)',
              style: TextStyle(
                color: isValid ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final Map<String, int> distribution;
  final Map<String, Color> colors;

  PieChartPainter(this.distribution, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width < size.height ? size.width / 2 : size.height / 2;
    
    // Start angle (in radians)
    double startAngle = -90 * (3.14159 / 180); // Start from the top (270 degrees)
    
    // Draw each segment
    distribution.forEach((category, percentage) {
      final sweepAngle = percentage * (3.14159 * 2) / 100; // Convert to radians
      
      final paint = Paint()
        ..color = colors[category] ?? Colors.grey
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      // Update start angle for next segment
      startAngle += sweepAngle;
    });
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}