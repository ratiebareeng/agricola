import 'package:agricola/domain/auth/models/user_model.dart';
import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/profile_setup/models/farmer_profile_model.dart';
import 'package:agricola/features/profile_setup/models/merchant_profile_model.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:equatable/equatable.dart';

/// Unified profile model that combines Firestore auth data with PostgreSQL profile data
/// This allows the app to display user information even when the PostgreSQL profile
/// hasn't been created yet.
sealed class DisplayableProfile extends Equatable {
  final String userId;
  final String displayName;
  final String email;
  final String? phoneNumber;
  final String? photoUrl;
  final UserType userType;
  final MerchantType? merchantType;

  const DisplayableProfile({
    required this.userId,
    required this.displayName,
    required this.email,
    this.phoneNumber,
    this.photoUrl,
    required this.userType,
    this.merchantType,
  });

  @override
  List<Object?> get props => [
        userId,
        displayName,
        email,
        phoneNumber,
        photoUrl,
        userType,
        merchantType,
      ];
}

/// Minimal profile created from Firestore auth data only
/// Used when user hasn't completed profile setup yet
class MinimalProfile extends DisplayableProfile {
  const MinimalProfile({
    required super.userId,
    required super.displayName,
    required super.email,
    super.phoneNumber,
    super.photoUrl,
    required super.userType,
    super.merchantType,
  });

  /// Create minimal profile from Firestore UserModel
  /// Extracts display name from email (before @ symbol)
  factory MinimalProfile.fromUserModel(UserModel user) {
    final displayName = user.email.split('@').first;

    return MinimalProfile(
      userId: user.uid,
      displayName: displayName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      photoUrl: null, // No custom photo yet
      userType: user.userType,
      merchantType: user.merchantType,
    );
  }
}

/// Complete farmer profile combining Firestore auth data with PostgreSQL profile data
class CompleteFarmerProfile extends DisplayableProfile {
  final FarmerProfileModel farmerData;

  const CompleteFarmerProfile({
    required super.userId,
    required super.displayName,
    required super.email,
    super.phoneNumber,
    super.photoUrl,
    required this.farmerData,
  }) : super(userType: UserType.farmer, merchantType: null);

  /// Create complete farmer profile from both Firestore and PostgreSQL data
  factory CompleteFarmerProfile.fromModels({
    required UserModel user,
    required FarmerProfileModel profile,
  }) {
    return CompleteFarmerProfile(
      userId: user.uid,
      displayName: user.email.split('@').first,
      email: user.email,
      phoneNumber: user.phoneNumber,
      photoUrl: profile.photoUrl,
      farmerData: profile,
    );
  }

  @override
  List<Object?> get props => [...super.props, farmerData];
}

/// Complete merchant profile combining Firestore auth data with PostgreSQL profile data
class CompleteMerchantProfile extends DisplayableProfile {
  final MerchantProfileModel merchantData;

  const CompleteMerchantProfile({
    required super.userId,
    required super.displayName,
    required super.email,
    super.phoneNumber,
    super.photoUrl,
    required this.merchantData,
  }) : super(userType: UserType.merchant, merchantType: null);

  /// Create complete merchant profile from both Firestore and PostgreSQL data
  /// Uses business name as display name for merchants
  factory CompleteMerchantProfile.fromModels({
    required UserModel user,
    required MerchantProfileModel profile,
  }) {
    return CompleteMerchantProfile(
      userId: user.uid,
      displayName: profile.businessName,
      email: user.email,
      phoneNumber: user.phoneNumber,
      photoUrl: profile.photoUrl,
      merchantData: profile,
    );
  }

  @override
  List<Object?> get props => [...super.props, merchantData];
}
