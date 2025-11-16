import 'dart:async'; // Diperlukan untuk Timer
import 'dart:ui';
import 'package:dio/dio.dart'; // Diperlukan untuk Repository
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // Diperlukan untuk Repository
import 'package:flutter_bloc/flutter_bloc.dart'; // Diperlukan untuk BLoC
import 'package:greengrow_app/data/repositories/sensor_repository.dart'; // Import Repository
import 'package:greengrow_app/presentation/blocs/sensor/sensor_bloc.dart'; // Import BLoC
import 'package:greengrow_app/data/models/sensor_data_model.dart'; // Import Model
import 'package:greengrow_app/presentation/blocs/sensor/sensor_event.dart';
import 'package:greengrow_app/presentation/blocs/sensor/sensor_state.dart';
import 'package:greengrow_app/presentation/pages/device/device_screen_update.dart';
import 'package:greengrow_app/presentation/pages/profile/profile_farmer_screen.dart';
import 'package:greengrow_app/presentation/widgets/notification_badge.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../../core/providers/auth_provider.dart'; // Tidak diperlukan lagi di file ini
import '../../../core/providers/notification_provider.dart'; // Masih ada, tapi dinonaktifkan
import '../settings/settings_screen.dart';
import '../../widgets/glass_card.dart';

class FarmerDashboardScreenUpdate extends StatefulWidget {
  const FarmerDashboardScreenUpdate({super.key});

  @override
  State<FarmerDashboardScreenUpdate> createState() =>
      _FarmerDashboardScreenUpdateState();
}

class _FarmerDashboardScreenUpdateState
    extends State<FarmerDashboardScreenUpdate> {
  int _selectedIndex = 0;

  // 1. Logika BLoC dan Timer (menggantikan state lama)
  late final SensorBloc _sensorBloc; // <-- Variabel 'late' Anda
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // ==========================================================
    // PASTIKAN BARIS INI ADA, TIDAK DIKOMENTARI, DAN BENAR
    _sensorBloc =
        SensorBloc(SensorRepository(Dio(), const FlutterSecureStorage()));
    // ==========================================================

    // Panggil event BLoC
    _fetchData();

    // Set timer untuk refresh data
    _timer = Timer.periodic(const Duration(seconds: 15), (_) => _fetchData());

    // Nonaktifkan notifikasi untuk menghindari error 404
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Provider.of<NotificationProvider>(context, listen: false)
      //     .loadUnreadCount();
    });
  }

  // Fungsi untuk memanggil BLoC
  void _fetchData() {
    // Memanggil event BLoC yang sudah kita buat
    _sensorBloc.add(FetchLatestSensorData());
  }

  @override
  void dispose() {
    // 3. Hapus BLoC dan Timer
    _timer?.cancel();
    _sensorBloc.close();
    super.dispose();
  }

  // 4. Hapus semua fungsi fetch data yang lama
  // - fetchLatestSensorData() (DIHAPUS)
  // - fetchRealtimeSensorData() (DIHAPUS)
  // - setDeviceStatus() (DIHAPUS, pindahkan ke DeviceRepository)
  // - _getTemperatureStatus() (DIHAPUS, logika baru)
  // - _getHumidityStatus() (DIHAPUS, logika baru)

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const DeviceScreenUpdate(),
          ),
        );
        break;
      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const SettingsScreen(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Dashboard Petani',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: false,
        actions: [
          const NotificationBadge(),
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProfileFarmerScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/login.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Blur overlay
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
          // Main content
          SafeArea(
            // 5. Bungkus ListView dengan BlocProvider
            child: BlocProvider.value(
              value: _sensorBloc,
              child: RefreshIndicator(
                onRefresh: () async {
                  _fetchData();
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Center(
                        child: Text(
                      'INFORMATION',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold),
                    )),
                    const SizedBox(height: 16),

                    // 6. Gunakan BlocBuilder untuk menampilkan data
                    BlocBuilder<SensorBloc, SensorState>(
                      builder: (context, state) {
                        // --- Saat Loading ---
                        if (state is SensorLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            ),
                          );
                        }

                        // --- Saat Sukses ---
                        if (state is SensorLoaded) {
                          final data = state.sensorData; // Data baru kita

                          // Kita buat ulang UI-nya agar mirip
                          return Column(
                            children: [
                              // Card 1: Suhu & Kelembapan
                              GlassCard(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildSensorInfoColumn(
                                        'Suhu',
                                        '${data.temp.toStringAsFixed(1)}°C',
                                        Icons.thermostat,
                                      ),
                                      // Pemisah
                                      Container(
                                        width: 1,
                                        height: 60,
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                      _buildSensorInfoColumn(
                                        'Kelembapan',
                                        '${data.humbd.toStringAsFixed(1)}%',
                                        Icons.water_drop_outlined,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Card 2: Status & Konfigurasi
                              GlassCard(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Center(
                                        child: Text(
                                          'Status Konfigurasi',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.white),
                                        ),
                                      ),
                                      const Divider(color: Colors.white54),
                                      _buildConfigRow(
                                          'Mode Otomatis',
                                          data.config.automation
                                              ? 'AKTIF'
                                              : 'MATI'),
                                      _buildConfigRow('Status Blower',
                                          data.config.blower ? 'ON' : 'OFF'),
                                      _buildConfigRow('Batas Suhu',
                                          '${data.config.maxTemp}°C'),
                                      _buildConfigRow('Heat Index',
                                          '${data.hic.toStringAsFixed(1)}°C'),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        // --- Saat Error ---
                        if (state is SensorError) {
                          return Center(
                            child: Text(
                              'Gagal memuat data: ${state.message}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }

                        // State Awal
                        return const SizedBox();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        // ... (BottomNavigationBar Anda sudah benar) ...
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF509168),
              Color(0xFF2F7E68),
              Color(0xFF193326),
            ],
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.developer_board),
              label: 'Control',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  // 7. Widget helper BARU untuk data dari model baru
  Widget _buildSensorInfoColumn(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // 8. HAPUS SEMUA WIDGET HELPER LAMA
  // - _formatTime() (DIHAPUS)
  // - _buildBigSensorCard() (DIHAPUS)
  // - _buildTripleSensorCard() (DIHAPUS)
  // - _buildSensorRow() (DIHAPUS)
}

// 9. HAPUS SEMUA CLASS HELPER LAMA DI BAWAH INI
// - class SensorRealtimeData (DIHAPUS)
// - double? _parseToDouble(dynamic value) (DIHAPUS)
// - class _SensorValueColumn (DIHAPUS)
