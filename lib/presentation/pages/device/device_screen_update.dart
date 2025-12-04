import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greengrow_app/presentation/pages/dashboard/farmer_dashboard_screen_update.dart';
import '../../blocs/device_control/device_control_bloc.dart';
import '../../../data/repositories/device_control_repository.dart';
import '../settings/settings_screen.dart';
// import '../../../core/providers/auth_provider.dart'; // Tidak digunakan di sini
// import 'package:provider/provider.dart'; // Tidak digunakan di sini
import 'dart:ui';
import '../../widgets/glass_card.dart';

class DeviceScreenUpdate extends StatelessWidget {
  const DeviceScreenUpdate({super.key});

  @override
  Widget build(BuildContext context) {
    // Kita tidak perlu AuthProvider di sini karena Repository akan mengambil token
    return BlocProvider(
      create: (context) => DeviceControlBloc(
        DeviceControlRepository(Dio(), const FlutterSecureStorage()),
      )..add(DeviceControlFetchStatus()), // Langsung ambil status
      child: BlocConsumer<DeviceControlBloc, DeviceControlState>(
        listener: (context, state) {
          // Bagian listener untuk SnackBar (sudah benar)
          if (state is DeviceControlStatus && state.message != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      state.success == false ? Icons.error : Icons.check_circle,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(state.message!)),
                  ],
                ),
                backgroundColor: state.success == false
                    ? const Color(0xFFE57373)
                    : const Color(0xFF4CAF50),
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          } else if (state is DeviceControlError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(child: Text(state.message)),
                  ],
                ),
                backgroundColor: const Color(0xFFE57373),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          // Ambil nilai dari state dengan nilai default
          bool blowerOn = false;
          bool isAutomationEnabled = false;
          int maxTemp = 0; // <-- NILAI BARU KITA

          if (state is DeviceControlStatus) {
            blowerOn = state.blowerOn;
            isAutomationEnabled = state.isAutomationEnabled;
            maxTemp = state.maxTemp; // <-- Ambil maxTemp dari state
          } else if (state is DeviceControlLoading) {
            // Kita bisa tambahkan ini untuk UI yang lebih baik
            // (Opsional) Anda bisa menampilkan loading di sini
          }

