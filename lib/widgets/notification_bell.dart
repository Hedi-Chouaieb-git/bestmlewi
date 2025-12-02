import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/auth_service.dart';
import '../models/notification.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  final NotificationService _notificationService = NotificationService();
  final AuthService _authService = AuthService();
  int _unreadCount = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    final userId = await _authService.getCurrentUserId();
    if (userId != null) {
      // Initialize local notifications if not already done
      await _notificationService.initializeLocalNotifications();

      _notificationService.initializeRealtimeNotifications(userId);
      _loadUnreadCount();

      // Listen to real-time notifications
      _notificationService.notificationStream.listen((notification) {
        if (mounted) {
          setState(() {
            if (!notification.lue) _unreadCount++;
          });
        }
      });
    }
    setState(() => _isInitialized = true);
  }

  Future<void> _loadUnreadCount() async {
    final userId = await _authService.getCurrentUserId();
    if (userId != null) {
      final count = await _notificationService.getUnreadCount(userId);
      if (mounted) {
        setState(() => _unreadCount = count);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const SizedBox.shrink();
    }

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications, color: Colors.white),
          onPressed: () => _showNotificationsDialog(context),
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              constraints: const BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  void _showNotificationsDialog(BuildContext context) async {
    final userId = await _authService.getCurrentUserId();
    if (userId == null) return;

    final notifications = await _notificationService.fetchNotifications(userId);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2B2B2B),
        title: const Text(
          'Notifications',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: notifications.isEmpty
              ? const Center(
                  child: Text(
                    'Aucune notification',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return ListTile(
                      title: Text(
                        notification.titre,
                        style: TextStyle(
                          color: notification.lue ? Colors.white70 : Colors.white,
                          fontWeight: notification.lue ? FontWeight.normal : FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        notification.message,
                        style: TextStyle(
                          color: notification.lue ? Colors.white54 : Colors.white70,
                        ),
                      ),
                      trailing: notification.lue
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.mark_as_unread, color: Colors.white70),
                              onPressed: () async {
                                await _notificationService.markAsRead(notification.idNotification);
                                setState(() => _unreadCount--);
                                Navigator.of(context).pop();
                                _showNotificationsDialog(context);
                              },
                            ),
                      onTap: () async {
                        if (!notification.lue) {
                          await _notificationService.markAsRead(notification.idNotification);
                          setState(() => _unreadCount--);
                        }
                        Navigator.of(context).pop();
                        _showNotificationsDialog(context);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Fermer',
              style: TextStyle(color: Color(0xFFFF6B35)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notificationService.dispose();
    super.dispose();
  }
}
