import 'package:flutter/material.dart';
import 'package:kidview/data/models/parent_model.dart';
import 'package:kidview/features/parent_dashboard/widgets/section_header.dart';
import 'dart:math' as math;

class ScreenTimeDashboard extends StatelessWidget {
  final List<Child> children;
  final List<TimeRange> scheduledViewingTimes;
  final Function(int) onRemoveScheduledTime;
  final VoidCallback onAddScheduledTime;

  const ScreenTimeDashboard({
    super.key,
    required this.children,
    required this.scheduledViewingTimes,
    required this.onRemoveScheduledTime,
    required this.onAddScheduledTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Screen Time Management'),
        _buildUsageSummary(context),
        const SizedBox(height: 24),
        _buildScheduledTimes(context),
      ],
    );
  }

  Widget _buildUsageSummary(BuildContext context) {
    // This would be real usage data in a production app
    // For demo purposes, we'll generate some random data
    final random = math.Random();
    final Map<String, int> usageMinutes = {};
    
    for (final child in children) {
      // Random value between 0 and daily limit
      usageMinutes[child.id] = random.nextInt(child.dailyTimeLimit);
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Today\'s Usage',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            
            // Display time used per child
            ...children.map((child) {
              final usedMinutes = usageMinutes[child.id] ?? 0;
              final totalMinutes = child.dailyTimeLimit;
              final remainingMinutes = totalMinutes - usedMinutes;
              final usagePercentage = usedMinutes / totalMinutes;
              
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        child.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '$usedMinutes / $totalMinutes min',
                        style: TextStyle(
                          color: usagePercentage > 0.8 
                              ? Colors.red
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: usagePercentage,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      usagePercentage > 0.8 
                          ? Colors.red 
                          : Theme.of(context).primaryColor,
                    ),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$remainingMinutes minutes remaining today',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }),
            
            // Show different message based on number of children
            if (children.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'No children profiles available. Add a child profile to track screen time.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ),
            
            // Weekly report button
            if (children.isNotEmpty)
              Center(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Show weekly report
                    _showWeeklyReport(context);
                  },
                  icon: const Icon(Icons.bar_chart),
                  label: const Text('View Weekly Report'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduledTimes(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Scheduled Viewing Times',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Set times when your children are allowed to use the app',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            // List of scheduled times
            if (scheduledViewingTimes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(
                  child: Text(
                    'No scheduled viewing times set',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: scheduledViewingTimes.length,
                itemBuilder: (context, index) {
                  final timeRange = scheduledViewingTimes[index];
                  return Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surface,
                    child: ListTile(
                      leading: Icon(
                        _getDayIcon(timeRange.dayOfWeek),
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(timeRange.dayOfWeek),
                      subtitle: Text('${timeRange.startTime} - ${timeRange.endTime}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => onRemoveScheduledTime(index),
                      ),
                    ),
                  );
                },
              ),
            
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: onAddScheduledTime,
                icon: const Icon(Icons.add),
                label: const Text('Add Allowed Time'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getDayIcon(String day) {
    switch (day) {
      case 'Monday':
        return Icons.looks_one;
      case 'Tuesday':
        return Icons.looks_two;
      case 'Wednesday':
        return Icons.looks_3;
      case 'Thursday':
        return Icons.looks_4;
      case 'Friday':
        return Icons.looks_5;
      case 'Saturday':
        return Icons.weekend;
      case 'Sunday':
        return Icons.weekend;
      default:
        return Icons.calendar_today;
    }
  }

  void _showWeeklyReport(BuildContext context) {
    // Create a sample data for the weekly report
    final Map<String, List<int>> weeklyData = {};
    final random = math.Random();
    final daysOfWeek = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    for (final child in children) {
      weeklyData[child.id] = List.generate(
        7, 
        (index) => random.nextInt(child.dailyTimeLimit),
      );
    }
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Weekly Screen Time Report'),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: Column(
            children: [
              const Text(
                'Minutes used each day this week',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              
              // Create a bar chart
              Expanded(
                child: ListView.builder(
                  itemCount: children.length,
                  itemBuilder: (context, index) {
                    final child = children[index];
                    final data = weeklyData[child.id] ?? List.filled(7, 0);
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: Row(
                            children: List.generate(
                              7, 
                              (dayIndex) {
                                final value = data[dayIndex];
                                final maxValue = child.dailyTimeLimit;
                                final percentage = value / maxValue;
                                
                                return Expanded(
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 4),
                                          alignment: Alignment.bottomCenter,
                                          child: FractionallySizedBox(
                                            heightFactor: percentage,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: percentage > 0.8 
                                                    ? Colors.red 
                                                    : Theme.of(context).primaryColor,
                                                borderRadius: const BorderRadius.vertical(
                                                  top: Radius.circular(4),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        daysOfWeek[dayIndex],
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      Text(
                                        '$value min',
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const Divider(),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // In a real app, this would save or share the report
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report exported successfully')),
              );
            },
            child: const Text('Export Report'),
          ),
        ],
      ),
    );
  }
}