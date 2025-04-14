import 'package:kidview/data/models/parent_model.dart';

import 'package:kidview/data/models/video_model.dart';

class MockDataService {
  // Provides mock data for the app

  Future<Parent> getMockParent() async {
    // Simulate a short network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Create a mock parent profile with two children
    return Parent(
      id: 'demo-user-123',
      email: 'demo@example.com',
      displayName: 'Demo Parent',
      children: _getMockChildren(),
      controls: _getMockParentalControls(),
    );
  }
  
  List<Child> _getMockChildren() {
    return [
      Child(
        id: 'child-1',
        name: 'Emma',
        avatarUrl: '',
        ageGroup: 'younger',
        allowedContentCategories: ['Education', 'Fun', 'Music', 'Art'],
        dailyTimeLimit: 120, // 2 hours
        watchHistory: [],
        favorites: [],
        specialInterests: ['Dinosaurs', 'Space', 'Animals'],
        contentDistribution: {
          'Values & Social Skills': 30,
          'STEM Topics': 25,
          'Creative Arts': 20,
          'Special Interests': 15,
          'Free Choice': 10,
        },
        contentTags: {
          'Values': ['Kindness', 'Sharing', 'Honesty'],
          'Learning Approach': ['Exploratory', 'Project-based'],
          'Content Format': ['Animation', 'Short-form'],
          'Developmental Focus': ['Vocabulary building', 'Social skills'],
        },
      ),
      Child(
        id: 'child-2',
        name: 'Jacob',
        avatarUrl: '',
        ageGroup: 'older',
        allowedContentCategories: ['Education', 'Science', 'Technology'],
        dailyTimeLimit: 180, // 3 hours
        watchHistory: [],
        favorites: [],
        specialInterests: ['Robots', 'Coding', 'Chemistry'],
        contentDistribution: {
          'STEM Topics': 40,
          'Values & Social Skills': 20,
          'Creative Arts': 15,
          'Special Interests': 15,
          'Free Choice': 10,
        },
        contentTags: {
          'Values': ['Teamwork', 'Leadership', 'Perseverance'],
          'Learning Approach': ['Problem-solving', 'Gamified learning'],
          'Content Format': ['Interactive', 'Long-form'],
          'Developmental Focus': ['Logical reasoning', 'Scientific thinking'],
        },
      ),
    ];
  }
  
  ParentalControls _getMockParentalControls() {
    return ParentalControls(
      pinProtected: true,
      pin: '1234',
      allowDownloads: true,
      preventAppSwitching: false,
      scheduledViewingTimes: _getMockViewingSchedule(),
      contentFilters: {
        'violence': true,
        'language': true,
        'fear': true,
        'consumerism': true,
      },
    );
  }
  
  List<TimeRange> _getMockViewingSchedule() {
    return [
      TimeRange(
        dayOfWeek: 'Monday',
        startTime: '15:00',
        endTime: '17:00',
      ),
      TimeRange(
        dayOfWeek: 'Wednesday',
        startTime: '15:00',
        endTime: '17:00',
      ),
      TimeRange(
        dayOfWeek: 'Friday',
        startTime: '15:00',
        endTime: '18:00',
      ),
      TimeRange(
        dayOfWeek: 'Saturday',
        startTime: '10:00',
        endTime: '12:00',
      ),
      TimeRange(
        dayOfWeek: 'Sunday',
        startTime: '10:00',
        endTime: '12:00',
      ),
    ];
  }
  
