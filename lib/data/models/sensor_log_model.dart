class SensorLogModel {
  final double temp;
  final double humidity;
  final String docId; // Tanggal (2025-12-12)
  final String lastUpdated;

  SensorLogModel({
    required this.temp,
    required this.humidity,
    required this.docId,
    required this.lastUpdated,
  });

  factory SensorLogModel.fromJson(Map<String, dynamic> json) {
    // Handle konversi int ke double jika API mengembalikan angka bulat
    return SensorLogModel(
      temp: (json['temp'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      docId: json['docId'] ?? '',
      lastUpdated: json['lastUpdated'] ?? '',
    );
  }
}
