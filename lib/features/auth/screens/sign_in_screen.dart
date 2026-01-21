import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/app_buttons.dart';
import 'package:agricola/core/widgets/app_text_field.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/auth/providers/sign_in_provider.dart';
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
    final authState = ref.watch(currentUserProvider);
    final signInNotifier = ref.read(signInProvider.notifier);

    if (authState != null) {
      // Redirect to home if already signed in
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/home');
      });
    }

    // Show error or success message if present
    if (signInState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(signInState.errorMessage!),
            backgroundColor: signInState.errorMessage!.contains('sent')
                ? Colors.green
                : Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        signInNotifier.clearError();
      });
    }

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkGray),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t('sign_in', currentLang),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 32),
                AppTextField(
                  label: t('email', currentLang),
                  hint: 'example@email.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (_) => signInNotifier.validateEmail(),
                ),
                const SizedBox(height: 24),
                AppTextField(
                  label: t('password', currentLang),
                  hint: '********',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (_) => signInNotifier.validatePassword(),
                ),
                const SizedBox(height: 32),
                AppPrimaryButton(
                  label: t('sign_in', currentLang),
                  onTap: () => _onSignIn(signInNotifier),
                  isLoading: signInState.isLoading,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: signInState.isLoading
                          ? null
                          : () => signInNotifier.sendPasswordResetEmail(),
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: signInState.isLoading
                              ? AppColors.mediumGray
                              : AppColors.green,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        t('or_continue_with', currentLang),
                        style: const TextStyle(
                          color: AppColors.mediumGray,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: AppSecondaryButton(
                        label: t('google', currentLang),
                        icon: Icons.g_mobiledata,
                        onTap: () => signInNotifier.signInWithGoogle(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppSecondaryButton(
                        label: t('facebook', currentLang),
                        icon: Icons.facebook,
                        onTap: () => context.go('/home'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      t('dont_have_account', currentLang),
                      style: const TextStyle(
                        color: AppColors.darkGray,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/sign-up'),
                      child: Text(
                        t('sign_up', currentLang),
                        style: const TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
