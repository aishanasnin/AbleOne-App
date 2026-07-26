import 'package:flutter/material.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';

class DataConsentPage extends StatefulWidget {
  const DataConsentPage({super.key});

  @override
  State<DataConsentPage> createState() => _DataConsentPageState();
}

class _DataConsentPageState extends State<DataConsentPage> {
  bool _shareAIAnalysis = true;
  bool _logSessionHistory = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Consent Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(AppConstants.lg),
          children: [
            const Text(
              'Your Data, Your Controls',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'We believe in total transparency. Choose what diagnostic details you share with the AI tutor.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: AppConstants.lg),
            
            SwitchListTile(
              activeTrackColor: AppColors.primary,
              title: const Text('Share Performance with AI Tutor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Allows the Gemini engine to customize lessons based on quiz results.'),
              value: _shareAIAnalysis,
              onChanged: (val) {
                setState(() {
                  _shareAIAnalysis = val;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('AI analysis sharing: ${val ? "Enabled" : "Disabled"}')),
                );
              },
            ),
            const Divider(),
            
            SwitchListTile(
              activeTrackColor: AppColors.primary,
              title: const Text('Log Learning Sessions locally', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: const Text('Caches completion speeds to offer reading pacing metrics.'),
              value: _logSessionHistory,
              onChanged: (val) {
                setState(() {
                  _logSessionHistory = val;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Session caching: ${val ? "Enabled" : "Disabled"}')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
