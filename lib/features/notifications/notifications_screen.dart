import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme.dart';
import '../../core/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationService = Provider.of<NotificationService>(context);
    final notifications = notificationService.notifications;
    final isLight = Theme.of(context).brightness == Brightness.light;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Notifikácie',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isLight ? Colors.black87 : Colors.white,
              ),
        ),
        actions: [
          if (notificationService.unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Badge(
                label: Text(
                  notificationService.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: AppTheme.primary,
              ),
            ),
          IconButton(
            icon: const Icon(LucideIcons.settings, size: 20),
            color: isLight ? Colors.black54 : Colors.white70,
            onPressed: () {
              // Show notification settings
            },
          ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmptyState(context, isLight)
          : _buildNotificationsList(context, notifications, notificationService, isLight),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isLight) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.bell,
            size: 64,
            color: isLight ? Colors.black26 : Colors.white24,
          ),
          const SizedBox(height: 16),
          Text(
            'Žiadne notifikácie',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isLight ? Colors.black54 : Colors.white54,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Budete informovaní o nových udalostiach',
            style: TextStyle(
              color: isLight ? Colors.black38 : Colors.white38,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsList(
    BuildContext context,
    List<AppNotification> notifications,
    NotificationService notificationService,
    bool isLight,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildHeaderActions(context, notificationService, isLight);
        }
        final notification = notifications[index - 1];
        return _buildNotificationItem(
          context,
          notification,
          notificationService,
          isLight,
        );
      },
    );
  }

  Widget _buildHeaderActions(
    BuildContext context,
    NotificationService notificationService,
    bool isLight,
  ) {
    final unreadCount = notificationService.unreadCount;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: AppTheme.glassDecoration(),
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (unreadCount > 0)
            TextButton.icon(
              onPressed: () {
                notificationService.markAllAsRead();
              },
              icon: Icon(LucideIcons.checkCheck, size: 16),
              label: Text('Označiť všetko ako prečítané'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.primary,
                textStyle: TextStyle(fontSize: 12),
              ),
            ),
          TextButton.icon(
            onPressed: () {
              notificationService.clearRead();
            },
            icon: Icon(LucideIcons.trash2, size: 16),
            label: Text('Vymazať prečítané'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.error,
              textStyle: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
    BuildContext context,
    AppNotification notification,
    NotificationService notificationService,
    bool isLight,
  ) {
    final isUnread = !notification.read;
    final color = isLight ? Colors.black87 : Colors.white;
    final secondaryColor = isLight ? Colors.black54 : Colors.white70;

    return InkWell(
      onTap: () {
        if (isUnread) {
          notificationService.markAsRead(notification.id);
        }
        // Navigate based on notification payload
        _handleNotificationTap(context, notification);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isUnread
              ? AppTheme.primary.withValues(alpha: 0.05)
              : Colors.transparent,
          border: Border.all(
            color: isUnread
                ? AppTheme.primary.withValues(alpha: 0.2)
                : Colors.transparent,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon based on notification type
            _buildNotificationIcon(notification.type, isUnread),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: isUnread ? FontWeight.bold : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: TextStyle(
                      color: secondaryColor,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTimeAgo(notification.createdAt),
                    style: TextStyle(
                      color: isLight ? Colors.black38 : Colors.white38,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            // Unread indicator
            if (isUnread)
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(NotificationType type, bool isUnread) {
    final color = isUnread ? AppTheme.primary : Colors.white54;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        _getIconForType(type),
        size: 20,
        color: color,
      ),
    );
  }

  IconData _getIconForType(NotificationType type) {
    switch (type) {
      case NotificationType.bugAssigned:
        return LucideIcons.bug;
      case NotificationType.bugStatusChanged:
        return LucideIcons.refreshCw;
      case NotificationType.bugComment:
        return LucideIcons.messageSquare;
      case NotificationType.systemAlert:
        return LucideIcons.alertTriangle;
      case NotificationType.syncError:
        return LucideIcons.alertCircle;
      case NotificationType.offlineWarning:
        return LucideIcons.wifiOff;
    }
  }

  void _handleNotificationTap(BuildContext context, AppNotification notification) {
    // Parse payload and navigate
    if (notification.payload != null) {
      // Example: {"type":"bug","id":"bug_123"}
      // Could navigate to bug detail or other screens
      debugPrint('Notification tapped: ${notification.payload}');
    }
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'Pred ${difference.inDays} dňami';
    } else if (difference.inHours > 0) {
      return 'Pred ${difference.inHours} hodinami';
    } else if (difference.inMinutes > 0) {
      return 'Pred ${difference.inMinutes} minútami';
    } else {
      return 'Práve teraz';
    }
  }
}
