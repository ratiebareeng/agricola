import 'package:equatable/equatable.dart';
import 'package:agricola/features/profile_setup/models/farmer_profile_model.dart';
import 'package:agricola/features/profile_setup/models/merchant_profile_model.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';

sealed class ProfileResponse extends Equatable {
  const ProfileResponse();
}

class FarmerProfileResponse extends ProfileResponse {
  final FarmerProfileModel profile;

  const FarmerProfileResponse(this.profile);

  @override
  List<Object?> get props => [profile];
}

class MerchantProfileResponse extends ProfileResponse {
  final MerchantProfileModel profile;

  const MerchantProfileResponse(this.profile);

  @override
  List<Object?> get props => [profile];
}

extension ProfileResponseX on ProfileResponse {
  String get userId {
    return switch (this) {
      FarmerProfileResponse(profile: final p) => p.userId,
      MerchantProfileResponse(profile: final p) => p.userId,
    };
  }

  String get id {
    return switch (this) {
      FarmerProfileResponse(profile: final p) => p.id,
      MerchantProfileResponse(profile: final p) => p.id,
    };
  }

  String? get photoUrl {
    return switch (this) {
      FarmerProfileResponse(profile: final p) => p.photoUrl,
      MerchantProfileResponse(profile: final p) => p.photoUrl,
    };
  }

  UserType get userType {
    return switch (this) {
      FarmerProfileResponse() => UserType.farmer,
      MerchantProfileResponse() => UserType.merchant,
    };
  }

  DateTime get createdAt {
    return switch (this) {
      FarmerProfileResponse(profile: final p) => p.createdAt,
      MerchantProfileResponse(profile: final p) => p.createdAt,
    };
  }

  DateTime get updatedAt {
    return switch (this) {
      FarmerProfileResponse(profile: final p) => p.updatedAt,
      MerchantProfileResponse(profile: final p) => p.updatedAt,
    };
  }
}
