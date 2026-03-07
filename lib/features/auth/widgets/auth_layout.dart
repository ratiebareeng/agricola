import 'package:agricola/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthLayout extends StatelessWidget {
  final Widget child;
  final String? title;
  final bool showBackButton;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  const AuthLayout({
    super.key,
    required this.child,
    this.title,
    this.showBackButton = true,
    this.onBack,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: title != null
            ? Text(
                title!,
                style: const TextStyle(
                  color: AppColors.darkGray,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
        leading: showBackButton && (context.canPop() || onBack != null)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.darkGray),
                onPressed: onBack ?? () => context.pop(),
              )
            : null,
        actions: actions,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: child,
        ),
      ),
    );
  }
}
