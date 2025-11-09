import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../core/providers/notification_provider.dart';
import '../../widgets/notification_card.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  List<NotificationModel> _notifications = [];
  int _currentPage = 1;
  int _totalPages = 1;
  bool _unreadOnly = false;
  late NotificationRepository _notificationRepository;

  @override
  void initState() {
    super.initState();
    _notificationRepository = NotificationRepository(
      Dio(),
      const FlutterSecureStorage(),
    );
    _scrollController.addListener(_scrollListener);
    _loadNotifications();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (_currentPage < _totalPages) {
        _loadMore();
      }
    }
  }

  Future<void> _loadNotifications({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
      });
    }
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    
    try {
      final result = await _notificationRepository.getNotifications(
        page: _currentPage,
        unreadOnly: _unreadOnly,
      );
      
      setState(() {
        _notifications = refresh
            ? result['notifications']
            : [..._notifications, ...result['notifications']];
        _totalPages = result['totalPages'];
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_currentPage < _totalPages) {
      setState(() {
        _currentPage++;
      });
      await _loadNotifications();
    }
  }

  Future<void> _markAsRead(NotificationModel notification) async {
    try {
      await _notificationRepository.markAsRead(notification.id);
      setState(() {
        final index = _notifications.indexOf(notification);
        if (index != -1) {
          final updatedNotification = NotificationModel(
            id: notification.id,
            userId: notification.userId,
            title: notification.title,
            message: notification.message,
            type: notification.type,
            data: notification.data,
            isRead: true,
            createdAt: notification.createdAt,
            updatedAt: DateTime.now(),
          );
          _notifications[index] = updatedNotification;
        }
      });
      
      // Update the unread count in the provider
      if (!notification.isRead) {
        final provider = Provider.of<NotificationProvider>(context, listen: false);
        provider.decrementUnreadCount();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menandai notifikasi sebagai dibaca')),
      );
    }
  }

  Future<void> _markAllAsRead() async {
    try {
      await _notificationRepository.markAllAsRead();
      setState(() {
        _notifications = _notifications.map((notification) {
          return NotificationModel(
            id: notification.id,
            userId: notification.userId,
            title: notification.title,
            message: notification.message,
            type: notification.type,
            data: notification.data,
            isRead: true,
            createdAt: notification.createdAt,
            updatedAt: DateTime.now(),
          );
        }).toList();
      });
      
      // Reset the unread count in the provider
      final provider = Provider.of<NotificationProvider>(context, listen: false);
      provider.resetUnreadCount();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua notifikasi ditandai sebagai dibaca')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menandai semua notifikasi sebagai dibaca')),
      );
    }
  }

  Future<void> _deleteNotification(NotificationModel notification) async {
    try {
      await _notificationRepository.deleteNotification(notification.id);
      setState(() {
        _notifications.remove(notification);
      });
      
      // Update unread count if needed
      if (!notification.isRead) {
        final provider = Provider.of<NotificationProvider>(context, listen: false);
        provider.decrementUnreadCount();
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Notifikasi dihapus')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal menghapus notifikasi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline),
            onPressed: _notifications.isEmpty ? null : _markAllAsRead,
            tooltip: 'Tandai semua sudah dibaca',
          ),
          IconButton(
            icon: Icon(_unreadOnly 
                ? Icons.visibility_off 
                : Icons.visibility),
            onPressed: () {
              setState(() {
                _unreadOnly = !_unreadOnly;
              });
              _loadNotifications(refresh: true);
            },
            tooltip: _unreadOnly 
                ? 'Tampilkan semua notifikasi' 
                : 'Hanya belum dibaca',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading && _notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Error: $_errorMessage',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadNotifications(refresh: true),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      );
    }
    
    if (_notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _unreadOnly 
                  ? 'Tidak ada notifikasi yang belum dibaca' 
                  : 'Tidak ada notifikasi',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => _loadNotifications(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _notifications.length + (_currentPage < _totalPages ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _notifications.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          final notification = _notifications[index];
          return Dismissible(
            key: Key('notification-${notification.id}'),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (_) => _deleteNotification(notification),
            child: NotificationCard(
              notification: notification,
              onTap: () {
                if (!notification.isRead) {
                  _markAsRead(notification);
                }
                _showNotificationDetail(notification);
              },
              onMarkRead: !notification.isRead 
                  ? () => _markAsRead(notification) 
                  : null,
            ),
          );
        },
      ),
    );
  }

  void _showNotificationDetail(NotificationModel notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(notification.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(notification.message),
              const SizedBox(height: 16),
              if (notification.data != null) ...[
                const Text(
                  'Detail:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                _buildNotificationDataDetail(notification),
              ],
              const SizedBox(height: 16),
              Text(
                'Waktu: ${DateFormat('dd MMM yyyy, HH:mm').format(notification.createdAt)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationDataDetail(NotificationModel notification) {
    if (notification.data == null) return const SizedBox();
    
    final data = notification.data!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (data.containsKey('temperature'))
          Text('Suhu: ${data['temperature']}°C'),
        if (data.containsKey('humidity'))
          Text('Kelembapan: ${data['humidity']}%'),
        if (data.containsKey('threshold'))
          Text('Ambang batas: ${data['threshold']}${notification.type.contains('temperature') ? '°C' : '%'}'),
      ],
    );
  }
}