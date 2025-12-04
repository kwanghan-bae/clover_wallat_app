import 'package:flutter/material.dart';
import 'package:clover_wallet_app/utils/theme.dart';
import 'package:intl/intl.dart';
import 'package:clover_wallet_app/services/notification_api_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationApiService _apiService = NotificationApiService();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await _apiService.getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // Show error snackbar if needed
    }
  }

  Future<void> _markAsRead(int id) async {
    try {
      await _apiService.markAsRead(id);
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == id);
        if (index != -1) {
          // Update local state to reflect read status
          // Since NotificationModel is immutable, we replace it
          // Actually, for simplicity, we just reload or ignore as it's just visual
          // Better to update the list locally
           // _notifications[index] = _notifications[index].copyWith(isRead: true); // Need copyWith
        }
      });
      _loadNotifications(); // Reload to get fresh state
    } catch (e) {
      print('Error marking as read: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CloverTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('알림'),
        actions: [
          TextButton(
            onPressed: () {
              // Mark all as read logic if supported
            },
            child: const Text('모두 읽음', style: TextStyle(color: CloverTheme.primaryColor)),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text('새로운 알림이 없습니다.', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    return _buildNotificationItem(notification);
                  },
                ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return GestureDetector(
      onTap: () => _markAsRead(notification.id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.white : Colors.blue[50],
          borderRadius: BorderRadius.circular(16),
          boxShadow: CloverTheme.softShadow,
          border: notification.isRead ? null : Border.all(color: CloverTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getIconColor(notification.type).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(_getIcon(notification.type), color: _getIconColor(notification.type), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        notification.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: notification.isRead ? Colors.black87 : CloverTheme.primaryColor,
                        ),
                      ),
                      Text(
                        _formatDate(notification.createdAt),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
            ),
            if (!notification.isRead)
              Container(
                margin: const EdgeInsets.only(left: 8, top: 8),
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: CloverTheme.primaryColor,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'WINNING':
        return Icons.emoji_events_rounded;
      case 'REMINDER':
        return Icons.alarm_rounded;
      case 'EVENT':
        return Icons.campaign_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'WINNING':
        return Colors.amber;
      case 'REMINDER':
        return Colors.blue;
      case 'EVENT':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return DateFormat('yyyy.MM.dd').format(date);
    }
  }
}
