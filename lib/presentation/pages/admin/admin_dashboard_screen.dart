import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

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

  bool isLoading = true;
  double temperature = 0.0;
  double humidity = 0.0;
  String blowerStatus = 'OFF';
  String sprayerStatus = 'OFF';
  bool isAutomationOn = false;
  List<ActivityLog> recentActivities = [];
  String sensorStatus = '-';
  String error = '';
  Timer? _refreshTimer;
  final String baseUrl = 'http://10.0.2.2:3000';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchAllData();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Pastikan currentIndex tidak out of range
    if (_selectedIndex > 2) {
      setState(() {
        _selectedIndex = 0;
      });
    }
  }

  Future<void> _fetchAllData() async {
    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;

      if (token == null) {
        setState(() {
          error = 'Token tidak ditemukan. Silakan login ulang.';
          isLoading = false;
        });
        return;
      }

      final headers = {'Authorization': 'Bearer $token'};

      // Ambil sensor terbaru dari /api/sensors/
      final sensorResp = await http.get(Uri.parse('$baseUrl/api/sensors/'), headers: headers);
      if (sensorResp.statusCode == 200) {
        final data = json.decode(sensorResp.body);
        final sensors = data['data'];
        if (sensors is List && sensors.isNotEmpty) {
          final latest = sensors[0];
          temperature = latest['temperature'] != null ? double.tryParse(latest['temperature'].toString()) ?? 0.0 : 0.0;
          humidity = latest['humidity'] != null ? double.tryParse(latest['humidity'].toString()) ?? 0.0 : 0.0;
          sensorStatus = latest['status'] ?? '-';
        }
      } else {
        throw Exception('Gagal ambil data sensor, status: ${sensorResp.statusCode}');
      }

      // Ambil status automation
      final autoResp = await http.get(Uri.parse('$baseUrl/api/sensors/automation/status'), headers: headers);
      if (autoResp.statusCode == 200) {
        final autoData = json.decode(autoResp.body);
        final automationData = autoData['data'] ?? autoData;
        blowerStatus = automationData['blower_status'] ?? 'OFF';
        sprayerStatus = automationData['sprayer_status'] ?? 'OFF';
        isAutomationOn = automationData['is_automation_enabled'] == true;
      } else {
        throw Exception('Gagal ambil status automation, status: ${autoResp.statusCode}');
      }

      // Ambil aktivitas terbaru
      final activityRepo = ActivityRepository();
      final activities = await activityRepo.getActivityLogs(token: token, greenhouseId: 1);

      setState(() {
        recentActivities = activities.take(3).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Gagal mengambil data: $e';
        isLoading = false;
      });
    }
  }

  void _onTabTapped(int index) {
    if (index == 0) {
      setState(() {
        _selectedIndex = 0;
      });
    } else if (index == 1) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminControlScreen()));
    } else if (index == 2) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AdminSettingsScreen()));
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
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_input_component), label: 'Control'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildTabContent(int index) {
    return _buildDashboardTab();
  }

  Widget _buildDashboardTab() {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _fetchAllData,
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
                  _buildRecentActivity(),
                  if (error.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(error, style: const TextStyle(color: Colors.red)),
                  ],
                ],
              ),
            ),
          );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('Admin Dashboard', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Text('GreenGrow Greenhouse Control', style: TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  Widget _buildStatusCards() {
    return Row(
      children: [
        Expanded(child: _buildSensorCard(title: 'Temperature', value: '${temperature.toStringAsFixed(1)}°C', icon: Icons.thermostat, color: const Color(0xFF2ECC71))),
        const SizedBox(width: 15),
        Expanded(child: _buildSensorCard(title: 'Humidity', value: '${humidity.toStringAsFixed(1)}%', icon: Icons.water_drop, color: const Color(0xFF3498DB))),
      ],
    );
  }

  Widget _buildSensorCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Container(width: 50, height: 50, decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 24))]),
          const SizedBox(height: 15),
          Text(title, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
          const SizedBox(height: 5),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('System Status', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatusItem('Blower', blowerStatus == 'ON', Icons.air),
              _buildStatusItem('Sprayer', sprayerStatus == 'ON', Icons.water),
              _buildStatusItem('Auto Mode', isAutomationOn, Icons.auto_mode),
            ],
          ),
        ],
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
            color: isActive ? const Color(0xFF2ECC71).withOpacity(0.2) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: isActive ? const Color(0xFF2ECC71) : Colors.grey, width: 2),
          ),
          child: Icon(icon, color: isActive ? const Color(0xFF2ECC71) : Colors.grey, size: 24),
        ),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
        const SizedBox(height: 4),
        Container(width: 8, height: 8, decoration: BoxDecoration(color: isActive ? const Color(0xFF2ECC71) : Colors.grey, borderRadius: BorderRadius.circular(4))),
      ],
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF1A1F2E), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Activity', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          if (recentActivities.isEmpty) const Text('No recent activity', style: TextStyle(color: Colors.white70)),
          for (final activity in recentActivities) _buildActivityItem(activity),
        ],
      ),
    );
  }

  Widget _buildActivityItem(ActivityLog activity) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFF2ECC71).withOpacity(0.2), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.event, color: Color(0xFF2ECC71), size: 20)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity.activityType, style: const TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 4),
                Text(activity.description, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12)),
                const SizedBox(height: 4),
                Text(_formatActivityTime(activity.createdAt), style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
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
