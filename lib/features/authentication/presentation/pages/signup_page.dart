import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/router/route_names.dart';
import 'package:ableone_app/core/constants/app_constants.dart';
import 'package:ableone_app/shared/widgets/primary_button.dart';
import 'package:ableone_app/shared/widgets/custom_text_field.dart';
import 'package:ableone_app/features/authentication/data/repositories/authentication_repository_impl.dart';
import 'package:ableone_app/features/profile/domain/entities/user_entity.dart';
import 'package:ableone_app/features/profile/data/repositories/user_repository_impl.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final email = _emailController.text.trim();
        final password = _passwordController.text;
        final name = _nameController.text.trim();

        final user = await ref.read(authenticationRepositoryProvider).signUpWithEmailAndPassword(
          email,
          password,
          name,
        );

        if (user != null && mounted) {
          final profile = UserEntity(
            uid: user.uid,
            name: name,
            email: email,
            role: 'student',
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
          // Success routing to role selection page
          context.go(RouteNames.roleSelectionPath);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        leading: Semantics(
          label: 'Back to Login',
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: _isLoading ? null : () => context.go(RouteNames.loginPath),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.lg, vertical: AppConstants.md),
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
                    Text(
                      'Create Account',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.xs),
                    Text(
                      'Join AbleOne to get accessibility and learning support',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.xl),

                    // Full Name Field
                    CustomTextField(
                      controller: _nameController,
                      labelText: 'Full Name',
                      hintText: 'John Doe',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      semanticsLabel: 'Full Name entry field. Enter your first and last name.',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        if (value.trim().length < 2) {
                          return 'Name must be at least 2 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.md),

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
                      hintText: 'At least 6 characters',
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
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.md),

                    // Confirm Password Field
                    CustomTextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      prefixIcon: const Icon(Icons.lock_reset_outlined),
                      semanticsLabel: 'Confirm Password entry field. Confirm your password.',
                      suffixIcon: Semantics(
                        button: true,
                        label: _obscureConfirmPassword ? 'Show password' : 'Hide password',
                        child: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscureConfirmPassword = !_obscureConfirmPassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppConstants.xl),

                    // Continue Button
                    PrimaryButton(
                      text: 'Continue',
                      onPressed: _isLoading ? null : _handleSignup,
                      isLoading: _isLoading,
                      semanticsLabel: 'Register account. Double tap to submit details and choose role.',
                    ),
                    const SizedBox(height: AppConstants.xl),

                    // Already have an account navigation
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        Semantics(
                          link: true,
                          label: 'Sign in to existing account. Tap to log in.',
                          child: TextButton(
                            onPressed: _isLoading ? null : () => context.go(RouteNames.loginPath),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryDark,
                            ),
                            child: const Text(
                              'Sign In',
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
