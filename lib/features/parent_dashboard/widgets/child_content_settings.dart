import 'package:flutter/material.dart';
import 'package:kidview/data/models/parent_model.dart';
import 'package:kidview/features/parent_dashboard/widgets/section_header.dart';
import 'package:kidview/features/parent_dashboard/widgets/category_filter_card.dart';
import 'package:kidview/features/parent_dashboard/widgets/interest_editor.dart';
import 'package:kidview/features/parent_dashboard/widgets/content_distribution_editor.dart';

class ChildContentSettings extends StatelessWidget {
  final Child child;
  final List<String> allowedCategories;
  final List<String> specialInterests;
  final Map<String, int> contentDistribution;
  final Function(List<String>) onCategoriesChanged;
  final Function(List<String>) onInterestsChanged;
  final Function(String, int) onDistributionChanged;

  const ChildContentSettings({
    super.key,
    required this.child,
    required this.allowedCategories,
    required this.specialInterests,
    required this.contentDistribution,
    required this.onCategoriesChanged,
    required this.onInterestsChanged,
    required this.onDistributionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ageLabel = child.ageGroup == 'younger' ? '4-7 years' : '8-12 years';
    final color = child.ageGroup == 'younger'
        ? Theme.of(context).primaryColor
        : Theme.of(context).colorScheme.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with child info
        _buildHeader(context, ageLabel, color),
        const SizedBox(height: 24),
        
        // Content category filters
        const SectionHeader(title: 'Allowed Categories'),
        const SizedBox(height: 8),
        Text(
          'Select which categories of content this child can access:',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        CategoryFilterCard(
          selectedCategories: allowedCategories,
          onChange: onCategoriesChanged,
        ),
        const SizedBox(height: 24),
        
        // Special interests
        const SectionHeader(title: 'Special Interests'),
        const SizedBox(height: 8),
        Text(
          'Add topics that your child is particularly interested in:',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        InterestEditor(
          interests: specialInterests,
          onChange: onInterestsChanged,
        ),
        const SizedBox(height: 24),
        
        // Content distribution
        const SectionHeader(title: 'Content Balance'),
        const SizedBox(height: 8),
        Text(
          'Adjust the balance of different types of content:',
          style: TextStyle(color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        ContentDistributionEditor(
          distribution: contentDistribution,
          onChange: onDistributionChanged,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, String ageLabel, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: color.withOpacity(0.2),
              child: Text(
                child.name[0].toUpperCase(),
                style: TextStyle(
                  color: color,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Age Group: $ageLabel',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Daily Limit: ${child.dailyTimeLimit} minutes',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
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