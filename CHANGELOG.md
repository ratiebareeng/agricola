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
