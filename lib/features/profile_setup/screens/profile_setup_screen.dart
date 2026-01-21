import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/widgets/app_buttons.dart';
import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:agricola/features/profile_setup/widgets/wizard_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Import step widgets (will create next)
import '../widgets/step_content.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  final String? initialUserType;
  const ProfileSetupScreen({super.key, this.initialUserType});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileSetupProvider);
    final notifier = ref.read(profileSetupProvider.notifier);
    final currentLang = ref.watch(languageProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (state.currentStep > 0) {
              notifier.previousStep();
            } else {
              context.pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Skip logic - maybe go to dashboard
              context.go('/home'); // Placeholder route
            },
            child: Text(
              t('skip', currentLang),
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WizardProgressBar(
                    currentStep: state.currentStep,
                    totalSteps: state.totalSteps,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${t('step', currentLang)} ${state.currentStep + 1} ${t('of', currentLang)} ${state.totalSteps}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getStepTitle(
                      state.currentStep,
                      state.userType,
                      currentLang,
                    ),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: StepContent(
                  step: state.currentStep,
                  userType: state.userType,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: AppPrimaryButton(
                label: state.currentStep == state.totalSteps - 1
                    ? t('finish', currentLang)
                    : t('continue', currentLang),
                onTap: _canContinue(state)
                    ? () {
                        if (state.currentStep == state.totalSteps - 1) {
                          context.go('/home');
                        } else {
                          notifier.nextStep();
                        }
                      }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialUserType != null) {
        final notifier = ref.read(profileSetupProvider.notifier);

        if (widget.initialUserType == 'farmer') {
          notifier.startNewProfileSetup(UserType.farmer, null);
        } else {
          MerchantType? merchantType;
          if (widget.initialUserType == 'agriShop') {
            merchantType = MerchantType.agriShop;
          } else if (widget.initialUserType == 'supermarketVendor') {
            merchantType = MerchantType.supermarketVendor;
          }
          notifier.startNewProfileSetup(UserType.merchant, merchantType);
        }
      }
    });
  }

  bool _canContinue(ProfileSetupState state) {
    if (state.userType == UserType.farmer) {
      switch (state.currentStep) {
        case 0:
          if (state.village.isEmpty) return false;
          if (state.village == 'Other' && state.customVillage.isEmpty) {
            return false;
          }
          return true;
        case 1:
          return state.selectedCrops.isNotEmpty;
        case 2:
          return state.farmSize.isNotEmpty;
        case 3:
          return true;
        default:
          return false;
      }
    } else {
      switch (state.currentStep) {
        case 0:
          return state.businessName.isNotEmpty;
        case 1:
          return state.location.isNotEmpty;
        case 2:
          return state.selectedProducts.isNotEmpty;
        case 3:
          return true;
        default:
          return false;
      }
    }
  }

  String _getStepTitle(int step, UserType userType, AppLanguage lang) {
    if (userType == UserType.farmer) {
      switch (step) {
        case 0:
          return t('where_is_farm', lang);
        case 1:
          return t('what_do_you_grow', lang);
        case 2:
          return t('how_big_is_farm', lang);
        case 3:
          return t('add_photo', lang);
        default:
          return '';
      }
    } else {
      final state = ref.watch(profileSetupProvider);
      final isAgriShop = state.merchantType == MerchantType.agriShop;

      switch (step) {
        case 0:
          return t('business_details', lang);
        case 1:
          return t('where_are_you_located', lang);
        case 2:
          return isAgriShop
              ? t('what_do_you_sell', lang)
              : t('what_do_you_buy', lang);
        case 3:
          return t('add_photo', lang);
        default:
          return '';
      }
    }
  }
}
