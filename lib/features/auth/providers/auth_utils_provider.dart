import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/auth/providers/auth_state_provider.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRedirectRouteProvider = Provider<String>((ref) {
  final authState = ref.watch(unifiedAuthStateProvider);

  if (authState.needsProfileSetup) {
    final userTypeRoute = ref.watch(userTypeRouteProvider);
    return '/profile-setup?type=${userTypeRoute ?? "farmer"}';
  }

  if (authState.isAuthenticated) {
    return '/home';
  }

  return '/welcome';
});

final canAccessFarmerFeaturesProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.userType == UserType.farmer;
});

final canAccessMerchantFeaturesProvider = Provider<bool>((ref) {
  final user = ref.watch(currentUserProvider);
  return user?.userType == UserType.merchant;
});

final userDisplayNameProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return null;
  }

  final email = user.email;
  if (email.isEmpty) {
    return 'User';
  }

  final username = email.split('@').first;
  return username.isNotEmpty ? username : 'User';
});

final userTypeDescriptionProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return null;
  }

  if (user.userType == UserType.farmer) {
    return 'Farmer';
  } else if (user.userType == UserType.merchant) {
    return user.merchantType == MerchantType.agriShop
        ? 'Agri Shop'
        : 'Supermarket Vendor';
  }

  {
    return null;
  }
});

final userTypeRouteProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return null;
  }

  if (user.userType == UserType.farmer) {
    return 'farmer';
  } else if (user.userType == UserType.merchant) {
    return user.merchantType == MerchantType.agriShop
        ? 'agriShop'
        : 'supermarketVendor';
  }

  return 'farmer'; // fallback
});
