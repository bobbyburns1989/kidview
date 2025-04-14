import 'package:flutter/material.dart';

class CategoryButton extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final bool isYoungerChild;

  const CategoryButton({
    super.key,
    required this.name,
    required this.icon,
    required this.color,
    required this.isYoungerChild,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = isYoungerChild ? 48.0 : 32.0;
    final fontSize = isYoungerChild ? 18.0 : 14.0;
    final borderRadius = isYoungerChild ? 20.0 : 12.0;

    return Hero(
      tag: 'category-$name',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // In a real app, navigate to category view
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$name videos coming soon!')),
            );
          },
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: color.withOpacity(0.3),
          highlightColor: color.withOpacity(0.1),
          child: Ink(
            decoration: BoxDecoration(
              color: color.withAlpha(38), // Equivalent to opacity 0.15
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: color.withAlpha(77), // Equivalent to opacity 0.3
                width: isYoungerChild ? 3 : 2,
              ),
              boxShadow: isYoungerChild ? [
                BoxShadow(
                  color: color.withOpacity(0.2),
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                )
              ] : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: color,
                  size: iconSize,
                ),
                SizedBox(height: isYoungerChild ? 12 : 8),
                Text(
                  name,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}