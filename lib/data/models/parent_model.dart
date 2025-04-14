class Parent {
  final String id;
  final String email;
  final String displayName;
  final List<Child> children;
  final ParentalControls controls;

  Parent({
    required this.id,
    required this.email,
    required this.displayName,
    required this.children,
    required this.controls,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      id: json['id'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      children: (json['children'] as List<dynamic>)
          .map((childJson) => Child.fromJson(childJson as Map<String, dynamic>))
          .toList(),
      controls: ParentalControls.fromJson(json['controls'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'children': children.map((child) => child.toJson()).toList(),
      'controls': controls.toJson(),
    };
  }
}

class Child {
  final String id;
  final String name;
  final String avatarUrl;
  final String ageGroup; // 'younger' (4-7) or 'older' (8-12)
  final List<String> allowedContentCategories;
  final int dailyTimeLimit; // in minutes
  final List<String> watchHistory;
  final List<String> favorites;
  final List<String> specialInterests; // New field for special interests
  final Map<String, int> contentDistribution; // Distribution percentages for different content types
  final Map<String, List<String>> contentTags; // Multi-dimensional tagging system

  Child({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.ageGroup,
    required this.allowedContentCategories,
    required this.dailyTimeLimit,
    required this.watchHistory,
    required this.favorites,
    this.specialInterests = const [], // Default to empty list
    this.contentDistribution = const {}, // Default to empty map
    this.contentTags = const {}, // Default to empty map
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatarUrl'] as String,
      ageGroup: json['ageGroup'] as String,
      allowedContentCategories: (json['allowedContentCategories'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      dailyTimeLimit: json['dailyTimeLimit'] as int,
      watchHistory: (json['watchHistory'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      favorites: (json['favorites'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      specialInterests: json.containsKey('specialInterests') 
          ? (json['specialInterests'] as List<dynamic>).map((e) => e as String).toList() 
          : [],
      contentDistribution: json.containsKey('contentDistribution') 
          ? (json['contentDistribution'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(key, value as int)) 
          : {},
      contentTags: json.containsKey('contentTags') 
          ? (json['contentTags'] as Map<String, dynamic>).map(
              (key, value) => MapEntry(
                key, 
                (value as List<dynamic>).map((e) => e as String).toList()
              )
            ) 
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatarUrl': avatarUrl,
      'ageGroup': ageGroup,
      'allowedContentCategories': allowedContentCategories,
      'dailyTimeLimit': dailyTimeLimit,
      'watchHistory': watchHistory,
      'favorites': favorites,
      'specialInterests': specialInterests,
      'contentDistribution': contentDistribution,
      'contentTags': contentTags,
    };
  }
}

class ParentalControls {
  final bool pinProtected;
  final String pin;
  final bool allowDownloads;
  final bool preventAppSwitching;
  final List<TimeRange> scheduledViewingTimes;
  final Map<String, bool> contentFilters;

  ParentalControls({
    required this.pinProtected,
    required this.pin,
    required this.allowDownloads,
    required this.preventAppSwitching,
    required this.scheduledViewingTimes,
    required this.contentFilters,
  });

  factory ParentalControls.fromJson(Map<String, dynamic> json) {
    return ParentalControls(
      pinProtected: json['pinProtected'] as bool,
      pin: json['pin'] as String,
      allowDownloads: json['allowDownloads'] as bool,
      preventAppSwitching: json['preventAppSwitching'] as bool,
      scheduledViewingTimes: (json['scheduledViewingTimes'] as List<dynamic>)
          .map((e) => TimeRange.fromJson(e as Map<String, dynamic>))
          .toList(),
      contentFilters: (json['contentFilters'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(key, value as bool)),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pinProtected': pinProtected,
      'pin': pin,
      'allowDownloads': allowDownloads,
      'preventAppSwitching': preventAppSwitching,
      'scheduledViewingTimes': scheduledViewingTimes.map((time) => time.toJson()).toList(),
      'contentFilters': contentFilters,
    };
  }
}

class TimeRange {
  final String dayOfWeek; // Monday, Tuesday, etc.
  final String startTime; // HH:MM format
  final String endTime; // HH:MM format

  TimeRange({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });

  factory TimeRange.fromJson(Map<String, dynamic> json) {
    return TimeRange(
      dayOfWeek: json['dayOfWeek'] as String,
      startTime: json['startTime'] as String,
      endTime: json['endTime'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
    };
  }
}