import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/router/route_names.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/primary_button.dart';
import 'package:ableone_app/shared/widgets/secondary_button.dart';
import 'package:ableone_app/shared/widgets/custom_text_field.dart';
import 'package:ableone_app/features/authentication/data/repositories/authentication_repository_impl.dart';
import 'package:ableone_app/features/profile/domain/entities/user_entity.dart';
import 'package:ableone_app/features/profile/data/repositories/user_repository_impl.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text;

        final user = await ref.read(authenticationRepositoryProvider).signInWithEmailAndPassword(email, password);

        if (user != null && mounted) {
          // Retrieve user profile from Firestore
          var profile = await ref.read(userRepositoryProvider).getUser(user.uid);
          
          if (profile == null) {
            // Firestore profile does not exist: create it automatically
            profile = UserEntity(
              uid: user.uid,
              name: user.displayName ?? 'AbleOne User',
              email: email,
              role: email.contains('parent') 
                  ? 'parent' 
                  : (email.contains('counselor') 
                      ? 'counselor' 
                      : (email.contains('admin') ? 'admin' : 'student')),
              language: 'English',
              phone: '',
              profileImage: '',
              disabilityType: '',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              isActive: true,
            );
            await ref.read(userRepositoryProvider).createUser(profile);
          }

          if (mounted) {
            final role = profile.role.toLowerCase();
            if (role == 'parent') {
              context.go(RouteNames.parentDashboardPath);
            } else if (role == 'counselor') {
              context.go(RouteNames.counselorDashboardPath);
            } else if (role == 'admin') {
              context.go(RouteNames.adminDashboardPath);
            } else {
              context.go(RouteNames.studentDashboardPath);
            }
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: AppColors.error,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address in the field first.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Basic email validation regex checking before calling password reset
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address first.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(authenticationRepositoryProvider).resetPassword(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A password reset link has been sent to your email.'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.lg),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: isDesktop ? 450 : double.infinity,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.all_inclusive_rounded,
                      size: 64,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: AppConstants.md),
                    Text(
                      'Welcome Back',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.xs),
                    Text(
                      'Sign in to continue to AbleOne',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.xl),

                    // Email Field
                    CustomTextField(
                      controller: _emailController,
                      labelText: 'Email Address',
                      hintText: 'name@example.com',
                      prefixIcon: const Icon(Icons.email_outlined),
                      keyboardType: TextInputType.emailAddress,
                      semanticsLabel: 'Email entry field. Enter your email address.',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email address';
                        }
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.md),

                    // Password Field
                    CustomTextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outlined),
                      semanticsLabel: 'Password entry field. Enter your password.',
                      suffixIcon: Semantics(
                        button: true,
                        label: _obscurePassword ? 'Show password' : 'Hide password',
                        child: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.sm),

                    // Forgot Password Link
                    Align(
                      alignment: Alignment.centerRight,
                      child: Semantics(
                        link: true,
                        label: 'Forgot Password. Tap to request password reset email.',
                        child: TextButton(
                          onPressed: _isLoading ? null : _handleForgotPassword,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.primaryDark,
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.lg),

                    // Login Button
                    PrimaryButton(
                      text: 'Sign In',
                      onPressed: _isLoading ? null : _handleLogin,
                      isLoading: _isLoading,
                      semanticsLabel: 'Sign in to AbleOne. Double tap to submit.',
                    ),
                    const SizedBox(height: AppConstants.lg),

                    // Divider segment
                    Row(
                      children: [
                        const Expanded(child: Divider(color: AppColors.border)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppConstants.md),
                          child: Text(
                            'OR',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.textLight,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Expanded(child: Divider(color: AppColors.border)),
                      ],
                    ),
                    const SizedBox(height: AppConstants.lg),

                    // Google Sign-In Button (Redirects to role selection in mock view)
                    SecondaryButton(
                      text: 'Sign in with Google',
                      icon: Icons.g_mobiledata_rounded,
                      onPressed: _isLoading ? null : () => context.go(RouteNames.roleSelectionPath),
                      semanticsLabel: 'Sign in with your Google account. Double tap to authenticate.',
                    ),
                    const SizedBox(height: AppConstants.xl),

                    // Create Account link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account?",
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        Semantics(
                          link: true,
                          label: 'Create Account. Tap to open the registration page.',
                          child: TextButton(
                            onPressed: _isLoading ? null : () => context.go(RouteNames.signupPath),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryDark,
                            ),
                            child: const Text(
                              'Create Account',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
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
      ),
    );
  }
}
