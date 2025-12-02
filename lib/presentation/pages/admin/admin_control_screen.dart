import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/audit_log_model.dart';
import '../../../data/models/sensor_data_model.dart';
import '../../../data/repositories/audit_repository.dart';
import '../../blocs/audit/audit_bloc.dart';
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
  late final AuditBloc _auditBloc;

  double tempMax = 40.0; // Default
  double originalTempMax = 40.0;
  // 2. HAPUS SEMUA VARIABEL HUMIDITY
  bool showSuccess = false;
  bool showError = false;
  String errorMsg = '';
  // 3. HAPUS THRESHOLD ID

  late DeviceControlRepository deviceRepo; // 4. GANTI REPOSITORY

  @override
  void initState() {
    // Init Audit Bloc
    _auditBloc =
        AuditBloc(AuditRepository(Dio(), const FlutterSecureStorage()));

    _fetchData();

    super.initState();
    // 5. INISIALISASI REPOSITORY YANG BENAR
    deviceRepo = DeviceControlRepository(Dio(), const FlutterSecureStorage());
    // 6. PANGGIL FUNGSI LOAD (UNCOMMENT)
    _loadThresholds();
  }

  Future<void> _fetchData() async {
    _auditBloc.add(FetchAuditLogs());
  }

  @override
  void dispose() {
    _auditBloc.close();
    super.dispose();
  }

  Future<void> _loadThresholds() async {
    try {
      // 7. PANGGIL FUNGSI REPOSITORY YANG BENAR
      final ConfigModel config = await deviceRepo.getDeviceStatus();

      setState(() {
        // 8. AMBIL DATA DARI CONFIG MODEL
        tempMax = config.maxTemp.toDouble();
        originalTempMax = config.maxTemp.toDouble();
        // 9. HAPUS LOGIKA HUMIDITY
      });
    } catch (e) {
      setState(() {
        showError = true;
        errorMsg = 'Gagal memuat config: $e';
      });
    }
  }

  // --- LOGIKA BARU UNTUK TOMBOL ---
  void _decrementTemp() {
    setState(() {
      if (tempMax > 0) tempMax--; // Batas bawah 0
    });
  }

  void _incrementTemp() {
    setState(() {
      if (tempMax < 100) tempMax++; // Batas atas 100 (sesuaikan jika perlu)
    });
  }
  // --------------------------------

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
      _fetchData();

      setState(() {
        showSuccess = true;
        originalTempMax = tempMax;
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
    setState(() {
      tempMax = originalTempMax;
      // 12. HAPUS LOGIKA HUMIDITY
      showSuccess = false;
      showError = false;
    });
    try {
      // 13. PANGGIL FUNGSI UPDATE YANG BENAR
      // await deviceRepo.updateMaxTemp(
      //   temp: originalTempMax.round(),
      // );

      // TRIGGER REFRESH LOG JUGA DI SINI
      _fetchData();

      setState(() {
        showSuccess = false;
        originalTempMax = originalTempMax; // Update juga nilai aslinya
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
    bool hasChanges = tempMax != originalTempMax;

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
                child: const Row(
                  children: [
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
                              const Column(
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
                              // Text('Suhu Maksimum: ${tempMax.round()}°C',
                              //     style: const TextStyle(
                              //         fontSize: 14,
                              //         fontWeight: FontWeight.w500,
                              //         color: Colors.white)),
                              // const SizedBox(height: 8),
                              // === BAGIAN YANG DIUBAH: DARI SLIDER KE BUTTON ===
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Tombol Minus
                                  _buildControlButton(
                                    icon: Icons.remove,
                                    onTap: _decrementTemp,
                                  ),
                                  const SizedBox(width: 24),
                                  // Tampilan Angka
                                  Container(
                                    width: 120,
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${tempMax.round()}°C',
                                      style: const TextStyle(
                                        fontSize: 48,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 24),
                                  // Tombol Plus
                                  _buildControlButton(
                                    icon: Icons.add,
                                    onTap: _incrementTemp,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16)
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
                          // 5. Gunakan hasChanges untuk enable/disable button
                          onPressed: hasChanges ? _handleSave : null,
                          icon: Icon(Icons.save,
                              color:
                                  hasChanges ? Colors.white : Colors.white38),
                          label: Text('Simpan',
                              style: TextStyle(
                                  color: hasChanges
                                      ? Colors.white
                                      : Colors.white38)),
                          style: ElevatedButton.styleFrom(
                            // Ubah warna background saat disabled
                            backgroundColor: hasChanges
                                ? const Color(0xFF2ECC71)
                                : const Color(0xFF2ECC71).withOpacity(0.3),
                            disabledBackgroundColor:
                                const Color(0xFF2ECC71).withOpacity(0.3),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        )),
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
                    MultiBlocProvider(
                        providers: [BlocProvider.value(value: _auditBloc)],
                        child: RefreshIndicator(
                          onRefresh: () async {
                            _fetchData();
                          },
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(top: 20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildRecentActivity(),
                              ],
                            ),
                          ),
                        ))
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

  // Widget Helper untuk Tombol Plus/Minus
  Widget _buildControlButton(
      {required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF2ECC71).withOpacity(0.1),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFF2ECC71).withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          color: const Color(0xFF2ECC71),
          size: 28,
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: const Color(0xFF1A1F2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Activity',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),

          // Gunakan BlocBuilder untuk AuditBloc
          BlocBuilder<AuditBloc, AuditState>(
            builder: (context, state) {
              if (state is AuditLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is AuditLoaded) {
                if (state.logs.isEmpty) {
                  return const Text('No recent activity',
                      style: TextStyle(color: Colors.white70));
                }
                // Ambil 5 log terakhir saja agar tidak kepanjangan
                final logsToShow = state.logs.take(5).toList();
                return Column(
                  children:
                      logsToShow.map((log) => _buildActivityItem(log)).toList(),
                );
              } else if (state is AuditError) {
                return Text('Error: ${state.message}',
                    style: const TextStyle(color: Colors.red));
              }
              return const SizedBox();
            },
          ),
        ],
      ),
    );
  }

  // 8. Sesuaikan _buildActivityItem dengan Model Baru
  Widget _buildActivityItem(AuditLogModel log) {
    // Tentukan icon dan warna berdasarkan action
    IconData icon;
    Color color;
    String description;

    if (log.action == 'set_max_temp') {
      icon = Icons.thermostat;
      color = Colors.orange;
      description = 'Mengubah suhu maks menjadi ${log.newValue}°C';
    } else {
      icon = Icons.info;
      color = const Color(0xFF2ECC71);
      description = 'Action: ${log.action} -> ${log.newValue}';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama User yang melakukan aksi
                Text(log.user.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                // Deskripsi aksi
                Text(description,
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.7), fontSize: 12)),
                const SizedBox(height: 4),
                // Waktu
                Text(_formatActivityTime(log.timestamp),
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
    // Konversi ke waktu lokal agar sesuai jam Indonesia
    final localTime = dateTime.toLocal();
    final now = DateTime.now();
    final diff = now.difference(localTime);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    return '${localTime.day}/${localTime.month}/${localTime.year} ${localTime.hour}:${localTime.minute}';
  }
}
