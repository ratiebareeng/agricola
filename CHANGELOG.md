## 0.20.0 - 2026-03-07

### Added
- **Marketplace image upload** — product listings now support real images via Firebase Storage
  - Image picker (camera/gallery) on Add/Edit Product screen with preview and remove
  - `compressProductImage`: JPEG re-encoding at 1200x1200, 80% quality
  - `uploadMarketplaceImage` in `FirebaseStorageService` (path: `marketplace/{userId}/{listingId}/`)
  - Removed dummy `picsum.photos` images from inventory detail screen
- **Marketplace owner controls** — listing owners can now edit and delete their own listings
  - `MarketplaceDetailScreen`: detects ownership via `sellerId == currentUser.uid`
  - Owner sees edit/delete icons in app bar and "Edit Listing" button; others see "Contact Seller"
  - `InventoryDetailScreen`: listed items now show "View Listing" + "Unlist" buttons (was only "Unlist")

### Security
- **Image upload hardening** — three-layer validation before upload
  - Magic bytes check: verifies JPEG (`FF D8 FF`) / PNG (`89 50 4E 47`) file signatures
  - Compression failure = rejection: `FormatException` thrown instead of uploading the original file
  - Content type restricted to `image/jpeg` and `image/png` only
- 10 new bilingual translation keys

---

## 0.19.0 - 2026-03-07

### Added
- **Analytics API Integration** — server-side aggregated stats for reports
  - `AnalyticsModel` with typed sub-models: `CropAnalytics`, `HarvestAnalytics`, `InventoryAnalytics`, `MarketplaceAnalytics`, `OrderAnalytics`, `PurchaseAnalytics`
  - `AnalyticsApiService`: GET `/api/v1/analytics?period=month|week|year|all`
  - `analyticsProvider`: `FutureProvider.family` parameterized by period
  - Reports screen now fetches stats from backend in a single request instead of aggregating from 4-5 raw data endpoints
  - Graceful fallback: if analytics API fails, falls back to existing client-side providers
  - Farmer reports now include harvest stats (total harvests, total yield)
  - 2 new bilingual translation keys: `total_harvests`, `total_yield`

---

## 0.18.0 - 2026-03-07

### Added
- **Loss Detail View** — new screen to view details of a saved loss calculation
  - `LossDetailScreen`: shows calculation results and prevention tips for a specific record
  - Added navigation from `LossHistoryScreen` to `LossDetailScreen`

### Changed
- **Simplified Loss Comparison UI** — removed confusing +/- signed differences
  - `LossResultsCard`: now shows "Your Loss" and "Region Avg" side-by-side as plain numbers
  - Improved visual clarity for farmers to compare their performance with regional data
  - Added new translation keys: `your_loss`, `region_avg`, `based_on_crop`

---

## 0.17.0 - 2026-03-07

### Added
- **Loss Calculator Backend Integration** — save, view history, and delete loss calculations
  - `LossCalculation` model: added `id`, `userId`, `cropCategory`, `calculationDate`, `createdAt` fields + `toJson()`/`fromJson()`/`copyWith()`
  - `LossStage` model: added `toJson()`/`fromJson()`
  - `LossCalculatorApiService`: POST (save), GET (list), GET/:id, DELETE via `/api/v1/loss-calculator`
  - `lossCalculatorNotifierProvider`: `StateNotifierProvider` for saved calculations list
  - "Save Results" button on step 3 of loss calculator (optional — calculator still works fully client-side)
  - `LossHistoryScreen`: view saved calculations with delete, accessible via history icon in app bar
  - `lossCalculatorEndpoint` added to `ApiConstants`
  - 8 new bilingual translation keys (history, save, delete confirmation)

---

## 0.16.0 - 2026-03-07

### Added
- **Data Export (PDF/CSV)** — export farm or business data from the Reports screen
  - **CSV exports**: Crops, Inventory, Purchases, Orders — each generates a downloadable `.csv` file with bilingual column headers
  - **PDF summary reports**: Farm Summary (farmer) and Business Summary (merchant) — single-page A4 PDF with stats overview
  - Export FAB on both `ReportsScreen` and `MerchantReportsScreen`
  - Bottom sheet picker for selecting data type and format
  - Native share sheet integration via `share_plus` (save to files, email, WhatsApp, etc.)
  - All export labels translated (English + Setswana)
  - New dependencies: `csv`, `pdf`, `share_plus`

