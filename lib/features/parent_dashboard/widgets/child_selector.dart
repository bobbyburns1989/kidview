import 'package:flutter/material.dart';
import 'package:kidview/data/models/parent_model.dart';

class ChildSelector extends StatelessWidget {
  final List<Child> children;
  final Child? selectedChild;
  final Function(Child) onChildSelected;

  const ChildSelector({
    super.key,
    required this.children,
    required this.selectedChild,
    required this.onChildSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Child',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];
              final isSelected = selectedChild?.id == child.id;
              final color = child.ageGroup == 'younger'
                  ? Theme.of(context).primaryColor
                  : Theme.of(context).colorScheme.secondary;

              return Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () => onChildSelected(child),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: color, width: 3)
                              : null,
                        ),
                        padding: isSelected ? const EdgeInsets.all(2) : null,
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor: color.withOpacity(0.2),
                          backgroundImage: child.avatarUrl.isNotEmpty
                              ? NetworkImage(child.avatarUrl)
                              : null,
                          child: child.avatarUrl.isEmpty
                              ? Text(
                                  child.name[0].toUpperCase(),
                                  style: TextStyle(
                                    color: color,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        child.name,
                        style: TextStyle(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? color : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}