import 'dart:math';
import 'package:kidview/data/models/parent_model.dart';

/// Service for tracking and reporting screen time and content usage
class UsageTrackingService {
  // Singleton pattern
  static final UsageTrackingService _instance = UsageTrackingService._internal();
  factory UsageTrackingService() => _instance;
  UsageTrackingService._internal();
  
  // Store usage data
  final Map<String, ChildUsageData> _usageData = {};
  
  /// Initialize with demo data for all children
  void initializeDemoData(List<Child> children) {
    for (final child in children) {
      if (!_usageData.containsKey(child.id)) {
        _usageData[child.id] = ChildUsageData.generateDemo(child);
      }
    }
  }
  
  /// Get today's usage for a specific child
  UsageDay getTodayUsage(String childId) {
    if (!_usageData.containsKey(childId)) {
      return UsageDay(minutesUsed: 0, contentViewed: {});
    }
    return _usageData[childId]!.today;
  }
  
  /// Get weekly usage data for a specific child
  List<UsageDay> getWeeklyUsage(String childId) {
    if (!_usageData.containsKey(childId)) {
      return List.generate(7, (_) => UsageDay(minutesUsed: 0, contentViewed: {}));
    }
    return _usageData[childId]!.weeklyData;
  }
  
  /// Get most watched categories for a child
  Map<String, int> getMostWatchedCategories(String childId) {
    if (!_usageData.containsKey(childId)) {
      return {};
    }
    return _usageData[childId]!.categoryDistribution;
  }
  
  /// Log video view (would actually track in a real app)
  void logVideoView(String childId, String videoId, String category, int minutes) {
    if (!_usageData.containsKey(childId)) {
      return;
    }
    
    // Update today's usage
    final today = _usageData[childId]!.today;
    _usageData[childId]!.today = UsageDay(
      minutesUsed: today.minutesUsed + minutes,
      contentViewed: {
        ...today.contentViewed,
        videoId: (today.contentViewed[videoId] ?? 0) + minutes,
      },
    );
    
    // Update category distribution
    final categories = _usageData[childId]!.categoryDistribution;
    categories[category] = (categories[category] ?? 0) + minutes;
    
    // In a real app, this would be saved to a database
  }
  
  /// Get report data for a child
  ScreenTimeReport generateReport(String childId) {
    if (!_usageData.containsKey(childId)) {
      return ScreenTimeReport(
        childId: childId,
        weeklyUsage: List.generate(7, (_) => UsageDay(minutesUsed: 0, contentViewed: {})),
        totalMinutes: 0,
        dailyAverage: 0,
        mostWatchedDay: 'None',
        mostWatchedDayMinutes: 0,
        mostWatchedCategories: {},
        limitExceededDays: 0,
        weekOverWeekChange: 0,
        attentionSpan: 0,
        bestTimeOfDay: 'Morning',
        contentEngagementRatings: {},
        learningPatterns: [],
        bestDayRecommendation: 'Weekday',
        consistencyScore: 0,
      );
    }
    
    final data = _usageData[childId]!;
    final weeklyUsage = data.weeklyData;
    final totalMinutes = weeklyUsage.fold(0, (sum, day) => sum + day.minutesUsed);
    final dailyAverage = totalMinutes / 7;
    
    // Find most watched day
    int mostMinutes = 0;
    String mostDay = 'Sunday';
    final dayNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    
    for (int i = 0; i < weeklyUsage.length; i++) {
      if (weeklyUsage[i].minutesUsed > mostMinutes) {
        mostMinutes = weeklyUsage[i].minutesUsed;
        mostDay = dayNames[i];
      }
    }
    
    // Count days that exceeded limit
    int limitExceededDays = 0;
    int dailyLimit = data.dailyLimit;
    
    for (final day in weeklyUsage) {
      if (day.minutesUsed > dailyLimit) {
        limitExceededDays++;
      }
    }
    
    // Calculate week-over-week change (mocked for demo)
    final random = Random();
    final weekOverWeekChange = random.nextDouble() * 20 - 10; // -10% to +10%
    
    // Calculate average attention span (mocked for demo)
    final attentionSpan = (10 + random.nextInt(15)).toDouble(); // 10-25 minutes
    
    // Determine best time of day based on engagement (mocked for demo)
    final timeOptions = ['Morning', 'Afternoon', 'Evening'];
    final bestTimeOfDay = timeOptions[random.nextInt(timeOptions.length)];
    
    // Generate content engagement ratings (mocked for demo)
    final contentEngagementRatings = <String, double>{};
    for (final category in data.categoryDistribution.keys) {
      contentEngagementRatings[category] = 3 + random.nextDouble() * 2; // 3-5 rating
    }
    
    // Generate learning patterns (mocked for demo)
    final learningOptions = [
      'Visual Learning', 
      'Auditory Learning', 
      'Interactive Learning',
      'Reading',
      'Problem Solving',
    ];
    
    final learningPatterns = <String>[];
    final numPatterns = 2 + random.nextInt(2); // 2-3 patterns
    while (learningPatterns.length < numPatterns) {
      final pattern = learningOptions[random.nextInt(learningOptions.length)];
      if (!learningPatterns.contains(pattern)) {
        learningPatterns.add(pattern);
      }
    }
    
    // Calculate consistency score (mocked for demo)
    double consistencyScore = 0;
    if (limitExceededDays <= 1) {
      consistencyScore = 80 + random.nextDouble() * 20; // 80-100%
    } else {
      consistencyScore = 50 + random.nextDouble() * 30; // 50-80%
    }
    
    // Determine best day recommendation based on patterns (mocked for demo)
    final bestDayRecommendation = weeklyUsage.indexed
        .where((day) => day.$2.minutesUsed <= dailyLimit) // Only consider days within limit
        .map((day) => dayNames[day.$1])
        .toList()
        .firstOrNull ?? 'Weekday';
    
    return ScreenTimeReport(
      childId: childId,
      weeklyUsage: weeklyUsage,
      totalMinutes: totalMinutes,
      dailyAverage: dailyAverage,
      mostWatchedDay: mostDay,
      mostWatchedDayMinutes: mostMinutes,
      mostWatchedCategories: data.categoryDistribution,
      limitExceededDays: limitExceededDays,
      weekOverWeekChange: weekOverWeekChange,
      attentionSpan: attentionSpan,
      bestTimeOfDay: bestTimeOfDay,
      contentEngagementRatings: contentEngagementRatings,
      learningPatterns: learningPatterns,
      bestDayRecommendation: bestDayRecommendation,
      consistencyScore: consistencyScore,
    );
  }
}

