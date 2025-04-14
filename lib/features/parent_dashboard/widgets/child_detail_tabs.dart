import 'package:flutter/material.dart';
import 'package:kidview/data/models/parent_model.dart';

/// Tabs for viewing child details
class ChildDetailTabs {
  /// Basic information tab content
  static Widget buildBasicInfoTab(Child child, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow('Age Group:', child.ageGroup == "younger" ? "4-7 years" : "8-12 years"),
        SizedBox(height: 16),
        _infoRow('Daily Time Limit:', '${child.dailyTimeLimit} minutes'),
        SizedBox(height: 16),
        Text('Allowed Categories:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: child.allowedContentCategories.map((category) {
            return Chip(
              label: Text(category, style: TextStyle(fontSize: 12)),
              backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  /// Content preferences tab
  static Widget buildContentTab(Child child, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Special Interests:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        child.specialInterests.isEmpty
            ? Text('No special interests set', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))
            : Wrap(
                spacing: 4,
                runSpacing: 4,
                children: child.specialInterests.map((interest) {
                  return Chip(
                    label: Text(interest, style: TextStyle(fontSize: 12)),
                    backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  );
                }).toList(),
              ),
        SizedBox(height: 16),
        
        Text('Content Distribution:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        
        ...child.contentDistribution.entries.map((entry) {
          return _buildDistributionBar(entry.key, entry.value, context);
        }),
      ],
    );
  }
  
  /// Content filtering tab
  static Widget buildFiltersTab(Child child, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Multi-dimensional Tagging:', style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        
        ...child.contentTags.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.key, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: entry.value.map((tag) {
                  return Chip(
                    label: Text(tag, style: TextStyle(fontSize: 12)),
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  );
                }).toList(),
              ),
              SizedBox(height: 12),
            ],
          );
        }),
        
        if (child.contentTags.isEmpty)
          Text('No content tags set', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
      ],
    );
  }
  
  /// Helper method for info row
  static Widget _infoRow(String label, String value) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(width: 8),
        Text(value),
      ],
    );
  }
  
  /// Helper for distribution bar
  static Widget _buildDistributionBar(String key, int value, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(key),
            Text('$value%'),
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
            widthFactor: value / 100,
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
        SizedBox(height: 12),
      ],
    );
  }
}