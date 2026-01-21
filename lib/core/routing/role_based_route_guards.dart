import 'package:agricola/core/routing/route_guard_helpers.dart';
import 'package:agricola/domain/profile/enum/merchant_type.dart';
import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:agricola/features/auth/providers/auth_state_provider.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class RoleBasedRouteGuards {
  static const farmerOnlyRoutes = {'/crops', '/farm-management'};

  static const merchantOnlyRoutes = {'/merchant-dashboard', '/inventory'};

  static const agriShopOnlyRoutes = {'/agri-shop-inventory'};

  static const supermarketOnlyRoutes = {'/supermarket-inventory'};

  static bool canAccessAgriShopRoutes(WidgetRef ref) {
    final user = ref.read(currentUserProvider);
    return user?.userType == UserType.merchant &&
        user?.merchantType == MerchantType.agriShop;
  }

  static bool canAccessFarmerRoutes(WidgetRef ref) {
    final user = ref.read(currentUserProvider);
    return user?.userType == UserType.farmer;
  }

  static bool canAccessMerchantRoutes(WidgetRef ref) {
    final user = ref.read(currentUserProvider);
    return user?.userType == UserType.merchant;
  }

  static bool canAccessSupermarketRoutes(WidgetRef ref) {
    final user = ref.read(currentUserProvider);
    return user?.userType == UserType.merchant &&
        user?.merchantType == MerchantType.supermarketVendor;
  }

  /// Extended redirect with role-based checks
  /// To use: Replace RouteGuards.redirect in main.dart with this method
  static String? redirectWithRoles(WidgetRef ref, GoRouterState state) {
    final authState = ref.read(unifiedAuthStateProvider);
    final path = state.uri.path;

    if (!RouteGuardHelpers.canAccessDebugRoute(path)) {
      return '/';
    }

    final isPublicRoute = RouteGuardHelpers.isPublicRoute(path);

    if (authState.isAuthenticated) {
      if (authState.needsProfileSetup) {
        if (path != '/profile-setup') {
          final userType = state.uri.queryParameters['type'] ?? 'farmer';
          return '/profile-setup?type=$userType';
        }
        return null;
      }

      if (farmerOnlyRoutes.contains(path) && !canAccessFarmerRoutes(ref)) {
        return '/home';
      }

      if (merchantOnlyRoutes.contains(path) && !canAccessMerchantRoutes(ref)) {
        return '/home';
      }

      if (agriShopOnlyRoutes.contains(path) && !canAccessAgriShopRoutes(ref)) {
        return '/home';
      }

      if (supermarketOnlyRoutes.contains(path) &&
          !canAccessSupermarketRoutes(ref)) {
        return '/home';
      }

      if (isPublicRoute) {
        return '/home';
      }
      return null;
    }

    if (!isPublicRoute && path != '/profile-setup') {
      return '/';
    }

    return null;
  }
}

/// Example: Using role-based guards in UI
/// 
/// ```dart
/// // Check if user can see farmer features
/// if (RoleBasedRouteGuards.canAccessFarmerRoutes(ref)) {
///   ElevatedButton(
///     onPressed: () => context.go('/crops'),
///     child: const Text('Manage Crops'),
///   ),
/// }
/// 
/// // Check if user can see merchant features
/// if (RoleBasedRouteGuards.canAccessMerchantRoutes(ref)) {
///   ElevatedButton(
///     onPressed: () => context.go('/inventory'),
///     child: const Text('Manage Inventory'),
///   ),
/// }
/// ```
