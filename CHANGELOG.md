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
