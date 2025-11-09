class ActivityLog {
  final int id;
  final int greenhouseId;
  final String activityType;
  final String description;
  final String? photoPath;
  final String userName;
  final DateTime createdAt;

  ActivityLog({
    required this.id,
    required this.greenhouseId,
    required this.activityType,
    required this.description,
    this.photoPath,
    required this.userName,
    required this.createdAt,
  });

  factory ActivityLog.fromJson(Map<String, dynamic> json) {
    return ActivityLog(
      id: json['id'],
      greenhouseId: json['greenhouse_id'],
      activityType: json['activity_type'],
      description: json['description'],
      photoPath: json['photo_path'],
      userName: json['user_name'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'greenhouse_id': greenhouseId,
      'activity_type': activityType,
      'description': description,
      'photo_path': photoPath,
      'user_name': userName,
      'created_at': createdAt.toIso8601String(),
    };
  }
} 