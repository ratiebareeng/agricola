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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: title != null
            ? Text(
                title!,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.deepEmerald,
                  fontWeight: FontWeight.w800,
                ),
              )
            : null,
        leading: showBackButton && (context.canPop() || onBack != null)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.deepEmerald),
                onPressed: onBack ?? () => context.pop(),
              )
            : null,
        actions: actions,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: child,
        ),
      ),
    );
  }
}
