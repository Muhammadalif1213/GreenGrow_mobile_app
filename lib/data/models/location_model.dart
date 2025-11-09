class LocationModel {
  final int id;
  final int greenhouseId;
  final String name;
  final double latitude;
  final double longitude;
  final String address;
  final String greenhouseName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? distance; // Optional, only present in nearby search

  LocationModel({
    required this.id,
    required this.greenhouseId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.greenhouseName,
    required this.createdAt,
    required this.updatedAt,
    this.distance,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'],
      greenhouseId: json['greenhouse_id'],
      name: json['name'],
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      address: json['address'],
      greenhouseName: json['greenhouse_name'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      distance: json['distance']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'greenhouse_id': greenhouseId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'greenhouse_name': greenhouseName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (distance != null) 'distance': distance,
    };
  }
} 