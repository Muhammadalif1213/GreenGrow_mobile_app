// import 'dart:convert';
// import 'package:greengrow_app/presentation/pages/device/device_screen.dart';
// import 'package:greengrow_app/presentation/pages/profile/profile_farmer_screen.dart';
// import 'package:greengrow_app/presentation/widgets/notification_badge.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../../../core/providers/auth_provider.dart';
// import '../../../core/providers/notification_provider.dart';
// import '../settings/settings_screen.dart';
// import 'dart:ui';
// import '../../widgets/glass_card.dart';

// class FarmerDashboardScreen extends StatefulWidget {
//   const FarmerDashboardScreen({super.key});

//   @override
//   State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
// }

// class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
//   int _selectedIndex = 0;
//   bool isLoading = true;
//   bool isAutomationOn = false;
//   bool isAutomationLoading = false;
//   String blowerStatus = 'OFF';
//   String sprayerStatus = 'OFF';
//   double temperature = 0.0;
//   double humidity = 0.0;
//   String sensorStatus = '-';
//   // Ganti dengan alamat backend kamu
//   final String baseUrl = 'http://10.0.2.2:3000';

//   SensorRealtimeData? previousSensorData;
//   SensorRealtimeData? currentSensorData;
//   SensorForecastData? forecastSensorData;
//   bool isRealtimeLoading = true;
//   String realtimeError = '';

//   @override
//   void initState() {
//     super.initState();
//     // Load unread notification count when dashboard is opened
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Provider.of<NotificationProvider>(context, listen: false)
//           .loadUnreadCount();
//     });
//     fetchAutomationStatus();
//     fetchLatestSensorData();
//     fetchRealtimeSensorData();
//   }

//   Future<void> fetchAutomationStatus() async {
//     final authProvider = Provider.of<AuthProvider>(context, listen: false);
//     final token = authProvider.token;
//     final response = await http.get(
//       Uri.parse('$baseUrl/api/sensors/automation/status'),
//       headers: token != null ? {'Authorization': 'Bearer $token'} : null,
//     );
//     if (response.statusCode == 200) {
//       final data = json.decode(response.body);
//       // Perbaiki parsing sesuai struktur respons backend
//       final automationData = data['data'] ?? data;
//       setState(() {
//         isAutomationOn = automationData['is_automation_enabled'] == true;
//         blowerStatus = automationData['blower_status'] ?? 'OFF';
//         sprayerStatus = automationData['sprayer_status'] ?? 'OFF';
//       });
//     } else {
//       setState(() {
//         isAutomationOn = false;
//         blowerStatus = 'OFF';
//         sprayerStatus = 'OFF';
//       });
//     }
//   }

//   Future<void> fetchLatestSensorData() async {
//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final token = authProvider.token;
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/sensors/latest'),
//         headers: token != null ? {'Authorization': 'Bearer $token'} : null,
//       );
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           temperature = data['temperature']?.toDouble() ?? 0.0;
//           humidity = data['humidity']?.toDouble() ?? 0.0;
//           sensorStatus = data['status'] ?? '-';
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//           // Jika gagal, coba ambil status dari currentSensorData
//           if (currentSensorData != null) {
//             sensorStatus =
//                 'Suhu:  ${currentSensorData?.temperature?.toStringAsFixed(1) ?? '-'}°C, Kelembapan:  ${currentSensorData?.humidity?.toStringAsFixed(1) ?? '-'}%';
//           } else {
//             sensorStatus =
//                 'Gagal mengambil data sensor (${response.statusCode})';
//           }
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         // Jika error, coba ambil status dari currentSensorData
//         if (currentSensorData != null) {
//           sensorStatus =
//               'Suhu:  ${currentSensorData?.temperature?.toStringAsFixed(1) ?? '-'}°C, Kelembapan:  ${currentSensorData?.humidity?.toStringAsFixed(1) ?? '-'}%';
//         } else {
//           sensorStatus = 'Gagal mengambil data sensor (error: $e)';
//         }
//       });
//     }
//   }

//   Future<void> fetchRealtimeSensorData() async {
//     setState(() {
//       isRealtimeLoading = true;
//       realtimeError = '';
//     });
//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final token = authProvider.token;
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/sensors/realtime'),
//         headers: token != null ? {'Authorization': 'Bearer $token'} : null,
//       );
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         final Map<String, dynamic>? d = data['data'];
//         setState(() {
//           previousSensorData = SensorRealtimeData.fromJson(d?['previous']);
//           currentSensorData = SensorRealtimeData.fromJson(d?['current']);
//           forecastSensorData = SensorForecastData.fromJson(d?['forecast']);
//           isRealtimeLoading = false;
//         });
//       } else {
//         setState(() {
//           isRealtimeLoading = false;
//           realtimeError =
//               'Gagal mengambil data realtime (${response.statusCode})';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         isRealtimeLoading = false;
//         realtimeError = 'Gagal mengambil data realtime (error: $e)';
//       });
//     }
//   }

