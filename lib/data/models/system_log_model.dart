class SystemLog {
  final String action;
  final DateTime timestamp;
  final LogActor actor;
  final LogPayload? payload;

  SystemLog({
    required this.action,
    required this.timestamp,
    required this.actor,
    this.payload,
  });

  factory SystemLog.fromJson(Map<String, dynamic> json) {
    return SystemLog(
      action: json['action'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      actor: LogActor.fromJson(json['actor'] ?? {}),
      payload: json['payload'] != null ? LogPayload.fromJson(json['payload']) : null,
    );
  }
}

class LogActor {
  final String name;
  final String role;
  final String email;

  LogActor({required this.name, required this.role, required this.email});

  factory LogActor.fromJson(Map<String, dynamic> json) {
    return LogActor(
      name: json['name'] ?? 'System/Unknown',
      role: json['role'] ?? '-',
      email: json['email'] ?? '-',
    );
  }
}

class LogPayload {
  final String name;
  final String email;

  LogPayload({required this.name, required this.email});

  factory LogPayload.fromJson(Map<String, dynamic> json) {
    return LogPayload(
      name: json['name'] ?? 'Unknown User',
      email: json['email'] ?? '-',
    );
  }
}