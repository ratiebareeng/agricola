import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/app_buttons.dart';
import 'package:agricola/core/widgets/app_text_field.dart';
import 'package:agricola/features/auth/providers/sign_up_provider.dart';
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

    // Show error message if present
    if (signUpState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(signUpState.errorMessage!),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        signUpNotifier.clearError();
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
                  t('sign_up', currentLang),
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
                        icon: Icons.g_mobiledata, // Placeholder
                        onTap: () => signUpNotifier.signUpWithGoogle(
                          userType: widget.userType ?? 'farmer',
                          context: context,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppSecondaryButton(
                        label: t('facebook', currentLang),
                        icon: Icons.facebook,
                        onTap: () {
                          // TODO: Implement Facebook sign-up
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      t('already_have_account', currentLang),
                      style: const TextStyle(
                        color: AppColors.darkGray,
                        fontSize: 16,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/sign-in'),
                      child: Text(
                        t('sign_in', currentLang),
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

  void _onSignUp(SignUpNotifier signUpNotifier) {
    if (_formKey.currentState!.validate()) {
      signUpNotifier.signUpWithEmailPassword(
        userType: widget.userType ?? 'farmer',
        context: context,
      );
    }
  }
}
