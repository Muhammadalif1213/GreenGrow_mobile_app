import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../data/repositories/sensor_repository.dart';
import '../../widgets/sensor_trend_chart.dart';
import '../../../domain/models/sensor_trend.dart';

class SensorTrendScreen extends StatefulWidget {
  const SensorTrendScreen({super.key});

  @override
  State<SensorTrendScreen> createState() => _SensorTrendScreenState();
}

class _SensorTrendScreenState extends State<SensorTrendScreen> {
  late final SensorRepository repository;
  bool isLoading = true;
  String? error;
  List<SensorTrend> temperatureData = [];
  List<SensorTrend> humidityData = [];
  String range = 'week';

  @override
  void initState() {
    super.initState();
    repository = SensorRepository(Dio(), const FlutterSecureStorage());
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final result =
          await repository.fetchTemperatureAndHumidityTrends(range: range);
      setState(() {
        temperatureData = result['temperature'] ?? [];
        humidityData = result['humidity'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      print('Error in sensor_trend_screen: $e');
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grafik Tren Suhu & Kelembapan'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) {
              setState(() {
                range = val;
              });
              fetchData();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'week', child: Text('Mingguan')),
              const PopupMenuItem(value: 'month', child: Text('Bulanan')),
            ],
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $error', textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchData,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : temperatureData.isEmpty && humidityData.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada data tersedia.\nPastikan Anda telah menambahkan data sensor.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchData,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        child: SensorTrendChart(
                          temperatureData: temperatureData,
                          humidityData: humidityData,
                          isWeekly: range == 'week',
                        ),
                      ),
                    ),
    );
  }
}
