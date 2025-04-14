import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kidview/data/models/parent_model.dart';
import 'package:kidview/data/models/video_model.dart';
import 'package:kidview/data/services/mock_data_service.dart';

/// Utility class to seed Firestore with initial data
/// Use this to populate your Firestore database with test data
class FirebaseSeed {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final MockDataService _mockService = MockDataService();
  
  /// Seed Firestore with mock parent data
  Future<void> seedParents() async {
    try {
      // Get mock parent data
      final Parent parent = await _mockService.getMockParent();
      
      // Write to Firestore
      await _firestore
        .collection('parents')
        .doc(parent.id)
        .set(parent.toJson());
        
      // Use logger instead of print in production code
      print('✅ Successfully seeded parent data');
    } catch (e) {
      print('❌ Error seeding parent data: $e');
    }
  }
  
  /// Seed Firestore with mock videos
  Future<void> seedVideos() async {
    try {
      // Get mock video data
      final List<Video> videos = _mockService.getMockVideos();
      
      // Create batch for efficient writes
      final batch = _firestore.batch();
      
      // Add videos to batch
      for (final video in videos) {
        final videoRef = _firestore.collection('videos').doc(video.id);
        batch.set(videoRef, video.toJson());
      }
      
      // Commit batch
      await batch.commit();
      
      // Use logger instead of print in production code
      print('✅ Successfully seeded ${videos.length} videos');
    } catch (e) {
      print('❌ Error seeding videos: $e');
    }
  }
  
  /// Seed Firestore with sample video views for watch history
  Future<void> seedVideoViews() async {
    try {
      // Get mock data
      final Parent parent = await _mockService.getMockParent();
      final List<Video> videos = _mockService.getMockVideos();
      
      // Create batch for efficient writes
      final batch = _firestore.batch();
      
      // Add sample views for each child
      for (final child in parent.children) {
        // Add 5 random views per child
        final randomVideos = List<Video>.from(videos)..shuffle();
        final selectedVideos = randomVideos.take(5).toList();
        
        for (int i = 0; i < selectedVideos.length; i++) {
          final viewRef = _firestore.collection('videoViews').doc();
          
          // Create timestamps going back in time
          final timestamp = Timestamp.fromDate(
            DateTime.now().subtract(Duration(hours: i * 3))
          );
          
          batch.set(viewRef, {
            'childId': child.id,
            'videoId': selectedVideos[i].id,
            'timestamp': timestamp,
          });
        }
      }
      
      // Commit batch
      await batch.commit();
      
      // Use logger instead of print in production code
      print('✅ Successfully seeded watch history data');
    } catch (e) {
      print('❌ Error seeding watch history: $e');
    }
  }
  
  /// Run all seed methods at once
  Future<void> seedAll() async {
    print('🔄 Starting Firebase seed process...');
    
    await seedParents();
    await seedVideos();
    await seedVideoViews();
    
    print('✅ Firebase seeding complete!');
  }
}