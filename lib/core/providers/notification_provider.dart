import 'package:flutter/foundation.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationRepository _notificationRepository;
  int _unreadCount = 0;
  bool _isLoading = false;

  NotificationProvider(this._notificationRepository);

  int get unreadCount => _unreadCount;
  bool get isLoading => _isLoading;

  Future<void> loadUnreadCount() async {
    try {
      _isLoading = true;
      notifyListeners();
      
      _unreadCount = await _notificationRepository.getUnreadCount();
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading unread count: $e');
    }
  }

  void decrementUnreadCount() {
    if (_unreadCount > 0) {
      _unreadCount--;
      notifyListeners();
    }
  }

  void resetUnreadCount() {
    _unreadCount = 0;
    notifyListeners();
  }
}