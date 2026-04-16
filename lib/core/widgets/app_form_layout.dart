import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/app_buttons.dart';
import 'package:flutter/material.dart';

class AppFormLayout extends StatelessWidget {
  final String title;
  final Widget child;
  final String? submitLabel;
  final VoidCallback? onSubmit;
  final bool isLoading;
  final List<Widget>? actions;
  final Widget? bottomWidget;

  const AppFormLayout({
    super.key,
    required this.title,
    required this.child,
    this.submitLabel,
    this.onSubmit,
    this.isLoading = false,
    this.actions,
    this.bottomWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 18),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.deepEmerald,
        elevation: 0,
        actions: actions,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: child,
            ),
          ),
          if (bottomWidget != null) bottomWidget!,
          if (submitLabel != null && onSubmit != null)
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepEmerald.withValues(alpha: 0.05),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: AppPrimaryButton(
                  label: submitLabel!,
                  onTap: onSubmit,
                  isLoading: isLoading,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
