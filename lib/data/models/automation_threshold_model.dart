class AutomationThresholdModel {
  final int id;
  final String parameter;
  final String deviceType;
  final double? minValue;
  final double? maxValue;

  AutomationThresholdModel({
    required this.id,
    required this.parameter,
    required this.deviceType,
    this.minValue,
    this.maxValue,
  });

  factory AutomationThresholdModel.fromJson(Map<String, dynamic> json) {
    return AutomationThresholdModel(
      id: json['id'],
      parameter: json['parameter'],
      deviceType: json['device_type'],
      minValue: json['min_value'] != null ? double.tryParse(json['min_value'].toString()) : null,
      maxValue: json['max_value'] != null ? double.tryParse(json['max_value'].toString()) : null,
    );
  }
} 