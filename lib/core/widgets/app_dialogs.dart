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
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: _buildTitle(title, icon, isDestructive),
        content: Text(
          content,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.deepEmerald.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16, left: 16),
        actions: isDestructive
            ? [
                // Dangerous action: text link on left, safe Cancel as stadium on right
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.alertRed,
                    textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
                  ),
                  child: Text(actionText.toUpperCase()),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
                  ),
                  child: Text(cancelText.toUpperCase()),
                ),
              ]
            : [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.deepEmerald.withValues(alpha: 0.4),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
                  ),
                  child: Text(cancelText.toUpperCase()),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.forestGreen,
                    foregroundColor: AppColors.white,
                    elevation: 0,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
                  ),
                  child: Text(actionText.toUpperCase()),
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
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: _buildTitle(title, icon, false),
        content: body ??
            Text(
              content!,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.deepEmerald.withValues(alpha: 0.7),
                fontWeight: FontWeight.w500,
              ),
            ),
        actionsPadding: const EdgeInsets.only(right: 16, bottom: 16, left: 16),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.forestGreen,
              foregroundColor: AppColors.white,
              elevation: 0,
              shape: const StadiumBorder(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, letterSpacing: 0.5),
            ),
            child: Text(okayText.toUpperCase()),
          ),
        ],
      ),
    );
  }

  static Widget _buildTitle(String title, IconData? icon, bool isDestructive) {
    final titleWidget = Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: AppColors.deepEmerald,
        letterSpacing: -0.5,
      ),
    );
    if (icon == null) return titleWidget;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isDestructive ? AppColors.alertRed : AppColors.forestGreen).withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDestructive ? AppColors.alertRed : AppColors.forestGreen,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: titleWidget),
      ],
    );
  }
}
