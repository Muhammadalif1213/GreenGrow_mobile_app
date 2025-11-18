import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greengrow_app/core/config/api_config.dart';
import 'package:greengrow_app/data/repositories/device_control_repository.dart';
import 'package:greengrow_app/presentation/blocs/device_control/device_control_bloc.dart';
// 1. IMPORT DITAMBAHKAN:
import 'package:greengrow_app/presentation/blocs/sensor/sensor_state.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

import '../../../data/repositories/sensor_repository.dart';
import '../../blocs/sensor/sensor_bloc.dart';
import '../../blocs/sensor/sensor_event.dart';
import 'admin_control_screen.dart';
import 'admin_settings_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../data/models/activity_log_model.dart';
import '../../../data/repositories/activity_repository.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  late final SensorBloc _sensorBloc;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _sensorBloc =
        SensorBloc(SensorRepository(Dio(), const FlutterSecureStorage()));

    _fetchData();

    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchData());
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

  void _onTabTapped(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 1) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => AdminControlScreen()));
    } else if (index == 2) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => AdminSettingsScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: SafeArea(child: _buildTabContent(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
        selectedItemColor: const Color(0xFF2ECC71),
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF1A1F2E),
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings_input_component), label: 'Control'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildTabContent(int index) {
    return _buildDashboardTab();
  }

  Widget _buildDashboardTab() {
    return BlocProvider.value(
      value: _sensorBloc,
      child: RefreshIndicator(
        onRefresh: () async {
          _fetchData();
          // Anda juga bisa refresh BLoC kedua saat pull-to-refresh
          // context.read<DeviceControlBloc>().add(DeviceControlFetchStatus());
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildStatusCards(),
              const SizedBox(height: 20),
              _buildQuickStats(),
              const SizedBox(height: 20),
              // _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Admin Dashboard',
            style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Text('GreenGrow Greenhouse Control',
            style: TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  Widget _buildStatusCards() {
    return BlocBuilder<SensorBloc, SensorState>(
      builder: (context, state) {
        if (state is SensorLoading || state is SensorInitial) {
          // Tampilkan loading skeleton
          return Row(
            children: [
              Expanded(
                  child:
                      _buildSensorCardSkeleton(color: const Color(0xFF2ECC71))),
              const SizedBox(width: 15),
              Expanded(
                  child:
                      _buildSensorCardSkeleton(color: const Color(0xFF3498DB))),
            ],
          );
        } else if (state is SensorLoaded) {
          final data = state.sensorData;
          return Row(
            children: [
              Expanded(
                  child: _buildSensorCard(
                      title: 'Temperature',
                      value: '${data.temp.toStringAsFixed(1)}°C',
                      icon: Icons.thermostat,
                      color: const Color(0xFF2ECC71))),
              const SizedBox(width: 15),
              Expanded(
                  child: _buildSensorCard(
                      title: 'Humidity',
                      value: '${data.humbd.toStringAsFixed(1)}%',
                      icon: Icons.water_drop,
                      color: const Color(0xFF3498DB))),
            ],
          );
        } else if (state is SensorError) {
          return Center(
              child: Text(state.message,
                  style: const TextStyle(color: Colors.red)));
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildSensorCard(
      {required String title,
      required String value,
      required IconData icon,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24))
          ]),
          const SizedBox(height: 15),
          Text(title,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7), fontSize: 14)),
          const SizedBox(height: 5),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // Widget skeleton untuk loading
  Widget _buildSensorCardSkeleton({required Color color}) {
    return Container(
      height: 160, // Sesuaikan tinggi dengan card asli
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12)),
                child:
                    Icon(Icons.circle, color: color.withOpacity(0.5), size: 24))
          ]),
          const SizedBox(height: 15),
          Container(height: 14, width: 80, color: Colors.grey.withOpacity(0.2)),
          const SizedBox(height: 5),
          Container(
              height: 24, width: 100, color: Colors.grey.withOpacity(0.2)),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return BlocProvider(
      create: (_) => DeviceControlBloc(
        DeviceControlRepository(Dio(), const FlutterSecureStorage()),
      )
        // 2. PERBAIKAN: Panggil event saat BLoC dibuat
        ..add(DeviceControlFetchStatus()),
      child: BlocBuilder<DeviceControlBloc, DeviceControlState>(
        builder: (context, state) {
          if (state is DeviceControlLoading || state is DeviceControlInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DeviceControlStatus) {
            final isBlowerOn = state.blowerOn;
            final isAutomationOn = state.isAutomationEnabled;
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: const Color(0xFF1A1F2E),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.1))),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('System Status',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatusItem('Blower', isBlowerOn, Icons.air),
                      _buildStatusItem(
                          'Auto Mode', isAutomationOn, Icons.auto_mode),
                    ],
                  ),
                ],
              ),
            );
          } else if (state is DeviceControlError) {
            return Center(
                child: Text(state.message,
                    style: const TextStyle(color: Colors.red)));
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Widget _buildStatusItem(String title, bool isActive, IconData icon) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF2ECC71).withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
                color: isActive ? const Color(0xFF2ECC71) : Colors.grey,
                width: 2),
          ),
          child: Icon(icon,
              color: isActive ? const Color(0xFF2ECC71) : Colors.grey,
              size: 24),
        ),
        const SizedBox(height: 8),
        Text(title,
            style:
                TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
        const SizedBox(height: 4),
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
                color: isActive ? const Color(0xFF2ECC71) : Colors.grey,
                borderRadius: BorderRadius.circular(4))),
      ],
    );
  }

  // ... (Sisa kode activity Anda)
  Widget _buildActivityItem(ActivityLog activity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10)),
              child:
                  const Icon(Icons.event, color: Color(0xFF2ECC71), size: 20)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.activityType,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 4),
                Text(activity.description,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 12)),
                const SizedBox(height: 4),
                Text(_formatActivityTime(activity.createdAt),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5), fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatActivityTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} minutes ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }
}
