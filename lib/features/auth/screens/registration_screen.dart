import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/app_buttons.dart';
import 'package:agricola/core/widgets/selection_card.dart';
import 'package:agricola/features/auth/providers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

enum UserType { farmer, agriShop, supermarketVendor }

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  UserType? _selectedUserType;

  @override
  Widget build(BuildContext context) {
    final currentLang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkGray),
          onPressed: () => context.pop(),
        ),
        title: Text(
          t('create_account', currentLang),
          style: const TextStyle(
            color: AppColors.darkGray,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                t('select_account_type', currentLang),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 32),
              SelectionCard(
                title: t('farmer', currentLang),
                description: t('farmer_desc', currentLang),
                icon: Icons.agriculture,
                isSelected: _selectedUserType == UserType.farmer,
                onTap: () {
                  setState(() {
                    _selectedUserType = UserType.farmer;
                  });
                },
              ),
              const SizedBox(height: 16),
              SelectionCard(
                title: t('agri_shop', currentLang),
                description: t('agri_shop_desc', currentLang),
                icon: Icons.store,
                isSelected: _selectedUserType == UserType.agriShop,
                onTap: () {
                  setState(() {
                    _selectedUserType = UserType.agriShop;
                  });
                },
              ),
              const SizedBox(height: 16),
              SelectionCard(
                title: t('supermarket_vendor', currentLang),
                description: t('supermarket_vendor_desc', currentLang),
                icon: Icons.storefront,
                isSelected: _selectedUserType == UserType.supermarketVendor,
                onTap: () {
                  setState(() {
                    _selectedUserType = UserType.supermarketVendor;
                  });
                },
              ),
              const SizedBox(height: 32),
              AppPrimaryButton(
                label: t('continue', currentLang),
                onTap: _selectedUserType != null ? _onContinue : null,
              ),
              const SizedBox(height: 24),
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
              const SizedBox(height: 24),
              // Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      t('or', currentLang),
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
              // Continue as Guest button
              AppSecondaryButton(
                label: t('continue_as_guest', currentLang),
                onTap: _onContinueAsGuest,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _onContinue() {
    if (_selectedUserType != null) {
      context.push('/sign-up?type=${_selectedUserType!.name}');
    }
  }

  Future<void> _onContinueAsGuest() async {
    final authController = ref.read(authControllerProvider.notifier);
    await authController.signInAnonymously();

    if (mounted) {
      // Wait a brief moment for auth state to update
      await Future.delayed(const Duration(milliseconds: 300));

      if (mounted) {
        context.go('/home');
      }
    }
  }
}
