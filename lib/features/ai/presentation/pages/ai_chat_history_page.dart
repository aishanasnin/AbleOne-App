import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/empty_state.dart';
import 'package:ableone_app/features/ai/data/repositories/ai_repository_impl.dart';

/// Screen displaying previously saved AI Tutor chat dialogue transcripts stored locally.
class AIChatHistoryPage extends ConsumerWidget {
  /// Creates an [AIChatHistoryPage] instance.
  const AIChatHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final messages = ref.watch(chatMessagesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversation Logs'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: messages.isEmpty
                  ? const EmptyState(
                      title: 'No Logs Found',
                      message: 'No previous tutoring session histories were found in local storage.',
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(AppConstants.lg),
                      child: Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                              side: const BorderSide(color: AppColors.border, width: 1),
                            ),
                            elevation: 0,
                            child: ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: messages.length,
                              separatorBuilder: (context, index) => const Divider(height: 1),
                              itemBuilder: (context, index) {
                                final msg = messages[index];
                                final isUser = msg.role == 'user';
                                final formattedDate = DateFormat('MMM d, h:mm a').format(msg.timestamp);

                                return Semantics(
                                  label: 'Message from ${isUser ? 'User' : 'AI Tutor'} at $formattedDate: ${msg.message}',
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: isUser ? AppColors.primary.withValues(alpha: 0.1) : AppColors.secondary.withValues(alpha: 0.1),
                                      child: Icon(
                                        isUser ? Icons.person_outline_rounded : Icons.smart_toy_outlined,
                                        color: isUser ? AppColors.primary : AppColors.secondary,
                                        size: 20,
                                      ),
                                    ),
                                    title: Text(
                                      msg.message,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: isUser ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '$formattedDate • ${msg.role.toUpperCase()}',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
            
            // Delete controls
            if (messages.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(AppConstants.md),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(top: BorderSide(color: AppColors.border, width: 1)),
                ),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: TextButton.icon(
                        icon: const Icon(Icons.delete_forever_rounded, color: AppColors.error),
                        label: const Text('Clear All Conversations', style: TextStyle(color: AppColors.error)),
                        onPressed: () {
                          ref.read(chatMessagesProvider.notifier).clearHistory();
                        },
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