## 0.15.0 - 2026-03-07

### Added
- **Offline Support — Phase 5 & 6 complete**
  - **Purchases offline CRUD**: merchants can record, edit and delete purchases with no connection; changes queue to sync automatically when connectivity returns
    - `PurchasesLocalDao`, `PurchasesOfflineRepository` following established crop/inventory pattern
    - `purchases` entity type wired into `SyncService`
  - **Marketplace read-only cache**: listings fetched online are cached locally; served from cache when offline (writes remain online-only)
    - `MarketplaceLocalDao`, cache-aware `MarketplaceNotifier.loadListings()`
  - **Orders read-only cache**: orders fetched online are cached locally; served from cache when offline (status updates remain online-only)
    - `OrdersLocalDao`, cache-aware `OrdersNotifier.loadOrders()`
  - **DB schema v2**: `LocalPurchases` table gains `localId` and `isSynced` columns with automatic Drift migration
  - **`isSyncingProvider`**: exposes live sync-in-progress state to the UI
  - **`unsyncedCropIdsProvider`** / **`unsyncedInventoryIdsProvider`**: stream providers returning IDs of locally-modified unsynced items
  - **Sync improvements**: `SyncService.syncAll()` now calls `refreshProviders()` after each sync cycle; `purchasesNotifierProvider`, `marketplaceNotifierProvider`, and `ordersNotifierProvider` are invalidated on sync completion

### Changed
- **`OfflineBanner`**: shows an amber "Syncing…" indicator with spinner while a sync cycle is in progress (previously only shown when offline)
- **`CropCard`**: new `isSynced` flag — shows a cloud-upload icon on any crop modified offline but not yet synced
- **`InventoryItemCard`**: new `isSynced` flag — same pending-sync icon as crop card
- **`CropsScreen`** / **`FarmerInventoryScreen`**: watch `unsyncedCropIdsProvider` / `unsyncedInventoryIdsProvider` and pass `isSynced` to each card

## 0.14.0 - 2026-03-07

### Added
- **Reusable Form Widgets** — new modular components for consistent and simplified data entry
  - `AppFormLayout`: Shared scaffold with scrollable body and pinned bottom button
  - `AppFormSection`: Standardized headers with optional description and info tooltips
  - `AppDropdownField`: Consistent dropdown styling across all forms
  - `AppDateField`: Simplified date picker with standardized icon and formatting
  - `AppFilterChipGroup`: Reusable multi-select chip groups with max selection limit
  - `AppRadioGroup`: Standardized single-select list items

### Refactored
- **Forms Architecture** — refactored several screens to use the new standardized components:
  - `AddEditInventoryScreen`: Simplified inventory CRUD forms
  - `EditFarmerProfileScreen`: Refactored profile update with new selection widgets
  - `AddEditCropScreen`: Reorganized complex multi-step crop form using form layout and sections
- **AppTextField** — enhanced with `onSaved`, `maxLines`, and `initialValue` for better form integration

## 0.13.0 - 2026-03-07

### Added
- **Reusable Auth Widgets** — new modular components for consistent auth UI
  - `AuthLayout`: Standardized scaffold for auth screens with title and back navigation
  - `AuthTitle`: Large title with optional subtitle
  - `SocialLoginButtons`: Shared Google/Facebook login buttons with divider
  - `AuthFooterLink`: Consistent link style for "Already have an account?" or "Sign Up" links
  - `OrDivider`: Simple centered text divider

### Refactored
- **Auth Screens** — simplified `RegistrationScreen`, `SignInScreen`, and `SignUpScreen` using the new reusable components
- Improved error handling in `SignInScreen` and `SignUpScreen` using `ref.listen` for SnackBars
- Streamlined navigation logic in `SignUpScreen`

## 0.12.0 - 2026-03-07

