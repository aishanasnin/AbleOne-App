import 'package:flutter/material.dart';
import 'package:ableone_app/core/theme/app_colors.dart';
import 'package:ableone_app/core/constants/app_constants.dart';

/// Premium glassmorphic card container with light contrast borders and shadow overlays.
class GlassCard extends StatelessWidget {
  /// The body layout widget of this card.
  final Widget child;

  /// Optional custom padding.
  final EdgeInsetsGeometry? padding;

  /// Optional border radius.
  final double? borderRadius;

  /// Optional color background.
  final Color? color;

  /// Creates a [GlassCard] instance.
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.borderRadius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color ?? Colors.white.withValues(alpha: 0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius ?? AppConstants.radiusLg),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.8), width: 1.5),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius ?? AppConstants.radiusLg),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: padding ?? const EdgeInsets.all(AppConstants.lg),
        child: child,
      ),
    );
  }
}

/// Styled container utilizing modern gradient colors and visual contrast.
class GradientCard extends StatelessWidget {
  /// The body layout widget of this card.
  final Widget child;

  /// Custom gradient colors list.
  final List<Color> colors;

  /// Optional click listener.
  final VoidCallback? onTap;

  /// Creates a [GradientCard] instance.
  const GradientCard({
    super.key,
    required this.child,
    required this.colors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [
          BoxShadow(
            color: colors.first.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.lg),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Circular progress ring utilizing custom painter elements for smooth visual aesthetics.
class ProgressRing extends StatelessWidget {
  /// Progress percentage decimal range from 0.0 to 1.0.
  final double value;

  /// Circular dimensions sizing constraint.
  final double size;

  /// Ring line stroke width.
  final double strokeWidth;

  /// Active path color mapping.
  final Color? color;

  /// Creates a [ProgressRing] instance.
  const ProgressRing({
    super.key,
    required this.value,
    this.size = 60.0,
    this.strokeWidth = 6.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: value,
            strokeWidth: strokeWidth,
            backgroundColor: AppColors.border,
            valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.primary),
          ),
          Text(
            '${(value * 100).toInt()}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: size * 0.22,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tactical click scale animation button mimicking modern gaming styles.
class AnimatedButton extends StatefulWidget {
  /// Sizable body content.
  final Widget child;

  /// Callback when button is pressed.
  final VoidCallback onPressed;

  /// Creates an [AnimatedButton] instance.
  const AnimatedButton({super.key, required this.child, required this.onPressed});

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 90),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          widget.onPressed();
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: IgnorePointer(child: widget.child),
        ),
      ),
    );
  }
}

/// Shimmer skeleton loader box simulating loading screens in modern applications.
class LoadingSkeleton extends StatefulWidget {
  /// Sizing width.
  final double width;

  /// Sizing height.
  final double height;

  /// Radius constraints.
  final double borderRadius;

  /// Creates a [LoadingSkeleton] instance.
  const LoadingSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  State<LoadingSkeleton> createState() => _LoadingSkeletonState();
}

class _LoadingSkeletonState extends State<LoadingSkeleton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _opacityAnimation = Tween<double>(begin: 0.35, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(widget.borderRadius),
            ),
          ),
        );
      },
    );
  }
}

/// Styled welcome card showing a user avatar and visual achievements.
class ProfileHeader extends StatelessWidget {
  /// User profile display name.
  final String name;

  /// Descriptive subtitle.
  final String description;

  /// Number of active learning streak days.
  final int streakDays;

  /// Creates a [ProfileHeader] instance.
  const ProfileHeader({
    super.key,
    required this.name,
    required this.description,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppConstants.md),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary,
            child: Text(
              name.isEmpty ? 'S' : name[0].toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: AppConstants.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (streakDays > 0)
            Semantics(
              label: 'Daily learning streak is $streakDays days',
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                  border: Border.all(color: Colors.orange, width: 0.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: Colors.orange, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      '$streakDays d',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
