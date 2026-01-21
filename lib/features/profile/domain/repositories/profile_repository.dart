import 'dart:io';

import 'package:agricola/features/profile/domain/failures/profile_failure.dart';
import 'package:agricola/features/profile/domain/models/profile_response.dart';
import 'package:agricola/features/profile_setup/models/farmer_profile_model.dart';
import 'package:agricola/features/profile_setup/models/merchant_profile_model.dart';
import 'package:fpdart/fpdart.dart';

abstract class ProfileRepository {
  Future<Either<ProfileFailure, Unit>> clearCache();

  Future<Either<ProfileFailure, FarmerProfileModel>> createFarmerProfile({
    required FarmerProfileModel profile,
  });

  Future<Either<ProfileFailure, MerchantProfileModel>> createMerchantProfile({
    required MerchantProfileModel profile,
  });

  Future<Either<ProfileFailure, Unit>> deleteProfile({
    required String profileId,
  });

  Future<Either<ProfileFailure, Unit>> deleteProfilePhoto({
    required String photoUrl,
  });

  Future<Either<ProfileFailure, ProfileResponse>> getProfile({
    required String userId,
  });

  Future<Either<ProfileFailure, ProfileResponse>> refreshProfile({
    required String userId,
  });

  Future<Either<ProfileFailure, FarmerProfileModel>> updateFarmerProfile({
    required FarmerProfileModel profile,
  });

  Future<Either<ProfileFailure, MerchantProfileModel>> updateMerchantProfile({
    required MerchantProfileModel profile,
  });

  Future<Either<ProfileFailure, String>> uploadProfilePhoto({
    required File photoFile,
    required String userId,
  });
}
