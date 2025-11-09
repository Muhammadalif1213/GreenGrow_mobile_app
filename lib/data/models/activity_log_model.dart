class ActivityLog {
  final int id;
  final String activityType;
  final String description;
  final String? photoUrl;
  final DateTime createdAt;

  ActivityLog({
    required this.id,
    required this.activityType,
    required this.description,
    this.photoUrl,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'],
      activityType: json['activity_type'],
      description: json['description'] ?? '',
      photoUrl: json['photo_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
} 