import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kidview/config/app_config.dart';
import 'package:kidview/config/routes.dart';
import 'package:kidview/config/themes.dart';
import 'package:kidview/data/providers/auth_provider.dart';
import 'package:kidview/data/providers/theme_provider.dart';
import 'package:kidview/data/services/analytics_service.dart';
import 'package:kidview/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize analytics service
  await AnalyticsService().initialize();
  
  // Log app open event
  await AnalyticsService().logAppOpen();
  
  // Initialize app configuration
  await AppConfig.initialize();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Add other providers here
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'KidView',
            debugShowCheckedModeBanner: false,
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter.router,
            // Enable analytics navigation observer (router will handle this)
            builder: (context, child) {
              // Apply any app-wide styling or behavior here
              return child!;
            },
          );
        },
      ),
    );
  }
}