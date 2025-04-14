import 'package:kidview/data/models/parent_model.dart';
import 'package:kidview/data/models/video_model.dart';

class VideoService {
  // Demo-friendly version with no Firebase dependencies
  
  // Videos for child based on age group and allowed categories
  Future<List<Video>> getVideosForChild(Child child) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 800));
    
    // Return appropriate mock videos for the child's age group
    List<Video> allVideos = getMockVideos();
    
    // Filter by age group and categories
    return allVideos.where((video) => 
      (video.ageRating == child.ageGroup || video.ageRating == 'all') &&
      video.categories.any((category) => child.allowedContentCategories.contains(category))
    ).toList();
  }
  
  // Educational videos
  Future<List<Video>> getEducationalVideos(Child child) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 800));
    
    List<Video> allVideos = getMockVideos();
    
    // Filter by educational category and age group
    return allVideos.where((video) => 
      (video.ageRating == child.ageGroup || video.ageRating == 'all') && 
      video.categories.contains('Education')
    ).toList();
  }
  
  // Downloaded videos (mocked)
  Future<List<Video>> getDownloadedVideos(String childId) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    
    // In a demo, we'll assume the first 2 videos are downloaded
    return getMockVideos().take(2).toList();
  }
  
  // Check if screen time is allowed
  bool isScreenTimeAllowed(ParentalControls controls) {
    // For demo purposes, always allow
    return true;
  }
  
  // Log video view (mocked)
  Future<void> logVideoView(String videoId, String childId) async {
    // Just simulate a delay for the demo
    await Future.delayed(Duration(milliseconds: 300));
    print('Logged view of video $videoId for child $childId');
  }
  
  // Helper method to get the current day name
  String getCurrentDay() {
    const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final now = DateTime.now();
    // DateTime.weekday returns 1 for Monday, 2 for Tuesday, etc.
    return days[now.weekday - 1];
  }
  
  // Get featured videos
  Future<List<Video>> getFeaturedVideos(String ageGroup) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 600));
    
    final allVideos = getMockVideos();
    // Filter by age group
    final filteredVideos = allVideos.where((video) => 
      video.ageRating == ageGroup || video.ageRating == 'all'
    ).toList();
    
    // Sort by rating and take top 3
    filteredVideos.sort((a, b) => b.rating.compareTo(a.rating));
    return filteredVideos.take(3).toList();
  }
  
  // Get recommended videos
  Future<List<Video>> getRecommendedVideos(String ageGroup) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 500));
    
    final allVideos = getMockVideos();
    // Filter by age group
    final filteredVideos = allVideos.where((video) => 
      video.ageRating == ageGroup || video.ageRating == 'all'
    ).toList();
    
    // Sort by view count and take top 4
    filteredVideos.sort((a, b) => b.viewCount.compareTo(a.viewCount));
    return filteredVideos.take(4).toList();
  }
  
  // Get video by ID
  Future<Video?> getVideoById(String id) async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300));
    
    final allVideos = getMockVideos();
    try {
      return allVideos.firstWhere((video) => video.id == id);
    } catch (_) {
      return null;
    }
  }
  
  // Mock data for demo
  List<Video> getMockVideos() {
    return [
      Video(
        id: '1',
        title: 'Learn Colors with Fun Shapes',
        description: 'A colorful adventure teaching basic shapes and colors for younger children.',
        thumbnailUrl: 'https://via.placeholder.com/640x360?text=Learn+Colors',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        creatorId: 'creator1',
        creatorName: 'Kids Learning Channel',
        categories: ['Education', 'Art'],
        tags: ['colors', 'shapes', 'basic learning'],
        ageRating: 'younger',
        duration: 360, // 6 minutes
        uploadDate: DateTime.now().subtract(const Duration(days: 30)),
        viewCount: 15240,
        rating: 4.8,
        educationalTags: [
          EducationalTag(
            name: 'Color Recognition',
            subject: 'Art',
            skill: 'Visual Learning',
            ageMin: 3,
            ageMax: 6,
          ),
          EducationalTag(
            name: 'Shape Recognition',
            subject: 'Mathematics',
            skill: 'Geometry',
            ageMin: 3,
            ageMax: 6,
          ),
        ],
        isDownloadable: true,
        isApprovedByKidView: true,
      ),
      Video(
        id: '2',
        title: 'Counting Adventure: Numbers 1-10',
        description: 'Join the counting adventure and learn numbers from 1 to 10 with fun characters!',
        thumbnailUrl: 'https://via.placeholder.com/640x360?text=Counting+Adventure',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        creatorId: 'creator1',
        creatorName: 'Kids Learning Channel',
        categories: ['Education', 'Mathematics'],
        tags: ['counting', 'numbers', 'basic math'],
        ageRating: 'younger',
        duration: 420, // 7 minutes
        uploadDate: DateTime.now().subtract(const Duration(days: 25)),
        viewCount: 18500,
        rating: 4.9,
        educationalTags: [
          EducationalTag(
            name: 'Number Recognition',
            subject: 'Mathematics',
            skill: 'Counting',
            ageMin: 3,
            ageMax: 6,
          ),
        ],
        isDownloadable: true,
        isApprovedByKidView: true,
      ),
      Video(
        id: '3',
        title: 'The Solar System for Kids',
        description: 'Explore the wonders of our solar system with this educational video about planets and space.',
        thumbnailUrl: 'https://via.placeholder.com/640x360?text=Solar+System',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
        creatorId: 'creator2',
        creatorName: 'Science Explorers',
        categories: ['Education', 'Science'],
        tags: ['space', 'planets', 'solar system'],
        ageRating: 'older',
        duration: 540, // 9 minutes
        uploadDate: DateTime.now().subtract(const Duration(days: 15)),
        viewCount: 21300,
        rating: 4.7,
        educationalTags: [
          EducationalTag(
            name: 'Astronomy',
            subject: 'Science',
            skill: 'Space Knowledge',
            ageMin: 8,
            ageMax: 12,
          ),
        ],
        isDownloadable: true,
        isApprovedByKidView: true,
      ),
      Video(
        id: '4',
        title: 'Basic Coding Concepts for Kids',
        description: 'Learn the fundamentals of coding logic with this fun introduction to programming concepts.',
        thumbnailUrl: 'https://via.placeholder.com/640x360?text=Coding+Concepts',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
        creatorId: 'creator3',
        creatorName: 'Code Kids',
        categories: ['Education', 'Technology'],
        tags: ['coding', 'programming', 'logic'],
        ageRating: 'older',
        duration: 600, // 10 minutes
        uploadDate: DateTime.now().subtract(const Duration(days: 10)),
        viewCount: 12600,
        rating: 4.6,
        educationalTags: [
          EducationalTag(
            name: 'Coding Logic',
            subject: 'Computer Science',
            skill: 'Problem Solving',
            ageMin: 8,
            ageMax: 12,
          ),
        ],
        isDownloadable: true,
        isApprovedByKidView: true,
      ),
      Video(
        id: '5',
        title: 'The Water Cycle',
        description: 'Learn about the water cycle and how water moves through our environment in this educational video.',
        thumbnailUrl: 'https://via.placeholder.com/640x360?text=Water+Cycle',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
        creatorId: 'creator2',
        creatorName: 'Science Explorers',
        categories: ['Education', 'Science'],
        tags: ['water cycle', 'environment', 'earth science'],
        ageRating: 'all',
        duration: 480, // 8 minutes
        uploadDate: DateTime.now().subtract(const Duration(days: 5)),
        viewCount: 8900,
        rating: 4.5,
        educationalTags: [
          EducationalTag(
            name: 'Earth Science',
            subject: 'Science',
            skill: 'Environmental Awareness',
            ageMin: 6,
            ageMax: 12,
          ),
        ],
        isDownloadable: true,
        isApprovedByKidView: true,
      ),
      Video(
        id: '6',
        title: 'Simple English Words for Beginners',
        description: 'Learn basic English vocabulary with fun animations and pronunciations.',
        thumbnailUrl: 'https://via.placeholder.com/640x360?text=English+Words',
        videoUrl: 'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
        creatorId: 'creator4',
        creatorName: 'Language Kids',
        categories: ['Education', 'Language'],
        tags: ['english', 'vocabulary', 'words'],
        ageRating: 'younger',
        duration: 360, // 6 minutes
        uploadDate: DateTime.now().subtract(const Duration(days: 12)),
        viewCount: 19400,
        rating: 4.7,
        educationalTags: [
          EducationalTag(
            name: 'Vocabulary Building',
            subject: 'Language',
            skill: 'Reading Readiness',
            ageMin: 4,
            ageMax: 7,
          ),
        ],
        isDownloadable: true,
        isApprovedByKidView: true,
      ),
    ];
  }
  
  // Additional mock data generators can be added as needed
}