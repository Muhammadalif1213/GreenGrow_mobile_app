import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/repositories/sensor_repository.dart';
import '../blocs/sensor/sensor_bloc.dart';
import '../blocs/sensor/sensor_event.dart';
import '../blocs/sensor/sensor_state.dart';
// import '../../data/local/sync_queue_db.dart'; // Hapus jika syncQueueToBackend ada di repo
// import '../../data/models/sensor_data_model.dart'; // Diimpor oleh state
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SensorMonitoringWidget extends StatefulWidget {
  const SensorMonitoringWidget({super.key});

  @override
  State<SensorMonitoringWidget> createState() => _SensorMonitoringWidgetState();
}

class _SensorMonitoringWidgetState extends State<SensorMonitoringWidget> {
  late final SensorBloc _sensorBloc;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // 1. Buat BLoC
    _sensorBloc =
        SensorBloc(SensorRepository(Dio(), const FlutterSecureStorage()));

    // 2. Panggil event yang benar
    _fetchData();

    // 3. Set timer untuk refresh
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _fetchData());
  }

  void _fetchData() {
    _sensorBloc.add(FetchLatestSensorData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sensorBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Kita gunakan BlocProvider di sini karena widget ini membuat BLoC-nya sendiri
    return BlocProvider.value(
      value: _sensorBloc,
      child: BlocBuilder<SensorBloc, SensorState>(
        builder: (context, state) {
          if (state is SensorLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          // 4. Dengarkan state yang benar
          else if (state is SensorLoaded) {
            // 5. Ambil data tunggal dari state
            final data = state.sensorData;

            // 6. Tampilkan data dari model BARU
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Suhu: ${data.temp.toStringAsFixed(1)}°C',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Kelembapan: ${data.humbd.toStringAsFixed(1)}%',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Otomatis: ${data.config.automation ? "ON" : "OFF"}',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            );
          } else if (state is SensorError) {
            return Text('Error Sensor: ${state.message}');
          }
          return const Text('Memuat data sensor...');
        },
      ),
    );
  }
}