### Added
- **Offline Support Foundation** — local SQLite database using drift for offline caching and sync
  - `AppDatabase` with 9 tables: cache tables for crops, inventory, harvests, marketplace, orders, purchases, crop catalog + sync queue + sync metadata
  - Automatic cache eviction (90-day TTL) on app startup

- **Connectivity Detection** — two-layer approach using `connectivity_plus`
  - `connectivityProvider` (online/offline/checking states) with server reachability ping to `/health`
  - `isOnlineProvider` (simple bool) for guards in repositories
  - 30-second debounce on reachability checks
  - `OfflineBanner` widget shown on HomeScreen when offline, with pending sync count and retry button

- **Crop Catalog Cache** (Phase 2) — read-only local cache with 7-day TTL
  - `CropCatalogLocalDao` for cache operations
  - `cropCatalogProvider` updated: serves from cache when fresh or offline, fetches from API when stale
  - Added `toJson()` to `CropCatalogEntry` for serialization

- **Crops Offline CRUD** (Phase 3) — full offline create/edit/delete for crops
  - `CropOfflineRepository` wraps `CropApiService` + `CropLocalDao`
  - Online: normal API call + cache result locally
  - Offline: assign local UUID, cache optimistically, queue to sync queue
  - `CropNotifier` now uses `CropOfflineRepository` (screens unchanged)

- **Inventory Offline CRUD** (Phase 4) — full offline create/edit/delete for inventory
  - `InventoryOfflineRepository` wraps `InventoryApiService` + `InventoryLocalDao`
  - Same online/offline pattern as crops

- **Harvests Offline CRUD** (Phase 4) — full offline create/delete for harvests
  - `HarvestOfflineRepository` wraps `HarvestApiService` + `HarvestLocalDao`
  - Handles crop-scoped harvest caching

- **Sync Service** — automatic queue replay when connectivity returns
  - `SyncService` processes pending mutations FIFO, handles local ID → server ID replacement
  - `syncTriggerProvider` auto-triggers sync on connectivity change
  - Client errors (4xx) marked as failed, server errors retry later

- **User-configurable offline mode** — toggle in Settings (default: off)
  - `offlineModeEnabledProvider` persisted via SharedPreferences
  - When disabled: pure API calls, no caching, no sync, no connectivity checks
  - When enabled: full offline CRUD + sync + cache + offline banner
  - Settings UI: toggle switch, cache size display, clear cache button with confirmation
  - All repositories, sync service, and offline banner respect the toggle

- **Bilingual offline strings** — 12 new translation keys (EN/SW): offlineMode, pendingChanges, checkingConnection, offlineNotAvailable, changesSaved, offlineModeTitle, offlineModeToggle, offlineModeDesc, cacheSize, clearCache, clearCacheWarning, cacheCleared

### Dependencies
- Added: `drift`, `drift_flutter`, `connectivity_plus`, `uuid`
- Added (dev): `drift_dev`, `build_runner`

## 0.11.1 - 2026-03-07

### Fixed
- Auth test compilation errors
  - Replaced `StreamProvider.overrideWithValue()` (not available in Riverpod 2.6.1) with `overrideWith()` using streams
  - Route protection tests now override `unifiedAuthStateProvider` directly instead of upstream `StreamProvider`
  - Fixed `FakeRef` to implement `Ref<Object?>` and `_FakeBuildContext` to implement `BuildContext` in sign-in tests

## 0.11.0 - 2026-03-07

### Added
- **Settings Screen** (`lib/features/settings/screens/settings_screen.dart`)
  - Dedicated settings screen accessible from both farmer and merchant profiles
  - Language toggle (English / Setswana) with current language display
  - Account section: change password, delete account (2-step confirmation)
  - Support section: report bug (BetterFeedback), help & support (contact info dialog)
  - About section: app version via `package_info_plus`, Agricola description
  - Logout button with confirmation dialog
  - All dialogs fully bilingual (EN/SW)