/// Model for a child's usage data
class ChildUsageData {
  final String childId;
  final int dailyLimit;
  UsageDay today;
  final List<UsageDay> weeklyData;
  final Map<String, int> categoryDistribution;
  
  ChildUsageData({
    required this.childId,
    required this.dailyLimit,
    required this.today,
    required this.weeklyData,
    required this.categoryDistribution,
  });
  
  /// Generate demo usage data for a child
  static ChildUsageData generateDemo(Child child) {
    final random = Random();
    final dailyLimit = child.dailyTimeLimit;
    final categories = child.allowedContentCategories;
    
    // Generate random data for the week
    final weeklyData = List.generate(7, (index) {
      // Most days under the limit, but some over
      final minutesUsed = index == 5 || index == 6 
          ? dailyLimit + random.nextInt(30) // Weekend days more likely to exceed
          : (dailyLimit * (0.5 + random.nextDouble() * 0.8)).round();
      
      return UsageDay(
        minutesUsed: minutesUsed,
        contentViewed: {
          'video-${random.nextInt(100)}': random.nextInt(30),
          'video-${random.nextInt(100)}': random.nextInt(20),
          'video-${random.nextInt(100)}': random.nextInt(15),
        },
      );
    });
    
    // Today's usage - random value between 0 and 80% of limit
    final todayMinutes = (dailyLimit * random.nextDouble() * 0.8).round();
    final today = UsageDay(
      minutesUsed: todayMinutes,
      contentViewed: {
        'video-${random.nextInt(100)}': min(todayMinutes, random.nextInt(20)),
        'video-${random.nextInt(100)}': min(todayMinutes, random.nextInt(15)),
      },
    );
    
    // Generate category distribution
    final Map<String, int> categoryDistribution = {};
    for (final category in categories) {
      categoryDistribution[category] = random.nextInt(120) + 30; // 30-150 minutes per category
    }
    
    return ChildUsageData(
      childId: child.id,
      dailyLimit: dailyLimit,
      today: today,
      weeklyData: weeklyData,
      categoryDistribution: categoryDistribution,
    );
  }
}

/// Model for a single day's usage
class UsageDay {
  final int minutesUsed;
  final Map<String, int> contentViewed; // videoId -> minutes
  
  UsageDay({
    required this.minutesUsed,
    required this.contentViewed,
  });
}

/// Model for a screen time report
class ScreenTimeReport {
  final String childId;
  final List<UsageDay> weeklyUsage;
  final int totalMinutes;
  final double dailyAverage;
  final String mostWatchedDay;
  final int mostWatchedDayMinutes;
  final Map<String, int> mostWatchedCategories;
  final int limitExceededDays;
  
  // Enhanced analytics fields
  final double weekOverWeekChange;
  final double attentionSpan;
  final String bestTimeOfDay;
  final Map<String, double> contentEngagementRatings;
  final List<String> learningPatterns;
  final String bestDayRecommendation;
  final double consistencyScore;
  
  ScreenTimeReport({
    required this.childId,
    required this.weeklyUsage,
    required this.totalMinutes,
    required this.dailyAverage,
    required this.mostWatchedDay,
    required this.mostWatchedDayMinutes,
    required this.mostWatchedCategories,
    required this.limitExceededDays,
    required this.weekOverWeekChange,
    required this.attentionSpan,
    required this.bestTimeOfDay,
    required this.contentEngagementRatings,
    required this.learningPatterns,
    required this.bestDayRecommendation,
    required this.consistencyScore,
  });
}