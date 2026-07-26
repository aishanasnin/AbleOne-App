import 'package:flutter/material.dart';
import 'package:ableone_app/core/constants/app_constants.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AbleOne Privacy & Data Policy',
                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppConstants.sm),
              const Text(
                'Last Updated: July 2026',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const Divider(height: 32),
              
              const Text(
                '1. HIPAA Compliance & Diagnostics',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'All diagnostic clinical notes recorded by counselors are fully encrypted. '
                'Diagnostic data is stored in partitioned directories accessible only by certified therapists, '
                'linked parents, and administrators.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: AppConstants.md),

              const Text(
                '2. Information We Collect',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'AbleOne collects learning preferences (such as preferred explanation complexity), '
                'accessibility options (narration speeds and font scaling), and completion history. '
                'No third-party brokers have access to user data.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
              const SizedBox(height: AppConstants.md),

              const Text(
                '3. Data Control Rights',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'Under COPPA and HIPAA guidelines, users (and their legal parent guardians) retain the right to '
                'export their stored metrics as standard JSON files or delete their profile entirely.',
                style: TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
