import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:greengrow_app/data/models/system_log_model.dart';
import 'package:greengrow_app/data/repositories/user_management_repository.dart';

class SystemLogSection extends StatefulWidget {
  final UserManagementRepository repository;

  const SystemLogSection({super.key, required this.repository});

  @override
  State<SystemLogSection> createState() => _SystemLogSectionState();
}

class _SystemLogSectionState extends State<SystemLogSection> {
  late Future<List<SystemLog>> _logsFuture;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  void _loadLogs() {
    setState(() {
      _logsFuture = widget.repository.getSystemLogs();
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date.toLocal());
  }

  // Styling Dark Mode untuk Aksi
  Map<String, dynamic> _getActionStyle(String action) {
    final act = action.toLowerCase();
    if (act.contains('delete')) {
      return {
        'icon': Icons.delete_forever_outlined,
        'bg_color': Colors.red.withOpacity(0.15),
        'icon_color': Colors.redAccent,
        'label': 'User Deleted'
      };
    } else if (act.contains('register') || act.contains('create')) {
      return {
        'icon': Icons.person_add_alt_1_outlined,
        'bg_color': Colors.green.withOpacity(0.15),
        'icon_color': Colors.greenAccent,
        'label': 'New Registration'
      };
    }
    return {
      'icon': Icons.info_outline,
      'bg_color': Colors.grey.withOpacity(0.15),
      'icon_color': Colors.grey,
      'label': action.replaceAll('_', ' ').toUpperCase()
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SystemLog>>(
      future: _logsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent),
                const SizedBox(height: 8),
                Text("Gagal memuat log.\n${snapshot.error}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70)),
                TextButton(onPressed: _loadLogs, child: const Text("Coba Lagi"))
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
              child: Text("Belum ada aktivitas tercatat.",
                  style: TextStyle(color: Colors.white54)));
        }

        final logs = snapshot.data!;

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: logs.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final log = logs[index];
            final style = _getActionStyle(log.action);
            final targetName =
                log.payload?.name ?? log.payload?.email ?? "Unknown";

            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1F2E), // Card Color
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: style['bg_color'], shape: BoxShape.circle),
                  child:
                      Icon(style['icon'], color: style['icon_color'], size: 20),
                ),
                title: Text(style['label'],
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                        children: [
                          const TextSpan(text: "Target: "),
                          TextSpan(
                              text: targetName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.admin_panel_settings_outlined,
                            size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                            "${log.actor.name} • ${_formatDate(log.timestamp)}",
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[600])),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
