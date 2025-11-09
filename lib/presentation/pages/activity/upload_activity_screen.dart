import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/config/api_config.dart';
import '../../../domain/repositories/activity_repository.dart';
import '../../../domain/models/activity_log.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../../core/providers/auth_provider.dart';
import '../dashboard/farmer_dashboard_screen.dart';
import '../device/device_screen.dart';
import 'activity_history_screen.dart';
import '../settings/settings_screen.dart';
import 'package:image/image.dart' as img;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import '../../widgets/glass_card.dart';
import 'dart:ui';

class UploadActivityScreen extends StatefulWidget {
  final int greenhouseId;
  final int userId;

  const UploadActivityScreen({
    Key? key,
    required this.greenhouseId,
    required this.userId,
  }) : super(key: key);

  @override
  State<UploadActivityScreen> createState() => _UploadActivityScreenState();
}

class _UploadActivityScreenState extends State<UploadActivityScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  String? _activityType;
  File? _photoFile;
  bool _isLoading = false;
  String? _error;
  AnimationController? _animationController;
  Animation<double>? _slideAnimation;
  Animation<double>? _fadeAnimation;

  // Activity type configurations with icons and colors
  final Map<String, Map<String, dynamic>> _activityConfig = {
    'penyiraman': {
      'label': 'Penyiraman',
      'icon': Icons.water_drop,
      'color': Colors.blue,
      'gradient': [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
    },
    'pemupukan': {
      'label': 'Pemupukan',
      'icon': Icons.scatter_plot,
      'color': Colors.orange,
      'gradient': [Color(0xFFFFB74D), Color(0xFFFF9800)],
    },
    'pemangkasan': {
      'label': 'Pemangkasan',
      'icon': Icons.content_cut,
      'color': Colors.green,
      'gradient': [Color(0xFF66BB6A), Color(0xFF4CAF50)],
    },
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeOutCubic,
    ));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController!,
      curve: Curves.easeIn,
    ));
    _animationController!.forward();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    _descController.dispose();
    super.dispose();
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('network')) {
      return 'Koneksi internet bermasalah';
    } else if (error.toString().contains('timeout')) {
      return 'Koneksi timeout';
    } else if (error.toString().contains('401')) {
      return 'Sesi anda telah berakhir, silakan login kembali';
    } else if (error.toString().contains('413')) {
      return 'Ukuran foto terlalu besar';
    } else if (error.toString().contains('415')) {
      return 'Format foto tidak didukung';
    }
    return 'Terjadi kesalahan, silakan coba lagi';
  }

  Future<bool> _checkAndRequestPermissions() async {
    final cameraStatus = await Permission.camera.request();
    if (cameraStatus.isDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Izin Kamera Diperlukan'),
            content: const Text(
              'Aplikasi membutuhkan izin untuk mengakses kamera. Silakan berikan izin di pengaturan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Buka Pengaturan'),
              ),
            ],
          ),
        );
      }
      return false;
    }

    final storageStatus = await Permission.storage.request();
    if (storageStatus.isDenied) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Izin Penyimpanan Diperlukan'),
            content: const Text(
              'Aplikasi membutuhkan izin untuk mengakses penyimpanan. Silakan berikan izin di pengaturan.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Buka Pengaturan'),
              ),
            ],
          ),
        );
      }
      return false;
    }

    return true;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      // Cek ekstensi file
      final ext = file.path.split('.').last.toLowerCase();
      if (ext != 'jpg' && ext != 'jpeg' && ext != 'png') {
        // Konversi ke JPEG
        final bytes = await file.readAsBytes();
        final decoded = img.decodeImage(bytes);
        if (decoded != null) {
          final jpgBytes = img.encodeJpg(decoded);
          final newPath = file.path.replaceAll(RegExp(r'\.[^.]*$'), '.jpg');
          final jpgFile = await File(newPath).writeAsBytes(jpgBytes);
          file = jpgFile;
        }
      }
      setState(() {
        _photoFile = file;
      });
    }
  }

  Future<void> _uploadActivity() async {
    if (!_formKey.currentState!.validate() || _photoFile == null) {
      setState(() { _error = 'Lengkapi semua data dan ambil foto!'; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_error!),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      final userId = widget.userId;
      if (token == null) throw Exception('Token tidak ditemukan, silakan login ulang.');
      if (userId == 0) {
        setState(() { _error = 'User tidak valid, silakan login ulang.'; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error!),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() { _isLoading = false; });
        return;
      }
      final uri = Uri.parse('http://10.0.2.2:3000/api/activities');
      var request = http.MultipartRequest('POST', uri);
      request.fields['user_id'] = widget.userId.toString();
      request.fields['greenhouse_id'] = widget.greenhouseId.toString();
      request.fields['activity_type'] = _activityType!;
      request.fields['description'] = _descController.text;
      request.fields['activity_date'] = DateTime.now().toIso8601String();
      // Pastikan nama file dan contentType benar
      String uploadFilePath = _photoFile!.path;
      String uploadFileName = uploadFilePath.split('/').last;
      if (!uploadFileName.endsWith('.jpg') && !uploadFileName.endsWith('.jpeg') && !uploadFileName.endsWith('.png')) {
        uploadFileName = uploadFileName.replaceAll(RegExp(r'\.[^.]*$'), '.jpg');
      }
      final mimeType = lookupMimeType(uploadFilePath) ?? 'image/jpeg';
      request.files.add(
        await http.MultipartFile.fromPath(
          'photo',
          uploadFilePath,
          contentType: MediaType('image', 'jpeg'),
          filename: uploadFileName,
        ),
      );
      request.headers['Authorization'] = 'Bearer $token';
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Aktivitas berhasil diupload!'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        print('Token setelah upload: ${authProvider.token}');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/activity-history');
        }
      } else {
        setState(() { _error = 'Upload gagal: ${response.statusCode}\n$respStr'; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_error!),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() { _error = 'Error: $e'; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_error!),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Widget _buildPhotoSection() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _photoFile != null
                    ? Image.file(
                        _photoFile!,
                        fit: BoxFit.cover,
                      )
                    : InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF509168).withOpacity(0.3),
                              width: 2,
                              style: BorderStyle.solid,
                            ),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF509168).withOpacity(0.3),
                                const Color(0xFF2F7E68).withOpacity(0.2),
                                const Color(0xFF193326).withOpacity(0.1),
                              ],
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF509168).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(
                                  Icons.add_a_photo,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Ambil Foto Aktivitas',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap untuk mengambil foto',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTypeSelector() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.agriculture, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Jenis Aktivitas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _activityConfig.entries.map((entry) {
                final isSelected = _activityType == entry.key;
                final config = entry.value;
                return GestureDetector(
                  onTap: () => setState(() => _activityType = entry.key),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? LinearGradient(colors: config['gradient'])
                          : LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF509168).withOpacity(0.3),
                                const Color(0xFF2F7E68).withOpacity(0.2),
                                const Color(0xFF193326).withOpacity(0.1),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.transparent : const Color(0xFF509168).withOpacity(0.3),
                        width: 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: config['color'].withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          config['icon'],
                          color: isSelected ? Colors.white : Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          config['label'],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_activityType == null)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Pilih jenis aktivitas',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Deskripsi Aktivitas',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Deskripsikan aktivitas yang dilakukan...',
                hintStyle: TextStyle(color: Colors.white70),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF509168), width: 2),
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Deskripsi tidak boleh kosong' : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF509168), Color(0xFF2F7E68)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
      child: ElevatedButton(
        onPressed: _isLoading ? null : _uploadActivity,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'Upload Aktivitas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int _selectedIndex = 3;
    void _onItemTapped(int index) {
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FarmerDashboardScreen()),
          );
          break;
        case 1:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DeviceScreen()),
          );
          break;
        case 2:
          Navigator.pushReplacementNamed(context, '/activity-history');
          break;
        case 3:
          // Sudah di halaman ini
          break;
        case 4:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
          break;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF010D0E),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        title: const Text(
          'Upload Aktivitas',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF010D0E), // rich-black
                Color(0xFF034041), // midnight-green
                Color(0xFF193326), // dark-green
              ],
            ),
          ),
        ),
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
            child: _fadeAnimation != null
              ? FadeTransition(
                  opacity: _fadeAnimation!,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(_slideAnimation!),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildPhotoSection(),
                          const SizedBox(height: 16),
                          _buildActivityTypeSelector(),
                          const SizedBox(height: 16),
                          _buildDescriptionField(),
                          const SizedBox(height: 24),
                          _buildUploadButton(),
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.red.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.error_outline, color: Colors.red.shade600),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: TextStyle(color: Colors.red.shade700),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 100), // Space for bottom navigation
                        ],
                      ),
                    ),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
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