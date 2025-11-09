import 'package:flutter/material.dart';
import 'package:greengrow_app/presentation/pages/activity/upload_activity_screen.dart';
import 'package:greengrow_app/presentation/pages/dashboard/farmer_dashboard_screen.dart';
import 'package:greengrow_app/presentation/pages/device/device_screen.dart';
import 'package:greengrow_app/presentation/widgets/sensor_history_widget.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/config/api_config.dart';
import '../../../data/repositories/activity_repository.dart';
import '../../../data/models/activity_log_model.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../core/providers/auth_provider.dart';
import '../sensor/sensor_trend_screen.dart';
import '../../blocs/sensor/sensor_bloc.dart';
import '../../blocs/sensor/sensor_event.dart';
import '../../blocs/sensor/sensor_state.dart';
import 'package:dio/dio.dart';
import '../settings/settings_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/sensor_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../widgets/glass_card.dart';
import 'dart:ui';

class ActivityHistoryScreen extends StatefulWidget {
  final int greenhouseId;

  const ActivityHistoryScreen({
    super.key,
    required this.greenhouseId,
  });

  @override
  State<ActivityHistoryScreen> createState() => _ActivityHistoryScreenState();
}

class _ActivityHistoryScreenState extends State<ActivityHistoryScreen> {
  List<ActivityLog> _activities = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    try {
      _activities = await ActivityRepository().getActivityLogs(token: token!, greenhouseId: widget.greenhouseId);
    } catch (e) {
      _error = e.toString();
    }
    setState(() => _isLoading = false);
  }

  // String _getPhotoUrl(String photoPath) {
  //   return '${ApiConfig.photoBaseUrl}$photoPath';
  // }

  String _getActivityTypeText(String type) {
    switch (type) {
      case 'watering':
        return 'Penyiraman';
      case 'fertilizing':
        return 'Pemupukan';
      case 'pruning':
        return 'Pemangkasan';
      case 'pest_control':
        return 'Pengendalian Hama';
      default:
        return type;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'watering':
        return Icons.water_drop;
      case 'fertilizing':
        return Icons.grass;
      case 'pruning':
        return Icons.content_cut;
      case 'pest_control':
        return Icons.bug_report;
      default:
        return Icons.agriculture;
    }
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'watering':
        return Colors.blue;
      case 'fertilizing':
        return Colors.brown;
      case 'pruning':
        return Colors.orange;
      case 'pest_control':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  double get _filterButtonHeight => 36;

  @override
  Widget build(BuildContext context) {
    Widget activityListWidget;
    if (_isLoading) {
      activityListWidget = const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF509168)),
        ),
      );
    } else if (_error != null) {
      activityListWidget = Center(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFE57373).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE57373)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Color(0xFFE57373), size: 48),
              const SizedBox(height: 16),
              const Text(
                'Gagal memuat data',
                style: TextStyle(
                  color: Color(0xFFE57373),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _error!,
                style: const TextStyle(color: Color(0xFFE57373)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF509168),
                  shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                ),
                  onPressed: _loadActivities,
                  child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    } else if (_activities.isEmpty) {
      activityListWidget = Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            const Icon(
                Icons.history,
                size: 64,
              color: Colors.white54,
              ),
              const SizedBox(height: 16),
            const Text(
                'Belum ada aktivitas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                color: Colors.white70,
                ),
              ),
              const SizedBox(height: 8),
            const Text(
                'Mulai catat aktivitas pertanian Anda',
              style: TextStyle(color: Colors.white54),
              ),
            ],
        ),
      );
    } else {
      activityListWidget = ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: _activities.length,
        itemBuilder: (context, index) {
          final activity = _activities[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF509168),
                  Color(0xFF2F7E68),
                  Color(0xFF193326),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF509168).withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon aktivitas
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getActivityIcon(activity.activityType),
                        color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Info aktivitas
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getActivityTypeText(activity.activityType),
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              activity.description,
                            style: const TextStyle(
                              color: Colors.white70,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                const Icon(
                                    Icons.calendar_today,
                                    size: 12,
                                  color: Colors.white70,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    activity.createdAt != null 
                                      ? DateFormat('dd MMM yyyy').format(activity.createdAt!)
                                      : 'Tanggal tidak tersedia',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Foto aktivitas
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: activity.photoUrl != null && activity.photoUrl!.isNotEmpty
                              ? Image.network(
                                  'http://10.0.2.2:3000${activity.photoUrl!}',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 80,
                                    height: 80,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF193326),
                                    ),
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 32,
                                    color: Colors.white24,
                                    ),
                                  ),
                                )
                              : Container(
                                  width: 80,
                                  height: 80,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF193326),
                                    ),
                                child: const Icon(
                                    Icons.image,
                                    size: 32,
                                  color: Colors.white24,
                                  ),
                                ),
                        ),
                      ),
                    ],
                ),
              ),
            ),
          );
        },
      );
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
                // Header
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Riwayat Aktivitas',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.white),
                        onPressed: _loadActivities,
                      ),
                    ],
                  ),
                ),
                // GlassCard untuk Riwayat Data Sensor
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF509168), Color(0xFF2F7E68)],
                                    ),
                                    borderRadius: BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: const Icon(
                                    Icons.sensors,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Riwayat Data Sensor',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.info_outline, color: Colors.white),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: const Color(0xFF193326),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      title: Row(
                                        children: const [
                                          Icon(Icons.info, color: Colors.white),
                                          SizedBox(width: 8),
                                          Text('Informasi Filter Data Sensor', style: TextStyle(color: Colors.white)),
                                        ],
                                      ),
                                      content: const SingleChildScrollView(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Gunakan "Filter Kustom" untuk rentang waktu dan agregasi yang lebih spesifik.',
                                              style: TextStyle(height: 1.5, color: Colors.white70),
                                            ),
                                          ],
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context).pop(),
                                          child: const Text(
                                            'Tutup',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Kembalikan Container pembungkus SensorHistoryWidget
                        Container(
                          height: 400,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: BlocProvider(
                              create: (context) {
                                final token = Provider.of<AuthProvider>(context, listen: false).token;
                                final bloc = SensorBloc(
                                  SensorRepository(Dio(), const FlutterSecureStorage()),
                                );
                                return bloc;
                              },
                              child: SensorHistoryWidget(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // GlassCard untuk Riwayat Kegiatan
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF509168), Color(0xFF2F7E68)],
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(10)),
                              ),
                              child: const Icon(
                                Icons.agriculture,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Riwayat Kegiatan',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Kembalikan Container pembungkus activityListWidget
                        Container(
                          height: 400,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: activityListWidget,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
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
                    builder: (context) => const FarmerDashboardScreen(),
                  ),
                );
                break;
              case 1:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DeviceScreen(),
                  ),
                );
                break;
              case 2:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ActivityHistoryScreen(greenhouseId: widget.greenhouseId),
                  ),
                );
                break;
              case 3:
                final userIdStr = Provider.of<AuthProvider>(context, listen: false).userId;
                final userId = userIdStr != null ? int.tryParse(userIdStr) ?? 0 : 0;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UploadActivityScreen(greenhouseId: widget.greenhouseId, userId: userId),
                  ),
                );
                break;
              case 4:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
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
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.add_photo_alternate),
              label: 'Aktivitas',
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
}