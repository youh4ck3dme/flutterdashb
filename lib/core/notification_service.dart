import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'models.dart';

/// Service for handling in-app and push notifications
enum NotificationType {
  bugAssigned,
  bugStatusChanged,
  bugComment,
  systemAlert,
  syncError,
  offlineWarning,
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final NotificationType type;
  final String? payload;
  final DateTime createdAt;
  bool read;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.payload,
    required this.createdAt,
    this.read = false,
  });

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => NotificationType.systemAlert,
      ),
      payload: map['payload'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      read: map['read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'type': type.name,
      'payload': payload,
      'created_at': createdAt.toIso8601String(),
      'read': read,
    };
  }
}

class NotificationService with ChangeNotifier {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() => _instance;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<AppNotification> _notifications = [];
  bool _initialized = false;
  bool _hasPermission = false;

  List<AppNotification> get notifications => List.unmodifiable(_notifications);
  bool get initialized => _initialized;
  bool get hasPermission => _hasPermission;

  int get unreadCount => _notifications.where((n) => !n.read).length;

  /// Initialize the notification service
  Future<void> init() async {
    if (_initialized) return;

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        _handleNotificationTap(response.payload);
      },
    );

    // Check permissions
    _hasPermission = await _requestPermission();
    _initialized = true;
    notifyListeners();
  }

  Future<bool> _requestPermission() async {
    try {
      // For Android 13+ we need to request permission
      // This is a simplified approach
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Show a local notification
  Future<void> showLocalNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.systemAlert,
    String? payload,
    int id = 0,
  }) async {
    if (!_initialized) await init();
    if (!_hasPermission) return;

    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      'dashboard_channel',
      'Centralny Dashboard',
      channelDescription: 'Notifikácie z Centralného Dashboardu',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await _notificationsPlugin.show(id, title, body, notificationDetails,
        payload: payload);

    // Also add to in-app notifications
    addNotification(
      title: title,
      body: body,
      type: type,
      payload: payload,
    );
  }

  /// Add notification to in-app list
  void addNotification({
    required String title,
    required String body,
    required NotificationType type,
    String? payload,
  }) {
    final notification = AppNotification(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      type: type,
      payload: payload,
      createdAt: DateTime.now(),
      read: false,
    );

    _notifications.insert(0, notification);
    notifyListeners();
  }

  /// Mark notification as read
  void markAsRead(String id) {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index].read = true;
      notifyListeners();
    }
  }

  /// Mark all notifications as read
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.read = true;
    }
    notifyListeners();
  }

  /// Clear all notifications
  void clearAll() {
    _notifications.clear();
    notifyListeners();
  }

  /// Clear only read notifications
  void clearRead() {
    _notifications.removeWhere((n) => n.read);
    notifyListeners();
  }

  /// Handle notification tap
  void _handleNotificationTap(String? payload) {
    if (payload != null && payload.isNotEmpty) {
      // Parse payload and navigate accordingly
      // Example payload: {"type": "bug", "id": "bug_123"}
      debugPrint('Notification tapped with payload: $payload');
    }
  }

  /// Show notification for bug assignment
  void notifyBugAssigned(Bug bug, String assignedToUserId) {
    addNotification(
      title: 'Nová priradená chyba',
      body: 'Chyba ${bug.trackingId}: ${bug.title} bola priradená Vám',
      type: NotificationType.bugAssigned,
      payload: '{"type":"bug","id":"${bug.id}"}',
    );

    showLocalNotification(
      title: 'Nová priradená chyba',
      body: 'Chyba ${bug.trackingId}: ${bug.title}',
      type: NotificationType.bugAssigned,
      payload: '{"type":"bug","id":"${bug.id}"}',
      id: bug.id.hashCode,
    );
  }

  /// Show notification for bug status change
  void notifyBugStatusChanged(Bug bug, String oldStatus, String newStatus) {
    addNotification(
      title: 'Zmena stavu chyby',
      body: 'Chyba ${bug.trackingId}: Stav zmenený z ${_getStatusLabel(oldStatus)} na ${_getStatusLabel(newStatus)}',
      type: NotificationType.bugStatusChanged,
      payload: '{"type":"bug","id":"${bug.id}"}',
    );

    showLocalNotification(
      title: 'Zmena stavu chyby',
      body: 'Chyba ${bug.trackingId}: ${bug.title}',
      type: NotificationType.bugStatusChanged,
      payload: '{"type":"bug","id":"${bug.id}"}',
      id: bug.id.hashCode + newStatus.hashCode,
    );
  }

  /// Show notification for sync errors
  void notifySyncError(String errorMessage) {
    addNotification(
      title: 'Chyba synchronizácie',
      body: 'Nepodarilo sa synchronizovať dáta: $errorMessage',
      type: NotificationType.syncError,
      payload: '{"type":"sync_error","message":"$errorMessage"}',
    );

    showLocalNotification(
      title: 'Chyba synchronizácie',
      body: errorMessage,
      type: NotificationType.syncError,
    );
  }

  /// Show offline warning
  void notifyOfflineMode() {
    addNotification(
      title: 'Offline režim',
      body: 'Ste v offline režíme. Zmeny budú synchronizované až pri obnovení pripojenia.',
      type: NotificationType.offlineWarning,
    );

    showLocalNotification(
      title: 'Offline režim',
      body: 'Zmeny sa uložia a synchronizujú neskôr',
      type: NotificationType.offlineWarning,
    );
  }

  String _getStatusLabel(String status) {
    return {
      'new': 'Nová',
      'assigned': 'Priradená',
      'in_progress': 'V riešení',
      'testing': 'Testovanie',
      'resolved': 'Vyriešená',
      'closed': 'Uzatvorená',
    }[status] ?? status;
  }

  /// Dispose the service
  @override
  void dispose() {
    super.dispose();
  }
}
