import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final profileSetupProvider =
    StateNotifierProvider<ProfileSetupNotifier, ProfileSetupState>((ref) {
      return ProfileSetupNotifier()..loadProfile();
    });

class ProfileSetupNotifier extends StateNotifier<ProfileSetupState> {
  bool _isNewProfileSetup = false;

  ProfileSetupNotifier() : super(ProfileSetupState());

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
    saveProfile();
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
    );
  }
}

enum UserType { farmer, merchant }
