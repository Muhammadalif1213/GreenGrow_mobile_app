import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fl_chart/fl_chart.dart'; // [NEW] Untuk Grafik
import 'package:intl/intl.dart'; // [NEW] Untuk Format Tanggal

// --- IMPORTS APLIKASI ANDA ---
// Sesuaikan path ini dengan struktur folder project Anda jika berbeda
import 'package:greengrow_app/core/config/api_config.dart';
import 'package:greengrow_app/data/models/activity_log_model.dart';
import 'package:greengrow_app/data/models/sensor_log_model.dart'; // [NEW] Pastikan model ini ada
import 'package:greengrow_app/data/repositories/activity_repository.dart';
import 'package:greengrow_app/data/repositories/device_control_repository.dart';
import 'package:greengrow_app/data/repositories/sensor_repository.dart';
import 'package:greengrow_app/presentation/blocs/device_control/device_control_bloc.dart';
import 'package:greengrow_app/presentation/blocs/sensor/sensor_bloc.dart';
import 'package:greengrow_app/presentation/blocs/sensor/sensor_event.dart';
import 'package:greengrow_app/presentation/blocs/sensor/sensor_state.dart';

// Import Halaman Lain
import '../../widgets/weekly_history_error.dart';
import 'admin_control_screen.dart';
import 'admin_settings_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedIndex = 0;

  late final SensorBloc _sensorBloc;

  // [NEW] Variable untuk menampung future data history
  late Future<List<SensorLogModel>> _historyFuture;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Inisialisasi Repository
    final sensorRepository =
        SensorRepository(Dio(), const FlutterSecureStorage());

    // 1. Setup Bloc untuk Realtime Data
    _sensorBloc = SensorBloc(sensorRepository);
    _fetchRealtimeData();

    // 2. Setup Timer untuk Realtime Data (setiap 5 detik)
    _timer =
        Timer.periodic(const Duration(seconds: 5), (_) => _fetchRealtimeData());

    // 3. [NEW] Load Data History (Hanya sekali saat init, tidak perlu timer 5 detik)
    _historyFuture = sensorRepository.getSensorLogs();
  }

  void _fetchRealtimeData() {
    if (!mounted) return;
    _sensorBloc.add(FetchLatestSensorData());
  }

  // Fungsi untuk refresh manual (Pull to Refresh)
  Future<void> _handleRefresh() async {
    _fetchRealtimeData(); // Refresh realtime
    setState(() {
      // Refresh grafik history
      _historyFuture =
          SensorRepository(Dio(), const FlutterSecureStorage()).getSensorLogs();
    });
    // Beri sedikit delay agar UI terasa refresh
    await Future.delayed(const Duration(seconds: 1));
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
      backgroundColor: const Color(0xFF0F1419), // Dark Background
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
    // Saat ini hanya Dashboard Tab yang kita fokuskan
    return _buildDashboardTab();
  }

  Widget _buildDashboardTab() {
    return BlocProvider.value(
      value: _sensorBloc,
      child: RefreshIndicator(
        onRefresh:
            _handleRefresh, // Menggunakan fungsi refresh yang sudah diupdate
        color: const Color(0xFF2ECC71),
        backgroundColor: const Color(0xFF1A1F2E),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),

              // 1. Realtime Status Cards
              _buildStatusCards(),
              const SizedBox(height: 25),

              // 2. [NEW] History Chart Section
              const Text('Weekly History (7 Days)',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              _buildHistoryChartSection(),

              const SizedBox(height: 25),

              // 3. Quick Stats (Control Status)
              _buildQuickStats(),
              const SizedBox(height: 20),

              // 4. Recent Activity (Placeholder jika Anda ingin mengaktifkannya kembali)
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

  // --- WIDGET CHART BARU ---
  Widget _buildHistoryChartSection() {
    return FutureBuilder<List<SensorLogModel>>(
      future: _historyFuture,
      builder: (context, snapshot) {
        // STATE: LOADING
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF2ECC71))),
          );
        }
        // STATE: ERROR (GANTI BAGIAN INI)
        else if (snapshot.hasError) {
          return WeeklyHistoryError(
            errorMessage: snapshot.error.toString(),
            onRetry: () {
              setState(() {
                // Refresh logic: Panggil ulang repository
                _historyFuture =
                    SensorRepository(Dio(), const FlutterSecureStorage())
                        .getSensorLogs();
              });
            },
          );
        }
        // STATE: EMPTY DATA
        else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // Kita gunakan UI Error juga tapi pesannya beda untuk Empty State
          return Container(
            height: 300,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1F2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.query_stats,
                    size: 64, color: Colors.white.withOpacity(0.2)),
                const SizedBox(height: 16),
                Text("Belum ada data history",
                    style: TextStyle(color: Colors.white.withOpacity(0.5))),
              ],
            ),
          );
        }

        final logs = snapshot.data!;

        // STATE: SUCCESS (Code Chart Lama Anda)
        return Container(
          height: 300,
          padding: const EdgeInsets.fromLTRB(10, 20, 20, 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1F2E),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5))
            ],
          ),
          child: LineChart(
            // ... (kode konfigurasi chart Anda tetap sama seperti sebelumnya) ...
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.white.withOpacity(0.05),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < logs.length) {
                        try {
                          final date = DateTime.parse(logs[index].docId);
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('dd/MM').format(date),
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        } catch (e) {
                          return const SizedBox.shrink();
                        }
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 20,
                    reservedSize: 35,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 10,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (logs.length - 1).toDouble(),
              minY: 0,
              maxY: 100,
              lineBarsData: [
                LineChartBarData(
                  spots: logs.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value.humidity);
                  }).toList(),
                  isCurved: true,
                  color: const Color(0xFF3498DB),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: const Color(0xFF3498DB).withOpacity(0.1),
                  ),
                ),
                LineChartBarData(
                  spots: logs.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value.temp);
                  }).toList(),
                  isCurved: true,
                  color: const Color(0xFF2ECC71),
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (touchedSpot) =>
                      const Color(0xFF0F1419).withOpacity(0.9),
                  getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                    return touchedBarSpots.map((barSpot) {
                      final val = barSpot.y;
                      if (barSpot.barIndex == 0) {
                        return LineTooltipItem(
                          'Kelembaban: $val%',
                          const TextStyle(
                              color: Color(0xFF3498DB),
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        );
                      } else {
                        return LineTooltipItem(
                          'Suhu: $val°C',
                          const TextStyle(
                              color: Color(0xFF2ECC71),
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        );
                      }
                    }).toList();
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- REALTIME STATUS CARDS (BLOC) ---
  Widget _buildStatusCards() {
    return BlocBuilder<SensorBloc, SensorState>(
      builder: (context, state) {
        if (state is SensorLoading || state is SensorInitial) {
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
              color: color.withOpacity(0.1), // Sedikit dikurangi opacity shadow
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

  Widget _buildSensorCardSkeleton({required Color color}) {
    return Container(
      height: 160,
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

  // --- QUICK STATS (BLOC CONTROL) ---
  Widget _buildQuickStats() {
    return BlocProvider(
      create: (_) => DeviceControlBloc(
        DeviceControlRepository(Dio(), const FlutterSecureStorage()),
      )..add(DeviceControlFetchStatus()),
      child: BlocBuilder<DeviceControlBloc, DeviceControlState>(
        builder: (context, state) {
          if (state is DeviceControlLoading || state is DeviceControlInitial) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2ECC71)));
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
}
