import 'package:flutter/material.dart';

class PrivacyScreen extends StatefulWidget {
  const PrivacyScreen({Key? key}) : super(key: key);

  @override
  State<PrivacyScreen> createState() => _PrivacyScreenState();
}

class _PrivacyScreenState extends State<PrivacyScreen> {
  bool _dataCollectionEnabled = true;
  bool _locationSharingEnabled = true;
  bool _photoStorageEnabled = true;
  bool _notificationEnabled = true;
  bool _analyticsEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'Privacy & Keamanan',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.security,
                    color: Colors.green[700],
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'GreenGrow melindungi data pertanian dan informasi pribadi Anda dengan enkripsi tingkat tinggi.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Pengaturan Privacy
            _buildPrivacySection(
              'Pengaturan Data & Privacy',
              [
                _buildSwitchTile(
                  'Pengumpulan Data Sensor',
                  'Izinkan aplikasi mengumpulkan data suhu dan kelembapan untuk analisis',
                  Icons.sensors,
                  _dataCollectionEnabled,
                  (value) {
                    setState(() {
                      _dataCollectionEnabled = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  'Berbagi Lokasi Greenhouse',
                  'Gunakan GPS untuk menampilkan lokasi greenhouse di peta',
                  Icons.location_on,
                  _locationSharingEnabled,
                  (value) {
                    setState(() {
                      _locationSharingEnabled = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  'Penyimpanan Foto Perawatan',
                  'Simpan foto bukti perawatan tanaman di server lokal',
                  Icons.photo_camera,
                  _photoStorageEnabled,
                  (value) {
                    setState(() {
                      _photoStorageEnabled = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  'Notifikasi Push',
                  'Terima notifikasi untuk kondisi suhu abnormal',
                  Icons.notifications,
                  _notificationEnabled,
                  (value) {
                    setState(() {
                      _notificationEnabled = value;
                    });
                  },
                ),
                _buildSwitchTile(
                  'Analytics & Laporan',
                  'Bantu tingkatkan aplikasi dengan berbagi data analytics (anonim)',
                  Icons.analytics,
                  _analyticsEnabled,
                  (value) {
                    setState(() {
                      _analyticsEnabled = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Keamanan Akun
            _buildPrivacySection(
              'Keamanan Akun',
              [
                _buildActionTile(
                  'Ubah Password',
                  'Perbarui password untuk keamanan akun',
                  Icons.lock_outline,
                  () {
                    _showChangePasswordDialog();
                  },
                ),
                _buildActionTile(
                  'Riwayat Login',
                  'Lihat aktivitas login terakhir',
                  Icons.history,
                  () {
                    _showLoginHistoryDialog();
                  },
                ),
                _buildActionTile(
                  'Perangkat Terdaftar',
                  'Kelola perangkat yang terhubung dengan akun',
                  Icons.devices,
                  () {
                    _showDevicesDialog();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Data Management
            _buildPrivacySection(
              'Manajemen Data',
              [
                _buildActionTile(
                  'Export Data Sensor',
                  'Unduh riwayat data suhu dan kelembapan dalam format PDF',
                  Icons.file_download,
                  () {
                    _showExportDialog();
                  },
                ),
                _buildActionTile(
                  'Hapus Data Lokal',
                  'Bersihkan data sensor yang tersimpan di perangkat',
                  Icons.delete_outline,
                  () {
                    _showDeleteLocalDataDialog();
                  },
                ),
                _buildActionTile(
                  'Backup & Restore',
                  'Cadangkan atau pulihkan pengaturan aplikasi',
                  Icons.backup,
                  () {
                    _showBackupDialog();
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Informasi Legal
            _buildPrivacySection(
              'Informasi Legal',
              [
                _buildActionTile(
                  'Kebijakan Privasi',
                  'Baca kebijakan privasi lengkap GreenGrow',
                  Icons.policy,
                  () {
                    _showPrivacyPolicyDialog();
                  },
                ),
                _buildActionTile(
                  'Syarat & Ketentuan',
                  'Lihat syarat penggunaan aplikasi',
                  Icons.description,
                  () {
                    _showTermsDialog();
                  },
                ),
                _buildActionTile(
                  'Kontak Support',
                  'Hubungi tim dukungan untuk pertanyaan privacy',
                  Icons.support_agent,
                  () {
                    _showSupportDialog();
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, IconData icon, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.green[700],
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.green,
      ),
    );
  }

  Widget _buildActionTile(String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.green[700],
        size: 24,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[400],
      ),
      onTap: onTap,
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ubah Password'),
        content: const Text('Fitur ubah password akan segera tersedia. Anda akan diarahkan ke halaman keamanan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLoginHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Riwayat Login'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLoginHistoryItem('Android - Samsung Galaxy', '2 jam yang lalu', true),
            _buildLoginHistoryItem('Web Browser - Chrome', '1 hari yang lalu', false),
            _buildLoginHistoryItem('Android - Xiaomi Redmi', '3 hari yang lalu', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginHistoryItem(String device, String time, bool isActive) {
    return ListTile(
      leading: Icon(
        Icons.smartphone,
        color: isActive ? Colors.green : Colors.grey,
      ),
      title: Text(device),
      subtitle: Text(time),
      trailing: isActive 
        ? Chip(
            label: const Text('Aktif', style: TextStyle(fontSize: 10)),
            backgroundColor: Colors.green[100],
          )
        : null,
    );
  }

  void _showDevicesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Perangkat Terdaftar'),
        content: const Text('Berikut perangkat IoT yang terhubung:\n\n• ESP32-Greenhouse-01\n• Sensor DHT22-01\n• Blower Control-01\n• Sprayer Control-01'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Export Data Sensor'),
        content: const Text('Pilih rentang waktu untuk export data sensor suhu dan kelembapan dalam format PDF.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Implement export functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Export data dimulai...')),
              );
            },
            child: const Text('Export'),
          ),
        ],
      ),
    );
  }

  void _showDeleteLocalDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data Lokal'),
        content: const Text('Apakah Anda yakin ingin menghapus semua data sensor yang tersimpan di perangkat? Data di server tetap aman.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data lokal berhasil dihapus')),
              );
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup & Restore'),
        content: const Text('Pilih aksi yang ingin dilakukan:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Backup berhasil dibuat')),
              );
            },
            child: const Text('Backup'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Restore berhasil dilakukan')),
              );
            },
            child: const Text('Restore'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kebijakan Privasi'),
        content: const SingleChildScrollView(
          child: Text(
            'GreenGrow berkomitmen melindungi privasi pengguna:\n\n'
            '1. Data sensor (suhu & kelembapan) hanya digunakan untuk monitoring greenhouse\n\n'
            '2. Lokasi GPS hanya digunakan untuk menampilkan posisi greenhouse di peta\n\n'
            '3. Foto perawatan disimpan secara aman di server lokal\n\n'
            '4. Data tidak dibagikan kepada pihak ketiga tanpa izin\n\n'
            '5. Enkripsi end-to-end untuk semua komunikasi data\n\n'
            '6. Pengguna dapat menghapus data kapan saja',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Syarat & Ketentuan'),
        content: const Text('Dengan menggunakan GreenGrow, Anda menyetujui syarat dan ketentuan penggunaan aplikasi monitoring greenhouse ini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kontak Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hubungi tim dukungan GreenGrow:'),
            const SizedBox(height: 12),
            const Text('📧 Email: support@greengrow.app'),
            const Text('📱 WhatsApp: +62 812-3456-7890'),
            const Text('🕒 Senin-Jumat, 08:00-17:00 WIB'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}