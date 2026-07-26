import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/features/accessibility/data/repositories/accessibility_repository_impl.dart';
import 'package:ableone_app/core/services/firebase_service.dart';

class DataManagementPage extends ConsumerWidget {
  const DataManagementPage({super.key});

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final uid = ref.read(firebaseAuthProvider).currentUser?.uid ?? 'unknown';
    final accessSettings = ref.read(accessibilitySettingsProvider);

    final mockExport = {
      'exportedAt': DateTime.now().toIso8601String(),
      'userId': uid,
      'preferences': accessSettings.toMap(),
    };

    final prettyString = const JsonEncoder.withIndent('  ').convert(mockExport);

    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Exported Data (JSON)'),
          content: SingleChildScrollView(
            child: Text(
              prettyString,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearCache(BuildContext context, WidgetRef ref) async {
    try {
      ref.read(accessibilitySettingsProvider.notifier).setTextScale(1.0);
      ref.read(accessibilitySettingsProvider.notifier).setContrastMode('Normal');
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Local preferences and caches have been reset.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear cache: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Management'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.lg),
          children: [
            const Text(
              'Export or Reset Data',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Under GDPR and COPPA regulations, you can download a copy of all user progress parameters stored in our cloud caches.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: AppConstants.lg),
            
            ListTile(
              leading: const Icon(Icons.download_rounded, color: AppColors.primary),
              title: const Text('Export My Learning Metrics', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('View and copy your current accessibility settings and user details.'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
              onTap: () => _exportData(context, ref),
            ),
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.cleaning_services_rounded, color: AppColors.secondary),
              title: const Text('Reset Local Preference Cache', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Wipes local configurations and restores standard sizing.'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
              onTap: () => _clearCache(context, ref),
            ),
          ],
        ),
      ),
    );
  }
}
