import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/features/ai/domain/entities/ai_message_entity.dart';

/// Reusable chat bubble component rendering user or AI messages with premium styling and semantic screen reader helpers.
class ChatBubble extends StatelessWidget {
  /// The chat message entity to display.
  final AIMessageEntity message;

  /// Creates a [ChatBubble] instance.
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.role == 'user';
    final alignment = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = isUser ? AppColors.primary : AppColors.border.withValues(alpha: 0.4);
    final textColor = isUser ? Colors.white : AppColors.textPrimary;
    final timeColor = isUser ? Colors.white70 : AppColors.textSecondary;
    final formattedTime = DateFormat('h:mm a').format(message.timestamp);

    final String semanticsLabel = isUser
        ? 'User sent message at $formattedTime: ${message.message}'
        : 'AI Tutor replied at $formattedTime: ${message.message}';

    return Semantics(
      label: semanticsLabel,
      container: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          crossAxisAlignment: alignment,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppConstants.radiusLg),
                  topRight: Radius.circular(AppConstants.radiusLg),
                  bottomLeft: isUser ? Radius.circular(AppConstants.radiusLg) : Radius.zero,
                  bottomRight: isUser ? Radius.zero : Radius.circular(AppConstants.radiusLg),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        formattedTime,
                        style: TextStyle(
                          fontSize: 10,
                          color: timeColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
