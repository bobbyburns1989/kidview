import 'package:flutter/material.dart';
import 'package:kidview/data/models/parent_model.dart';
import 'package:kidview/features/parent_dashboard/widgets/child_profile_dialogs.dart';

class ChildProfileCard extends StatelessWidget {
  final Child child;

  const ChildProfileCard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final ageGroupLabel = child.ageGroup == 'younger' ? '4-7 years' : '8-12 years';
    final color = child.ageGroup == 'younger' 
        ? Theme.of(context).primaryColor.withAlpha(204) // Equivalent to opacity 0.8
        : Theme.of(context).colorScheme.secondary.withAlpha(204); // Equivalent to opacity 0.8
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => ChildProfileDialogs.showChildDetailsDialog(context, child),
        child: Stack(
          children: [
            // Background color
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color,
                    color.withAlpha(153), // Equivalent to opacity 0.6
                  ],
                ),
              ),
            ),
            
            // Content
            _buildCardContent(context, color, ageGroupLabel),
            
            // Edit button
            Positioned(
              top: 8,
              right: 8,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => ChildProfileDialogs.showEditChildDialog(context, child),
                  borderRadius: BorderRadius.circular(16),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.edit,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, Color color, String ageGroupLabel) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAvatar(color),
          const SizedBox(height: 16),
          _buildChildInfo(ageGroupLabel),
          const Spacer(),
          _buildEnterKidModeButton(context, color),
        ],
      ),
    );
  }

  Widget _buildAvatar(Color color) {
    return CircleAvatar(
      radius: 32,
      backgroundColor: Colors.white,
      backgroundImage: child.avatarUrl.isNotEmpty
          ? NetworkImage(child.avatarUrl)
          : null,
      child: child.avatarUrl.isEmpty
          ? Text(
              child.name[0].toUpperCase(),
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
    );
  }

  Widget _buildChildInfo(String ageGroupLabel) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          child.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          ageGroupLabel,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEnterKidModeButton(BuildContext context, Color color) {
    return ElevatedButton(
      onPressed: () => ChildProfileDialogs.showEnterChildModeDialog(context, child),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: color,
        minimumSize: const Size(double.infinity, 36),
      ),
      child: const Text('Enter Kid Mode'),
    );
  }
}
