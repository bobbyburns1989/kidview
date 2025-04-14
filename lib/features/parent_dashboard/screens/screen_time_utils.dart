import 'package:flutter/material.dart';
import 'package:kidview/data/models/parent_model.dart';
import 'dart:math' as math;

/// Utilities and helper methods for screen time features
class ScreenTimeUtils {
  /// Generate a weekly report from children's data
  static void showWeeklyReport(BuildContext context, List<Child> children) {
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
  
  /// Show time limit update dialog
  static void showTimeUpdateDialog(BuildContext context, Child child, Function(Child) onUpdate) {
    final timeController = TextEditingController(text: child.dailyTimeLimit.toString());
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Time Limit for ${child.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter the new daily time limit in minutes:'),
            const SizedBox(height: 16),
            TextField(
              controller: timeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Minutes',
                border: OutlineInputBorder(),
                suffixText: 'minutes',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final minutes = int.tryParse(timeController.text.trim());
              if (minutes != null && minutes > 0) {
                // Create updated child
                final updatedChild = Child(
                  id: child.id,
                  name: child.name,
                  avatarUrl: child.avatarUrl,
                  ageGroup: child.ageGroup,
                  allowedContentCategories: child.allowedContentCategories,
                  dailyTimeLimit: minutes,
                  watchHistory: child.watchHistory,
                  favorites: child.favorites,
                  specialInterests: child.specialInterests,
                  contentDistribution: child.contentDistribution,
                  contentTags: child.contentTags,
                );
                
                // Update child profile
                onUpdate(updatedChild);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
  
  /// Maps day name to appropriate icon
  static IconData getDayIcon(String day) {
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
  
  /// Build screen time limits section widget
  static Widget buildScreenTimeLimitsSection(
    BuildContext context, 
    List<Child> children,
    Function(Child) onUpdateChild,
  ) {
    if (children.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'No children profiles available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add a child profile to set individual screen time limits',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Individual Daily Limits',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Customize screen time limits for each child',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            // Child list with time limits
            ...children.map((child) {
              return Column(
                children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor,
                      child: Text(
                        child.name.isNotEmpty ? child.name[0] : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(child.name),
                    subtitle: Text('Current limit: ${child.dailyTimeLimit} minutes'),
                    trailing: ElevatedButton(
                      onPressed: () => showTimeUpdateDialog(context, child, onUpdateChild),
                      child: const Text('Edit'),
                    ),
                  ),
                  const Divider(),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
  
  /// Build parenting resources section widget
  static Widget buildResourcesSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Parenting Resources',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Learn more about managing screen time and content for children',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: Icon(Icons.article, color: Theme.of(context).primaryColor),
              title: const Text('Screen Time Guidelines'),
              subtitle: const Text('Age-appropriate recommendations from experts'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Would open a screen with guidelines in a real app
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feature coming soon!')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.video_library, color: Theme.of(context).primaryColor),
              title: const Text('Content Selection Guide'),
              subtitle: const Text('How to choose appropriate content for children'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Would open a screen with content guidelines in a real app
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feature coming soon!')),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: Icon(Icons.help_outline, color: Theme.of(context).primaryColor),
              title: const Text('Parental Controls FAQ'),
              subtitle: const Text('Answers to common questions'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Would open a FAQ screen in a real app
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Feature coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build advanced settings section widget
  static Widget buildAdvancedSettingsSection(
    BuildContext context, 
    ParentalControls controls,
    Function(bool) onToggleAllowDownloads,
    Function(bool) onTogglePreventAppSwitching,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Advanced Features',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Allow Downloads'),
              subtitle: const Text('Enable videos to be saved for offline viewing'),
              value: controls.allowDownloads,
              onChanged: onToggleAllowDownloads,
              secondary: Icon(
                Icons.download,
                color: controls.allowDownloads 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey,
              ),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Prevent App Switching'),
              subtitle: const Text('Keep children within the app during viewing sessions'),
              value: controls.preventAppSwitching,
              onChanged: onTogglePreventAppSwitching,
              secondary: Icon(
                Icons.phone_android,
                color: controls.preventAppSwitching 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            
            // Info about app switching
            if (controls.preventAppSwitching)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.5)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App Switching Prevention',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'When enabled, this feature helps keep children focused by preventing them from switching to other apps during video playback. Parents can override this with their PIN.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}