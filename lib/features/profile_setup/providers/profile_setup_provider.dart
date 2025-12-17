import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileSetupProvider =
    StateNotifierProvider<ProfileSetupNotifier, ProfileSetupState>((ref) {
      return ProfileSetupNotifier();
    });

class ProfileSetupNotifier extends StateNotifier<ProfileSetupState> {
  ProfileSetupNotifier() : super(ProfileSetupState());

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

  void setPhoto(String path) => state = state.copyWith(photoPath: path);

  void setUserType(UserType type) {
    state = state.copyWith(userType: type);
  }

  void toggleCrop(String crop) {
    final crops = List<String>.from(state.selectedCrops);
    if (crops.contains(crop)) {
      crops.remove(crop);
    } else {
      crops.add(crop);
    }
    state = state.copyWith(selectedCrops: crops);
  }

  void toggleProduct(String product) {
    final products = List<String>.from(state.selectedProducts);
    if (products.contains(product)) {
      products.remove(product);
    } else {
      products.add(product);
    }
    state = state.copyWith(selectedProducts: products);
  }

  void updateBusinessName(String value) =>
      state = state.copyWith(businessName: value);

  void updateCustomVillage(String value) =>
      state = state.copyWith(customVillage: value);

  void updateFarmSize(String value) => state = state.copyWith(farmSize: value);

  void updateLocation(String value) => state = state.copyWith(location: value);

  void updateVillage(String value) => state = state.copyWith(village: value);
}

class ProfileSetupState {
  final int currentStep;
  final int totalSteps;
  final UserType userType;

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
