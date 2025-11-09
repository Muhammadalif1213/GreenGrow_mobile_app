class SensorDataModel {
  final int id;
  final double temperature;
  final double humidity;
  final String status;
  final DateTime recordedAt;

  SensorDataModel({
    required this.id,
    required this.temperature,
    required this.humidity,
    required this.status,
    required this.recordedAt,
  });

  factory SensorDataModel.fromJson(Map<String, dynamic> json) {
    return SensorDataModel(
      id: json['id'],
      temperature: double.parse(json['temperature'].toString()),
      humidity: double.parse(json['humidity'].toString()),
      status: json['status'],
      recordedAt: DateTime.parse(json['recorded_at']),
    );
  }
} 