//   Future<void> setAutomationMode(bool value) async {
//     setState(() {
//       isAutomationLoading = true;
//       isAutomationOn = value; // Update state lokal agar UI langsung berubah
//     });
//     try {
//       final authProvider = Provider.of<AuthProvider>(context, listen: false);
//       final token = authProvider.token;
//       final response = await http.put(
//         Uri.parse('$baseUrl/api/sensors/automation/mode'),
//         headers: {
//           'Content-Type': 'application/json',
//           if (token != null) 'Authorization': 'Bearer $token',
//         },
//         body: json.encode({'is_automation_enabled': value}),
//       );
//       print(
//           'Automation PUT response: status=${response.statusCode}, body=${response.body}');
//       if (response.statusCode == 200) {
//         await Future.delayed(const Duration(milliseconds: 500));
//         await fetchAutomationStatus();
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               value
//                   ? 'Automation berhasil diaktifkan.'
//                   : 'Automation berhasil dinonaktifkan.',
//               style: const TextStyle(color: Colors.white),
//             ),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 2),
//           ),
//         );
//       } else if (response.statusCode == 401) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text(
//                 'Sesi login Anda sudah habis atau tidak valid. Silakan login ulang.'),
//             backgroundColor: Colors.red,
//             duration: Duration(seconds: 3),
//           ),
//         );
//         // Optional: redirect ke login
//         // Navigator.pushReplacementNamed(context, '/login');
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Gagal mengubah mode automation (Status: ${response.statusCode})\nBody: ${response.body}',
//               style: const TextStyle(color: Colors.white),
//             ),
//             backgroundColor: Colors.red,
//             duration: const Duration(seconds: 3),
//           ),
//         );
//         // Jika gagal, kembalikan ke state sebelumnya
//         setState(() {
//           isAutomationOn = !value;
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Terjadi error: $e',
//               style: const TextStyle(color: Colors.white)),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//       // Jika error, kembalikan ke state sebelumnya
//       setState(() {
//         isAutomationOn = !value;
//       });
//     } finally {
//       setState(() {
//         isAutomationLoading = false;
//       });
//     }
//   }

//   Future<void> setDeviceStatus({String? blower, String? sprayer}) async {
//     final response = await http.put(
//       Uri.parse('$baseUrl/api/automation/device'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({
//         if (blower != null) 'blower_status': blower,
//         if (sprayer != null) 'sprayer_status': sprayer,
//       }),
//     );
//     if (response.statusCode == 200) {
//       fetchAutomationStatus();
//     }
//   }

//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });

//     switch (index) {
//       case 0:
//         // Home - already on dashboard, do nothing
//         break;
//       case 1:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => DeviceScreen(),
//           ),
//         );
//         break;
//       // case 2:
//       //   Navigator.pushReplacement(
//       //     context,
//       //     MaterialPageRoute(
//       //       builder: (context) => ActivityHistoryScreen(greenhouseId: 1),
//       //     ),
//       //   );
//       //   break;
//       // case 3:
//       //   final userIdStr = Provider.of<AuthProvider>(context, listen: false).userId;
//       //   final userId = userIdStr != null ? int.tryParse(userIdStr) ?? 0 : 0;
//       //   Navigator.pushReplacement(
//       //     context,
//       //     MaterialPageRoute(
//       //       builder: (context) => UploadActivityScreen(greenhouseId: 1, userId: userId),
//       //     ),
//       //   );
//       //   break;
//       case 2:
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => SettingsScreen(),
//           ),
//         );
//         break;
//     }
//   }

//   // Fungsi untuk menentukan status suhu
//   String _getTemperatureStatus(double? temp) {
//     if (temp == null) return '-';
//     if (temp >= 28.0) return 'Terlalu Panas';
//     if (temp <= 20.0) return 'Terlalu Dingin';
//     return 'Normal';
//   }

//   // Fungsi untuk menentukan status kelembapan
//   String _getHumidityStatus(double? hum) {
//     if (hum == null) return '-';
//     if (hum >= 80.0) return 'Terlalu Lembap';
//     if (hum <= 50.0) return 'Terlalu Kering';
//     return 'Normal';
//   }

