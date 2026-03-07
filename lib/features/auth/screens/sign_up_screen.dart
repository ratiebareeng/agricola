import 'dart:developer' as developer;

import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/widgets/app_buttons.dart';
import 'package:agricola/core/widgets/app_text_field.dart';
import 'package:agricola/features/auth/providers/sign_up_provider.dart';
import 'package:agricola/features/auth/widgets/auth_footer_link.dart';
import 'package:agricola/features/auth/widgets/auth_layout.dart';
import 'package:agricola/features/auth/widgets/auth_title.dart';
import 'package:agricola/features/auth/widgets/social_login_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  final String? userType;
  const SignUpScreen({super.key, this.userType});

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);
    final signUpState = ref.watch(signUpProvider);
    final signUpNotifier = ref.read(signUpProvider.notifier);

    ref.listen(signUpProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        signUpNotifier.clearError();
      }
    });

    return AuthLayout(
      onBack: () {
        // Check if we can pop, otherwise go to register screen
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/register');
        }
      },
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthTitle(title: t('sign_up', currentLang)),
            const SizedBox(height: 32),
            AppTextField(
              label: t('email', currentLang),
              hint: 'example@email.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              validator: (_) => signUpNotifier.validateEmail(),
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: t('password', currentLang),
              hint: '********',
              controller: _passwordController,
              obscureText: true,
              validator: (_) => signUpNotifier.validatePassword(),
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: t('confirm_password', currentLang),
              hint: '********',
              controller: _confirmPasswordController,
              obscureText: true,
              validator: (_) => signUpNotifier.validateConfirmPassword(),
            ),
            const SizedBox(height: 32),
            AppPrimaryButton(
              label: t('sign_up', currentLang),
              onTap: () => _onSignUp(signUpNotifier),
              isLoading: signUpState.isLoading,
            ),
            const SizedBox(height: 32),
            SocialLoginButtons(
              isLoading: signUpState.isLoading,
              onGoogleTap: () => _onGoogleSignUp(signUpNotifier),
              onFacebookTap: () {
                // TODO: Implement Facebook sign-in
              },
            ),
            const SizedBox(height: 32),
            AuthFooterLink(
              text: t('already_have_account', currentLang),
              linkText: t('sign_in', currentLang),
              onTap: () => context.push('/sign-in'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Listen to text changes and update provider
    _emailController.addListener(() {
      ref.read(signUpProvider.notifier).updateEmail(_emailController.text);
    });
    _passwordController.addListener(() {
      ref
          .read(signUpProvider.notifier)
          .updatePassword(_passwordController.text);
    });
    _confirmPasswordController.addListener(() {
      ref
          .read(signUpProvider.notifier)
          .updateConfirmPassword(_confirmPasswordController.text);
    });
  }

  Future<void> _onGoogleSignUp(SignUpNotifier signUpNotifier) async {
    // Navigation is handled by the router listener in app_router.dart
    await signUpNotifier.signUpWithGoogle(
      userType: widget.userType ?? 'farmer',
      context: context,
    );
  }

  Future<void> _onSignUp(SignUpNotifier signUpNotifier) async {
    if (_formKey.currentState!.validate()) {
      developer.log(
        '📝 SIGN UP: Form validated, calling signUpWithEmailPassword',
        name: 'SignUpScreen',
      );

      // Navigation is handled by the router listener in app_router.dart
      await signUpNotifier.signUpWithEmailPassword(
        userType: widget.userType ?? 'farmer',
        context: context,
      );
    } else {
      developer.log('❌ SIGN UP: Form validation failed', name: 'SignUpScreen');
    }
  }
}
