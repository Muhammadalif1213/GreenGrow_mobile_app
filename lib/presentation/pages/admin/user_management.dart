import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Import Arsitektur BLoC & Model yang sudah kita buat
import 'package:greengrow_app/data/models/user_model.dart';
import 'package:greengrow_app/data/repositories/user_management_repository.dart';
import 'package:greengrow_app/presentation/blocs/get_users/get_users_bloc.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // Helper untuk memfilter user berdasarkan search query
  List<UserModel> _filterUsers(List<UserModel> users) {
    if (_searchQuery.isEmpty) return users;
    return users.where((user) {
      final name = user.fullName.toLowerCase();
      final email = user.email.toLowerCase();
      final phone = user.phoneNumber?.toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();

      return name.contains(query) ||
          email.contains(query) ||
          phone.contains(query);
    }).toList();
  }

  // Helper untuk memfilter berdasarkan Role
  List<UserModel> _getUsersByRole(List<UserModel> users, String role) {
    return users
        .where((user) => user.role.toLowerCase() == role.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // Inject BLoC Provider di sini
    return BlocProvider(
      create: (context) => UserManagementBloc(
        UserManagementRepository(Dio(), const FlutterSecureStorage()),
      )..add(FetchAllUsers()), // Langsung fetch data saat halaman dibuka
      child: Scaffold(
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
            // Tombol Refresh menggunakan Builder untuk mengakses context BLoC
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: () {
                    context.read<UserManagementBloc>().add(FetchAllUsers());
                    HapticFeedback.lightImpact();
                  },
                );
              },
            ),
            IconButton(
              icon:
                  const Icon(Icons.person_add_alt_rounded, color: Colors.white),
              onPressed: () => _showMoreOptions(context),
            ),
          ],
        ),
        // Gunakan BlocBuilder untuk membangun UI berdasarkan State
        body: BlocBuilder<UserManagementBloc, GetUsersState>(
          builder: (context, state) {
            if (state is GetUsersLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is GetUsersError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<UserManagementBloc>().add(FetchAllUsers());
                      },
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            }

            if (state is GetUsersLoaded) {
              final allUsers = state.users;
              final filteredUsers = _filterUsers(allUsers);

              // Filter berdasarkan role (string dari API: 'admin', 'farmer')
              final adminUsers = _getUsersByRole(filteredUsers, 'admin');
              final farmerUsers = _getUsersByRole(filteredUsers,
                  'farmer'); // Sesuaikan string role dari API Anda

              return Column(
                children: [
                  _buildHeader(allUsers), // Pass semua user untuk statistik
                  _buildSearchBar(),
                  _buildTabBar(
                    allCount: filteredUsers.length,
                    adminCount: adminUsers.length,
                    petaniCount: farmerUsers.length,
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildUsersList(filteredUsers),
                        _buildUsersList(adminUsers),
                        _buildUsersList(farmerUsers),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const SizedBox(); // State Initial
          },
        ),
      ),
    );
  }

  Widget _buildHeader(List<UserModel> users) {
    final activeCount = users.where((u) => u.isActive == true).length;
    final adminCount =
        users.where((u) => u.role.toLowerCase() == 'admin').length;

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
          _buildHeaderItem('Total Users', '${users.length}', Colors.white),
          _buildHeaderItem(
              'Active Users', '$activeCount', const Color(0xFF2ECC71)),
          _buildHeaderItem('Admins', '$adminCount', const Color(0xFF3B82F6)),
        ],
      ),
    );
  }

  Widget _buildHeaderItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: valueColor,
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildTabBar(
      {required int allCount,
      required int adminCount,
      required int petaniCount}) {
    return Container(
      color: const Color(0xFF1A1F2E),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF2ECC71),
        labelColor: const Color(0xFF2ECC71),
        unselectedLabelColor: Colors.white70,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        tabs: [
          Tab(text: 'All ($allCount)'),
          Tab(text: 'Admin ($adminCount)'),
          Tab(text: 'Petani ($petaniCount)'),
        ],
      ),
    );
  }

  Widget _buildUsersList(List<UserModel> users) {
    if (users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Color(0xFF9CA3AF)),
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
        return _buildUserCard(user, context);
      },
    );
  }

  Widget _buildUserCard(UserModel user, BuildContext context) {
    // Parsing tanggal aman
    DateTime? lastActive;
    if (user.lastLogin != null && user.lastLogin!.isNotEmpty) {
      try {
        lastActive = DateTime.parse(user.lastLogin!);
      } catch (_) {}
    }

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
                user.fullName.isNotEmpty
                    ? user.fullName
                        .split(' ')
                        .map((e) => e.isNotEmpty ? e[0] : '')
                        .take(2)
                        .join()
                        .toUpperCase()
                    : 'U',
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
                  color: (user.isActive ?? false)
                      ? const Color(0xFF2ECC71)
                      : const Color(0xFF6B7280),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        title: Text(
          user.fullName,
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
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildRoleBadge(user.role),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              lastActive != null
                  ? 'Last active: ${_formatLastActive(lastActive)}'
                  : 'Last active: -',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUserAction(value, user, context),
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
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color backgroundColor;
    Color textColor;
    String text = role;

    // Normalisasi string role untuk pengecekan
    final roleLower = role.toLowerCase();

    if (roleLower == 'admin' || roleLower == 'superadmin') {
      backgroundColor = const Color(0xFF3B82F6);
      textColor = Colors.white;
      text = 'Admin';
    } else {
      backgroundColor = const Color(0xFF10B981);
      textColor = Colors.white;
      text = 'Petani';
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

  void _showMoreOptions(BuildContext context) {
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
              leading: const Icon(Icons.admin_panel_settings_rounded),
              title: const Text('Add New Admin'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Fitur tambah admin akan segera hadir')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add_alt_1_rounded),
              title: const Text('Add New Farmer'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/register');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleUserAction(String action, UserModel user, BuildContext context) {
    switch (action) {
      case 'view':
        _showUserDetails(user, context);
        break;
    }
  }

  void _showUserDetails(UserModel user, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => UserDetailsDialog(user: user),
    );
  }
}

// User Details Dialog yang disesuaikan dengan UserModel
class UserDetailsDialog extends StatelessWidget {
  final UserModel user;

  const UserDetailsDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    DateTime? joinDate;
    DateTime? lastActive;

    try {
      if (user.createdAt != null) joinDate = DateTime.parse(user.createdAt!);
      if (user.lastLogin != null) lastActive = DateTime.parse(user.lastLogin!);
    } catch (_) {}

    return AlertDialog(
      title: Text(user.fullName),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('UID', user.uid ?? '-'),
            _buildDetailRow('Username', user.username),
            _buildDetailRow('Email', user.email),
            _buildDetailRow('Phone', user.phoneNumber ?? '-'),
            _buildDetailRow('Role', user.role),
            _buildDetailRow(
                'Status', (user.isActive ?? false) ? 'Active' : 'Inactive'),
            if (joinDate != null)
              _buildDetailRow('Join Date', _formatDate(joinDate)),
            if (lastActive != null)
              _buildDetailRow('Last Active', _formatLastActive(lastActive)),
          ],
        ),
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
