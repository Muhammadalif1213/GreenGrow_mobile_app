import 'package:flutter/material.dart';
import 'package:greengrow_app/presentation/pages/dashboard/farmer_dashboard_screen_update.dart';
import 'package:greengrow_app/presentation/pages/device/device_screen_update.dart';
import '../dashboard/farmer_dashboard_screen.dart';
import '../device/device_screen.dart';
import '../profile/profile_farmer_screen.dart';
import '../privacy/privacy_screen.dart';
import '../notification/notification_screen.dart';
import '../about/about_screen.dart';
import '../supports/supports_screen.dart';
import '../auth/register_screen.dart';
import '../auth/login_screen.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import 'dart:ui';
import 'package:greengrow_app/presentation/widgets/glass_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userIdStr = Provider.of<AuthProvider>(context, listen: false).userId;
    final userId = userIdStr != null ? int.tryParse(userIdStr) ?? 0 : 0;
    return Scaffold(
      extendBodyBehindAppBar: true,
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
            child: Column(
              children: [
                // Custom Header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Pengaturan',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      // Profile Card
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.agriculture,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Selamat datang, Petani!',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Kelola greenhouse Anda dengan mudah',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildSettingsSection(
                        'Akun & Profil',
                        [
                          _buildSettingsItem(
                            'Akun Saya',
                            Icons.person,
                            const Color(0xFF509168),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProfileFarmerScreen(),
                                ),
                              );
                            },
                          ),
                          _buildSettingsItem(
                            'Ubah Password',
                            Icons.lock,
                            const Color(0xFF509168),
                            () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder: (context) => ResetPasswordScreen(),
                              //   ),
                              // );
                            },
                          ),
                          // _buildSettingsItem(
                          //   'Privacy',
                          //   Icons.privacy_tip,
                          //   const Color(0xFF795548),
                          //   () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => PrivacyScreen(),
                          //       ),
                          //     );
                          //   },
                          // ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSettingsSection(
                        'Setting Device',
                        [
                          _buildSettingsItem(
                            'Ubah Ambang batas Suhu',
                            Icons.thermostat_auto_outlined,
                            const Color(0xFF2196F3),
                            () {
                            },
                          ),
                        ],
                      ),
                      // _buildSettingsSection(
                      //   'Greenhouse',
                      //   [
                      //     _buildSettingsItem(
                      //       'Lokasi Greenhouse',
                      //       Icons.location_on,
                      //       const Color(0xFF2196F3),
                      //       () {
                      //         Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //             builder: (context) => const GreenhouseMapScreen(),
                      //           ),
                      //         );
                      //       },
                      //     ),
                      //     _buildSettingsItem(
                      //       'Notifikasi',
                      //       Icons.notifications,
                      //       const Color(0xFFFF9800),
                      //       () {
                      //         Navigator.push(
                      //           context,
                      //           MaterialPageRoute(
                      //             builder: (context) => NotificationScreen(),
                      //           ),
                      //         );
                      //       },
                      //     ),
                      //   ],
                      // ),
                      const SizedBox(height: 16),
                      _buildSettingsSection(
                        'Informasi',
                        [
                          _buildSettingsItem(
                            'Tentang Aplikasi',
                            Icons.info,
                            const Color(0xFF9C27B0),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AboutScreen(),
                                ),
                              );
                            },
                          ),
                          _buildSettingsItem(
                            'Help & Support',
                            Icons.help_center,
                            const Color(0xFF607D8B),
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SupportsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _buildSettingsSection(
                        'Akun',
                        [
                          // _buildSettingsItem(
                          //   'Add Account',
                          //   Icons.person_add,
                          //   const Color(0xFF009688),
                          //   () {
                          //     Navigator.push(
                          //       context,
                          //       MaterialPageRoute(
                          //         builder: (context) => RegisterScreen(),
                          //       ),
                          //     );
                          //   },
                          // ),
                          _buildSettingsItem(
                            'Log out',
                            Icons.logout,
                            const Color(0xFFE91E63),
                            () {
                              _showLogoutDialog(context);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
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
          currentIndex: 2,
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FarmerDashboardScreenUpdate(),
                  ),
                );
                break;
              case 1:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeviceScreenUpdate(),
                  ),
                );
                break;
              // case 2:
              //   Navigator.pushReplacement(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => ActivityHistoryScreen(greenhouseId: 1),
              //     ),
              //   );
              //   break;
              // case 3:
              //   Navigator.pushReplacement(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => UploadActivityScreen(greenhouseId: 1, userId: userId),
              //     ),
              //   );
              //   break;
              case 2:
                // Sudah di halaman ini
                break;
            }
          },
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
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.history),
            //   label: 'History',
            // ),
            // BottomNavigationBarItem(
            //   icon: Icon(Icons.add_photo_alternate),
            //   label: 'Aktivitas',
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
        GlassCard(
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, Color iconColor, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E63).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout,
                  color: Color(0xFFE91E63),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Konfirmasi',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          content: const Text(
            'Apakah Anda yakin ingin keluar dari aplikasi?',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF666666),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                // Hapus token dan redirect ke login
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE91E63),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Keluar',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}