- **Reports Screen** (`lib/features/reports/`)
  - Farmer reports: farm overview stats (total/active/harvested crops, upcoming harvests), field summary (total size, estimated yield, inventory items, items needing attention, marketplace listings)
  - Merchant reports: business overview stats (products, orders, purchases, suppliers), financial summary (monthly/total revenue, monthly/total purchases), inventory summary
  - Activity timeline: recent activities across crops, inventory, purchases, and listings sorted by date
  - Both screens use real data from existing providers (no new backend endpoints)
  - Replaced hardcoded `BusinessStatisticsScreen` stub

- **Notifications Screen** (`lib/features/notifications/`)
  - Client-side notification system derived from existing crop and inventory data
  - Harvest reminders: overdue (high priority), upcoming within 7 days, approaching within 14 days
  - Inventory alerts: critical condition (high priority), needs attention (medium priority)
  - Notification bell with badge count on all 3 dashboard screens (farmer, merchant, AgriShop)
  - Priority-based sorting (high first, then by date)
  - Bilingual notification content (EN/SW)

- New dependency: `package_info_plus` ^9.0.0
- 30+ new translation keys for settings, reports, and notifications

### Changed
- Profile screens (farmer + merchant): replaced inline settings section with single "Settings" tile navigating to dedicated SettingsScreen
- Profile screens: removed ~250 lines of duplicated dialog code (change password, delete account, logout) now centralized in SettingsScreen
- Merchant profile: "Business Statistics" quick action now opens real MerchantReportsScreen
- Farmer profile: "View Reports" quick action now opens real ReportsScreen
- All 3 dashboard screens: "View Analytics" now navigates to reports instead of showing "coming soon"
- Removed `BusinessStatisticsScreen` (hardcoded stub)

## 0.10.0 - 2026-03-06

### Added
- Tester feedback / bug reporting feature
  - Integrated `feedback` package — screenshot annotation + text overlay
  - Integrated `flutter_email_sender` — sends annotated screenshot to developer@agricola-app.com
  - `FeedbackApiService` — silent POST to `/api/v1/feedback` backend endpoint
  - `showFeedbackOverlay()` helper — shared by both farmer and merchant profile screens
  - "Report Bug" settings tile in farmer and merchant profile screens (above Help & Support)
  - Dual delivery: email for immediate visibility, backend for historical record
  - `report_bug` translation key (EN: "Report Bug", SW: "Bega Bothata")
  - `feedbackEndpoint` added to `ApiConstants`
  - `BetterFeedback` widget wraps app in `main.dart`

## 0.9.0 - 2026-03-06

### Added
- List Inventory on Marketplace feature
  - Inventory items can be listed on the marketplace with pre-filled product details
  - "List on Marketplace" button on inventory detail screen navigates to AddProductScreen
  - "Unlist" button with confirmation dialog removes marketplace listing
  - "Listed" badge on inventory item cards shows marketplace status
  - `inventoryId` field on `MarketplaceListing` model links listings to inventory items

### Changed
- Rewrote `MerchantInventoryScreen` to use real backend data via `inventoryNotifierProvider`
  - Summary stats computed from real data (total items, low stock count)
  - FAB navigates to real `AddEditInventoryScreen`
  - Item tap navigates to real `InventoryDetailScreen` with edit/delete
- Extended `AddProductScreen` with `sourceInventory` parameter for pre-filling from inventory
- `InventoryDetailScreen` now shows marketplace list/unlist action at bottom
- `InventoryItemCard` accepts optional `isListed` flag for "Listed" badge
- Farmer and merchant inventory screens pass `isListed` status to cards

### Removed
- Deleted `MerchantInventoryDetailScreen` (hardcoded stub replaced by real `InventoryDetailScreen`)

## 0.8.0 - 2026-03-06

### Added
- Post-Harvest Loss Calculator (Phase 4)
  - 3-step form: crop/harvest selection, loss-by-stage inputs, results with prevention tips
  - `LossCalculation` model with stage breakdown, monetary loss, and severity classification
  - `LossResultsCard` widget: total loss %, monetary impact, stage progress bars, regional comparison
  - `PreventionTipsCard` widget: context-aware tips based on highest-loss stage and storage method
  - Regional average comparison using FAO Sub-Saharan Africa data
  - Loss causes per stage (field, transport, storage, processing) with Setswana translations
  - 13 bilingual prevention tips covering all loss stages
