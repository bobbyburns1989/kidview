class Video {
  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String videoUrl;
  final String creatorId;
  final String creatorName;
  final List<String> categories;
  final List<String> tags;
  final String ageRating; // 'younger', 'older', 'all'
  final int duration; // in seconds
  final DateTime uploadDate;
  final int viewCount;
  final double rating;
  final List<EducationalTag> educationalTags;
  final bool isDownloadable;
  final bool isApprovedByKidView;

  Video({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.videoUrl,
    required this.creatorId,
    required this.creatorName,
    required this.categories,
    required this.tags,
    required this.ageRating,
    required this.duration,
    required this.uploadDate,
    required this.viewCount,
    required this.rating,
    required this.educationalTags,
    required this.isDownloadable,
    required this.isApprovedByKidView,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      videoUrl: json['videoUrl'] as String,
      creatorId: json['creatorId'] as String,
      creatorName: json['creatorName'] as String,
      categories: (json['categories'] as List<dynamic>).map((e) => e as String).toList(),
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      ageRating: json['ageRating'] as String,
      duration: json['duration'] as int,
      uploadDate: DateTime.parse(json['uploadDate'] as String),
      viewCount: json['viewCount'] as int,
      rating: (json['rating'] as num).toDouble(),
      educationalTags: (json['educationalTags'] as List<dynamic>)
          .map((e) => EducationalTag.fromJson(e as Map<String, dynamic>))
          .toList(),
      isDownloadable: json['isDownloadable'] as bool,
      isApprovedByKidView: json['isApprovedByKidView'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnailUrl': thumbnailUrl,
      'videoUrl': videoUrl,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'categories': categories,
      'tags': tags,
      'ageRating': ageRating,
      'duration': duration,
      'uploadDate': uploadDate.toIso8601String(),
      'viewCount': viewCount,
      'rating': rating,
      'educationalTags': educationalTags.map((tag) => tag.toJson()).toList(),
      'isDownloadable': isDownloadable,
      'isApprovedByKidView': isApprovedByKidView,
    };
  }
}

class EducationalTag {
  final String name;
  final String subject; // math, science, language, arts, etc.
  final String skill; // specific skill being taught/reinforced
  final int ageMin;
  final int ageMax;

  EducationalTag({
    required this.name,
    required this.subject,
    required this.skill,
    required this.ageMin,
    required this.ageMax,
  });

  factory EducationalTag.fromJson(Map<String, dynamic> json) {
    return EducationalTag(
      name: json['name'] as String,
      subject: json['subject'] as String,
      skill: json['skill'] as String,
      ageMin: json['ageMin'] as int,
      ageMax: json['ageMax'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'subject': subject,
      'skill': skill,
      'ageMin': ageMin,
      'ageMax': ageMax,
    };
  }
}