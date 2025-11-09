import 'package:flutter/material.dart';
import 'admin_dashboard_screen.dart';
import 'admin_settings_screen.dart';
import '../../../data/repositories/automation_threshold_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../../../data/models/automation_threshold_model.dart';

class AdminControlScreen extends StatefulWidget {
  @override
  State<AdminControlScreen> createState() => _AdminControlScreenState();
}

class _AdminControlScreenState extends State<AdminControlScreen> {
  double tempMax = 30.0;
  double humidityMax = 70.0;
  bool showSuccess = false;
  bool showError = false;
  String errorMsg = '';
  int? tempThresholdId;
  int? humidityThresholdId;

  late AutomationThresholdRepository thresholdRepo;

  @override
  void initState() {
    super.initState();
    thresholdRepo = AutomationThresholdRepository(Dio(), const FlutterSecureStorage());
    _loadThresholds();
  }

  Future<void> _loadThresholds() async {
    try {
      final thresholds = await thresholdRepo.getThresholds();
      // Asumsi: parameter 'temperature' dan 'humidity'
      final temp = thresholds.firstWhere(
        (t) => t.parameter == 'temperature',
        orElse: () => AutomationThresholdModel(id: 0, parameter: '', deviceType: '', minValue: null, maxValue: null)
      );
      final hum = thresholds.firstWhere(
        (t) => t.parameter == 'humidity',
        orElse: () => AutomationThresholdModel(id: 0, parameter: '', deviceType: '', minValue: null, maxValue: null)
      );
      setState(() {
        if (temp.parameter == 'temperature') {
          tempMax = temp.maxValue ?? 30.0;
          tempThresholdId = temp.id;
        }
        if (hum.parameter == 'humidity') {
          humidityMax = hum.maxValue ?? 70.0;
          humidityThresholdId = hum.id;
        }
      });
    } catch (e) {
      setState(() {
        showError = true;
        errorMsg = 'Gagal memuat threshold: $e';
      });
    }
  }

  Future<void> _handleSave() async {
    setState(() {
      showSuccess = false;
      showError = false;
    });
    try {
      if (tempThresholdId != null) {
        await thresholdRepo.updateThresholdById(
          id: tempThresholdId!,
          maxValue: tempMax,
        );
      }
      if (humidityThresholdId != null) {
        await thresholdRepo.updateThresholdById(
          id: humidityThresholdId!,
          maxValue: humidityMax,
        );
      }
      setState(() {
        showSuccess = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          showSuccess = false;
        });
      });
    } catch (e) {
      setState(() {
        showError = true;
        errorMsg = 'Gagal menyimpan threshold: $e';
      });
    }
  }

  Future<void> _handleReset() async {
    setState(() {
      tempMax = 30.0;
      humidityMax = 70.0;
      showSuccess = false;
      showError = false;
    });
    try {
      if (tempThresholdId != null) {
        await thresholdRepo.updateThresholdById(
          id: tempThresholdId!,
          maxValue: 30.0,
        );
      }
      if (humidityThresholdId != null) {
        await thresholdRepo.updateThresholdById(
          id: humidityThresholdId!,
          maxValue: 70.0,
        );
      }
      setState(() {
        showSuccess = true;
      });
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          showSuccess = false;
        });
      });
    } catch (e) {
      setState(() {
        showError = true;
        errorMsg = 'Gagal reset threshold: $e';
      });
    }
  }

  void _onTabTapped(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminDashboardScreen()),
      );
    } else if (index == 1) {
      // Stay on this page
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AdminSettingsScreen()),
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
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
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
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
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
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                                child: const Icon(Icons.thermostat, color: Colors.green, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Suhu Maksimum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                                  Text('Atur batas maksimum suhu', style: TextStyle(fontSize: 14, color: Colors.white70)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Suhu Maksimum: ${tempMax.round()}°C', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                              const SizedBox(height: 8),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.green,
                                  inactiveTrackColor: Colors.green.withOpacity(0.2),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text('0°C', style: TextStyle(fontSize: 12, color: Colors.white54)),
                                  Text('50°C', style: TextStyle(fontSize: 12, color: Colors.white54)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Card Kelembapan
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
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
                                child: const Icon(Icons.water_drop, color: Colors.green, size: 24),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text('Kelembapan Maksimum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                                  Text('Atur batas maksimum kelembapan', style: TextStyle(fontSize: 14, color: Colors.white70)),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Kelembapan Maksimum: ${humidityMax.round()}%', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white)),
                              const SizedBox(height: 8),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  activeTrackColor: Colors.green,
                                  inactiveTrackColor: Colors.green.withOpacity(0.2),
                                  thumbColor: Colors.green,
                                  overlayColor: Colors.green.withOpacity(0.2),
                                  trackHeight: 8,
                                ),
                                child: Slider(
                                  value: humidityMax,
                                  min: 0,
                                  max: 100,
                                  divisions: 100,
                                  onChanged: (value) {
                                    setState(() {
                                      humidityMax = value;
                                    });
                                  },
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text('0%', style: TextStyle(fontSize: 12, color: Colors.white54)),
                                  Text('100%', style: TextStyle(fontSize: 12, color: Colors.white54)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _handleSave,
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text('Simpan', style: TextStyle(color: Colors.white)),
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
                            icon: const Icon(Icons.refresh, color: Colors.white),
                            label: const Text('Reset', style: TextStyle(color: Colors.white)),
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