  List<Video> getMockVideos() {
    // Generate a list of mock videos
    return [
      Video(
        id: 'video-1',
        title: 'Exploring Space: Journey to the Stars',
        description: 'Join us on an educational adventure through our solar system and beyond. Learn about planets, stars, and galaxies.',
        thumbnailUrl: 'assets/images/placeholder.png',
        videoUrl: 'https://example.com/videos/space-journey.mp4',
        creatorId: 'creator-1',
        creatorName: 'ScienceKids',
        categories: ['Education', 'Science'],
        tags: ['space', 'planets', 'astronomy', 'educational'],
        ageRating: 'all',
        duration: 720, // 12 minutes
        uploadDate: DateTime.now().subtract(const Duration(days: 30)),
        viewCount: 12500,
        rating: 4.8,
        educationalTags: [
          EducationalTag(
            name: 'Solar System',
            subject: 'Science',
            skill: 'Astronomy Basics',
            ageMin: 5,
            ageMax: 12,
          ),
          EducationalTag(
            name: 'Space Exploration',
            subject: 'Science',
            skill: 'Scientific Discovery',
            ageMin: 6,
            ageMax: 12,
          ),
        ],
        isDownloadable: true,
        isApprovedByKidView: true,
      ),
      Video(
        id: 'video-2',
        title: 'Counting with Animals',
        description: 'Learn to count from 1 to 20 with friendly animal characters. Perfect for preschoolers!',
        thumbnailUrl: 'assets/images/placeholder.png',
        videoUrl: 'https://example.com/videos/counting-animals.mp4',
        creatorId: 'creator-2',
        creatorName: 'Early Learning Channel',
        categories: ['Education', 'Math'],
        tags: ['counting', 'animals', 'numbers', 'preschool'],
        ageRating: 'younger',
        duration: 540, // 9 minutes
        uploadDate: DateTime.now().subtract(const Duration(days: 45)),
        viewCount: 18700,
        rating: 4.9,
        educationalTags: [
          EducationalTag(
            name: 'Counting',
            subject: 'Math',
            skill: 'Number Recognition',
            ageMin: 3,
            ageMax: 7,
          ),
          EducationalTag(
            name: 'Animal Recognition',
            subject: 'Science',
            skill: 'Biology Basics',
            ageMin: 3,
            ageMax: 7,
          ),
        ],
        isDownloadable: true,
        isApprovedByKidView: true,
      ),
      Video(
        id: 'video-3',
        title: 'The Water Cycle Adventure',
        description: 'Join Droplet on an adventure through the water cycle. Learn about evaporation, condensation, and precipitation.',
        thumbnailUrl: 'assets/images/placeholder.png',
        videoUrl: 'https://example.com/videos/water-cycle.mp4',
        creatorId: 'creator-1',
        creatorName: 'ScienceKids',
        categories: ['Education', 'Science'],
        tags: ['water', 'environment', 'nature', 'educational'],
        ageRating: 'all',
        duration: 660, // 11 minutes
        uploadDate: DateTime.now().subtract(const Duration(days: 60)),
        viewCount: 14200,
        rating: 4.7,
        educationalTags: [
          EducationalTag(
            name: 'Water Cycle',
            subject: 'Science',
            skill: 'Earth Science',
            ageMin: 6,
            ageMax: 12,
          ),
          EducationalTag(
            name: 'Environmental Science',
            subject: 'Science',
            skill: 'Ecology',
            ageMin: 6,
            ageMax: 12,
          ),
        ],
        isDownloadable: true,
        isApprovedByKidView: true,
      ),
      Video(
        id: 'video-4',
        title: 'Programming for Kids: Make Your First Game',
        description: 'Learn the basics of programming by creating a simple game. Perfect introduction to coding concepts.',
        thumbnailUrl: 'assets/images/placeholder.png',
        videoUrl: 'https://example.com/videos/programming-kids.mp4',
        creatorId: 'creator-3',
        creatorName: 'CodeKids',
        categories: ['Education', 'Technology'],
        tags: ['coding', 'programming', 'games', 'computers'],
        ageRating: 'older',
        duration: 840, // 14 minutes
        uploadDate: DateTime.now().subtract(const Duration(days: 20)),
        viewCount: 9500,
        rating: 4.6,
        educationalTags: [
          EducationalTag(
            name: 'Coding Basics',
            subject: 'Computer Science',
            skill: 'Programming Logic',
            ageMin: 8,
            ageMax: 12,
          ),
          EducationalTag(
            name: 'Game Development',
            subject: 'Computer Science',
            skill: 'Creative Computing',
            ageMin: 8,
            ageMax: 12,
          ),
        ],
        isDownloadable: true,
        isApprovedByKidView: true,
      ),
      Video(
        id: 'video-5',
        title: 'Dinosaur Adventure: Meet the T-Rex',
        description: 'Travel back in time to the age of dinosaurs and learn about the mighty Tyrannosaurus Rex.',
        thumbnailUrl: 'assets/images/placeholder.png',
        videoUrl: 'https://example.com/videos/dinosaur-adventure.mp4',
        creatorId: 'creator-4',
        creatorName: 'DinoExplorers',
        categories: ['Education', 'Science'],
        tags: ['dinosaurs', 'prehistoric', 'history', 'animals'],
        ageRating: 'younger',
        duration: 600, // 10 minutes
        uploadDate: DateTime.now().subtract(const Duration(days: 15)),
        viewCount: 22000,
        rating: 4.9,
        educationalTags: [
          EducationalTag(
            name: 'Dinosaurs',
            subject: 'Science',
            skill: 'Paleontology',
            ageMin: 4,
            ageMax: 10,
          ),
          EducationalTag(
            name: 'Prehistoric Life',
            subject: 'History',
            skill: 'Timeline Comprehension',
            ageMin: 4,
            ageMax: 10,
          ),
        ],
        isDownloadable: true,
        isApprovedByKidView: true,
      ),
    ];
  }
}