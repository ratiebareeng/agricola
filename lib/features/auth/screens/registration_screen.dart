import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/widgets/app_buttons.dart';
import 'package:agricola/core/widgets/selection_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

enum UserType { farmer, agriMerchant }

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
        child: Padding(
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
                title: t('agri_merchant', currentLang),
                description: t('agri_merchant_desc', currentLang),
                icon: Icons.storefront,
                isSelected: _selectedUserType == UserType.agriMerchant,
                onTap: () {
                  setState(() {
                    _selectedUserType = UserType.agriMerchant;
                  });
                },
              ),
              const Spacer(),
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
}
