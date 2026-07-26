import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/features/ai/domain/entities/ai_message_entity.dart';
import 'package:ableone_app/features/accessibility/presentation/widgets/voice_action_button.dart';

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
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            if (!isUser) ...[
              const CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.smart_toy_rounded, color: Colors.white, size: 16),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.70,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: isUser ? const Radius.circular(16) : Radius.zero,
                    bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
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
            ),
            if (!isUser) ...[
              const SizedBox(width: 4),
              VoiceActionButton(
                textToSpeak: message.message,
                semanticLabel: 'Read aloud tutor response',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
