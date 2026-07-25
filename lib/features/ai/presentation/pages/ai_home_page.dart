import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/router/route_names.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/section_title.dart';
import 'package:ableone_app/features/ai/presentation/widgets/suggestion_card.dart';

/// Landing page introducing the AI Tutor system and displaying clickable prompt suggestions.
class AIHomePage extends StatelessWidget {
  /// Creates an [AIHomePage] instance.
  const AIHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AbleOne AI Tutor'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.history_rounded, size: 20),
            label: const Text('History'),
            onPressed: () => context.push(RouteNames.aiHistoryPath),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.lg),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Premium welcome card panel
                  Card(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusXl),
                      side: const BorderSide(color: AppColors.primaryLight, width: 0.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.lg),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Semantics(
                                  header: true,
                                  child: Text(
                                    'Meet your AI Tutor! 🤖',
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppConstants.xs),
                                Text(
                                  'Ask questions, simplify lessons, generate custom quizzes, or translate phrases. I am ready to support your cognitive preferences.',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.xl),

                  const SectionTitle(
                    title: 'Quick Assistant Prompts',
                    semanticsLabel: 'Quick assistant actions section header',
                  ),
                  const Text(
                    'Select one of the topics below to start a quick chat conversation:',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: AppConstants.md),

                  // Responsive suggestion list
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: isDesktop ? 2 : 1,
                    crossAxisSpacing: AppConstants.md,
                    mainAxisSpacing: AppConstants.md,
                    childAspectRatio: isDesktop ? 2.5 : 2.8,
                    children: [
                      SuggestionCard(
                        title: 'Explain Topic',
                        description: 'Explain photosynthesis with simple breakdowns.',
                        icon: Icons.lightbulb_outline_rounded,
                        onTap: () => _navigateToChat(context, 'Explain photosynthesis'),
                      ),
                      SuggestionCard(
                        title: 'Summarize Lesson',
                        description: 'Help me summarize this study lesson.',
                        icon: Icons.summarize_outlined,
                        onTap: () => _navigateToChat(context, 'Summarize lesson'),
                      ),
                      SuggestionCard(
                        title: 'Create Quiz',
                        description: 'Test my knowledge with a quick sight words quiz.',
                        icon: Icons.quiz_outlined,
                        onTap: () => _navigateToChat(context, 'Create sight words quiz'),
                      ),
                      SuggestionCard(
                        title: 'Translate Phrase',
                        description: 'Translate "Hello, learn with me" to Spanish.',
                        icon: Icons.translate_rounded,
                        onTap: () => _navigateToChat(context, 'Translate "Hello, learn with me" to Spanish'),
                      ),
                      SuggestionCard(
                        title: 'Simplify Text',
                        description: 'Make cognitive comprehension definitions simpler.',
                        icon: Icons.psychology_outlined,
                        onTap: () => _navigateToChat(context, 'Simplify this text: "Cognitive comprehension requires active retention"'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.xl),

                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.chat_bubble_outline_rounded),
                        label: const Text('Start custom chat session'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                          ),
                        ),
                        onPressed: () => _navigateToChat(context, ''),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToChat(BuildContext context, String initialPrompt) {
    context.push(RouteNames.aiChatPath, extra: initialPrompt);
  }
}
