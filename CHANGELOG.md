## 0.3.1 - 2026-02-15

### Added
- Cold start handling for Render free tier backend
  - `RetryInterceptor` - Automatically retries failed requests with exponential backoff
  - `ServerWakeService` - Proactively wakes up idle servers via health endpoint
  - `ErrorRecoveryService` - User-friendly error messages with retry functionality
  - `ServerStatusProvider` - Riverpod providers for server status management
- Enhanced splash screen with real-time connection status
  - Shows "Connecting to server...", "Server is starting up...", "Connected!"
  - Graceful handling of slow server wake-up

### Changed
- Increased development `apiTimeout` from 30s to 45s to match production
- Added cold start configuration constants to `EnvironmentConfig`
  - `coldStartTimeout`: 60 seconds
  - `maxRetries`: 3 attempts
  - `initialRetryDelay`: 3 seconds
  - `serverWakeDelay`: 5 seconds

## 0.3.0 - 2026-02-14

### Added
- Improved marketplace empty state with context-aware messaging
  - Shows "No Listings Yet" when marketplace is empty
  - Shows "No Results" when filters are active but no matches found
  - Added translations: `marketplace_empty` and `marketplace_empty_hint`
- Debug-only quick actions card in farmer profile screen (hidden in production)

### Changed
- Code formatting improvements in language provider (condensed single-line maps)
- Reorganized marketplace screen methods for better readability

## 0.2.7 - 2026-02-14

### Changed
- Extracted anonymous home screen content into reusable `AnonymousHomeScreenContent` widget
- Simplified farmer dashboard header layout by removing language switcher and notification buttons
- Refactored home screen widget options list into `_widgetOptions()` helper method

## 0.2.6 - 2026-02-14

### Changed
- Extracted bottom navigation bar into reusable `HomeBottomNavigationBar` widget

## 0.2.5

### Fixed
- AgriShop dashboard stat card overflow errors
  - Removed "Coming Soon" subtitle text to fit within card bounds
  - Reduced padding and font sizes for compact layout
- AgriShop dashboard quick actions now navigate to actual screens
  - "Add New Product" navigates to AddProductScreen
  - "View Orders" switches to Orders tab (index 2)
  - "Check Inventory" switches to Inventory tab (index 1)
  - "View Analytics" still shows Coming Soon dialog
- Orders API endpoint path missing leading slash
  - Fixed `orders_api_service.dart` to use `/${ApiConstants.ordersEndpoint}` consistent with other services

## 0.2.4

### Added
- Orders Flutter integration for AgriShop merchants
  - `order_model.dart` - OrderItem and OrderModel with JSON serialization
  - `orders_api_service.dart` - Dio service for orders API (getUserOrders, getOrder, updateOrderStatus, cancelOrder)
  - `orders_provider.dart` - StateNotifierProvider for orders state management
  - `api_constants.dart` - Added ordersEndpoint
- Dashboard stats provider for AgriShop merchants
  - `dashboard_stats_provider.dart` - Aggregates data from orders, inventory, and marketplace
  - `myListingsNotifierProvider` - Fetches seller's own marketplace listings
  - `merchantDashboardStatsProvider` - Computes Total Products, Monthly Revenue, Active Orders, Low Stock Items
- Add Product screen for AgriShop merchants
  - `add_product_screen.dart` - Form to add marketplace listings (supplies for farmers)
  - "Add New Product" quick action now navigates to this screen

### Fixed
- StatCard overflow issue on merchant dashboard (non-AgriShop)
  - Reduced padding and font sizes for better fit
  - Changed aspect ratio from 1.5 to 1.25 for taller cards

### Changed
- `agri_shop_orders_screen.dart` - Full rewrite with:
  - Order list with pull-to-refresh
  - Color-coded status badges (pending/confirmed/shipped/delivered/cancelled)
  - Action buttons to progress order status (confirm → ship → deliver)
  - Bottom sheet order details showing items and totals
  - Loading, error, and empty states
- `merchant_dashboard_screen.dart` - Connected to real data:
  - Stats cards now show live data from backend
  - Recent activity section displays last 5 orders
  - Loading states while data fetches
  - "View All Orders" link navigates to Orders tab
- `marketplace_filter.dart` - Added sellerId filter for fetching seller's own listings
- `language_provider.dart` - Added translations for orders and product management
- `stat_card.dart` - Compact layout to prevent overflow

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
