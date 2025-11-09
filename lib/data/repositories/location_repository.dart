import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/location_model.dart';

class LocationRepository {
  final Dio dio;
  final FlutterSecureStorage storage;
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  LocationRepository(this.dio, this.storage);

  Future<List<LocationModel>> getAllLocations() async {
    final token = await storage.read(key: 'auth_token');
    final response = await dio.get(
      '$_baseUrl/locations',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (response.data['data'] as List)
        .map((e) => LocationModel.fromJson(e))
        .toList();
  }

  Future<List<LocationModel>> getNearbyLocations({
    required double latitude,
    required double longitude,
    double radius = 10,
  }) async {
    final token = await storage.read(key: 'auth_token');
    final response = await dio.get(
      '$_baseUrl/locations/nearby',
      queryParameters: {
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
      },
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (response.data['data'] as List)
        .map((e) => LocationModel.fromJson(e))
        .toList();
  }

  Future<LocationModel> getLocationById(int id) async {
    final token = await storage.read(key: 'auth_token');
    final response = await dio.get(
      '$_baseUrl/locations/$id',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return LocationModel.fromJson(response.data['data']);
  }

  Future<List<LocationModel>> getLocationsByGreenhouseId(int greenhouseId) async {
    final token = await storage.read(key: 'auth_token');
    final response = await dio.get(
      '$_baseUrl/locations/greenhouse/$greenhouseId',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return (response.data['data'] as List)
        .map((e) => LocationModel.fromJson(e))
        .toList();
  }
} 