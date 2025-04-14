import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kidview/firebase_options.dart';
import 'package:kidview/data/services/firebase_seed.dart';

/// Run this script to populate Firestore with initial data
/// Usage: flutter run -t lib/firebase_seed_script.dart
void main() async {
  // Initialize Flutter and Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Create seed utility
  final FirebaseSeed seed = FirebaseSeed();
  
  // Seed all data
  await seed.seedAll();
  
  // Exit when done
  print('Firebase seeding completed. Exiting...');
}