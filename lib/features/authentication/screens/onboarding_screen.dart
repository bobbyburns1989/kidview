import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kidview/core/constants/route_constants.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: 'True Parental Control',
      description: 'Take full control of what your child watches with advanced content filtering and age-appropriate recommendations.',
      image: 'assets/images/placeholder.png',
      color: Color(0xFF6C63FF),
    ),
    OnboardingPage(
      title: 'Educational Content',
      description: 'Access a curated library of educational videos that help your child learn and grow while being entertained.',
      image: 'assets/images/placeholder.png',
      color: Color(0xFF4CAF50),
    ),
    OnboardingPage(
      title: 'Safe & Ad-Free',
      description: 'KidView provides a completely ad-free experience with no inappropriate content or unwanted surprises.',
      image: 'assets/images/placeholder.png',
      color: Color(0xFF2196F3),
    ),
    OnboardingPage(
      title: 'Time Management',
      description: 'Set screen time limits and schedules to encourage healthy digital habits for your children.',
      image: 'assets/images/placeholder.png',
      color: Color(0xFFFF6584),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // On last page, navigate to login
      context.go(Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background color transition
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: _pages[_currentPage].color,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _pages[_currentPage].color,
                    _pages[_currentPage].color.withOpacity(0.8),
                    Colors.white,
                  ],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          
          // Page content
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),
          
          // Bottom navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Skip button
                  TextButton(
                    onPressed: () => context.go(Routes.login),
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 16,
                      ),
                    ),
                  ),
                  
                  // Page indicators
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? _pages[_currentPage].color
                              : Colors.grey[300],
                        ),
                      ),
                    ),
                  ),
                  
                  // Next button
                  ElevatedButton(
                    onPressed: _onNextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _pages[_currentPage].color,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _currentPage < _pages.length - 1 ? 'Next' : 'Get Started',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image
          Expanded(
            flex: 3,
            child: Image.asset(
              page.image,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                // Placeholder if image is missing
                return Container(
                  color: page.color.withOpacity(0.1),
                  child: Icon(
                    Icons.image,
                    size: 100,
                    color: page.color,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 48),
          
          // Title
          Text(
            page.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            page.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          
          // Bottom spacing for navigation
          SizedBox(height: 100),
        ],
      ),
    );
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final String image;
  final Color color;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.image,
    required this.color,
  });
}