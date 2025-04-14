import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:kidview/data/models/video_model.dart';

/// Service for tracking app analytics events
class AnalyticsService {
  // Singleton pattern
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // Firebase Analytics instance
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  // Enable analytics collection
  Future<void> initialize() async {
    await _analytics.setAnalyticsCollectionEnabled(true);
  }
  
  // Track app open event
  Future<void> logAppOpen() async {
    await _analytics.logAppOpen();
  }
  
  // Track login events
  Future<void> logLogin({required String method}) async {
    await _analytics.logLogin(loginMethod: method);
  }
  
  // Track registration events
  Future<void> logSignUp({required String method}) async {
    await _analytics.logSignUp(signUpMethod: method);
  }
  
  // Track video view events
  Future<void> logVideoView({
    required Video video,
    required String childId,
    int? watchDurationSeconds,
  }) async {
    await _analytics.logEvent(
      name: 'video_view',
      parameters: {
        'video_id': video.id,
        'video_title': video.title,
        'video_category': video.categories.isNotEmpty ? video.categories.first : 'unknown',
        'video_age_rating': video.ageRating,
        'child_id': childId,
        'educational_value': video.educationalTags.isNotEmpty ? video.educationalTags.first.name : 'unknown',
        if (watchDurationSeconds != null) 'duration_seconds': watchDurationSeconds,
      },
    );
  }
  
  // Track content search events
  Future<void> logSearch({required String searchTerm, required String childId}) async {
    await _analytics.logSearch(searchTerm: searchTerm);
    
    // Add custom parameters
    await _analytics.logEvent(
      name: 'child_search',
      parameters: {
        'search_term': searchTerm,
        'child_id': childId,
      },
    );
  }
  
  // Track screen time events
  Future<void> logScreenTime({
    required String childId,
    required int minutesUsed,
    required String contentType,
  }) async {
    await _analytics.logEvent(
      name: 'screen_time',
      parameters: {
        'child_id': childId,
        'minutes_used': minutesUsed,
        'content_type': contentType,
      },
    );
  }
  
  // Track parental control changes
  Future<void> logParentalControlChange({
    required String childId,
    required String controlType,
    required String changeDescription,
  }) async {
    await _analytics.logEvent(
      name: 'parental_control_change',
      parameters: {
        'child_id': childId,
        'control_type': controlType,
        'change_description': changeDescription,
      },
    );
  }
  
  // Track feature usage
  Future<void> logFeatureUse({
    required String featureName,
    required String userId,
    required bool isParent,
    Map<String, dynamic>? additionalParams,
  }) async {
    final Map<String, Object> params = {
      'feature_name': featureName,
      'user_id': userId,
      'is_parent': isParent,
    };
    
    if (additionalParams != null) {
      additionalParams.forEach((key, value) {
        if (value != null) {
          params[key] = value.toString();
        }
      });
    }
    
    await _analytics.logEvent(
      name: 'feature_use',
      parameters: params,
    );
  }
  
  // Track content preferences
  Future<void> logContentPreference({
    required String childId,
    required String contentCategory,
    required String action, // 'like', 'dislike', 'favorite'
    String? contentId,
  }) async {
    await _analytics.logEvent(
      name: 'content_preference',
      parameters: {
        'child_id': childId,
        'content_category': contentCategory,
        'action': action,
        if (contentId != null) 'content_id': contentId,
      },
    );
  }
  
  // Track child profile updates
  Future<void> logChildProfileUpdate({
    required String childId,
    required String updateType,
    required String parentId,
  }) async {
    await _analytics.logEvent(
      name: 'child_profile_update',
      parameters: {
        'child_id': childId,
        'update_type': updateType,
        'parent_id': parentId,
      },
    );
  }
  
  // Set user properties for better segmentation
  Future<void> setUserProperties({
    required String userId,
    required bool isParent,
    String? childAgeGroup,
    List<String>? contentPreferences,
  }) async {
    // Set user ID for analytics
    await _analytics.setUserId(id: userId);
    
    // Set user properties
    await _analytics.setUserProperty(name: 'is_parent', value: isParent.toString());
    
    if (childAgeGroup != null) {
      await _analytics.setUserProperty(name: 'child_age_group', value: childAgeGroup);
    }
    
    if (contentPreferences != null && contentPreferences.isNotEmpty) {
      await _analytics.setUserProperty(
        name: 'content_preferences',
        value: contentPreferences.join(','),
      );
    }
  }
}