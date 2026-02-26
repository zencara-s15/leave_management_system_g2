import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';

/// Primary filled button used throughout the app.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final Color? color;
  final double? width;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final btn = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color ?? AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 18),
                    const SizedBox(width: 8),
                    Text(label,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                )
              : Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
    );

    return width != null ? SizedBox(width: width, child: btn) : btn;
  }
}

/// Secondary outlined button.
class SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color? color;

  const SecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final fgColor = color ?? AppColors.primary;
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: fgColor,
        side: BorderSide(color: fgColor),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
        ),
      ),
      child: icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            )
          : Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
