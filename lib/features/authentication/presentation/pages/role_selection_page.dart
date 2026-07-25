import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/router/route_names.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/dashboard_card.dart';
import 'package:ableone_app/shared/widgets/loading_widget.dart';
import 'package:ableone_app/core/services/firebase_service.dart';
import 'package:ableone_app/features/profile/domain/entities/user_entity.dart';
import 'package:ableone_app/features/profile/data/repositories/user_repository_impl.dart';

class RoleSelectionPage extends ConsumerStatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  ConsumerState<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends ConsumerState<RoleSelectionPage> {
  bool _isLoading = false;

  Future<void> _selectRole(String role) async {
    setState(() {
      _isLoading = true;
    });

    final currentUser = ref.read(firebaseAuthProvider).currentUser;
    if (currentUser != null) {
      try {
        final profile = await ref.read(userRepositoryProvider).getUser(currentUser.uid);
        if (profile != null) {
          final updatedProfile = UserEntity(
            uid: profile.uid,
            name: profile.name,
            email: profile.email,
            role: role,
            profileImage: profile.profileImage,
            phone: profile.phone,
            language: profile.language,
            disabilityType: profile.disabilityType,
            createdAt: profile.createdAt,
            updatedAt: DateTime.now(),
            isActive: profile.isActive,
          );
          await ref.read(userRepositoryProvider).updateUser(updatedProfile);
        } else {
          final newProfile = UserEntity(
            uid: currentUser.uid,
            name: currentUser.displayName ?? 'AbleOne User',
            email: currentUser.email ?? '',
            role: role,
            language: 'English',
            phone: '',
            profileImage: '',
            disabilityType: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isActive: true,
          );
          await ref.read(userRepositoryProvider).createUser(newProfile);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update role: ${e.toString().replaceAll('Exception: ', '')}'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (role == 'student') {
        context.go(RouteNames.studentDashboardPath);
      } else if (role == 'parent') {
        context.go(RouteNames.parentDashboardPath);
      } else if (role == 'counselor') {
        context.go(RouteNames.counselorDashboardPath);
      } else if (role == 'admin') {
        context.go(RouteNames.adminDashboardPath);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: LoadingWidget(message: 'Setting up your workspace...'),
        ),
      );
    }

    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    // Adaptive layout helper constants
    final isDesktop = size.width > 900;
    final isTablet = size.width <= 900 && size.width > 600;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.lg),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.accessibility_new_rounded,
                    size: 64,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: AppConstants.md),
                  Semantics(
                    header: true,
                    child: Text(
                      'Select Your Profile Role',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppConstants.xs),
                  Text(
                    'Configure your AbleOne workspace by selecting how you will use the application.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.xl),

                  // Responsive layout selection
                  _buildResponsiveRoleLayout(context, isDesktop, isTablet),
                  
                  const SizedBox(height: AppConstants.xl),
                  Semantics(
                    button: true,
                    label: 'Back to Login. Tap to navigate to login page.',
                    child: TextButton(
                      onPressed: () => context.go(RouteNames.loginPath),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                      child: const Text('Back to Login'),
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

  Widget _buildResponsiveRoleLayout(BuildContext context, bool isDesktop, bool isTablet) {
    final cards = _buildRoleCards(context);

    if (isDesktop) {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 4,
        crossAxisSpacing: AppConstants.md,
        mainAxisSpacing: AppConstants.md,
        childAspectRatio: 0.85,
        children: cards,
      );
    } else if (isTablet) {
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: AppConstants.md,
        mainAxisSpacing: AppConstants.md,
        childAspectRatio: 1.25,
        children: cards,
      );
    } else {
      return Column(
        children: cards
            .map((card) => Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.md),
                  child: card,
                ))
            .toList(),
      );
    }
  }

  List<Widget> _buildRoleCards(BuildContext context) {
    return [
      DashboardCard(
        title: 'Student',
        subtitle: 'Access specialized lessons, cognitive games, screen aids, and chatbot helpers.',
        icon: Icons.school_rounded,
        color: AppColors.primary,
        onTap: () => _selectRole('student'),
        semanticsLabel: 'Student Role. Access specialized lessons, cognitive games, screen aids, and chatbot helpers. Double tap to select.',
      ),
      DashboardCard(
        title: 'Parent',
        subtitle: 'Monitor learning progress, assign training tasks, and consult therapists.',
        icon: Icons.family_restroom_rounded,
        color: AppColors.secondary,
        onTap: () => _selectRole('parent'),
        semanticsLabel: 'Parent Role. Monitor learning progress, assign training tasks, and consult therapists. Double tap to select.',
      ),
      DashboardCard(
        title: 'Counselor',
        subtitle: 'Manage diagnostics, clinical programs, calendars, and messages.',
        icon: Icons.psychology_rounded,
        color: AppColors.accent,
        onTap: () => _selectRole('counselor'),
        semanticsLabel: 'Counselor Role. Manage diagnostics, clinical programs, calendars, and messages. Double tap to select.',
      ),
      DashboardCard(
        title: 'Admin',
        subtitle: 'Manage configuration, templates directories, system audits, and logs.',
        icon: Icons.admin_panel_settings_rounded,
        color: AppColors.error,
        onTap: () => _selectRole('admin'),
        semanticsLabel: 'Administrator Role. Manage configuration, templates directories, system audits, and logs. Double tap to select.',
      ),
    ];
  }
}
