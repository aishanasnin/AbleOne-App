import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/features/ai/domain/entities/ai_message_entity.dart';
import 'package:ableone_app/features/ai/data/repositories/ai_repository_impl.dart';
import 'package:ableone_app/features/ai/presentation/widgets/chat_bubble.dart';
import 'package:ableone_app/features/ai/presentation/widgets/typing_indicator.dart';

/// Interactive chat screen with the AI Tutor, handling prompt inputs, message streams, and scroll alignments.
class AIChatPage extends ConsumerStatefulWidget {
  /// Optional initial prompt context.
  final String initialPrompt;

  /// Creates an [AIChatPage] instance.
  const AIChatPage({super.key, this.initialPrompt = ''});

  @override
  ConsumerState<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends ConsumerState<AIChatPage> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (widget.initialPrompt.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(chatMessagesProvider.notifier).sendMessage(widget.initialPrompt);
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _submitMessage() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    ref.read(chatMessagesProvider.notifier).sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final messages = ref.watch(chatMessagesProvider);
    final isTyping = ref.watch(aiTypingProvider);
    final chatError = ref.watch(aiChatErrorProvider);

    // Reactively scroll down whenever messages array updates
    ref.listen<List<AIMessageEntity>>(chatMessagesProvider, (prev, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });

    // Also scroll down when typing indicator is toggled
    ref.listen<bool>(aiTypingProvider, (prev, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });

    // Also scroll down when error is toggled
    ref.listen<String?>(aiChatErrorProvider, (prev, next) {
      if (next != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Tutor Session'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Clear Chat History',
            onPressed: () {
              ref.read(chatMessagesProvider.notifier).clearHistory();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Conversation messages list
            Expanded(
              child: messages.isEmpty && !isTyping
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(AppConstants.lg),
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_rounded,
                              size: 64,
                              color: AppColors.primary.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: AppConstants.md),
                            Text(
                              'Start your learning session',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppConstants.xs),
                            const Text(
                              'Type a question in the field below to start chatting with your AI Tutor.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(AppConstants.lg),
                      itemCount: messages.length + (isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == messages.length) {
                          return const TypingIndicator();
                        }
                        return ChatBubble(message: messages[index]);
                      },
                    ),
            ),

            if (chatError != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: AppConstants.lg, vertical: AppConstants.sm),
                padding: const EdgeInsets.all(AppConstants.md),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                        const SizedBox(width: AppConstants.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Tutor Error',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                chatError,
                                style: const TextStyle(
                                  color: AppColors.error,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            ref.read(chatMessagesProvider.notifier).retryLastMessage();
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Try Again'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            // Input controller footer panel
            Container(
              padding: const EdgeInsets.all(AppConstants.md),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border, width: 1)),
              ),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Row(
                    children: [
                      Expanded(
                        child: Semantics(
                          label: 'AI Chat prompt input field',
                          child: TextField(
                            controller: _inputController,
                            decoration: InputDecoration(
                              hintText: 'Type your question...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onSubmitted: (_) => _submitMessage(),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppConstants.sm),
                      Semantics(
                        label: 'Send message button',
                        child: CircleAvatar(
                          radius: 24,
                          backgroundColor: AppColors.primary,
                          child: IconButton(
                            icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                            onPressed: _submitMessage,
                          ),
                        ),
                      ),
                    ],
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
