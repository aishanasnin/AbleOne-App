import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/core/services/firebase_service.dart';

class AccountDeletionPage extends ConsumerStatefulWidget {
  const AccountDeletionPage({super.key});

  @override
  ConsumerState<AccountDeletionPage> createState() => _AccountDeletionPageState();
}

class _AccountDeletionPageState extends ConsumerState<AccountDeletionPage> {
  final _emailController = TextEditingController();
  bool _isProcessing = false;

  Future<void> _performDeletion() async {
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null) return;

    if (_emailController.text.trim() != user.email) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Verification email does not match active account.')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // 1. Delete Firestore user document
      final firestore = ref.read(firebaseFirestoreProvider);
      await firestore.collection('users').doc(user.uid).delete();

      // 2. Delete the Firebase Auth user object
      await user.delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account permanently deleted.')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete account: $e. You may need to re-authenticate first.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(firebaseAuthProvider).currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delete Account'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Card(
                color: AppColors.errorLight,
                elevation: 0,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 28),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Warning: Deleting your account will permanently wipe all course progress, XP achievements, and clinical counselor notes.',
                          style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.xl),
              const Text(
                'Verify Account Email',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Type your current email address (${user?.email ?? ""}) below to confirm deletion request:',
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  hintText: 'Enter account email address',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: AppConstants.xl),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isProcessing ? null : _performDeletion,
                  child: _isProcessing
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Permanently Delete My Data'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
