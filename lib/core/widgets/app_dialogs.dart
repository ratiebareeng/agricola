import 'package:agricola/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Standardized dialog helpers for the Agricola app.
///
/// Two types cover all use-cases:
/// - [confirm] — two-button (Cancel + Action) for confirmations & destructive actions
/// - [info] — single-button (Okay) for informational dialogs
class AppDialogs {
  AppDialogs._();

  /// Shows a confirmation dialog with Cancel + Action buttons.
  ///
  /// Returns `true` if the user tapped the action button, `false` otherwise.
  /// Set [isDestructive] to `true` for delete/logout actions (red button).
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String content,
    required String cancelText,
    required String actionText,
    bool isDestructive = false,
    IconData? icon,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: _buildTitle(title, icon, isDestructive),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelText,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isDestructive ? AppColors.alertRed : AppColors.green,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(actionText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Shows an informational dialog with a single Okay button.
  ///
  /// Pass either a plain [content] string or a custom [body] widget.
  static Future<void> info(
    BuildContext context, {
    required String title,
    String? content,
    Widget? body,
    required String okayText,
    IconData? icon,
  }) {
    assert(content != null || body != null);
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: _buildTitle(title, icon, false),
        content: body ?? Text(content!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppColors.green),
            child: Text(okayText),
          ),
        ],
      ),
    );
  }

  static Widget _buildTitle(String title, IconData? icon, bool isDestructive) {
    if (icon == null) return Text(title);
    return Row(
      children: [
        Icon(
          icon,
          color: isDestructive ? AppColors.alertRed : AppColors.green,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(title)),
      ],
    );
  }
}
