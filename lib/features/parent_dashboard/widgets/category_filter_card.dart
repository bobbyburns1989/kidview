import 'package:flutter/material.dart';

class CategoryFilterCard extends StatelessWidget {
  final List<String> selectedCategories;
  final Function(List<String>) onChange;

  const CategoryFilterCard({
    super.key,
    required this.selectedCategories,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    // Define all available categories
    final allCategories = [
      'Education',
      'Science',
      'Art',
      'Music',
      'Mathematics',
      'Language',
      'Technology',
      'Social Studies',
      'Health',
      'Fun',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Category checkboxes in a grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 4,
              ),
              itemCount: allCategories.length,
              itemBuilder: (context, index) {
                final category = allCategories[index];
                final isSelected = selectedCategories.contains(category);
                
                return CheckboxListTile(
                  title: Text(category),
                  value: isSelected,
                  onChanged: (bool? value) {
                    if (value == true && !isSelected) {
                      onChange([...selectedCategories, category]);
                    } else if (value == false && isSelected) {
                      onChange(selectedCategories.where((c) => c != category).toList());
                    }
                  },
                  dense: true,
                  activeColor: Theme.of(context).primaryColor,
                );
              },
            ),
            
            // Warning message if no categories are selected
            if (selectedCategories.isEmpty) ...[              
              const Divider(),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please select at least one category',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}