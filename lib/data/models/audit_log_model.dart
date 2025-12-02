class AuditUserModel {
  final String email;
  final String name;
  final String role;
  final String username;

  AuditUserModel({
    required this.email,
    required this.name,
    required this.role,
    required this.username,
  });

  factory AuditUserModel.fromJson(Map<String, dynamic> json) {
    return AuditUserModel(
      email: json['email'] ?? '',
      name: json['name'] ?? 'Unknown',
      role: json['role'] ?? '',
      username: json['username'] ?? '',
    );
  }
}

class AuditLogModel {
  final String action;
  final dynamic newValue; // Bisa int, bool, atau string
  final String userId;
  final DateTime timestamp;
  final AuditUserModel user;

  AuditLogModel({
    required this.action,
    required this.newValue,
    required this.userId,
    required this.timestamp,
    required this.user,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json) {
    return AuditLogModel(
      action: json['action'] ?? '',
      newValue: json['newValue'], 
      userId: json['userId'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      user: AuditUserModel.fromJson(json['user'] ?? {}),
    );
  }
}