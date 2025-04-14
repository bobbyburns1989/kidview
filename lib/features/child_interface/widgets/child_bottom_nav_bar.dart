import 'package:flutter/material.dart';

class ChildBottomNavBar extends StatelessWidget {
  final String ageGroup;
  final int currentIndex;
  final Function(int) onTap;
  final Color primaryColor;
  final bool isYoungerChild;

  const ChildBottomNavBar({
    super.key,
    required this.ageGroup,
    required this.currentIndex,
    required this.onTap,
    required this.primaryColor,
    required this.isYoungerChild,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: isYoungerChild 
            ? const BorderRadius.vertical(top: Radius.circular(20)) 
            : BorderRadius.zero,
        child: BottomNavigationBar(
          backgroundColor: primaryColor,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withAlpha(179), // Equivalent to opacity 0.7
          currentIndex: currentIndex,
          elevation: 16,
          iconSize: isYoungerChild ? 32 : 24,
          selectedFontSize: isYoungerChild ? 16 : 14,
          unselectedFontSize: isYoungerChild ? 14 : 12,
          type: BottomNavigationBarType.fixed,
          onTap: onTap,
          items: [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: isYoungerChild ? 4 : 0),
                child: const Icon(Icons.home),
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: isYoungerChild ? 4 : 0),
                child: const Icon(Icons.video_library),
              ),
              label: 'Videos',
            ),
          ],
        ),
      ),
    );
  }
}