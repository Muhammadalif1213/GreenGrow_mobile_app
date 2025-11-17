import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';

class ProfileFarmerScreen extends StatefulWidget {
  const ProfileFarmerScreen({Key? key}) : super(key: key);

  @override
  State<ProfileFarmerScreen> createState() => _ProfileFarmerScreenState();
}

class _ProfileFarmerScreenState extends State<ProfileFarmerScreen> {
  @override
  void initState() {
    super.initState();
    // Load user profile when screen is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).loadUserProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final userProfile = authProvider.userProfile;
        
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
              'Profile Petani',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  // Action untuk edit profile
                  _showEditDialog(context);
                },
                icon: const Icon(
                  Icons.edit_outlined,
                  color: Colors.black,
                ),
              ),
            ],
          ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Profile Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
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
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.green[100],
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userProfile?.username ?? 'Loading...',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.email,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        userProfile?.email ?? 'Loading...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Informasi Pribadi
            _buildInfoSection(
              'Informasi Pribadi',
              [
                //  _buildInfoItem('ID User', userProfile?.id.toString() ?? 'Loading...'),
                _buildInfoItem('Nama Lengkap', userProfile?.fullName ?? 'Loading...'),
                _buildInfoItem('Email', userProfile?.email ?? 'Loading...'),
                _buildInfoItem('Nomor Telepon', userProfile?.phoneNumber ?? 'Tidak tersedia'),
                _buildInfoItem('Role', userProfile?.role == 'farmer' ? 'Petani' : userProfile?.role ?? 'Loading...'),
              ],
            ),
            const SizedBox(height: 16),

            // Informasi Akun
            _buildInfoSection(
              'Informasi Akun',
              [
                _buildInfoItem('Status Akun', 'Aktif'),
                _buildInfoItem('Bergabung Sejak', '2024'),
                _buildInfoItem('Terakhir Login', 'Hari ini'),
              ],
            ),
            const SizedBox(height: 16),


          ],
        ),
      ),
    );
      },
    );
  }

  Widget _buildInfoSection(String title, List<Widget> items) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(': ', style: TextStyle(fontSize: 14)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }



  void _showEditDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: const Text('Fitur edit profile akan segera tersedia.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showContactDialog(BuildContext context) {
    final userProfile = Provider.of<AuthProvider>(context, listen: false).userProfile;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Informasi Kontak'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.email, color: Colors.orange),
                title: const Text('Email'),
                subtitle: Text(userProfile?.email ?? 'Tidak tersedia'),
                onTap: () {
                  Navigator.of(context).pop();
                  // Launch email
                },
              ),
              if (userProfile?.phoneNumber != null)
                ListTile(
                  leading: const Icon(Icons.phone, color: Colors.green),
                  title: const Text('Telepon'),
                  subtitle: Text(userProfile!.phoneNumber!),
                  onTap: () {
                    Navigator.of(context).pop();
                    // Launch phone call
                  },
                ),
              ListTile(
                leading: const Icon(Icons.person, color: Colors.blue),
                title: const Text('Username'),
                subtitle: Text(userProfile?.username ?? 'Tidak tersedia'),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }
}