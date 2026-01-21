import 'package:agricola/core/constants/validation_rules.dart';
import 'package:agricola/features/profile_setup/models/farmer_profile_model.dart';
import 'package:agricola/features/profile_setup/models/merchant_profile_model.dart';

class ProfileValidators {
  /// Validate business name (for forms)
  static String? validateBusinessName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Business name is required';
    }

    if (value.length < ValidationRules.minBusinessNameLength) {
      return ValidationRules.businessNameTooShort;
    }

    if (value.length > ValidationRules.maxBusinessNameLength) {
      return ValidationRules.businessNameTooLong;
    }

    return null;
  }

  /// Validate crops list (for forms)
  static String? validateCrops(List<String> crops) {
    if (crops.isEmpty) {
      return ValidationRules.cropsRequired;
    }

    if (crops.length > ValidationRules.maxPrimaryCropsCount) {
      return 'Select up to ${ValidationRules.maxPrimaryCropsCount} crops';
    }

    return null;
  }

  /// Validate farmer profile
  static String? validateFarmerProfile(FarmerProfileModel profile) {
    if (profile.village.isEmpty ||
        profile.village.length < ValidationRules.minVillageLength) {
      return ValidationRules.villageRequired;
    }

    if (profile.primaryCrops.isEmpty) {
      return ValidationRules.cropsRequired;
    }

    if (profile.primaryCrops.length > ValidationRules.maxPrimaryCropsCount) {
      return 'Select up to ${ValidationRules.maxPrimaryCropsCount} crops';
    }

    if (profile.farmSize.isEmpty) {
      return ValidationRules.farmSizeRequired;
    }

    return null; // Valid
  }

  /// Validate merchant profile
  static String? validateMerchantProfile(MerchantProfileModel profile) {
    if (profile.businessName.length < ValidationRules.minBusinessNameLength) {
      return ValidationRules.businessNameTooShort;
    }

    if (profile.businessName.length > ValidationRules.maxBusinessNameLength) {
      return ValidationRules.businessNameTooLong;
    }

    if (profile.location.isEmpty ||
        profile.location.length < ValidationRules.minVillageLength) {
      return ValidationRules.villageRequired;
    }

    return null; // Valid
  }

  /// Validate village (for forms)
  static String? validateVillage(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationRules.villageRequired;
    }

    if (value.length < ValidationRules.minVillageLength) {
      return 'Village name too short';
    }

    return null;
  }
}
