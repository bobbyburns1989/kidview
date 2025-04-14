import 'package:kidview/data/models/parent_model.dart';
import 'package:kidview/data/models/video_model.dart';
import 'package:kidview/data/services/mock_data_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Firebase service class that connects to Firebase
/// We'll start with a hybrid implementation that uses Firebase Auth
/// but still uses mock data for content until we populate Firestore
class FirebaseService {
  // Singleton pattern
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  // Mock data service for testing
  // We'll keep this for cases where Firebase is not yet populated
  final MockDataService _mockService = MockDataService();
  
  // Flag for Firebase connection status
  bool get isConnected => true; // Firebase is always initialized in main.dart

  // Initialize Firebase (no longer needed as we initialize in main.dart)
  Future<void> initialize() async {
    // Firebase is initialized in main.dart
    return;
  }

  // Authentication methods
  Future<String?> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid;
    } catch (e) {
      print('Error signing in: $e');
      
      // Fallback to demo account for development
      if (email == 'demo@example.com' && password == 'password') {
        return 'demo-user-123';
      }
      return null;
    }
  }

  Future<String?> createUserWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user?.uid;
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  // Firestore methods for user data
  Future<Parent?> getParentProfile(String userId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
        .collection('parents')
        .doc(userId)
        .get();
      
      if (docSnapshot.exists) {
        return Parent.fromJson(docSnapshot.data()!);
      }
      
      // If no profile in Firestore yet (during development), return mock data
      if (userId == 'demo-user-123') {
        return _mockService.getMockParent();
      }
      
      return null;
    } catch (e) {
      print('Error getting parent profile: $e');
      
      // Fallback to mock data
      if (userId == 'demo-user-123') {
        return _mockService.getMockParent();
      }
      return null;
    }
  }

  Future<bool> createParentProfile(Parent parent) async {
    try {
      await FirebaseFirestore.instance
        .collection('parents')
        .doc(parent.id)
        .set(parent.toJson());
      return true;
    } catch (e) {
      print('Error creating parent profile: $e');
      return false;
    }
  }

  Future<bool> updateParentProfile(Parent parent) async {
    try {
      await FirebaseFirestore.instance
        .collection('parents')
        .doc(parent.id)
        .update(parent.toJson());
      return true;
    } catch (e) {
      print('Error updating parent profile: $e');
      return false;
    }
  }

  // Firestore methods for child profiles
  Future<bool> updateChild(String parentId, Child child) async {
    try {
      // First get the current parent document
      final parentDoc = await FirebaseFirestore.instance
        .collection('parents')
        .doc(parentId)
        .get();
      
      if (!parentDoc.exists) return false;
      
      final parent = Parent.fromJson(parentDoc.data()!);
      
      // Find and update the child
      final updatedChildren = parent.children.map((c) => 
        c.id == child.id ? child : c
      ).toList();
      
      // Update the parent document with new children list
      await FirebaseFirestore.instance
        .collection('parents')
        .doc(parentId)
        .update({'children': updatedChildren.map((c) => c.toJson()).toList()});
        
      return true;
    } catch (e) {
      print('Error updating child: $e');
      return false;
    }
  }

  // Firestore methods for videos
  Future<List<Video>> getVideos(String ageGroup) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
        .collection('videos')
        .where('ageRating', whereIn: [ageGroup, 'all'])
        .get();
      
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs
          .map((doc) => Video.fromJson(doc.data()))
          .toList();
      }
      
      // Fallback to mock data if Firestore doesn't have videos yet
      final allVideos = _mockService.getMockVideos();
      return allVideos.where((video) => 
        video.ageRating == ageGroup || video.ageRating == 'all'
      ).toList();
    } catch (e) {
      print('Error getting videos: $e');
      
      // Fallback to mock data
      final allVideos = _mockService.getMockVideos();
      return allVideos.where((video) => 
        video.ageRating == ageGroup || video.ageRating == 'all'
      ).toList();
    }
  }

  Future<Video?> getVideoById(String videoId) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
        .collection('videos')
        .doc(videoId)
        .get();
        
      if (docSnapshot.exists) {
        return Video.fromJson(docSnapshot.data()!);
      }
      
      // If not in Firestore, try mock data
      return _mockService.getMockVideos()
        .firstWhere((video) => video.id == videoId);
    } catch (e) {
      print('Error getting video: $e');
      
      // Try mock data as fallback
      try {
        return _mockService.getMockVideos()
          .firstWhere((video) => video.id == videoId);
      } catch (_) {
        return null;
      }
    }
  }

  // Methods for tracking and analytics
  Future<void> logVideoView(String videoId, String childId) async {
    try {
      await FirebaseFirestore.instance.collection('videoViews').add({
        'videoId': videoId,
        'childId': childId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging video view: $e');
    }
  }

  Future<List<String>> getWatchHistory(String childId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
        .collection('videoViews')
        .where('childId', isEqualTo: childId)
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();
        
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs
          .map((doc) => doc.data()['videoId'] as String)
          .toList();
      }
      
      // Fallback to mock data
      final randomVideos = _mockService.getMockVideos()..shuffle();
      return randomVideos.take(3).map((v) => v.id).toList();
    } catch (e) {
      print('Error getting watch history: $e');
      
      // Fallback to mock data
      final randomVideos = _mockService.getMockVideos()..shuffle();
      return randomVideos.take(3).map((v) => v.id).toList();
    }
  }
}