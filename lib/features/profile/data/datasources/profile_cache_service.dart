import 'dart:convert';

import 'package:agricola/features/profile/domain/models/profile_response.dart';
import 'package:agricola/features/profile_setup/models/farmer_profile_model.dart';
import 'package:agricola/features/profile_setup/models/merchant_profile_model.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileCacheService {
  final SharedPreferences _prefs;

  static const String _farmerProfileKey = 'cached_farmer_profile';
  static const String _merchantProfileKey = 'cached_merchant_profile';
  static const String _profileCacheTimeKey = 'profile_cache_timestamp';
  static const String _userTypeKey = 'cached_user_type';
  static const Duration _cacheTTL = Duration(hours: 24);

  ProfileCacheService(this._prefs);

  Future<void> cacheFarmerProfile(FarmerProfileModel profile) async {
    await _prefs.setString(_farmerProfileKey, jsonEncode(profile.toJson()));
    await _prefs.setString(_userTypeKey, UserType.farmer.name);
    await _updateCacheTimestamp();
  }

  Future<void> cacheMerchantProfile(MerchantProfileModel profile) async {
    await _prefs.setString(_merchantProfileKey, jsonEncode(profile.toJson()));
    await _prefs.setString(_userTypeKey, UserType.merchant.name);
    await _updateCacheTimestamp();
  }

  ProfileResponse? getCachedProfile() {
    if (!_isCacheValid()) return null;

    final userTypeStr = _prefs.getString(_userTypeKey);
    if (userTypeStr == null) return null;

    final userType = UserType.values.firstWhere(
      (type) => type.name == userTypeStr,
      orElse: () => UserType.farmer,
    );

    if (userType == UserType.farmer) {
      final cachedData = _prefs.getString(_farmerProfileKey);
      if (cachedData == null) return null;

      try {
        final json = jsonDecode(cachedData) as Map<String, dynamic>;
        final profile = FarmerProfileModel.fromJson(json);
        return FarmerProfileResponse(profile);
      } catch (e) {
        return null;
      }
    } else {
      final cachedData = _prefs.getString(_merchantProfileKey);
      if (cachedData == null) return null;

      try {
        final json = jsonDecode(cachedData) as Map<String, dynamic>;
        final profile = MerchantProfileModel.fromJson(json);
        return MerchantProfileResponse(profile);
      } catch (e) {
        return null;
      }
    }
  }

  Future<void> clearCache() async {
    await _prefs.remove(_farmerProfileKey);
    await _prefs.remove(_merchantProfileKey);
    await _prefs.remove(_profileCacheTimeKey);
    await _prefs.remove(_userTypeKey);
  }

  bool _isCacheValid() {
    final timestampStr = _prefs.getString(_profileCacheTimeKey);
    if (timestampStr == null) return false;

    final timestamp = DateTime.tryParse(timestampStr);
    if (timestamp == null) return false;

    final now = DateTime.now();
    return now.difference(timestamp) < _cacheTTL;
  }

  Future<void> _updateCacheTimestamp() async {
    await _prefs.setString(
      _profileCacheTimeKey,
      DateTime.now().toIso8601String(),
    );
  }
}
