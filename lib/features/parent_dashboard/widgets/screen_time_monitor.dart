import 'package:flutter/material.dart';
import 'package:kidview/data/models/parent_model.dart';
import 'dart:math' as math;

class ScreenTimeMonitor extends StatelessWidget {
  final List<Child> children;
  final VoidCallback onViewWeeklyReport;
  final Function(Child) onEditTimeLimit;

  const ScreenTimeMonitor({
    super.key,
    required this.children,
    required this.onViewWeeklyReport,
    required this.onEditTimeLimit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today\'s Screen Time',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Nunito',
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.refresh),
                  tooltip: 'Refresh usage data',
                  onPressed: () {
                    // In a real app, this would refresh the usage data
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Refreshing usage data...')),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Monitor your children\'s screen time usage',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            
            // Quick stats overview
            _buildQuickStats(context),
            const SizedBox(height: 24),
            
            // Child-specific usage data
            ...children.map((child) => _buildChildUsage(context, child)),
            
            if (children.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_off,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No child profiles added yet',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add a child profile to start tracking screen time',
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
            // Weekly report button
            if (children.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),
              Center(
                child: OutlinedButton.icon(
                  onPressed: onViewWeeklyReport,
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('View Weekly Report'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildQuickStats(BuildContext context) {
    // Generate mock data for the demo
    final random = math.Random();
    int totalAllowed = 0;
    int totalUsed = 0;
    
    for (final child in children) {
      totalAllowed += child.dailyTimeLimit;
      // Random usage between 0 and limit
      totalUsed += random.nextInt(child.dailyTimeLimit);
    }
    
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            context,
            'Total Allowed',
            '$totalAllowed min',
            Icons.timer_outlined,
            Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Used Today',
            '$totalUsed min',
            Icons.play_circle_outline,
            totalUsed > totalAllowed * 0.8 ? Colors.red : Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            context,
            'Remaining',
            '${totalAllowed - totalUsed} min',
            Icons.hourglass_empty,
            Colors.orange,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatCard(
    BuildContext context, 
    String title, 
    String value, 
    IconData icon, 
    Color color
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(26), // ~0.1 opacity
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)), // ~0.3 opacity
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildChildUsage(BuildContext context, Child child) {
    // Generate mock data for the demo
    final random = math.Random();
    final usedMinutes = random.nextInt(child.dailyTimeLimit);
    final totalMinutes = child.dailyTimeLimit;
    final remainingMinutes = totalMinutes - usedMinutes;
    final usagePercentage = usedMinutes / totalMinutes;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).primaryColor,
                child: Text(
                  child.name.isNotEmpty ? child.name[0] : '?',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  child.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
              OutlinedButton.icon(
                onPressed: () => onEditTimeLimit(child),
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit Limit'),
                style: OutlinedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          
          // Progress bar
          Stack(
            children: [
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              FractionallySizedBox(
                widthFactor: usagePercentage.clamp(0.0, 1.0),
                child: Container(
                  height: 24,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: usagePercentage > 0.8 
                          ? [Colors.red.shade300, Colors.red]
                          : [
                              Theme.of(context).primaryColor.withAlpha(179), // ~0.7 opacity
                              Theme.of(context).primaryColor,
                            ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$usedMinutes min used',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '$remainingMinutes min left',
                        style: TextStyle(
                          color: usagePercentage > 0.8 ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          
          // Time breakdown
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily limit: $totalMinutes minutes',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                '${(usagePercentage * 100).round()}% of daily limit',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: usagePercentage > 0.8 
                      ? Colors.red 
                      : Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}