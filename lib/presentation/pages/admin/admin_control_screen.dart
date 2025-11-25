import 'package:flutter/material.dart';
import '../../../data/models/sensor_data_model.dart';
import 'admin_dashboard_screen.dart';
import 'admin_settings_screen.dart';
// 1. IMPORT REPOSITORY & MODEL YANG BENAR
import 'package:greengrow_app/data/repositories/device_control_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class AdminControlScreen extends StatefulWidget {
  const AdminControlScreen({super.key}); // Tambahkan const

  @override
  State<AdminControlScreen> createState() => _AdminControlScreenState();
}

class _AdminControlScreenState extends State<AdminControlScreen> {
  double tempMax = 40.0; // Default
  // 2. HAPUS SEMUA VARIABEL HUMIDITY
  bool showSuccess = false;
  bool showError = false;
  String errorMsg = '';
  // 3. HAPUS THRESHOLD ID

  late DeviceControlRepository deviceRepo; // 4. GANTI REPOSITORY

  @override
  void initState() {
    super.initState();
    // 5. INISIALISASI REPOSITORY YANG BENAR
    deviceRepo = DeviceControlRepository(Dio(), const FlutterSecureStorage());
    // 6. PANGGIL FUNGSI LOAD (UNCOMMENT)
    _loadThresholds();
  }

  Future<void> _loadThresholds() async {
    try {
      // 7. PANGGIL FUNGSI REPOSITORY YANG BENAR
      final ConfigModel config = await deviceRepo.getDeviceStatus();

      setState(() {
        // 8. AMBIL DATA DARI CONFIG MODEL
        tempMax = config.maxTemp.toDouble();
        // 9. HAPUS LOGIKA HUMIDITY
      });
    } catch (e) {
      setState(() {
        showError = true;
        errorMsg = 'Gagal memuat config: $e';
      });
    }
  }

  Future<void> _handleSave() async {
    setState(() {
      showSuccess = false;
      showError = false;
    });
    try {
      // 10. PANGGIL FUNGSI UPDATE YANG BENAR
      await deviceRepo.updateMaxTemp(
        temp: tempMax.round(), // Kirim nilai int
      );
      // 11. HAPUS LOGIKA HUMIDITY

      setState(() {
        showSuccess = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          // Tambahkan cek 'mounted'
          setState(() {
            showSuccess = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        showError = true;
        errorMsg = 'Gagal menyimpan config: $e';
      });
    }
  }

  Future<void> _handleReset() async {
    const double defaultTemp = 30.0;
    setState(() {
      tempMax = defaultTemp;
      // 12. HAPUS LOGIKA HUMIDITY
      showSuccess = false;
      showError = false;
    });
    try {
      // 13. PANGGIL FUNGSI UPDATE YANG BENAR
      await deviceRepo.updateMaxTemp(
        temp: defaultTemp.round(),
      );
      // 14. HAPUS LOGIKA HUMIDITY

      setState(() {
        showSuccess = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          // Tambahkan cek 'mounted'
          setState(() {
            showSuccess = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        showError = true;
        errorMsg = 'Gagal reset config: $e';
      });
    }
  }

  void _onTabTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => const AdminDashboardScreen()), // Tambah const
      );
    } else if (index == 1) {
      // Stay on this page
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => AdminSettingsScreen()), // Tambah const
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F2E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pengaturan Ambang Batas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (showSuccess)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2ECC71),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.save, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Pengaturan berhasil disimpan!',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            if (showError)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        errorMsg,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Card Suhu
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1F2E),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                        border:
                            Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.green.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(Icons.thermostat,
                                    color: Colors.green, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Suhu Maksimum',
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white)),
                                  Text('Atur batas maksimum suhu',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.white70)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Suhu Maksimum: ${tempMax.round()}°C',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white)),
                              const SizedBox(height: 8),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.green,
                                  inactiveTrackColor:
                                      Colors.green.withOpacity(0.2),
                                  thumbColor: Colors.green,
                                  overlayColor: Colors.green.withOpacity(0.2),
                                  trackHeight: 8,
                                ),
                                child: Slider(
                                  value: tempMax,
                                  min: 0,
                                  max: 50,
                                  divisions: 50,
                                  onChanged: (value) {
                                    setState(() {
                                      tempMax = value;
                                    });
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text('0°C',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.white54)),
                                  Text('50°C',
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.white54)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // 15. HAPUS CARD HUMIDITY (jika ada)

                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _handleSave,
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text('Simpan',
                                style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2ECC71),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handleReset,
                            icon:
                                const Icon(Icons.refresh, color: Colors.white),
                            label: const Text('Reset',
                                style: TextStyle(color: Colors.white)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.white54),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 1,
        onTap: _onTabTapped,
        selectedItemColor: const Color(0xFF2ECC71),
        unselectedItemColor: Colors.grey,
        backgroundColor: const Color(0xFF1A1F2E),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_input_component),
            label: 'Control',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
