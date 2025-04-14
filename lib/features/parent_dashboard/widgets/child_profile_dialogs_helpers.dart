import 'package:flutter/material.dart';
// import 'package:kidview/data/models/parent_model.dart';

/// Helper widgets and utilities for child profile dialogs
class ChildProfileDialogHelpers {
  /// Build tab buttons used in various child profile dialogs
  static Widget buildTabButton(
    BuildContext context, 
    String label, 
    bool isSelected, 
    VoidCallback onTap
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected 
                    ? Theme.of(context).primaryColor 
                    : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected 
                  ? Theme.of(context).primaryColor 
                  : Colors.grey[600],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
  
  /// Build information row with label and value
  static Widget infoRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: 8),
        Text(value),
      ],
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
  
  /// Content categories used by all child profile dialogs
  static List<String> getAllCategories() {
    return [
      'Education', 'Science', 'Math', 'Music', 
      'Art', 'Language', 'Fun', 'Technology'
    ];
  }
  
  /// Special interests used by all child profile dialogs
  static List<String> getAllSpecialInterests() {
    return [
      'Animals', 'Dinosaurs', 'Space', 'Robots', 'Cooking', 
      'Trains', 'Cars', 'Planes', 'Music', 'Sports',
      'Insects', 'Plants', 'Oceans', 'Building', 'Drawing',
      'Coding', 'Chemistry', 'Geography', 'History', 'Mythology'
    ];
  }
  
  /// Multi-dimensional tagging used by all child profile dialogs
  static Map<String, List<String>> getAllContentTags() {
    return {
      'Values': [
        'Kindness', 'Empathy', 'Sharing', 'Honesty', 'Perseverance', 
        'Teamwork', 'Leadership', 'Conflict resolution', 'Diversity', 'Inclusion'
      ],
      'Learning Approach': [
        'Instructional', 'Exploratory', 'Problem-solving', 'Project-based', 
        'Gamified learning'
      ],
      'Content Format': [
        'Animation', 'Live-action', 'Puppetry', 'Interactive', 
        'Short-form', 'Long-form'
      ],
      'Developmental Focus': [
        'Fine motor skills', 'Gross motor skills', 'Vocabulary building', 
        'Mathematical thinking', 'Scientific reasoning', 'Emotional intelligence', 
        'Social skills', 'Logical reasoning'
      ],
    };
  }
  
  /// Default content distribution settings
  static Map<String, int> getDefaultContentDistribution() {
    return {
      'Values & Social Skills': 30,
      'STEM Topics': 25,
      'Creative Arts': 20,
      'Special Interests': 15,
      'Free Choice': 10,
    };
  }
  
  /// Default content tags selection
  static Map<String, List<String>> getDefaultContentTags() {
    return {
      'Values': ['Kindness', 'Sharing'],
      'Learning Approach': ['Exploratory'],
      'Content Format': ['Animation', 'Short-form'],
      'Developmental Focus': ['Vocabulary building'],
    };
  }
  
  /// Build content distribution editor
  static Widget buildContentDistributionEditor({
    required BuildContext context,
    required Map<String, int> contentDistribution,
    required Function(String, int) onDistributionChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: contentDistribution.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.key),
                Text('${entry.value}%'),
              ],
            ),
            SizedBox(height: 4),
            // Visual representation of percentage
            Container(
              width: double.infinity,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: entry.value / 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).colorScheme.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
            Slider(
              value: entry.value.toDouble(),
              min: 0,
              max: 100,
              divisions: 20,
              onChanged: (value) {
                final newValue = value.round();
                onDistributionChanged(entry.key, newValue);
              },
            ),
            SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }
  
  /// Adjust content distribution to maintain 100% total
  static Map<String, int> adjustContentDistribution(
    Map<String, int> distribution,
    String changedKey,
    int newValue,
  ) {
    final result = Map<String, int>.from(distribution);
    result[changedKey] = newValue;
    
    // Calculate total of all percentages
    int total = result.values.fold(0, (sum, value) => sum + value);
    
    // If total exceeds 100%, adjust other categories proportionally
    if (total > 100) {
      // Calculate how much we need to reduce other categories
      int excess = total - 100;
      int otherCategoriesTotal = total - newValue;
      
      // Adjust other categories proportionally
      if (otherCategoriesTotal > 0) {
        for (var key in result.keys) {
          if (key != changedKey) {
            // Calculate reduction proportionally
            double reduction = excess * (result[key]! / otherCategoriesTotal);
            result[key] = (result[key]! - reduction.round()).clamp(0, 100);
          }
        }
      }
    }
    
    return result;
  }
}