          return Scaffold(
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
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // const SizedBox(height: 16),
                      // const Text(
                      //   'Control',
                      //   style: TextStyle(
                      //     color: Colors.white,
                      //     fontSize: 18,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      // const SizedBox(height: 8),
                      // // GlassCard status sistem (atas)
                      // GlassCard(
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(16.0),
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         Text(
                      //           'Status Perangkat',
                      //           style: TextStyle(
                      //             color: Colors.white.withOpacity(0.9),
                      //             fontSize: 14,
                      //             fontWeight: FontWeight.w500,
                      //           ),
                      //         ),
                      //         const SizedBox(height: 12),
                      //         Row(
                      //           children: [
                      //             const Text(
                      //               'Automation: ',
                      //               style: TextStyle(
                      //                 color: Colors.white,
                      //                 fontSize: 28,
                      //                 fontWeight: FontWeight.bold,
                      //               ),
                      //             ),
                      //             Text(
                      //               isAutomationEnabled ? 'ON' : 'OFF',
                      //               style: TextStyle(
                      //                 color: Colors.white.withOpacity(0.9),
                      //                 fontSize: 28,
                      //                 fontWeight: FontWeight.w400,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //         const SizedBox(height: 12),
                      //         Row(
                      //           children: [
                      //             const Text(
                      //               'Blower: ',
                      //               style: TextStyle(
                      //                 color: Colors.white,
                      //                 fontSize: 28,
                      //                 fontWeight: FontWeight.bold,
                      //               ),
                      //             ),
                      //             Text(
                      //               isAutomationEnabled ? 'ON' : 'OFF',
                      //               style: TextStyle(
                      //                 color: Colors.white.withOpacity(0.9),
                      //                 fontSize: 28,
                      //                 fontWeight: FontWeight.w400,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //         const SizedBox(height: 16),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(height: 16),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Status Sistem',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Container(
                          //   padding: const EdgeInsets.symmetric(
                          //       horizontal: 12, vertical: 6),
                          //   decoration: BoxDecoration(
                          //     color: Colors.white.withOpacity(0.2),
                          //     borderRadius: BorderRadius.circular(12),
                          //   ),
                          //   child: Text(
                          //     isAutomationEnabled
                          //         ? 'Sistem Aktif'
                          //         : 'Manual Mode',
                          //     style: const TextStyle(
                          //       color: Color.fromARGB(255, 255, 255, 255),
                          //       fontSize: 12,
                          //       fontWeight: FontWeight.w500,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            isAutomationEnabled
                                ? 'Sistem Otomatis'
                                : 'Sistem Manual',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      // // GlassCard status perangkat
                      // GlassCard(
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(16.0),
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         // === PERUBAHAN DI SINI ===
                      //         _buildStatusRow(
                      //             'Automation', isAutomationEnabled),
                      //         const SizedBox(height: 12),
                      //         _buildStatusRow('Blower', blowerOn),
                      //         const SizedBox(height: 12),
                      //         // Baris baru untuk MaxTemp
                      //         _buildStatusRow('Batas Suhu', maxTemp,
                      //             unit: '°C'),
                      //         // ========================
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(height: 16),
                      const Text(
                        'Kontrol Perangkat',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Row dua GlassCard untuk kontrol perangkat
                      Row(
                        children: [
                          // CARD 1: BLOWER (Sudah ada)
                          Expanded(
                            child: _buildDeviceCard(
                              context: context,
                              title: 'Blower',
                              subtitle: 'Sirkulasi udara',
                              icon: Icons.air,
                              isOn: blowerOn,
                              isAutomationEnabled: isAutomationEnabled,
                              isManualControl:
                                  true, // Ini adalah kontrol manual
                              onChanged: (isOn) {
                                context.read<DeviceControlBloc>().add(
                                      DeviceControlBlowerToggled(
                                        isEnabled: isOn,
                                      ),
                                    );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),

                          // === CARD 2: TAMBAHKAN CARD AUTOMATION ===
                          Expanded(
                            child: _buildDeviceCard(
                              context: context,
                              title: 'Automation',
                              subtitle: 'Mode otomatis',
                              icon: Icons.auto_mode, // Ikon baru
                              isOn: isAutomationEnabled,
                              isAutomationEnabled: isAutomationEnabled,
                              isManualControl:
                                  false, // Ini BUKAN kontrol manual
                              onChanged: (isOn) {
                                // Panggil event BLoC baru kita
                                context.read<DeviceControlBloc>().add(
                                      DeviceControlAutomationToggled(
                                        isEnabled: isOn,
                                      ),
                                    );
                              },
                            ),
                          ),
                          // ===================================
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
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
                currentIndex: 1,
                onTap: (index) {
                  switch (index) {
                    case 0:
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const FarmerDashboardScreenUpdate(),
                        ),
                      );
                      break;
                    case 1:
                      // Already on this page
                      break;
                    case 2:
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(),
                        ),
                      );
                      break;
                  }
                },
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white70,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.bold),
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
        },
      ),
    );
  }

  // Widget _buildActionButton (Tidak terpakai di UI ini, tapi biarkan)
  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    // ... (kode Anda sebelumnya)
    return Container(); // Placeholder
  }

  // Widget _buildDeviceCard (Dimodifikasi)
  Widget _buildDeviceCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isOn,
    required bool isAutomationEnabled,
    required Function(bool) onChanged,
    bool isManualControl = true, // <-- Tetap ada
  }) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // BUNGKUS SELURUH ROW DENGAN INKWELL AGAR SEMUA AREA BISA DIKLIK
            InkWell(
              onTap: () {
                // Logika sama seperti sebelumnya
                if (isManualControl && isAutomationEnabled) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                                'Matikan mode automation untuk kontrol manual $title.'),
                          ),
                        ],
                      ),
                      backgroundColor: const Color(0xFFE57373),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                  return; // Jangan toggle
                }
                // Toggle nilai dan panggil onChanged
                onChanged(!isOn); // Toggle dari isOn ke !isOn
              },
              borderRadius: BorderRadius.circular(12), // Agar efek ripple bulat
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // UBAH CONTAINER ICON: WARNA DINAMIS (ABU UNTUK OFF, HIJAU UNTUK ON)
                  Container(
                    padding: const EdgeInsets.only(
                        top: 50, bottom: 50, left: 70, right: 70),
                    decoration: BoxDecoration(
                      color: isOn
                          ? Colors.green.withOpacity(0.8)
                          : Colors.grey
                              .withOpacity(0.8), // Dinamis: hijau ON, abu OFF
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          icon,
                          color: Colors.white,
                          size: 24,
                        ),
                        Text(
                          isOn ? 'ON' : 'OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // HAPUS CARD TERPISAH UNTUK "ON/OFF" - SEKARANG ICON + BACKGROUND SUDAH MENUNJUKKAN STATUS
                  // (Opsional: Tambahkan teks status di sini jika ingin, tapi warna sudah cukup indikator)
                  // Contoh: Text(isOn ? 'ON' : 'OFF', style: TextStyle(color: Colors.white)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper _buildStatusRow (Diperbarui untuk menerima int/bool)
  Widget _buildStatusRow(String label, dynamic value, {String unit = ''}) {
    bool isOn = false;
    String textValue = '';

    if (value is bool) {
      isOn = value;
      textValue = isOn ? 'ON' : 'OFF';
    } else {
      // Asumsikan ini adalah int (maxTemp) atau tipe lain
      textValue = '$value$unit';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: (value is bool)
                ? (isOn ? const Color(0xFF4CAF50) : Colors.grey)
                : Colors.white.withOpacity(0.2), // Warna netral untuk nilai
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            textValue,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
