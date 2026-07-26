import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ableone_app/features/communication/domain/entities/notification_entity.dart';
import 'package:ableone_app/features/communication/domain/entities/message_entity.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';

class NotificationCard extends StatelessWidget {
  final NotificationEntity notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final formattedTime = DateFormat('MMM d, h:mm a').format(notification.createdAt);

    Color typeColor;
    IconData typeIcon;
    switch (notification.type.toLowerCase()) {
      case 'reminder':
        typeColor = Colors.orange;
        typeIcon = Icons.alarm_rounded;
        break;
      case 'progress':
        typeColor = Colors.green;
        typeIcon = Icons.trending_up_rounded;
        break;
      case 'system':
      default:
        typeColor = AppColors.primary;
        typeIcon = Icons.info_outline_rounded;
    }

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        side: BorderSide(
          color: notification.isRead ? AppColors.border : typeColor.withValues(alpha: 0.5),
          width: notification.isRead ? 1.0 : 1.5,
        ),
      ),
      color: notification.isRead ? Colors.transparent : typeColor.withValues(alpha: 0.03),
      child: ListTile(
        onTap: notification.isRead ? null : onTap,
        leading: CircleAvatar(
          backgroundColor: typeColor.withValues(alpha: 0.1),
          child: Icon(typeIcon, color: typeColor, size: 20),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                notification.title,
                style: TextStyle(
                  fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            if (!notification.isRead)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: typeColor, shape: BoxShape.circle),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              formattedTime,
              style: TextStyle(color: AppColors.textLight, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool isMe;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final formattedTime = DateFormat('h:mm a').format(message.timestamp);
    final bubbleColor = isMe ? AppColors.primary : AppColors.border.withValues(alpha: 0.4);
    final textColor = isMe ? Colors.white : AppColors.textPrimary;
    final timeColor = isMe ? Colors.white70 : AppColors.textSecondary;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.70,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.message,
              style: TextStyle(color: textColor, fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  formattedTime,
                  style: TextStyle(color: timeColor, fontSize: 9),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
