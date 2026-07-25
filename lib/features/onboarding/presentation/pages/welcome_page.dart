import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/router/route_names.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/primary_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 500 : double.infinity,
                minHeight: size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom,
              ),
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.lg, vertical: AppConstants.xl),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppConstants.md),
                  
                  // Brand Header visual
                  Column(
                    children: [
                      Semantics(
                        label: 'AbleOne Accessibility Logo',
                        image: true,
                        child: Container(
                          padding: const EdgeInsets.all(AppConstants.lg),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.accessibility_new_rounded,
                            size: 96,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppConstants.xl),
                      
                      // Accessible Feature Indicators
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: AppConstants.md,
                        runSpacing: AppConstants.sm,
                        children: [
                          _buildAccessIndicator(Icons.hearing_rounded, 'Audio Assist', 'Offers text-to-speech audio support'),
                          _buildAccessIndicator(Icons.visibility_rounded, 'Visual Aid', 'High contrast screens and font zoom aids'),
                          _buildAccessIndicator(Icons.psychology_rounded, 'Cognitive', 'Personalized visual sequencing schedules'),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.xl),
                  
                  // Text Block
                  Column(
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          'Welcome to AbleOne',
                          style: theme.textTheme.displayLarge?.copyWith(
                            fontSize: isDesktop ? 38 : 32,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: AppConstants.md),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppConstants.sm),
                        child: Text(
                          'An inclusive, AI-powered platform designed to support customized learning, therapy progress, and accessible communication for individuals of all abilities.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 15,
                            height: 1.55,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.xl),
                  
                  // Primary CTA Button
                  Column(
                    children: [
                      PrimaryButton(
                        text: 'Get Started',
                        onPressed: () => context.go(RouteNames.loginPath),
                        semanticsLabel: 'Get Started with AbleOne. Navigates to the sign in page.',
                      ),
                      const SizedBox(height: AppConstants.md),
                      Text(
                        'Empowering inclusive education and therapy',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccessIndicator(IconData icon, String label, String semanticsDesc) {
    return Semantics(
      container: true,
      label: '$label. $semanticsDesc',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.md, vertical: AppConstants.sm),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppColors.secondaryDark),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
