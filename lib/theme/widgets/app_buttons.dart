import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_gradients.dart';

class AppPrimaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double height;
  final BorderRadius borderRadius;

  const AppPrimaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 52,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppGradients.primary,
          borderRadius: borderRadius,
          boxShadow: [
            BoxShadow(
              color: AppColors.purpleDark.withValues(alpha: 0.25),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: SizedBox(
          height: height,
          child: Material(
            color: Colors.transparent,
            borderRadius: borderRadius,
            child: InkWell(
              borderRadius: borderRadius,
              onTap: onPressed,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class AppSecondaryButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final double height;
  final BorderRadius borderRadius;

  const AppSecondaryButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.height = 52,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null;
    return Opacity(
      opacity: disabled ? 0.55 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: borderRadius,
          border: Border.all(
            color: AppColors.elevated.withValues(alpha: 0.85),
          ),
        ),
        child: SizedBox(
          height: height,
          child: Material(
            color: Colors.transparent,
            borderRadius: borderRadius,
            child: InkWell(
              borderRadius: borderRadius,
              onTap: onPressed,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

