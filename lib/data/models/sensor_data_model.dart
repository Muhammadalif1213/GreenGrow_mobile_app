class ConfigModel {
  final bool automation;
  final bool blower;
  final int maxTemp;

  ConfigModel({
    required this.automation,
    required this.blower,
    required this.maxTemp,
  });

  factory ConfigModel.fromJson(Map<String, dynamic> json) {
    return ConfigModel(
      // ?? false adalah nilai default jika 'automation' null
      automation: json['automation'] ?? false, 
      blower: json['blower'] ?? false,
      // (json['maxTemp'] as num?)?.toInt() ?? 0 
      // adalah cara aman untuk mengambil angka (int)
      maxTemp: (json['maxTemp'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'automation': automation,
      'blower': blower,
      'maxTemp': maxTemp,
    };
  }
}

class SensorDataModel {
  final ConfigModel config;
  final double hic;
  final double humbd; // Perhatikan, namanya 'humbd' bukan 'humidity'
  final double temp;  // Perhatikan, namanya 'temp' bukan 'temperature'

  SensorDataModel({
    required this.config,
    required this.hic,
    required this.humbd,
    required this.temp,
  });

  factory SensorDataModel.fromJson(Map<String, dynamic> json) {
    return SensorDataModel(
      // 1. Panggil factory fromJson dari ConfigModel
      config: ConfigModel.fromJson(json['config'] ?? {}),
      
      // 2. Ambil nilai double dengan aman
      // (json['key'] as num?)?.toDouble() ?? 0.0
      // adalah cara aman untuk mengambil angka (double)
      hic: (json['hic'] as num?)?.toDouble() ?? 0.0,
      humbd: (json['humbd'] as num?)?.toDouble() ?? 0.0,
      temp: (json['temp'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'config': config.toJson(), // Panggil toJson() dari config
      'hic': hic,
      'humbd': humbd,
      'temp': temp,
    };
  }
}