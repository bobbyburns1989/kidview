import 'package:flutter/material.dart';
import 'package:kidview/features/parent_dashboard/widgets/child_profile_dialogs_helpers.dart';

/// Widgets for the different steps in the child profile creation process
class ProfileCreationSteps {
  /// Build the basic information step
  static Widget buildBasicInfoStep({
    required BuildContext context,
    required TextEditingController nameController,
    required String selectedAgeGroup,
    required int timeLimit,
    required Function(String) onAgeGroupChanged,
    required Function(int) onTimeLimitChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Basic Information', context),
        const SizedBox(height: 20),
        
        // Name field
        TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Child\'s Name',
            hintText: 'Enter your child\'s name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter a name';
            }
            return null;
          },
        ),
        const SizedBox(height: 24),
        
        // Age group selection
        Text(
          'Age Group',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildAgeGroupCard(
                context,
                'younger',
                '4-7 years',
                'Colorful, playful interface with simpler navigation',
                Colors.purple,
                selectedAgeGroup,
                onAgeGroupChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAgeGroupCard(
                context,
                'older',
                '8-12 years',
                'More sophisticated interface with additional features',
                Colors.blue,
                selectedAgeGroup,
                onAgeGroupChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // Daily time limit
        Text(
          'Daily Screen Time Limit',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Set how much time your child can use the app each day',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Text(
              '15 min',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            Expanded(
              child: Slider(
                value: timeLimit.toDouble(),
                min: 15,
                max: 180,
                divisions: 11,
                label: "$timeLimit min",
                onChanged: (value) {
                  onTimeLimitChanged(value.round());
                },
              ),
            ),
            Text(
              '3 hours',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$timeLimit minutes per day',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  /// Build avatar customization step
  static Widget buildAppearanceStep({
    required BuildContext context,
    required String name,
    required String ageGroup,
    required String avatarColor,
    required String avatarEmoji,
    required List<String> colorOptions,
    required List<String> emojiOptions,
    required Function(String) onColorSelected,
    required Function(String) onEmojiSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Personalize Profile', context),
        const SizedBox(height: 8),
        Text(
          'Create a fun avatar for your child\'s profile',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        
        // Avatar preview
        Center(
          child: Column(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getColorFromName(avatarColor),
                ),
                child: Center(
                  child: Text(
                    avatarEmoji,
                    style: const TextStyle(
                      fontSize: 60,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                name.trim().isNotEmpty ? name.trim() : 'Your Child',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Nunito',
                ),
              ),
              Text(
                ageGroup == 'younger' ? '4-7 years' : '8-12 years',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        
        // Color selection
        Text(
          'Background Color',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: colorOptions.length,
            itemBuilder: (context, index) {
              final color = colorOptions[index];
              final isSelected = color == avatarColor;
              
              return GestureDetector(
                onTap: () => onColorSelected(color),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getColorFromName(color),
                    border: isSelected
                        ? Border.all(color: Colors.black, width: 3)
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 32),
        
        // Emoji selection
        Text(
          'Character',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: emojiOptions.length,
            itemBuilder: (context, index) {
              final emoji = emojiOptions[index];
              final isSelected = emoji == avatarEmoji;
              
              return GestureDetector(
                onTap: () => onEmojiSelected(emoji),
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: isSelected
                        ? Border.all(
                            color: Theme.of(context).primaryColor,
                            width: 3,
                          )
                        : Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Theme.of(context).primaryColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      emoji,
                      style: const TextStyle(fontSize: 30),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  /// Build content preferences step
  static Widget buildContentPreferencesStep({
    required BuildContext context,
    required List<String> allCategories,
    required List<String> selectedCategories,
    required List<String> allInterests,
    required List<String> selectedInterests,
    required Function(String, bool) onCategorySelected,
    required Function(String, bool) onInterestSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Content Preferences', context),
        const SizedBox(height: 20),
        
        // Content categories
        Text(
          'Allowed Content Categories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select the types of content your child is allowed to watch',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allCategories.map((category) {
            final isSelected = selectedCategories.contains(category);
            return FilterChip(
              label: Text(category),
              selected: isSelected,
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              onSelected: (selected) => onCategorySelected(category, selected),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        
        // Special interests
        Text(
          'Special Interests',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select topics your child is particularly interested in',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: const InputDecoration(
            hintText: 'Search interests...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            // Filter interests based on search (not implemented in this demo)
          },
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: allInterests.map((interest) {
            final isSelected = selectedInterests.contains(interest);
            return FilterChip(
              label: Text(interest),
              selected: isSelected,
              selectedColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
              checkmarkColor: Theme.of(context).colorScheme.secondary,
              onSelected: (selected) => onInterestSelected(interest, selected),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  /// Build advanced settings step
  static Widget buildAdvancedSettingsStep({
    required BuildContext context,
    required Map<String, int> contentDistribution,
    required Map<String, List<String>> allContentTags,
    required Map<String, List<String>> selectedContentTags,
    required Function(String, int) onDistributionChanged,
    required Function(String, String, bool) onTagSelected,
    required String name,
    required String ageGroup,
    required int timeLimit,
    required List<String> selectedCategories,
    required List<String> selectedInterests,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Advanced Settings', context),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'These advanced settings help customize content recommendations and are optional.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        
        // Content distribution
        Text(
          'Content Distribution',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Adjust how content is balanced across different areas',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        
        ChildProfileDialogHelpers.buildContentDistributionEditor(
          context: context,
          contentDistribution: contentDistribution,
          onDistributionChanged: onDistributionChanged,
        ),
        
        const SizedBox(height: 24),
        
        // Multi-dimensional tagging
        Text(
          'Content Tags',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select specific content characteristics that match your child\'s preferences',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        
        // Expandable sections for tag categories
        ...allContentTags.entries.map((entry) {
          return Card(
            elevation: 0,
            color: Colors.grey.shade50,
            margin: const EdgeInsets.only(bottom: 16),
            child: ExpansionTile(
              title: Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                selectedContentTags[entry.key]?.isNotEmpty == true
                    ? '${selectedContentTags[entry.key]?.length} selected'
                    : 'No tags selected',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: entry.value.map((tag) {
                      final isSelected = selectedContentTags[entry.key]?.contains(tag) ?? false;
                      return FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
                        checkmarkColor: Theme.of(context).primaryColor,
                        onSelected: (selected) => onTagSelected(entry.key, tag, selected),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        }),
        
        const SizedBox(height: 24),
        
        // Summary of profile
        _buildProfileSummary(
          context,
          name,
          ageGroup,
          timeLimit,
          selectedCategories,
          selectedInterests,
        ),
      ],
    );
  }
  
  /// Helper for age group card widget
  static Widget _buildAgeGroupCard(
    BuildContext context,
    String value,
    String title,
    String description,
    Color color,
    String selectedAgeGroup,
    Function(String) onChanged,
  ) {
    final isSelected = selectedAgeGroup == value;
    
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Card(
        elevation: isSelected ? 4 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: isSelected 
              ? BorderSide(color: color, width: 2) 
              : BorderSide.none,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.1),
                ),
                child: Center(
                  child: Icon(
                    value == 'younger' ? Icons.child_care : Icons.face,
                    color: color,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              if (isSelected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Selected',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build profile summary widget
  static Widget _buildProfileSummary(
    BuildContext context,
    String name,
    String ageGroup,
    int timeLimit,
    List<String> categories,
    List<String> interests,
  ) {
    return Card(
      elevation: 0,
      color: Colors.blue.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            
            // Basic info
            _buildSummaryItem(
              'Name', 
              name.isEmpty ? 'Not specified' : name,
              Icons.person,
            ),
            _buildSummaryItem(
              'Age Group', 
              ageGroup == 'younger' ? '4-7 years' : '8-12 years',
              Icons.schedule,
            ),
            _buildSummaryItem(
              'Daily Time Limit', 
              '$timeLimit minutes',
              Icons.timer,
            ),
            
            // Content preferences
            const SizedBox(height: 8),
            _buildSummaryItem(
              'Categories', 
              categories.isEmpty 
                  ? 'None selected' 
                  : categories.join(', '),
              Icons.category,
            ),
            
            // Special interests
            if (interests.isNotEmpty)
              _buildSummaryItem(
                'Special Interests', 
                interests.join(', '),
                Icons.star,
              ),
          ],
        ),
      ),
    );
  }
  
  /// Helper for summary item widgets
  static Widget _buildSummaryItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Helper for section titles
  static Widget _buildSectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        fontFamily: 'Nunito',
        color: Theme.of(context).primaryColor,
      ),
    );
  }
  
  /// Convert color name to Color object
  static Color _getColorFromName(String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'purple':
        return Colors.purple;
      case 'red':
        return Colors.red;
      case 'orange':
        return Colors.orange;
      case 'pink':
        return Colors.pink;
      default:
        return Colors.blue;
    }
  }
}