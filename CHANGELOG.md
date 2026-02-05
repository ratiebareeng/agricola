## 0.2.4

### Added
- Orders Flutter integration for AgriShop merchants
  - `order_model.dart` - OrderItem and OrderModel with JSON serialization
  - `orders_api_service.dart` - Dio service for orders API (getUserOrders, getOrder, updateOrderStatus, cancelOrder)
  - `orders_provider.dart` - StateNotifierProvider for orders state management
  - `api_constants.dart` - Added ordersEndpoint

### Changed
- `agri_shop_orders_screen.dart` - Full rewrite with:
  - Order list with pull-to-refresh
  - Color-coded status badges (pending/confirmed/shipped/delivered/cancelled)
  - Action buttons to progress order status (confirm → ship → deliver)
  - Bottom sheet order details showing items and totals
  - Loading, error, and empty states

## 0.2.3

### Fixed
- Fixed blank screen after clicking logout in dialog
  - Removed redundant `Navigator.pop()` call that conflicted with `context.go('/')` navigation
- Fixed onboarding screens showing again after logout
  - Changed `prefs.clear()` to selectively remove only user-specific data
  - App-wide flags (`has_seen_welcome`, `has_seen_onboarding`, `language_code`) are now preserved

### Modified Files
- `farmer_profile_screen.dart` - Removed Navigator.pop after signOut
- `merchant_profile_screen.dart` - Removed Navigator.pop after signOut  
- `auth_controller.dart` - Selective SharedPreferences cleanup on logout

## 0.2.2

### Changed
- Profile screen UI cleanup for both farmer and merchant screens
  - Removed Farm/Business Details placeholder from incomplete profile view (redundant with profile completion banner)
  - Removed "Change PIN" menu item (not implemented)
  - Removed "Notifications" menu item (not implemented)
  - Added Change Password functionality - sends password reset email via Firebase
  - Added "Coming Soon" snackbar for Help & Support and About menu items

### Modified Files
- `farmer_profile_screen.dart` - Updated settings section and added password reset dialog
- `merchant_profile_screen.dart` - Updated settings section and added password reset dialog

## 0.2.1

### Fixed
- Splash screen now displays for minimum 2 seconds to allow backend warmup (Render free tier)
- Fixed brief flash of create account screen during app startup
- Back button no longer appears on auth screens when they are the first page in navigation stack

### Changed
- `splash_screen.dart` - Converted to stateful widget with minimum duration timer and auth state listeners
- `route_guards.dart` - Added auth loading state check to keep users on splash during Firebase verification
- `app_router.dart` - Added 100ms debounce to RouterNotifier to prevent rapid route re-evaluations
- `sign_up_screen.dart` - Back button now checks `canPop()` before showing
- `sign_in_screen.dart` - Back button now checks `canPop()` before showing
- `registration_screen.dart` - Back button now checks `canPop()` before showing

## 0.2.0

### Added
- Inventory management feature with full CRUD support
  - `inventory_api_service.dart` - API service with Dio for inventory operations
  - `inventory_providers.dart` - Riverpod state management for inventory
  - `add_edit_inventory_screen.dart` - Form screen for adding and editing inventory items

### Changed
- `farmer_inventory_screen.dart` - Now uses provider instead of hardcoded data, added "Add Inventory" button
- `inventory_detail_screen.dart` - Connected edit/delete buttons to provider
- `language_provider.dart` - Added inventory-related translations (English and Setswana)

## 0.1.0

- Initial version.
