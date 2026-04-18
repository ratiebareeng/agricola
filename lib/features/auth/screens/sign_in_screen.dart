import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/validation/field_limits.dart';
import 'package:agricola/core/widgets/agri_kit.dart';
import 'package:agricola/core/widgets/app_text_field.dart';
import 'package:agricola/features/auth/providers/sign_in_provider.dart';
import 'package:agricola/features/auth/widgets/auth_footer_link.dart';
import 'package:agricola/features/auth/widgets/auth_layout.dart';
import 'package:agricola/features/auth/widgets/auth_title.dart';
import 'package:agricola/features/auth/widgets/social_login_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);
    final signInState = ref.watch(signInProvider);
    final signInNotifier = ref.read(signInProvider.notifier);

    ref.listen(signInProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: next.errorMessage!.contains('sent')
                ? Colors.green
                : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        signInNotifier.clearError();
      }
    });

    return AuthLayout(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AuthTitle(title: t('sign_in', currentLang)),
            const SizedBox(height: 32),
            AppTextField(
              label: t('email', currentLang),
              hint: 'example@email.com',
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              maxLength: kMaxEmail,
              validator: (_) => signInNotifier.validateEmail(),
            ),
            const SizedBox(height: 24),
            AppTextField(
              label: t('password', currentLang),
              hint: '********',
              controller: _passwordController,
              obscureText: true,
              maxLength: kMaxPassword,
              validator: (_) => signInNotifier.validatePassword(),
            ),
            const SizedBox(height: 32),
            AgriStadiumButton(
              label: t('sign_in', currentLang),
              onPressed: () => _onSignIn(signInNotifier),
              isLoading: signInState.isLoading,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AgriTextButton(
                  label: t('forgot_password', currentLang),
                  onPressed: signInState.isLoading
                      ? null
                      : () => signInNotifier.sendPasswordResetEmail(),
                  color: AppColors.mediumGray,
                ),
              ],
            ),
            const SizedBox(height: 32),
            SocialLoginButtons(
              isLoading: signInState.isLoading,
              onGoogleTap: () => signInNotifier.signInWithGoogle(context),
            ),
            const SizedBox(height: 32),
            AuthFooterLink(
              text: t('dont_have_account', currentLang),
              linkText: t('sign_up', currentLang),
              onTap: () => context.push('/register'),
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
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Listen to text changes and update provider
    _emailController.addListener(() {
      ref.read(signInProvider.notifier).updateEmail(_emailController.text);
    });
    _passwordController.addListener(() {
      ref
          .read(signInProvider.notifier)
          .updatePassword(_passwordController.text);
    });
  }

  void _onSignIn(SignInNotifier signInNotifier) {
    if (_formKey.currentState!.validate()) {
      signInNotifier.signInWithEmailPassword(context);
    }
  }
}