//   @override
//   Widget build(BuildContext context) {
//     final authProvider = Provider.of<AuthProvider>(context);
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text('Dashboard Petani', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         centerTitle: false,
//         actions: [
//           const NotificationBadge(),
//           // IconButton(
//           //   icon: const Icon(Icons.location_on, color: Colors.white),
//           //   onPressed: () {
//           //     Navigator.push(
//           //       context,
//           //       MaterialPageRoute(
//           //         builder: (context) => const GreenhouseMapScreen(),
//           //       ),
//           //     );
//           //   },
//           // ),
//           IconButton(
//             icon: const Icon(Icons.person, color: Colors.white),
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (context) => const ProfileFarmerScreen(),
//                 ),
//               );
//             },
//           ),
//         ],
//       ),
//       body: Stack(
//         children: [
//           // Background image
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('assets/images/login.jpg'),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           // Blur overlay
//           BackdropFilter(
//             filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
//             child: Container(
//               color: Colors.black.withOpacity(0.2),
//             ),
//           ),
//           // Main content
//           SafeArea(
//             child: isLoading
//                 ? const Center(child: CircularProgressIndicator())
//                 : RefreshIndicator(
//                     onRefresh: () async {
//                       await fetchAutomationStatus();
//                       await fetchLatestSensorData();
//                       await fetchRealtimeSensorData();
//                     },
//                     child: ListView(
//                       padding: const EdgeInsets.all(16),
//                       children: [
//                         // Card Suhu & Kelembapan Gabung (glass)
//                         GlassCard(
//                           child: SensorCombinedCard(
//                             previousTemp: previousSensorData?.temperature,
//                             currentTemp: currentSensorData?.temperature,
//                             forecastTemp: forecastSensorData?.temperature,
//                             previousHum: previousSensorData?.humidity,
//                             currentHum: currentSensorData?.humidity,
//                             forecastHum: forecastSensorData?.humidity,
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         // Real-time Sensor Data Section (glass)
//                         GlassCard(
//                           child: Padding(
//                             padding: const EdgeInsets.all(12.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 const Text(
//                                   'Realtime Suhu & Kelembapan',
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
//                                 ),
//                                 const SizedBox(height: 8),
//                                 if (isRealtimeLoading)
//                                   const Center(child: CircularProgressIndicator())
//                                 else if (realtimeError.isNotEmpty)
//                                   Text(realtimeError, style: const TextStyle(color: Colors.red))
//                                 else ...[
//                                   _buildSensorRow('Previous', previousSensorData),
//                                   const Divider(),
//                                   _buildSensorRow('Current', currentSensorData),
//                                   const Divider(),
//                                   _buildForecastRow('Forecast', forecastSensorData),
//                                 ],
//                               ],
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         // Automation Card (glass)
//                         GlassCard(
//                           child: ListTile(
//                             title: const Text('Automation', style: TextStyle(color: Colors.white)),
//                             subtitle: Text(
//                               isAutomationOn ? 'ON (Otomatis)' : 'OFF (Manual)',
//                               style: TextStyle(color: Colors.white.withOpacity(0.7)),
//                             ),
//                             trailing: isAutomationLoading
//                                 ? SizedBox(
//                                     width: 48,
//                                     height: 24,
//                                     child: Center(
//                                       child: SizedBox(
//                                         width: 18,
//                                         height: 18,
//                                         child: CircularProgressIndicator(strokeWidth: 2),
//                                       ),
//                                     ),
//                                   )
//                                 : Switch(
//                                     value: isAutomationOn,
//                                     onChanged: isAutomationLoading ? null : (value) => setAutomationMode(value),
//                                     activeColor: Colors.white,
//                                     activeTrackColor: Colors.white24,
//                                     inactiveThumbColor: Colors.grey,
//                                     inactiveTrackColor: Colors.grey.shade300,
//                                   ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         // ...widget lain seperti histori, grafik, dsb sesuai kebutuhan...
//                       ],
//                     ),
//                   ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//             colors: [
//               Color(0xFF509168),
//               Color(0xFF2F7E68),
//               Color(0xFF193326),
//             ],
//           ),
//         ),
//         child: BottomNavigationBar(
//           type: BottomNavigationBarType.fixed,
//           currentIndex: _selectedIndex,
//           onTap: _onItemTapped,
//           selectedItemColor: Colors.white,
//           unselectedItemColor: Colors.white70,
//           backgroundColor: Colors.transparent,
//           elevation: 0,
//           selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.home),
//               label: 'Home',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.developer_board),
//               label: 'Control',
//             ),
//             // BottomNavigationBarItem(
//             //   icon: Icon(Icons.history),
//             //   label: 'History',
//             // ),
//             // BottomNavigationBarItem(
//             //   icon: Icon(Icons.add_photo_alternate),
//             //   label: 'Aktivitas',
//             // ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.settings),
//               label: 'Settings',
//             ),
            
//           ],
//         ),
//       ),
//     );
//   }

//   String _formatTime(String? isoString) {
//     if (isoString == null) return '-';
//     try {
//       final dt = DateTime.parse(isoString).toLocal();
//       return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
//     } catch (_) {
//       return '-';
//     }
//   }

//   Widget _buildBigSensorCard({
//     required String label,
//     double? value,
//     required String unit,
//     String? time,
//     required IconData icon,
//     required Color color,
//   }) {
//     return Card(
//       color: color,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Icon(icon, size: 32, color: Colors.black54),
//                 const SizedBox(width: 12),
//                 Text(
//                   label,
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Center(
//               child: Text(
//                 value != null ? value.toStringAsFixed(1) : '-',
//                 style: const TextStyle(
//                   fontSize: 48,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//             ),
//             Center(
//               child: Text(
//                 unit,
//                 style: const TextStyle(
//                   fontSize: 24,
//                   color: Colors.black54,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Center(
//               child: Text(
//                 'Waktu:  0${_formatTime(time)}',
//                 style: const TextStyle(
//                   fontSize: 16,
//                   color: Colors.black87,
//                   fontFamily: 'Courier',
//                   letterSpacing: 2,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildTripleSensorCard({
//     required String label,
//     double? previous,
//     double? current,
//     double? forecast,
//     required String unit,
//     required Color color,
//   }) {
//     return Card(
//       color: color,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               label,
//               style: const TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [
//                 _SensorValueColumn(
//                   value: previous,
//                   unit: unit,
//                   label: 'Sebelumnya',
//                 ),
//                 _SensorValueColumn(
//                   value: current,
//                   unit: unit,
//                   label: 'Saat Ini',
//                 ),
//                 _SensorValueColumn(
//                   value: forecast,
//                   unit: unit,
//                   label: 'Prediksi',
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSensorRow(String label, SensorRealtimeData? data) {
//     if (data == null || (data.temperature == null && data.humidity == null)) {
//       return Text('$label: Belum ada data', style: const TextStyle(color: Colors.white));
//     }
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
//         Text(
//           'Suhu: ${data.temperature?.toStringAsFixed(1) ?? '-'}°C\nKelembapan: ${data.humidity?.toStringAsFixed(1) ?? '-'}%\nWaktu: ${data.recordedAt ?? '-'}',
//           style: const TextStyle(color: Colors.white70),
//         ),
//       ],
//     );
//   }

//   Widget _buildForecastRow(String label, SensorForecastData? data) {
//     if (data == null || (data.temperature == null && data.humidity == null)) {
//       return Text('$label: Belum ada data prediksi', style: const TextStyle(color: Colors.white));
//     }
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text('$label:', style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
//         Text(
//           'Suhu: ${data.temperature?.toStringAsFixed(1) ?? '-'}°C\nKelembapan: ${data.humidity?.toStringAsFixed(1) ?? '-'}%',
//           style: const TextStyle(color: Colors.white70),
//         ),
//       ],
//     );
//   }
// }

// class SensorRealtimeData {
//   final double? temperature;
//   final double? humidity;
//   final String? recordedAt;

//   SensorRealtimeData({this.temperature, this.humidity, this.recordedAt});

//   factory SensorRealtimeData.fromJson(Map<String, dynamic>? json) {
//     if (json == null) return SensorRealtimeData();
//     return SensorRealtimeData(
//       temperature: _parseToDouble(json['temperature']),
//       humidity: _parseToDouble(json['humidity']),
//       recordedAt: json['recorded_at'] as String?,
//     );
//   }
// }

// class SensorForecastData {
//   final double? temperature;
//   final double? humidity;

//   SensorForecastData({this.temperature, this.humidity});

//   factory SensorForecastData.fromJson(Map<String, dynamic>? json) {
//     if (json == null) return SensorForecastData();
//     return SensorForecastData(
//       temperature: _parseToDouble(json['temperature']),
//       humidity: _parseToDouble(json['humidity']),
//     );
//   }
// }

// // Helper untuk parsing string/num ke double
// double? _parseToDouble(dynamic value) {
//   if (value == null) return null;
//   if (value is num) return value.toDouble();
//   if (value is String) return double.tryParse(value);
//   return null;
// }

// // Tambahkan di bawah semua class State
// class _SensorValueColumn extends StatelessWidget {
//   final double? value;
//   final String unit;
//   final String label;
//   const _SensorValueColumn(
//       {this.value, required this.unit, required this.label, Key? key})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Text(
//           value != null ? value!.toStringAsFixed(1) : '-',
//           style: const TextStyle(
//             fontSize: 40,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//             fontFamily: 'Courier',
//           ),
//         ),
//         Text(
//           unit,
//           style: const TextStyle(
//             fontSize: 18,
//             color: Colors.black54,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 14,
//             color: Colors.black87,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ],
//     );
//   }
// }
