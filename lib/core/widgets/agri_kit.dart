import 'package:agricola/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class AgriKit {
  /// Formatting utility for quantities (removes trailing zeros)
  static String formatQuantity(double quantity) {
    if (quantity == quantity.toInt().toDouble()) {
      return quantity.toInt().toString();
    }
    return quantity.toString();
  }
}

/// The core UI Kit for the "Digital Earth" design ethos.
class AgriFocusCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const AgriFocusCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: padding ?? const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color ?? AppColors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.deepEmerald.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class AgriMetricDisplay extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  final Color? labelColor;

  const AgriMetricDisplay({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
    this.labelColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: valueColor ?? AppColors.deepEmerald,
                  height: 1,
                ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: labelColor ?? AppColors.forestGreen.withValues(alpha: 0.6),
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
        ),
      ],
    );
  }
}

class AgriStadiumButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isPrimary;
  final IconData? icon;
  final bool isLoading;

  const AgriStadiumButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isPrimary = true,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isPrimary) {
      return ElevatedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : (icon != null ? Icon(icon) : const SizedBox.shrink()),
        label: Text(label),
      );
    } else {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : (icon != null ? Icon(icon) : const SizedBox.shrink()),
        label: Text(label),
      );
    }
  }
}

class AgriTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color? color;
  final bool isUnderlined;
  final double fontSize;

  const AgriTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.color,
    this.isUnderlined = false,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color ?? AppColors.forestGreen,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
          decoration: isUnderlined ? TextDecoration.underline : null,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
