import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// --- IMPORTS (SESUAIKAN PATH ANDA) ---
import 'package:greengrow_app/data/models/user_model.dart';
import 'package:greengrow_app/data/repositories/user_management_repository.dart';
import 'package:greengrow_app/presentation/blocs/get_users/get_users_bloc.dart';
import '../../widgets/system_log_section.dart';
import '../auth/register_screen.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({super.key});

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage>
    with SingleTickerProviderStateMixin {
  // Instance Repository dibuat di sini agar bisa dishare ke Bloc & Log Widget
  late final UserManagementRepository _repository;

  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // 1. Inisialisasi Repository
    _repository = UserManagementRepository(Dio(), const FlutterSecureStorage());

    // 2. TabController Length = 4 (All, Admin, Petani, Log)
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  // --- FILTER HELPER ---
  List<UserModel> _filterUsers(List<UserModel> users) {
    if (_searchQuery.isEmpty) return users;
    final query = _searchQuery.toLowerCase();
    return users.where((user) {
      final name = user.fullName.toLowerCase();
      final email = user.email.toLowerCase();
      final phone = user.phoneNumber?.toLowerCase() ?? '';
      return name.contains(query) ||
          email.contains(query) ||
          phone.contains(query);
    }).toList();
  }

  List<UserModel> _getUsersByRole(List<UserModel> users, String role) {
    return users
        .where((user) => user.role.toLowerCase() == role.toLowerCase())
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          UserManagementBloc(_repository)..add(FetchAllUsers()),
      child: Scaffold(
        backgroundColor: const Color(0xFF0F1419), // Dark Background
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
            Builder(builder: (context) {
              return IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: () {
                  context.read<UserManagementBloc>().add(FetchAllUsers());
                  HapticFeedback.lightImpact();
                },
              );
            }),
            Builder(builder: (context) {
              return IconButton(
                icon: const Icon(Icons.person_add_alt_rounded,
                    color: Colors.white),
                onPressed: () => _showMoreOptions(context),
              );
            }),
          ],
        ),

        // Menggunakan BlocConsumer untuk menghandle state List User
        body: BlocConsumer<UserManagementBloc, GetUsersState>(
          listener: (context, state) {
            if (state is GetUsersError) {
              // Error snackbar jika bukan loading awal (misal gagal delete)
              if (!state.message.toLowerCase().contains("memuat")) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red),
                );
              }
            }
          },
          builder: (context, state) {
            // STATE: LOADING
            if (state is GetUsersLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // STATE: ERROR (Initial Load)
            if (state is GetUsersError &&
                state.message.toLowerCase().contains("memuat")) {
              return _buildErrorState(context, state.message);
            }

            // STATE: LOADED
            if (state is GetUsersLoaded) {
              final allUsers = state.users;
              final filteredUsers = _filterUsers(allUsers);
              final adminUsers = _getUsersByRole(filteredUsers, 'admin');
              final farmerUsers = _getUsersByRole(filteredUsers, 'farmer');

              return Column(
                children: [
                  _buildHeader(allUsers),
                  _buildSearchBar(),

                  // --- TAB BAR ---
                  Container(
                    width: double.infinity, // Pastikan lebar container full
                    decoration: const BoxDecoration(
                      color: Color(0xFF1A1F2E),
                      border: Border(
                        bottom: BorderSide(
                            color: Colors.white10,
                            width: 1), // Garis tipis pemisah bawah
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,

                      // --- STYLE VISUAL ---
                      indicatorColor: const Color(0xFF2ECC71),
                      indicatorSize: TabBarIndicatorSize
                          .tab, // Indicator selebar tab, bukan selebar teks
                      indicatorWeight: 3,
                      labelColor: const Color(0xFF2ECC71),
                      unselectedLabelColor: Colors.grey[500],
                      labelStyle: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),

                      // --- PENGATURAN LAYOUT (Agar tidak nanggung) ---
                      isScrollable: true, // Wajib true karena ada 4 tab
                      tabAlignment:
                          TabAlignment.start, // (PENTING) Rata kiri agar rapi
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0), // Hilangkan padding luar
                      labelPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4), // Jarak antar teks lebih lega
                      dividerColor: Colors
                          .transparent, // Menghilangkan garis default Material 3
                      physics:
                          const BouncingScrollPhysics(), // Scroll terasa lebih smooth

                      tabs: [
                        Tab(text: 'All (${filteredUsers.length})'),
                        Tab(text: 'Admin (${adminUsers.length})'),
                        Tab(text: 'Petani (${farmerUsers.length})'),
                        // Tips: Nama tab "Log Aktivitas" agak panjang, "Activity" atau "Logs" lebih hemat tempat
                        const Tab(text: 'Log Aktivitas'),
                      ],
                    ),
                  ),

                  // --- TAB VIEW ---
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Tab 1: All Users
                        _buildUsersList(filteredUsers, context),
                        // Tab 2: Admin
                        _buildUsersList(adminUsers, context),
                        // Tab 3: Petani
                        _buildUsersList(farmerUsers, context),
                        // Tab 4: System Log (Dark Mode Version)
                        SystemLogSection(repository: _repository),
                      ],
                    ),
                  ),
                ],
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  // ==================== WIDGET BUILDERS ====================

  Widget _buildErrorState(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(message,
              style: const TextStyle(color: Colors.white70),
              textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                context.read<UserManagementBloc>().add(FetchAllUsers()),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(List<UserModel> users) {
    final adminCount =
        users.where((u) => u.role.toLowerCase() == 'admin').length;
    final farmerCount =
        users.where((u) => u.role.toLowerCase() == 'farmer').length;

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
          _buildHeaderItem('Admins', '$adminCount', const Color(0xFF3B82F6)),
          _buildHeaderItem('Farmers', '$farmerCount', const Color(0xFF10B981)),
        ],
      ),
    );
  }

  Widget _buildHeaderItem(String label, String value, Color valueColor) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: valueColor)),
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
        onChanged: (value) => setState(() => _searchQuery = value),
        decoration: InputDecoration(
          hintText: 'Search users...',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: Colors.white70),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.white70),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF1A1F2E),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildUsersList(List<UserModel> users, BuildContext context) {
    if (users.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 64, color: Color(0xFF9CA3AF)),
            SizedBox(height: 16),
            Text('No users found',
                style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (ctx, index) => _buildUserCard(users[index], context),
    );
  }

  Widget _buildUserCard(UserModel user, BuildContext context) {
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
              offset: const Offset(0, 2)),
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
                    color: Colors.white, fontWeight: FontWeight.bold),
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
        title: Text(user.fullName,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Colors.white)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(user.email,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 8),
            _buildRoleBadge(user.role),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleUserAction(value, user, context),
          itemBuilder: (context) => [
            const PopupMenuItem(
                value: 'view',
                child: Row(children: [
                  Icon(Icons.visibility, size: 20, color: Colors.grey),
                  SizedBox(width: 8),
                  Text('View Details')
                ])),
            const PopupMenuItem(
                value: 'delete',
                child: Row(children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete User', style: TextStyle(color: Colors.red))
                ])),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    Color backgroundColor;
    final roleLower = role.toLowerCase();
    if (roleLower == 'admin' || roleLower == 'superadmin') {
      backgroundColor = const Color(0xFF3B82F6);
    } else {
      backgroundColor = const Color(0xFF10B981);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: backgroundColor, borderRadius: BorderRadius.circular(12)),
      child: Text(role,
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }

  // --- ACTIONS ---

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1F2E),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.admin_panel_settings_rounded,
                  color: Colors.white),
              title: const Text('Add New Admin',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Fitur tambah admin segera hadir')));
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add_alt_1_rounded,
                  color: Colors.white),
              title: const Text('Add New Farmer',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BlocProvider.value(
                            value: context.read<UserManagementBloc>(),
                            child: const RegisterScreen())));
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleUserAction(String action, UserModel user, BuildContext context) {
    if (action == 'view') _showUserDetails(user, context);
    if (action == 'delete') _showDeleteConfirmation(user, context);
  }

  void _showDeleteConfirmation(UserModel user, BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F2E),
        title: const Text('Delete User', style: TextStyle(color: Colors.white)),
        content: Text('Are you sure you want to delete "${user.fullName}"?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (user.uid != null) {
                context.read<UserManagementBloc>().add(DeleteUser(user.uid!));
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Deleting user...'),
                    duration: Duration(seconds: 1)));
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(UserModel user, BuildContext context) {
    showDialog(
        context: context, builder: (context) => UserDetailsDialog(user: user));
  }
}

// --- USER DETAILS DIALOG (Tetap) ---
class UserDetailsDialog extends StatelessWidget {
  final UserModel user;
  const UserDetailsDialog({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    DateTime? joinDate;
    try {
      if (user.createdAt != null) joinDate = DateTime.parse(user.createdAt!);
    } catch (_) {}

    return AlertDialog(
      backgroundColor: const Color(0xFF1A1F2E),
      title: Text(user.fullName, style: const TextStyle(color: Colors.white)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _row('UID', user.uid ?? '-'),
            _row('Username', user.username),
            _row('Email', user.email),
            _row('Phone', user.phoneNumber ?? '-'),
            _row('Role', user.role),
            _row('Status', (user.isActive ?? false) ? 'Active' : 'Inactive'),
            if (joinDate != null)
              _row('Joined',
                  '${joinDate.day}/${joinDate.month}/${joinDate.year}'),
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Colors.white)))
      ],
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 80,
              child: Text('$label:',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.white70))),
          Expanded(
              child: Text(value, style: const TextStyle(color: Colors.white))),
        ],
      ),
    );
  }
}
