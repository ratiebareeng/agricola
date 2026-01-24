import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/auth/providers/auth_controller.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/profile/providers/profile_controller_provider.dart';
import 'package:agricola/features/profile/utils/profile_validators.dart';
import 'package:agricola/features/profile_setup/models/farmer_profile_model.dart';
import 'package:agricola/features/profile_setup/models/merchant_profile_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final profileSetupProvider =
    StateNotifierProvider<ProfileSetupNotifier, ProfileSetupState>((ref) {
      return ProfileSetupNotifier(ref)..loadProfile();
    });

class ProfileSetupNotifier extends StateNotifier<ProfileSetupState> {
  final Ref _ref;
  bool _isNewProfileSetup = false;

  ProfileSetupNotifier(this._ref) : super(ProfileSetupState());

  /// Complete profile setup and create profile in backend
  Future<bool> completeSetup() async {
    // Set loading state
    state = state.copyWith(isCreatingProfile: true, clearError: true);

    final user = _ref.read(currentUserProvider);
    if (user == null) {
      state = state.copyWith(
        isCreatingProfile: false,
        errorMessage: 'User not authenticated',
      );
      return false;
    }

    try {
      if (state.userType == UserType.farmer) {
        // Create farmer profile model
        final farmerProfile = FarmerProfileModel(
          id: '', // Will be assigned by backend
          userId: user.uid,
          village: state.village,
          customVillage: state.customVillage.isNotEmpty
              ? state.customVillage
              : null,
          primaryCrops: state.selectedCrops,
          farmSize: state.farmSize,
          photoUrl: state.photoPath,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Validate farmer profile
        final validationError = ProfileValidators.validateFarmerProfile(
          farmerProfile,
        );
        if (validationError != null) {
          state = state.copyWith(
            isCreatingProfile: false,
            errorMessage: validationError,
          );
          return false;
        }

        // Create profile in backend
        final success = await _ref
            .read(profileControllerProvider.notifier)
            .createFarmerProfile(profile: farmerProfile);

        if (success) {
          // Mark profile as complete in Firestore
          await _ref
              .read(authControllerProvider.notifier)
              .markProfileAsComplete();

          state = state.copyWith(isCreatingProfile: false, clearError: true);
        } else {
          state = state.copyWith(
            isCreatingProfile: false,
            errorMessage: 'Failed to create profile. Please try again.',
          );
        }

        return success;
      } else {
        // Validate merchant type is set
        if (state.merchantType == null) {
          state = state.copyWith(
            isCreatingProfile: false,
            errorMessage: 'Merchant type is required',
          );
          return false;
        }

        // Create merchant profile model
        final merchantProfile = MerchantProfileModel(
          id: '', // Will be assigned by backend
          userId: user.uid,
          merchantType: state.merchantType!,
          businessName: state.businessName,
          location: state.location,
          customLocation: state.customVillage.isNotEmpty
              ? state.customVillage
              : null,
          productsOffered: state.selectedProducts,
          photoUrl: state.photoPath,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Validate merchant profile
        final validationError = ProfileValidators.validateMerchantProfile(
          merchantProfile,
        );
        if (validationError != null) {
          state = state.copyWith(
            isCreatingProfile: false,
            errorMessage: validationError,
          );
          return false;
        }

        // Create profile in backend
        final success = await _ref
            .read(profileControllerProvider.notifier)
            .createMerchantProfile(profile: merchantProfile);

        if (success) {
          // Mark profile as complete in Firestore
          await _ref
              .read(authControllerProvider.notifier)
              .markProfileAsComplete();

          state = state.copyWith(isCreatingProfile: false, clearError: true);
        } else {
          state = state.copyWith(
            isCreatingProfile: false,
            errorMessage: 'Failed to create profile. Please try again.',
          );
        }

        return success;
      }
    } catch (e) {
      state = state.copyWith(
        isCreatingProfile: false,
        errorMessage: 'An error occurred: ${e.toString()}',
      );
      return false;
    }
  }

  Future<void> loadProfile() async {
    if (_isNewProfileSetup) return;

    final prefs = await SharedPreferences.getInstance();
    final userTypeString = prefs.getString('userType');
    final merchantTypeString = prefs.getString('merchantType');

    if (userTypeString != null) {
      final userType = UserType.values.firstWhere(
        (e) => e.name == userTypeString,
        orElse: () => UserType.farmer,
      );

      MerchantType? merchantType;
      if (merchantTypeString != null) {
        merchantType = MerchantType.values.firstWhere(
          (e) => e.name == merchantTypeString,
          orElse: () => MerchantType.agriShop,
        );
      }

      state = state.copyWith(
        userType: userType,
        merchantType: merchantType,
        village: prefs.getString('village') ?? '',
        customVillage: prefs.getString('customVillage') ?? '',
        selectedCrops: prefs.getStringList('selectedCrops') ?? [],
        farmSize: prefs.getString('farmSize') ?? '',
        businessName: prefs.getString('businessName') ?? '',
        location: prefs.getString('location') ?? '',
        selectedProducts: prefs.getStringList('selectedProducts') ?? [],
        photoPath: prefs.getString('photoPath'),
      );
    }
  }

  void nextStep() {
    if (state.currentStep < state.totalSteps - 1) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  Future<void> saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userType', state.userType.name);
    if (state.merchantType != null) {
      await prefs.setString('merchantType', state.merchantType!.name);
    }
    await prefs.setString('village', state.village);
    await prefs.setString('customVillage', state.customVillage);
    await prefs.setStringList('selectedCrops', state.selectedCrops);
    await prefs.setString('farmSize', state.farmSize);
    await prefs.setString('businessName', state.businessName);
    await prefs.setString('location', state.location);
    await prefs.setStringList('selectedProducts', state.selectedProducts);
    if (state.photoPath != null) {
      await prefs.setString('photoPath', state.photoPath!);
    }
  }

  void setMerchantType(MerchantType type) {
    state = state.copyWith(merchantType: type);
    saveProfile();
  }

  void setPhoto(String path) {
    state = state.copyWith(photoPath: path);
    saveProfile();
  }

  void setUserType(UserType type) {
    state = state.copyWith(userType: type);
    saveProfile();
  }

  void startNewProfileSetup(UserType type, MerchantType? merchantType) {
    _isNewProfileSetup = true;
    state = state.copyWith(
      userType: type,
      merchantType: merchantType,
      currentStep: 0,
      village: '',
      customVillage: '',
      selectedCrops: [],
      farmSize: '',
      businessName: '',
      location: '',
      selectedProducts: [],
      photoPath: null,
    );
    // Clear old cache and save new profile type (async, runs after build)
    Future.microtask(() => _clearCacheAndSave());
  }

  Future<void> _clearCacheAndSave() async {
    final prefs = await SharedPreferences.getInstance();
    // Clear all previous profile data
    await prefs.clear();
    // Save new profile data
    await saveProfile();
  }

  void toggleCrop(String crop) {
    final crops = List<String>.from(state.selectedCrops);
    if (crops.contains(crop)) {
      crops.remove(crop);
    } else {
      crops.add(crop);
    }
    state = state.copyWith(selectedCrops: crops);
    saveProfile();
  }

  void toggleProduct(String product) {
    final products = List<String>.from(state.selectedProducts);
    if (products.contains(product)) {
      products.remove(product);
    } else {
      products.add(product);
    }
    state = state.copyWith(selectedProducts: products);
    saveProfile();
  }

  void updateBusinessName(String value) {
    state = state.copyWith(businessName: value);
    saveProfile();
  }

  void updateCustomVillage(String value) {
    state = state.copyWith(customVillage: value);
    saveProfile();
  }

  void updateFarmSize(String value) {
    state = state.copyWith(farmSize: value);
    saveProfile();
  }

  void updateLocation(String value) {
    state = state.copyWith(location: value);
    saveProfile();
  }

  void updateVillage(String value) {
    state = state.copyWith(village: value);
    saveProfile();
  }
}

class ProfileSetupState {
  final int currentStep;
  final int totalSteps;
  final UserType userType;
  final MerchantType? merchantType;

  // Farmer Fields
  final String village;
  final String customVillage;
  final List<String> selectedCrops;
  final String farmSize;

  // Merchant Fields
  final String businessName;
  final String location;
  final List<String> selectedProducts;

  // Common
  final String? photoPath;

  // Creation state
  final bool isCreatingProfile;
  final String? errorMessage;

  ProfileSetupState({
    this.currentStep = 0,
    this.totalSteps = 4,
    this.userType = UserType.farmer,
    this.merchantType,
    this.village = '',
    this.customVillage = '',
    this.selectedCrops = const [],
    this.farmSize = '',
    this.businessName = '',
    this.location = '',
    this.selectedProducts = const [],
    this.photoPath,
    this.isCreatingProfile = false,
    this.errorMessage,
  });

  ProfileSetupState copyWith({
    int? currentStep,
    int? totalSteps,
    UserType? userType,
    MerchantType? merchantType,
    String? village,
    String? customVillage,
    List<String>? selectedCrops,
    String? farmSize,
    String? businessName,
    String? location,
    List<String>? selectedProducts,
    String? photoPath,
    bool? isCreatingProfile,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ProfileSetupState(
      currentStep: currentStep ?? this.currentStep,
      totalSteps: totalSteps ?? this.totalSteps,
      userType: userType ?? this.userType,
      merchantType: merchantType ?? this.merchantType,
      village: village ?? this.village,
      customVillage: customVillage ?? this.customVillage,
      selectedCrops: selectedCrops ?? this.selectedCrops,
      farmSize: farmSize ?? this.farmSize,
      businessName: businessName ?? this.businessName,
      location: location ?? this.location,
      selectedProducts: selectedProducts ?? this.selectedProducts,
      photoPath: photoPath ?? this.photoPath,
      isCreatingProfile: isCreatingProfile ?? this.isCreatingProfile,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

enum UserType { farmer, merchant }
