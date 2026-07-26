import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/core/services/firebase_service.dart';
import 'package:ableone_app/features/communication/data/repositories/communication_repository_impl.dart';
import 'package:ableone_app/features/communication/presentation/widgets/communication_widgets.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String peerId;
  final String peerName;

  const ChatPage({
    super.key,
    required this.peerId,
    required this.peerName,
  });

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final currentUser = ref.read(firebaseAuthProvider).currentUser;
    if (currentUser == null) return;

    _messageController.clear();
    setState(() {
      _isTyping = true;
    });

    try {
      await ref.read(communicationRepositoryProvider).sendChatMessage(
            currentUser.uid,
            widget.peerId,
            text,
          );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to send message: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTyping = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(firebaseAuthProvider).currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Authentication session expired.')),
      );
    }

    final chatParams = ChatParams(senderId: currentUser.uid, receiverId: widget.peerId);
    final messagesAsync = ref.watch(messagesStreamProvider(chatParams));

    // Reactively scroll down whenever messages array updates
    ref.listen(messagesStreamProvider(chatParams), (prev, next) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.peerName),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Messages List
            Expanded(
              child: messagesAsync.when(
                data: (messages) {
                  if (messages.isEmpty) {
                    return const Center(
                      child: Text(
                        'No messages in this chat yet.',
                        style: TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(AppConstants.lg),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      return MessageBubble(
                        message: msg,
                        isMe: msg.senderId == currentUser.uid,
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error loading messages: $err')),
              ),
            ),

            if (_isTyping)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Sending message...', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                ),
              ),

            // Input Panel
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
                          label: 'Write message input field',
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type your message...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                                borderSide: const BorderSide(color: AppColors.border),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onSubmitted: (_) => _sendMessage(),
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
                            onPressed: _sendMessage,
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