- Access points: farmer dashboard stat card tap, "Calculate Losses" quick action, crop details bottom bar
- `StatCard.onTap` callback for tappable stat cards

### Changed
- Farmer dashboard: added "Calculate Losses" quick action button below stats grid
- Crop details screen: bottom bar now shows "Calculate Losses" + "Record Harvest" side by side
- ~40 new EN/SW translation keys for loss calculator UI

## 0.7.0 - 2026-03-06

### Added
- Purchase record feature for merchants
  - `PurchaseModel`, `PurchasesApiService`, `PurchasesNotifier` provider
  - `AddPurchaseScreen` with catalog-driven crop dropdown, auto-calculated total
  - "Record Purchase" quick action on non-AgriShop merchant dashboard
- Setswana translations for all purchase-related strings

### Fixed
- AgriShop tab order bug: widget options now match nav labels (Products=1, Orders=2, Marketplace=3)
- AgriShop dashboard now uses `merchantDashboardStatsProvider` for live stats instead of hardcoded zeros
- Non-AgriShop merchant dashboard stats connected to real data (products, purchases, suppliers, low stock)
- Removed duplicate `enter_quantity` translation key

### Changed
- `MerchantDashboardStats` extended with `monthlyPurchases` and `totalSuppliers` fields
- `merchantDashboardStatsProvider` now watches `purchasesNotifierProvider` for purchase data
- `AgriShopDashboardScreen` refactored into small modular widget classes

## 0.6.1 - 2026-03-06

### Added
- `isNetworkUrl()` utility to guard against file:// URIs crashing `NetworkImage`
- 32 new tests: URL validation, crop helpers, CropCard widget, profile photo display
- `MockHttpOverrides` test helper for widget tests with `NetworkImage`

### Fixed
- Marketplace detail screen missing URL guard on `listing.imagePath`

### Changed
- Refactored 5 screens to use shared `isNetworkUrl()` instead of inline `.startsWith('http')`

## 0.6.0 - 2026-03-05

### Added
- Firebase Crashlytics for production error monitoring
  - Global error handling in `main.dart` via `runZonedGuarded`, `FlutterError.onError`, and `PlatformDispatcher.onError`
  - Non-fatal API error logging in Dio interceptor (logs method, path, and status code)
  - User identifier set on auth state change for error attribution
  - Android Gradle plugins configured for Crashlytics

## 0.5.0 - 2026-03-05

### Changed
- Moved crop catalog data from hardcoded Flutter maps to backend API (`/api/v1/crop-catalog`)
  - Added `CropCatalogEntry` model, `CropCatalogApiService`, and Riverpod providers
  - Refactored `add_edit_crop_screen.dart` to load crop categories and harvest days from catalog
  - Refactored `crop_helpers.dart` - `imageUrlForCrop()` now takes a server-provided image map
  - Refactored `add_edit_inventory_screen.dart` - crop dropdown populated from catalog
  - Refactored `farmer_inventory_screen.dart` - filter chips derived from catalog
  - Refactored `step_content.dart` (profile setup) - crop selection from catalog
  - Removed ~200 lines of hardcoded crop translations from `language_provider.dart`
  - Category translations (`vegetables`, `field_crops`, `fruits`) kept as fallback

## 0.4.1 - 2026-03-05

### Changed
- Migrated production backend from Render to GCP Cloud Run (europe-west2)
- Updated production API URL to `https://pandamatenga-api-510300582302.europe-west2.run.app`
- Added CLAUDE.md project context file for AI-assisted development
- Added auto-commit skill for streamlined commit workflow

## 0.4.0 - 2026-02-15

### Added
- Profile setup skip tracking with Firestore persistence
  - Added `hasSkippedProfileSetup` field to UserModel
  - Implemented `markProfileSetupAsSkipped()` method in auth repository and controller
  - Profile setup screens now properly mark and handle skip state
  - Auth state refreshes after skipping to reflect updated Firestore data

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
