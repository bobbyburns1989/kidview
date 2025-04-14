import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kidview/config/themes.dart';
import 'package:kidview/core/constants/route_constants.dart';
import 'package:provider/provider.dart';
import 'package:kidview/data/providers/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
    
    _controller.forward();
    
    // Navigate after splash duration
    Future.delayed(const Duration(seconds: 3), () {
      _navigateToNextScreen();
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _navigateToNextScreen() {
    if (!mounted) return;
    
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated) {
      context.go(Routes.parentHome);
    } else {
      // In demo mode, we'll always go to onboarding
      context.go(Routes.onboarding);
      
      // Real implementation would check SharedPreferences:
      // final isFirstTime = preferences.getBool('first_time') ?? true;
      // context.go(isFirstTime ? Routes.onboarding : Routes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6C63FF),
              Color(0xFF4E4AAD),
            ],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with animation
            ScaleTransition(
              scale: _scaleAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppThemes.withTransparency(Colors.black, 0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      'assets/images/logo/bubble.png',
                      width: 100,
                      height: 100,
                      color: AppThemes.withTransparency(Color(0xFF6C63FF), 0.7),
                    ),
                    Text(
                      'KV',
                      style: TextStyle(
                        color: Color(0xFF6C63FF),
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: AppThemes.withTransparency(Colors.white, 0.5),
                            blurRadius: 5,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24),
            
            // App name with fade transition
            FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Interval(0.5, 1.0, curve: Curves.easeIn),
                ),
              ),
              child: Text(
                'KidView',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            SizedBox(height: 8),
            
            // Tagline
            FadeTransition(
              opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: Interval(0.7, 1.0, curve: Curves.easeIn),
                ),
              ),
              child: Text(
                'Safe viewing for growing minds',
                style: TextStyle(
                  color: Colors.white.withAlpha(204), // Equivalent to opacity 0.8
                  fontSize: 16,
                ),
              ),
            ),
            
            SizedBox(height: 64),
            
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}