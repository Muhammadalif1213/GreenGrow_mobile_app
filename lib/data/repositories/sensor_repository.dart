import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/sensor_data_model.dart';
import '../local/sensor_local_db.dart';
import '../local/sync_queue_db.dart';
import '../../domain/models/sensor_trend.dart';

class SensorRepository {
  final Dio dio;
  final FlutterSecureStorage? storage;
  static const String _baseUrl = 'http://10.0.2.2:3000/api';

  SensorRepository(this.dio, [this.storage]);

  Future<SensorDataModel> getLatestSensorData({required String token}) async {
    final response = await dio.get(
      '$_baseUrl/sensors/latest',
      options: Options(headers: {'Authorization': 'Bearer $token'}),
    );
    return SensorDataModel.fromJson(response.data['data']);
  }

  Future<List<SensorDataModel>> getSensorHistory(
      {String? start, String? end, int? limit, String? groupBy}) async {
    final token = await storage?.read(key: 'auth_token');
    final queryParams = <String, dynamic>{};
    if (start != null) queryParams['start_date'] = start;
    if (end != null) queryParams['end_date'] = end;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (groupBy != null) queryParams['group_by'] = groupBy;

    try {
      print('Fetching sensor history with params: $queryParams');
      print('API URL: $_baseUrl/sensor');
      print('Token: $token');

      final response = await dio.get(
        '$_baseUrl/sensor',
        queryParameters: queryParams,
        options: token != null
            ? Options(headers: {'Authorization': 'Bearer $token'})
            : null,
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      if (response.data['status'] == 'success') {
        final List<dynamic> data = response.data['data'] as List;
        print('Data length: ${data.length}');

        if (data.isEmpty) {
          print('No data returned from API');
          return [];
        }

        // Handle different response formats based on groupBy
        if (groupBy != null) {
          // For aggregated data
          return data.map((item) {
            try {
              // Create a SensorDataModel from aggregated data
              // The keys might be different based on the groupBy parameter
              Map<String, dynamic> sensorData = {
                'id': 0, // Use a placeholder ID
                'temperature':
                    double.parse((item['avg_temperature'] ?? 0.0).toString()),
                'humidity':
                    double.parse((item['avg_humidity'] ?? 0.0).toString()),
                'status': 'Aggregated', // Use a placeholder status
              };

              // Handle different date formats based on groupBy
              DateTime recordedAt;
              switch (groupBy) {
                case 'hour':
                  recordedAt = DateTime.parse(
                      '${item['date']} ${item['hour'].toString().padLeft(2, '0')}:00:00');
                  break;
                case 'day':
                  recordedAt = DateTime.parse('${item['date']} 00:00:00');
                  break;
                case 'week':
                  // For week, we use year and week number
                  // This is an approximation as exact date calculation from week number is complex
                  recordedAt = DateTime(item['year'], 1, 1)
                      .add(Duration(days: (item['week'] - 1) * 7));
                  break;
                case 'month':
                  recordedAt = DateTime(item['year'], item['month'], 1);
                  break;
                case 'year':
                  recordedAt = DateTime(item['year'], 1, 1);
                  break;
                default:
                  // Fallback to current time if format is unknown
                  recordedAt = DateTime.now();
              }

              sensorData['recorded_at'] = recordedAt.toIso8601String();
              return SensorDataModel.fromJson(sensorData);
            } catch (e) {
              print('Error parsing aggregated data: $e for item: $item');
              // Return a placeholder model in case of parsing error
              return SensorDataModel(
                id: 0,
                temperature: 0,
                humidity: 0,
                status: 'Error',
                recordedAt: DateTime.now(),
              );
            }
          }).toList();
        } else {
          // For raw data
          return data.map((e) {
            try {
              return SensorDataModel.fromJson(e);
            } catch (e) {
              print('Error parsing sensor data: $e for item: $e');
              // Return a placeholder model in case of parsing error
              return SensorDataModel(
                id: 0,
                temperature: 0,
                humidity: 0,
                status: 'Error',
                recordedAt: DateTime.now(),
              );
            }
          }).toList();
        }
      } else {
        print('API returned error: ${response.data['message']}');
        // Return empty list if API returns an error
        throw Exception(
            'API error: ${response.data['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error fetching sensor history: $e');
      // Propagate the error instead of returning dummy data
      throw Exception('Failed to fetch sensor data: $e');
    }
  }

  Future<SensorDataModel> getLatestSensorDataWithCache({required String token}) async {
    try {
      final data = await getLatestSensorData(token: token);
      await SensorLocalDb.insertSensorData(data);
      return data;
    } catch (_) {
      final local = await SensorLocalDb.getAllSensorData();
      if (local.isNotEmpty) return local.first;
      rethrow;
    }
  }

  Future<List<SensorDataModel>> getSensorHistoryWithCache({
    String? start,
    String? end,
    int? limit,
    String? groupBy,
  }) async {
    try {
      final history = await getSensorHistory(
        start: start,
        end: end,
        limit: limit,
        groupBy: groupBy,
      );

      // Only cache raw data, not aggregated data
      if (groupBy == null) {
        for (final d in history) {
          await SensorLocalDb.insertSensorData(d);
        }
      }

      return history;
    } catch (_) {
      // If we're requesting aggregated data but the API call fails,
      // we can't properly aggregate from local cache, so just return raw data
      return await SensorLocalDb.getAllSensorData();
    }
  }

  Future<void> syncQueueToBackend() async {
    final queue = await SyncQueueDb.getQueue();
    for (final data in queue) {
      try {
        await dio.post(
          '$_baseUrl/sensor',
          data: {
            'temperature': data.temperature,
            'humidity': data.humidity,
            'status': data.status,
            'recorded_at': data.recordedAt.toIso8601String(),
          },
        );
      } catch (_) {
        // Jika gagal, biarkan tetap di queue
        return;
      }
    }
    await SyncQueueDb.clearQueue();
  }

  Future<List<SensorTrend>> fetchTrend({
    required String type, // 'temperature' atau 'humidity'
    String range = 'week',
  }) async {
    try {
      final token = await storage?.read(key: 'auth_token');
      final response = await dio.get(
        '$_baseUrl/sensors/trends', // Diperbaiki dari /sensor/trends menjadi /sensors/trends
        queryParameters: {
          'type': type,
          'range': range,
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      // Tambahkan logging untuk debug
      print('Response trend data: ${response.data}');

      if (response.data['status'] == 'success') {
        final data = response.data['data'] as List;
        return data.map((e) => SensorTrend.fromJson(e)).toList();
      } else {
        throw Exception('API error: ${response.data['message']}');
      }
    } catch (e) {
      print('Error fetching trend data: $e');
      rethrow;
    }
  }

  // Helper untuk ambil dua tren sekaligus
  Future<Map<String, List<SensorTrend>>> fetchTemperatureAndHumidityTrends(
      {String range = 'week'}) async {
    try {
      final temp = await fetchTrend(type: 'temperature', range: range);
      final hum = await fetchTrend(type: 'humidity', range: range);
      return {'temperature': temp, 'humidity': hum};
    } catch (e) {
      print('Error in fetchTemperatureAndHumidityTrends: $e');
      rethrow;
    }
  }

  // Mendapatkan semua data sensor dari endpoint GET /api/sensors/
  Future<List<SensorDataModel>> getAllSensors() async {
    final token = await storage?.read(key: 'auth_token');
    final url = '$_baseUrl/sensors/';
    print('Requesting: ' + url + ' with token: ' + (token ?? 'NO TOKEN'));
    final response = await dio.get(
      url,
      options: token != null
          ? Options(headers: {'Authorization': 'Bearer $token'})
          : null,
    );
    print('Response status: ' + response.statusCode.toString());
    print('Response data: ' + response.data.toString());
    return (response.data['data'] as List)
        .map((e) => SensorDataModel.fromJson(e))
        .toList();
  }
}
