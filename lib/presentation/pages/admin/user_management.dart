import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:greengrow_app/data/models/user_model.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isLoading = false;
  
  // Sample data - replace with actual data from your backend
  List<User> _users = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchUsersFromBackend();
  }

  Future<void> _fetchUsersFromBackend() async {
    setState(() { _isLoading = true; });
    try {
      final storage = const FlutterSecureStorage();
      final dio = Dio();
      final token = await storage.read(key: 'auth_token');
      final response = await dio.get(
        'http://10.0.2.2:3000/api/users',
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
      final List<dynamic> data = response.data['data'] ?? response.data;
      _users = data.map<User>((json) => User(
        id: json['id'] is int ? json['id'] : int.tryParse(json['id'].toString()) ?? 0,
        name: json['full_name'] ?? '',
        email: json['email'] ?? '',
        role: (json['role_id'] == 1) ? UserRole.admin : UserRole.petani,
        phone: json['phone_number'] ?? '',
        // location: json['profile_photo'] ?? '-', // Hapus location
        isActive: json['is_active'] == 1 || json['is_active'] == true,
        lastActive: DateTime.tryParse(json['last_login']?.toString() ?? '') ?? DateTime.now(),
        joinDate: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
        avatar: '',
      )).toList();
    } catch (e) {
      // ignore error, show empty
    }
    setState(() { _isLoading = false; });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<User> get _filteredUsers {
    if (_searchQuery.isEmpty) return _users;
    return _users.where((user) {
      return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.phone.contains(_searchQuery);
    }).toList();
  }

  List<User> get _adminUsers =>
      _filteredUsers.where((user) => user.role == UserRole.admin).toList();

  List<User> get _petaniUsers =>
      _filteredUsers.where((user) => user.role == UserRole.petani).toList();

  bool get _isCurrentUserAdmin {
    // Cek role user login dari secure storage (atau provider jika ada)
    // Sementara, asumsikan token admin tersimpan di secure storage dengan key 'user_role'
    // Jika tidak ada, tombol delete tetap tampil
    // Untuk produksi, sebaiknya gunakan provider/auth state
    return true; // Ganti dengan pengecekan role admin jika sudah ada
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF1A1F2E),
        foregroundColor: Colors.white,
        title: const Text(
          'User Management',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshUsers,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildAllUsersTab(),
                      _buildRoleUsersTab(_adminUsers),
                      _buildRoleUsersTab(_petaniUsers),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1F2E),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Users',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_users.length}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Active Users',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_users.where((u) => u.isActive).length}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2ECC71),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Admins',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_adminUsers.length}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Search users...',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF1A1F2E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: const Color(0xFF1A1F2E),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF2ECC71),
        labelColor: const Color(0xFF2ECC71),
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: [
          Tab(text: 'All (${_filteredUsers.length})'),
          Tab(text: 'Admin (${_adminUsers.length})'),
          Tab(text: 'Petani (${_petaniUsers.length})'),
        ],
      ),
    );
  }

  Widget _buildAllUsersTab() {
    return _buildUsersList(_filteredUsers);
  }

  Widget _buildRoleUsersTab(List<User> users) {
    return _buildUsersList(users);
  }

  Widget _buildUsersList(List<User> users) {
    if (users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Color(0xFF9CA3AF),
            ),
            SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(User user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1F2E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: const Color(0xFF2ECC71),
              child: Text(
                user.name.split(' ').map((e) => e[0]).take(2).join().toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: user.isActive ? const Color(0xFF2ECC71) : const Color(0xFF6B7280),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          user.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              user.email,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildRoleBadge(user.role),
                const SizedBox(width: 8),
                // Hapus location
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Last active: ${_formatLastActive(user.lastActive)}',
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUserAction(value, user),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 20),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            // Hapus edit & delete
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(UserRole role) {
    Color backgroundColor;
    Color textColor;
    String text;

    switch (role) {
      case UserRole.admin:
        backgroundColor = const Color(0xFF3B82F6);
        textColor = Colors.white;
        text = 'Admin';
        break;
      case UserRole.petani:
        backgroundColor = const Color(0xFF10B981);
        textColor = Colors.white;
        text = 'Petani';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatLastActive(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  void _refreshUsers() {
    _fetchUsersFromBackend();
    HapticFeedback.lightImpact();
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.file_download),
              title: const Text('Export Users'),
              onTap: () {
                Navigator.pop(context);
                _exportUsers();
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('User Settings'),
              onTap: () {
                Navigator.pop(context);
                _showUserSettings();
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const Text('Help'),
              onTap: () {
                Navigator.pop(context);
                _showHelp();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleUserAction(String action, User user) {
    switch (action) {
      case 'view':
        _showUserDetails(user);
        break;
      // Hapus edit & delete
    }
  }

  void _showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) => UserDetailsDialog(user: user),
    );
  }

  void _exportUsers() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export feature coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showUserSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('User settings coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showHelp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Help documentation coming soon'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

// User Model
class User {
  final int id;
  final String name;
  final String email;
  final UserRole role;
  final String phone;
  bool isActive;
  final DateTime lastActive;
  final DateTime joinDate;
  final String avatar;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.isActive,
    required this.lastActive,
    required this.joinDate,
    required this.avatar,
  });
}

enum UserRole { admin, petani }

// User Details Dialog
class UserDetailsDialog extends StatelessWidget {
  final User user;

  const UserDetailsDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(user.name),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('Email', user.email),
          _buildDetailRow('Phone', user.phone),
          _buildDetailRow('Role', user.role == UserRole.admin ? 'Admin' : 'Petani'),
          // Hapus location
          _buildDetailRow('Status', user.isActive ? 'Active' : 'Inactive'),
          _buildDetailRow('Join Date', _formatDate(user.joinDate)),
          _buildDetailRow('Last Active', _formatLastActive(user.lastActive)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatLastActive(DateTime lastActive) {
    final now = DateTime.now();
    final difference = now.difference(lastActive);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}