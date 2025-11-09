import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greengrow_app/presentation/pages/activity/activity_history_screen.dart';
import 'package:greengrow_app/presentation/pages/activity/upload_activity_screen.dart';
import 'package:greengrow_app/presentation/pages/dashboard/farmer_dashboard_screen.dart';
import 'package:greengrow_app/presentation/pages/dashboard/farmer_dashboard_screen_update.dart';
import '../../blocs/device_control/device_control_bloc.dart';
import '../../blocs/device_control/device_control_event.dart';
import '../../blocs/device_control/device_control_state.dart';
import '../../../data/repositories/device_control_repository.dart';
import '../settings/settings_screen.dart';
import '../../../core/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import '../../widgets/glass_card.dart';

class DeviceScreen extends StatelessWidget {
  const DeviceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userIdStr = Provider.of<AuthProvider>(context, listen: false).userId;
    final userId = userIdStr != null ? int.tryParse(userIdStr) ?? 0 : 0;
    return BlocProvider(
      create: (context) => DeviceControlBloc(
        DeviceControlRepository(Dio(), const FlutterSecureStorage()),
      )..add(DeviceControlFetchStatus()),
      child: BlocConsumer<DeviceControlBloc, DeviceControlState>(
        listener: (context, state) {
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
          bool blowerOn = false;
          bool sprayerOn = false;
          bool isAutomationEnabled = false;
          if (state is DeviceControlStatus) {
            blowerOn = state.blowerOn;
            sprayerOn = state.sprayerOn;
            isAutomationEnabled = state.isAutomationEnabled;
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
                      const SizedBox(height: 16),
                      const Text(
                        'Control',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // GlassCard status sistem (atas)
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Status Perangkat',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Text(
                                    'Automation: ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    isAutomationEnabled ? 'ON' : 'OFF',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.9),
                                      fontSize: 28,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      isAutomationEnabled ? 'Sistema Aktif' : 'Manual Mode',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.trending_up,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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
                          Expanded(
                            child: GlassCard(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: _buildDeviceCard(
                                  context: context,
                                  title: 'Blower',
                                  subtitle: 'Sirkulasi udara',
                                  icon: Icons.air,
                                  isOn: blowerOn,
                                  isAutomationEnabled: isAutomationEnabled,
                                  onChanged: (isOn) {
                                    if (isAutomationEnabled) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(Icons.warning, color: Colors.white),
                                              const SizedBox(width: 8),
                                              const Expanded(
                                                child: Text('Matikan mode automation untuk kontrol manual blower.'),
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
                                      return;
                                    }
                                    context.read<DeviceControlBloc>().add(
                                      DeviceControlRequested(
                                        deviceType: 'blower',
                                        action: isOn ? 'ON' : 'OFF',
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GlassCard(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: _buildDeviceCard(
                                  context: context,
                                  title: 'Sprayer',
                                  subtitle: 'Sistem penyiraman',
                                  icon: Icons.opacity,
                                  isOn: sprayerOn,
                                  isAutomationEnabled: isAutomationEnabled,
                                  onChanged: (isOn) {
                                    if (isAutomationEnabled) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              const Icon(Icons.warning, color: Colors.white),
                                              const SizedBox(width: 8),
                                              const Expanded(
                                                child: Text('Matikan mode automation untuk kontrol manual sprayer.'),
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
                                      return;
                                    }
                                    context.read<DeviceControlBloc>().add(
                                      DeviceControlRequested(
                                        deviceType: 'sprayer',
                                        action: isOn ? 'ON' : 'OFF',
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Status Perangkat',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // GlassCard status perangkat
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildStatusRow('Automation', isAutomationEnabled),
                              const SizedBox(height: 12),
                              _buildStatusRow('Blower', blowerOn),
                              const SizedBox(height: 12),
                              _buildStatusRow('Sprayer', sprayerOn),
                            ],
                          ),
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
                currentIndex: 1,
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
                      // Already on this page
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
        },
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isActive 
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF509168), // sea-green
                    Color(0xFF2F7E68), // viridian
                  ],
                )
              : null,
          color: isActive ? null : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: isActive 
              ? Border.all(color: const Color(0xFF509168), width: 1)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isOn,
    required bool isAutomationEnabled,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: isOn 
                        ? const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF509168), // sea-green
                              Color(0xFF2F7E68), // viridian
                            ],
                          )
                        : null,
                    color: isOn ? null : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                Switch(
                  value: isOn,
                  onChanged: onChanged,
                  activeColor: const Color(0xFF4CAF50),
                  inactiveThumbColor: Colors.grey,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
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

  // Helper for status row in status perangkat card
  Widget _buildStatusRow(String label, bool isOn) {
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
            color: isOn ? const Color(0xFF4CAF50) : Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            isOn ? 'ON' : 'OFF',
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

  Widget _buildStatusCard({
    required String title,
    required String value,
    required IconData icon,
    required String trend,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF509168).withOpacity(0.3), // sea-green
            const Color(0xFF2F7E68).withOpacity(0.2), // viridian
            const Color(0xFF193326).withOpacity(0.1), // dark-green
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF509168).withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF509168).withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF509168), // sea-green
                      Color(0xFF2F7E68), // viridian
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF509168), // sea-green
                      Color(0xFF2F7E68), // viridian
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ],
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
            value,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF509168), // sea-green
                  Color(0xFF2F7E68), // viridian
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              trend,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}