import 'package:flutter/material.dart';
import 'package:kidview/data/models/parent_model.dart';

class WelcomeCard extends StatelessWidget {
  final Parent parent;
  final VoidCallback onAddChild;

  const WelcomeCard({
    super.key,
    required this.parent,
    required this.onAddChild,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(
                    parent.displayName[0].toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
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
                        'Welcome, ${parent.displayName}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getGreeting(),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (parent.children.isEmpty) ...[              
              _buildEmptyChildrenSection(context),
            ] else ...[              
              _buildChildrenCountSection(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChildrenSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Text(
          'You haven\'t added any child profiles yet.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(height: 8),
        ElevatedButton.icon(
          onPressed: onAddChild,
          icon: const Icon(Icons.add),
          label: const Text('Add Child Profile'),
        ),
      ],
    );
  }

  Widget _buildChildrenCountSection(BuildContext context) {
    return Column(
      children: [
        const Divider(),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Child Profiles (${parent.children.length})',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle),
              onPressed: onAddChild,
            ),
          ],
        ),
      ],
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }
}
