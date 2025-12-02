import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  StreamSubscription? _subscription;

  // Flutter Local Notifications
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  // Stream controller for real-time notifications
  final StreamController<NotificationModel> _notificationController = StreamController<NotificationModel>.broadcast();
  Stream<NotificationModel> get notificationStream => _notificationController.stream;

  // Initialize Flutter Local Notifications
  Future<void> initializeLocalNotifications() async {
    print('🔧 Initializing local notifications...');

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
        print('🔔 Notification tapped: ${response.payload}');
      },
    );

    // Request notification permissions
    final status = await Permission.notification.request();
    print('📱 Notification permission status: $status');

    if (status.isGranted) {
      print('✅ Notification permissions granted');
    } else {
      print('❌ Notification permissions denied');
    }

    // Create notification channels for Android
    const AndroidNotificationChannel staffChannel = AndroidNotificationChannel(
      'order_notifications',
      'Staff Order Notifications',
      description: 'Notifications for staff order updates',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    const AndroidNotificationChannel clientChannel = AndroidNotificationChannel(
      'client_order_notifications',
      'Client Order Notifications',
      description: 'Notifications for client order updates',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(staffChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(clientChannel);

    print('🎯 Notification channels created');

    // Request notification permissions for Android 13+
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    print('✅ Local notifications initialized successfully');
  }

  // Initialize real-time subscription for notifications
  void initializeRealtimeNotifications(String userId) {
    print('📡 Initializing realtime notifications for user: $userId');

    _subscription = _supabase
        .from('Notifications')
        .stream(primaryKey: ['idNotification'])
        .eq('idDestinataire', userId)
        .listen((data) {
          print('📨 Realtime notification received: ${data.length} items');
          for (var item in data) {
            print('📨 Notification data: $item');
            final notification = NotificationModel.fromJson(item);
            _notificationController.add(notification);
            // Show push notification
            _showPushNotification(notification);
          }
        }, onError: (error) {
          print('❌ Realtime subscription error: $error');
        });

    print('✅ Realtime subscription initialized');
  }

  // Show push notification
  Future<void> _showPushNotification(NotificationModel notification) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'order_notifications',
      'Order Notifications',
      channelDescription: 'Notifications for order updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      notification.idNotification.hashCode,
      notification.titre,
      notification.message,
      platformChannelSpecifics,
      payload: notification.idCommande,
    );
  }

  // Show push notification for clients (not stored in database)
  Future<void> showClientNotification({
    required String orderId,
    required String title,
    required String message,
  }) async {
    print('📱 Showing client push notification:');
    print('   - Order ID: $orderId');
    print('   - Title: $title');
    print('   - Message: $message');

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'client_order_notifications',
      'Client Order Notifications',
      channelDescription: 'Notifications for client order updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch,
      title,
      message,
      platformChannelSpecifics,
      payload: orderId,
    );

    print('✅ Client push notification sent successfully');
  }

  // Dispose of the subscription
  void dispose() {
    _subscription?.cancel();
    _notificationController.close();
  }

  // Create a new notification
  Future<void> createNotification({
    required String recipientId,
    String? orderId,
    required String type,
    required String title,
    required String message,
  }) async {
    try {
      final notificationId = DateTime.now().millisecondsSinceEpoch.toString();
      print('💾 Creating notification in database:');
      print('   - ID: $notificationId');
      print('   - Recipient: $recipientId');
      print('   - Order: $orderId');
      print('   - Type: $type');
      print('   - Title: $title');
      print('   - Message: $message');

      await _supabase.from('Notifications').insert({
        'idNotification': notificationId,
        'idDestinataire': recipientId,
        'idCommande': orderId,
        'type': type,
        'titre': title,
        'message': message,
        'lue': false,
        'created_at': DateTime.now().toIso8601String(),
      });

      print('✅ Notification inserted successfully in database');
    } catch (e) {
      print('❌ Error creating notification: $e');
      rethrow;
    }
  }

  // Fetch notifications for a user
  Future<List<NotificationModel>> fetchNotifications(String userId) async {
    try {
      final response = await _supabase
          .from('Notifications')
          .select()
          .eq('idDestinataire', userId)
          .order('created_at', ascending: false);

      return response.map((item) => NotificationModel.fromJson(item)).toList();
    } catch (e) {
      print('Error fetching notifications: $e');
      return [];
    }
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('Notifications')
          .update({'lue': true})
          .eq('idNotification', notificationId);
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('Notifications')
          .delete()
          .eq('idNotification', notificationId);
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  // Get unread count
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _supabase
          .from('Notifications')
          .select('idNotification')
          .eq('idDestinataire', userId)
          .eq('lue', false);

      return response.length;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
}
