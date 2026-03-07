import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/app_buttons.dart';
import 'package:agricola/core/widgets/selection_card.dart';
import 'package:agricola/features/auth/providers/auth_controller.dart';
import 'package:agricola/features/auth/widgets/auth_footer_link.dart';
import 'package:agricola/features/auth/widgets/auth_layout.dart';
import 'package:agricola/features/auth/widgets/or_divider.dart';
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

    return AuthLayout(
      title: t('create_account', currentLang),
      showBackButton: true,
      onBack: context.canPop() ? () => context.pop() : null,
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
          AuthFooterLink(
            text: t('already_have_account', currentLang),
            linkText: t('sign_in', currentLang),
            onTap: () => context.push('/sign-in'),
          ),
          const SizedBox(height: 24),
          OrDivider(text: t('or', currentLang)),
          const SizedBox(height: 24),
          // Continue as Guest button
          AppSecondaryButton(
            label: t('continue_as_guest', currentLang),
            onTap: _onContinueAsGuest,
          ),
          const SizedBox(height: 16),
        ],
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
