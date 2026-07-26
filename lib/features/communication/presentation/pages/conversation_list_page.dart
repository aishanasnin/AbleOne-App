import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/core/services/firebase_service.dart';
import 'package:ableone_app/features/communication/data/repositories/communication_repository_impl.dart';
import 'package:ableone_app/features/communication/presentation/pages/chat_page.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';

class ConversationListPage extends ConsumerWidget {
  const ConversationListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(firebaseAuthProvider).currentUser;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view conversations.')),
      );
    }

    final conversationsAsync = ref.watch(conversationsStreamProvider(currentUser.uid));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inbox Messages'),
      ),
      body: conversationsAsync.when(
        data: (users) {
          if (users.isEmpty) {
            return const Center(child: Text('No other registered users found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppConstants.md),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final peer = users[index];
              final peerName = peer['name'] as String? ?? 'User';
              final peerRole = (peer['role'] as String? ?? 'student').toUpperCase();

              return Card(
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                  side: const BorderSide(color: AppColors.border),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(peerName.isNotEmpty ? peerName[0] : 'U'),
                  ),
                  title: Text(peerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(peer['email'] as String? ?? ''),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      peerRole,
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => ChatPage(
                          peerId: peer['uid'] as String,
                          peerName: peerName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading inbox: $err')),
      ),
    );
  }
}
