import 'package:flutter/material.dart';

class CategoryFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Function(bool) onSelected;
  final Color primaryColor;

  const CategoryFilterChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onSelected,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      backgroundColor: Colors.grey[200],
      selectedColor: primaryColor.withOpacity(0.2),
      checkmarkColor: primaryColor,
      labelStyle: TextStyle(
        color: isSelected ? primaryColor : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : null,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? primaryColor : Colors.transparent,
          width: 1.5,
        ),
      ),
      elevation: isSelected ? 2 : 0,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }
}