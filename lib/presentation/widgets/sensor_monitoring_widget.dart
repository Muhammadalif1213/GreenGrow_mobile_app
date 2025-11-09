import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../data/repositories/sensor_repository.dart';
import '../blocs/sensor/sensor_bloc.dart';
import '../blocs/sensor/sensor_event.dart';
import '../blocs/sensor/sensor_state.dart';
import '../../data/local/sync_queue_db.dart';
import '../../data/models/sensor_data_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SensorMonitoringWidget extends StatefulWidget {
  const SensorMonitoringWidget({super.key});

  @override
  State<SensorMonitoringWidget> createState() => _SensorMonitoringWidgetState();
}

class _SensorMonitoringWidgetState extends State<SensorMonitoringWidget> {
  late final SensorBloc _sensorBloc;
  Timer? _timer;
  StreamSubscription<ConnectivityResult>? _connectivitySub;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _sensorBloc =
        SensorBloc(SensorRepository(Dio(), const FlutterSecureStorage()));
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _fetchData());
    _connectivitySub =
        Connectivity().onConnectivityChanged.listen((result) async {
      final online = result != ConnectivityResult.none;
      if (mounted && online != _isOnline) {
        setState(() => _isOnline = online);
        if (online) {
          // Sync queue ke backend saat online
          await SensorRepository(Dio(), const FlutterSecureStorage())
              .syncQueueToBackend();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Koneksi kembali online. Data lokal disinkronkan!')),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Koneksi internet terputus. Mode offline aktif!')),
            );
          }
        }
      }
    });
  }

  void _fetchData() {
    // Ganti event ke FetchAllSensors agar ambil data dari endpoint /api/sensors/
    _sensorBloc.add(FetchAllSensors());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _connectivitySub?.cancel();
    _sensorBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _sensorBloc,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_isOnline ? Icons.wifi : Icons.wifi_off,
                  color: _isOnline ? Colors.green : Colors.red),
              const SizedBox(width: 8),
              Text(_isOnline ? 'Online' : 'Offline',
                  style:
                      TextStyle(color: _isOnline ? Colors.green : Colors.red)),
            ],
          ),
          BlocBuilder<SensorBloc, SensorState>(
            builder: (context, state) {
              if (state is SensorLoading || state is SensorInitial) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is SensorHistoryLoaded) {
                final data =
                    state.history.isNotEmpty ? state.history.first : null;
                if (data == null) return Text('Tidak ada data sensor');
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Suhu: ${data.temperature}°C',
                        style: const TextStyle(fontSize: 18)),
                    Text('Kelembapan: ${data.humidity}%',
                        style: const TextStyle(fontSize: 18)),
                    Text('Status: ${data.status}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('Update: ${data.recordedAt.toLocal()}'),
                  ],
                );
              } else if (state is SensorError) {
                return Text('Error: ${state.message}');
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
