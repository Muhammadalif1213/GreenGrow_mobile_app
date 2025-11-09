class SensorTrend {
  final DateTime date;
  final double avg;

  SensorTrend({
    required this.date,
    required this.avg,
  });

  factory SensorTrend.fromJson(Map<String, dynamic> json) {
    // Mencoba parse date dengan lebih fleksibel
    DateTime parseDate(dynamic dateValue) {
      if (dateValue is String) {
        try {
          // Coba parse format ISO datetime
          return DateTime.parse(dateValue);
        } catch (e) {
          // Jika format bukan ISO, coba format yang lebih sederhana
          try {
            // Asumsi format date saja (YYYY-MM-DD)
            final parts = dateValue.split('-');
            if (parts.length == 3) {
              return DateTime(int.parse(parts[0]), int.parse(parts[1]),
                  int.parse(parts[2]));
            }
          } catch (_) {}

          // Jika masih gagal, gunakan datetime saat ini
          return DateTime.now();
        }
      } else if (dateValue is DateTime) {
        return dateValue;
      } else {
        return DateTime.now();
      }
    }

    // Handling nilai avg dengan lebih fleksibel
    double parseAvg(dynamic avgValue) {
      if (avgValue is num) {
        return avgValue.toDouble();
      } else if (avgValue is String) {
        try {
          return double.parse(avgValue);
        } catch (_) {
          return 0.0;
        }
      } else {
        return 0.0;
      }
    }

    return SensorTrend(
      date: parseDate(json['date']),
      avg: parseAvg(json['avg']),
    );
  }
}
