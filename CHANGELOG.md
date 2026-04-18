## 1.4.1 - 2026-04-18

### Fixed
- **Order status confirmation** — Seller status changes (Confirm / Ship / Delivered) now require a confirmation dialog before proceeding, preventing accidental irreversible status updates. Matches the existing pattern used for buyer order cancellation.

## 1.4.0 - 2026-04-18

### Changed
- **Crop Availability — open to all stakeholders** — Farmers, merchants, and AgriShops all now access the Crop Availability screen from the marketplace AppBar grass icon. Previously farmers were gated out. The feature is for market transparency: merchants plan preorders, farmers assess saturation before planting.

### Added
- **Crop Availability — In 8 Weeks tab** — Forecast window extended 6 → 8 weeks; screen now has 5 tabs (Available Now / In 2 / 4 / 6 / 8 weeks).
- **Market Saturation banner** — Each upcoming tab shows a horizontally scrollable row of per-crop aggregate cards: total expected kg + farmer count + colour-coded supply level (red = saturated, amber = healthy, green = low). Thresholds are cautious flat defaults in `lib/features/marketplace/models/saturation_thresholds.dart`; prod-data calibration plan is in `tasks/todo.md`.
- **`SupplyAggregate` model** — `crop_availability_model.dart` now exposes `summary`, `in8Weeks` and `summaryForWindow(window)`. New `SaturationLevel` enum.
- **i18n** — `in_8_weeks`, `market_saturation`, `saturated_supply`, `moderate_supply`, `low_supply`, `farmers_count` (EN + TSN).

### Fixed
- **"Available Now" was returning stale listings** — backend query now filters `marketplace_listings.created_at >= NOW() - 60 days` (was unfiltered by age). Listings older than 60 days no longer appear as available.

## 1.3.1 - 2026-04-18

### Fixed
- **Phone number in edit profile** — Both farmer and merchant edit profile screens now include an editable phone number field. Phone is stored in the profile backend (new `phone_number` column via migration 018).
- **Farm size preselection** — Standardised farm size options to `< 1 Hectare / 1-5 Hectares / 5-10 Hectares / 10+ Hectares / Other` across both profile setup and edit farmer screens. Previously the edit screen used mismatched labels so the saved value was never pre-selected.
- **Farm size widget** — Replaced `AppRadioGroup` with card-based selector in `EditFarmerProfileScreen` to match the profile setup step and the merchant edit screen.
- **"Other" option in all dropdowns** — Added `Other` to yield units, storage methods (crops), inventory units, storage locations, and purchase units. Selecting `Other` reveals a text field for the custom value, which is saved in place of the generic option.

## 1.3.0 - 2026-04-18

### Added
- **Crop Availability screen** — Merchants and AgriShops can browse farmers' current marketplace listings and upcoming harvests by time window (Available Now, In 2 Weeks, In 4 Weeks, In 6 Weeks). Accessible via the grass icon in the marketplace AppBar (merchants only).
- **Inventory unit price** — Inventory add/edit form now includes an optional "Unit Price (P)" field. The inventory card shows `· P{total}` beside quantity when a price is set. Total value in the header card now uses actual unit prices instead of a hardcoded estimate.
- **Merchant feature showcase** — Profile setup complete screen now shows user-type-specific feature highlights: farmers see crops/inventory/marketplace, AgriShops see source-from-farmers/orders/inventory, other merchants see list-products/orders/analytics.

### Fixed
- **Order detail bottom sheet invisible** — The sheet now has a white background and rounded top corners (was transparent, making content unreadable on dark backgrounds).
- **"Kilograms" → "kg"** — Unit label translated to abbreviated "kg" instead of full "Kilograms" throughout the inventory list.

## 1.2.1 - 2026-04-17

### Fixed
- **Heading font sizes** — Standardised all body-level screen headings (My Crops, Inventory View, Store/Produce Inventory) to `displaySmall` (24 px) for visual consistency with the marketplace AppBar title.
- **Call / email buttons** — Added `LSApplicationQueriesSchemes` (iOS) and `<queries>` intents (Android) for `tel` and `mailto` so the phone and email buttons now reliably open native apps. Error snackbar shown if launch fails. Phone number whitespace stripped before dialling.
- **Phone icon centering** — Replaced empty-label `AgriStadiumButton` with new `AgriIconButton` widget in the marketplace detail bottom bar so the phone icon is correctly centred in its circular outline button.
- **Image upload — compress before reject** — Images are now compressed first, then size-checked, so large raw photos (e.g. 12 MB DSLR shots) upload successfully after compression. Invalid format shows a specific error; multi-image picker shows a count of skipped files instead of failing silently.
- **Seller shown as "Unknown"** — Marketplace listings created by farmers (who have no `businessName`) now show the email prefix as the seller name instead of "Unknown". Merchants still use `businessName`.
- **Stale inventory "Listed" state** — After deleting or unlisting a marketplace listing, `myListingsNotifierProvider` and `inventoryNotifierProvider` are now invalidated centrally in `MarketplaceNotifier`, so the inventory screen immediately reflects the unlisted state.
- **Marketplace delete → Unlist** — When a listing is linked to an inventory item (`inventoryId != null`), the owner action icon and confirmation dialog now say "Unlist" instead of "Delete" to match the expected behaviour.
- **Quantity validation** — Marketplace listing form now defaults quantity to `1` and rejects zero/empty values with a validation error. Sold-out listings (quantity ≤ 0) show a `SOLD OUT` badge, the available metric turns red, and the "Request to Buy" button is disabled (contact seller remains active).
- **Image loading speed** — Added `AgricolaCacheManager` (30-day stale period, 500-object limit) as the shared cache manager for all `AppNetworkImage` widgets. Images now fade in instantly when served from cache. Marketplace and inventory list screens precache up to 20 image URLs after the initial data load.

### Added
- **`AgriIconButton`** widget — circular icon-only outlined button for use when no label is needed.
- **`AgricolaCacheManager`** — shared network image cache manager (`lib/core/widgets/app_image_cache.dart`).
- **i18n keys** — `image_invalid_format`, `image_too_large_even_compressed`, `some_images_skipped`, `could_not_open_phone_app`, `could_not_open_email_app`, `sold_out`.

### Changed
- **Splash screen** — Background is now solid `deepEmerald` green with bone-coloured title text and an earth-yellow loading indicator.

## 1.2.0 - 2026-04-17

### Fixed
- **Merchant tab routing bug** — Non-AgriShop merchant dashboard INVENTORY and ORDERS quick-action buttons were navigating to the wrong tabs (Marketplace and Inventory respectively) because `profileSetupProvider` defaulted to AgriShop when unloaded. Removed the dead `isAgriShop` branch from `MerchantDashboardScreen`; INVENTORY now correctly goes to the Produce tab, ORDERS navigates to the Orders screen, and "View all orders" in Recent Activity no longer miswires to the Inventory tab.
- **Loss calculator — unnecessary decimals** — Summary values like `20.0%` and `3.0 Kilograms` now display as `20%` and `3 Kilograms` when the value is a whole number. Added `AgriKit.formatPercent()` helper and applied it across the results card and running-total row.
- **Orders — tap card to view details** — Order cards are now tappable for both buyers and sellers, opening the full details sheet. After placing an order via the marketplace, a "View Orders" snackbar action lets users jump directly to their order list without losing context.

### Added
- **Loss calculator — "Other" option** — Unit dropdown (kg / bags / tons) and storage method dropdown now include an "Other" option. Selecting it reveals a mandatory free-text field that flows through to all stage inputs and the results summary.
- **Loss calculator — per-stage monetary impact** — Each stage row in the results breakdown now shows the monetary value lost (e.g. `- P7.95`) alongside the quantity and percentage.

### Changed
- **Inventory tab — Digital Earth redesign** — Replaced the legacy tinted green/yellow summary cards ("AI-tell" pattern) with a single dark `AgriFocusCard` hero displaying Total Value and Items Needing Attention metrics. Title uses `displayMedium` with an uppercase letter-spaced subtitle. Background updated to `AppColors.bone` for consistency with other Digital Earth screens.

## 1.1.4 - 2026-04-17

### Fixed
- **Help & Support dialog** — Email address no longer overflows the card edge on narrow screens (wrapped in `Flexible`).
- **Destructive dialog UX** — Flipped button order for dangerous actions: the safe "Cancel" is now the prominent stadium button, and the destructive action is a subtle red text link. Affects Delete Account, Logout, Cancel Order, Unlist, and Delete Listing dialogs.
- **Edit Business Profile pre-selection** — Replaced invisible Material 3 `Radio` buttons with clear Digital Earth card selector; merchant type is now visually pre-selected on screen open.
- **Dropdowns — full migration to modal bottom sheet** — Replaced all raw `DropdownButton` / `DropdownButtonFormField` usages (Add Product, Loss Calculator, Record Harvest, Loss Stage Input) with the updated `AppDropdownField` that opens a draggable bottom sheet with a close X and proper dismiss affordance.
- **Marketplace detail — Available amount** — "AVAILABLE" metric now right-anchors for a clean space-between layout against "PRICE" in the Hero card.
- **Translation raw keys** — Added 14 missing EN/Setswana keys to `agricola_core` (`my_orders`, `sales`, `my_requests`, `no_purchase_requests`, `purchase_requests_appear_here`, `photos_optional_hint`, `add_image_slot`, `at_least_one_image_required`, `error_upload_failed`, `contact_phone`, `phone_required_for_listing`, `request_to_buy`, `no_orders_yet`, `orders_will_appear_here`). Upgraded `agricola_core` lock to latest `main` — all previously stale keys are now live.
- **Inventory upload error** — Error snackbar now shows translated message. In debug builds, the underlying exception is appended for faster root-cause diagnosis.

## 1.1.3 - 2026-04-17

### Changed
- **UI component refactoring** — migrated button components (`AppPrimaryButton`, `AppSecondaryButton`, `AppTextButton`) into unified `AgriKit` library; added `AgriTextButton` for consistent text button styling and `AgriKit.formatQuantity()` utility for quantity formatting
- **Cleaned up language provider** — removed deprecated and unused translation keys to reduce bundle size
- **Code organization** — consolidated core UI widgets into `agri_kit.dart` for better maintainability

## 1.1.2 - 2026-04-17

### Fixed
- **Profile setup error handling** — surface backend validation errors for profile creation flow instead of generic failure messages; improved error message extraction from 400 responses

## 1.1.1 - 2026-04-16

### Added
- **Direct Seller Contact** — Added prominent **Call** and **Email** action buttons to the Marketplace Detail screen, powered by `url_launcher`.
- **Integrated url_launcher** — Added dependency to support native phone and email application launching.

### Fixed
- **Metric Scaling** — Improved `AgriMetricDisplay` with `FittedBox` to prevent UI overflow when displaying long values (e.g., large quantities).
- **Redesign Completion** — Migrated remaining legacy UI components to the "Digital Earth" ethos, including Settings, Purchase forms, Profile completion, and shared Dialogs.
- **Button Consistency** — Styled all remaining `TextButton` and `ElevatedButton` instances to follow the bold, high-contrast aesthetic.
- **SwitchListTile Deprecation** — Replaced deprecated `activeColor` with `activeThumbColor` in Settings.

## 1.1.0 - 2026-04-16

### Added
- **"Digital Earth" Design Ethos overhaul** — Complete visual redesign of the application using a bold, modern, and clean aesthetic.
- **Forest & Bone palette** — Replaced generic colors with a premium high-contrast theme featuring Deep Emerald (#081C15) and Forest Green (#1B4332) on a warm Bone (#FDFCF9) background.
- **Plus Jakarta Sans typography** — Implemented a modern geometric typeface app-wide, using heavy weights (ExtraBold/Black) for metrics and headers to improve visual hierarchy and scan-ability.
- **Hero Focus Dashboards** — Redesigned Farmer, Merchant, and AgriShop dashboards with large summary cards that highlight key metrics at a glance.
- **AgriKit UI Components** — New suite of reusable widgets including `AgriFocusCard` (high radius corners), `AgriStadiumButton` (fully rounded tactile actions), and `AgriMetricDisplay`.
- **Stadium-style inputs** — Redesigned all form fields and dropdowns with fully rounded borders and bold, technical labels.

### Fixed
- **Null-safety in order displays** — Resolved potential crashes when rendering orders with missing or short IDs on dashboard screens.
- **Deprecated API usage** — Migrated from `withOpacity()` to the new `withValues(alpha: ...)` API throughout the codebase to ensure compatibility with latest Flutter versions.

## 1.0.19 - 2026-04-16

### Fixed
- **Location search partial matching** — Replaced pure Nominatim lookups with a hybrid approach: 160+ bundled Botswana settlements are filtered locally by prefix/contains match (instant, offline-capable), with Nominatim running in parallel for 4+ character queries to surface less-common locations not in the local list.
- **Edit inventory image upload** — Images added while editing an existing inventory item now upload to a timestamp-based folder (same as add mode) instead of an item-ID-based path, resolving the Firebase Storage path mismatch that caused the "Photo upload failed" error. Same fix applied to edit marketplace listing.

### Added
- **Image caching** — All `Image.network()` calls replaced with `CachedNetworkImage` via a new shared `AppNetworkImage` widget. Images are cached on-device after first load, eliminating re-downloads on every screen visit (inventory detail, marketplace detail, image pickers).

## 1.0.18 - 2026-04-16

### Fixed
- **Inventory delete guard** — Deleting an inventory item that is listed on the marketplace now shows a warning dialog ("Delete Both") and automatically removes the marketplace listing first, preventing orphaned listings. Combined success message shown on completion.

## 1.0.17 - 2026-04-16

### Fixed
- **Multi-photo selection** — Gallery picker in both inventory edit and marketplace add-product forms now uses `pickMultiImage`, letting users select up to 5 photos in a single gallery session instead of one at a time. Camera remains single-shot.
- **Inventory edit add-photo** — Fixed silent image-picker failure on the edit inventory screen (matched the multi-image approach used by the marketplace form).
- **Inventory detail layout** — Changed sticky bottom button `SafeArea` to `top: false`, preventing unexpected top padding inside the Scaffold body that was compressing the scrollable content area.
- **Marketplace two-way trading (R-??)** — Farmers can now list produce for sale (not just supplies). `AddProductScreen` now has a "Listing Type" toggle (Produce / Supplies) that defaults to Produce when listing from inventory or creating a new listing, and restores the existing type when editing. Marketplace provider no longer force-filters by user type — all users see all listings; type filtering is available via the filter sheet.

## 1.0.16 - 2026-04-16

### Added
- **Farm location autocomplete (R-01)** — Replaced the hardcoded dropdown of 20 towns with a live search field backed by Nominatim (OpenStreetMap geocoding, filtered to Botswana). Users can type any village, settlement, or area and select from real suggestions. Works in profile setup (farmer + merchant) and both edit-profile screens. The map picker is retained as an optional visual fallback.

## 1.0.15 - 2026-04-16

### Fixed
- **Inventory detail redesign** — Replaced the tinted-green header container with a full-width hero image (PageView with animated dots for multi-photo items), clean bold crop name, green quantity, and plain colour-coded condition text. Removed blank-sheet effect caused by short content; content now fills screen correctly.
- **Password visibility toggle** — `AppTextField` is now stateful; when `obscureText: true`, a visibility icon button is shown automatically in the suffix position. Works on both sign-in and sign-up screens.
- **Order card detail** — Order cards now list each item by name with quantity (e.g. "Maize × 3") instead of "1 item". Total amount moved inline with the timestamp row.
- **Seller orders auto-refresh** — `OrdersScreen` now triggers a fresh load of both seller and buyer providers every time the screen is visited, so newly placed purchase requests appear immediately without requiring a manual pull-to-refresh.
- **Farmer seller orders** — Farmers' "My Orders" dashboard button now shows both the Sales tab (incoming purchase requests for their listings) and the My Requests tab (`showSalesTab: true`).
- **Product categories expanded** — Marketplace listing form now includes Vegetables, Fruits, Grains & Cereals, Legumes, Roots & Tubers, Herbs & Spices, Livestock, Poultry, Dairy & Eggs, Processed Foods, plus the original agricultural supply categories. Selecting "Other" reveals a free-text field to specify the category.
- **Quantity units expanded** — Both the marketplace add-product form and the inventory add/edit form now offer a full set of farming units: kg, g, tons, bags, sacks, crates, litres, ml, pieces, boxes, bundles, heads, dozen, bales, trays.

## 1.0.14 - 2026-04-16

### Added
- **Request-to-Buy CTA on product pages (R-05)** — Non-owner marketplace detail page now has a "Request to Buy" primary button alongside a phone contact shortcut. Tapping it opens a bottom sheet with quantity input (validated), optional note, and live total preview. Submitting creates a `pending` order via `POST /api/v1/orders` with success feedback explaining that the seller will arrange payment and delivery off-platform.
- **Tabbed Orders screen (Sales | My Requests)** — Replaced the AgriShop-only orders view with a unified `OrdersScreen` supporting both seller (Sales) and buyer (My Requests) tabs. Buyers can cancel pending requests. Sellers can confirm → ship → delivered.
- **Orders entry for all user types** — Farmers get a "My Orders" quick-action button on their dashboard (alongside the existing Loss Calculator). Non-AgriShop merchants now navigate to the full Orders screen from "View Orders" instead of a coming-soon dialog.

## 1.0.13 - 2026-04-16

### Fixed
- **Crop limit removed (R-02)** — Profile setup and edit farmer profile no longer enforce a hard cap of 5 crops. Farmers can now select as many crops as they grow. Removed `maxPrimaryCropsCount` constant, dropped the upper-bound validation from `ProfileValidators`, and removed `maxSelection: 5` from the edit profile chip group.

## 1.0.12 - 2026-04-16

### Fixed
- **Sign-up bypasses account type selection** — "Don't have an account? Sign up" link on the sign-in screen was navigating directly to `/sign-up`, skipping the account type selection screen (`/register`). Now correctly routes to `/register` first so users choose Farmer, Agri Shop, or Supermarket Vendor before entering credentials.

## 1.0.11 - 2026-04-16

### Added
- **Real photo uploads for inventory and marketplace** — Users can attach up to 5 real photos per inventory item and marketplace listing. Inventory `AddEditInventoryScreen` has a horizontal scroll image picker (camera + gallery). Marketplace `AddProductScreen` upgraded from single-image to the same multi-image pattern. Marketplace list cards now show a thumbnail. Marketplace detail view shows all images in a swipeable PageView with dot indicators. `FirebaseStorage` now has `uploadInventoryImage()` at `inventory/{userId}/{itemId}/`. Backend migration 016 adds `image_urls TEXT[]` to the inventory table.

### Fixed
- **Inventory image mismatch + harvest-to-inventory gap (R-07)** — Inventory cards and detail screens now show the actual crop thumbnail (same `imageUrlForCrop` logic as crop cards, with a neutral `local_florist_outlined` icon as fallback). After a harvest is saved, a one-tap confirm dialog appears — "Add {amount} {unit} of {crop} to inventory?" — pre-filled from the harvest form. Dismissing with "Not now" is instant; confirming creates the inventory entry automatically with quality mapped to condition.

## 1.0.9 - 2026-04-16

### Fixed
- **Crop image mismatch (R-06)** — removed the maize fallback in `imageUrlForCrop` that was showing a corn photo for any crop without its own image (e.g. "Rape" displayed maize). `CropCard` now renders a neutral icon placeholder when no image URL is available. Backend migration 015 also backfills all 49 previously-NULL crop image URLs, so the placeholder path is reserved for genuinely unknown crop types.

## 1.0.8 - 2026-04-16

### Fixed
- **Profile setup error handling** — surface backend validation messages from profile creation and avoid a generic failure state when creating user profiles.

## 1.1.2 - 2026-04-17

### Changed
- **UI component refactoring** — migrated button components (`AppPrimaryButton`, `AppSecondaryButton`, `AppTextButton`) into unified `AgriKit` library; added `AgriTextButton` for consistent text button styling and `AgriKit.formatQuantity()` utility for quantity formatting
- **Cleaned up language provider** — removed deprecated and unused translation keys to reduce bundle size
- **Code organization** — consolidated core UI widgets into `agri_kit.dart` for better maintainability

## 1.0.7 - 2026-04-12

### Fixed
- **Setswana error translations** — replaced transliterated/incorrect strings in `error_no_connection`, `error_timeout`, `error_server_slow`, `error_server`, `error_conflict`, `error_cancelled`, and `error_auth_required` with native-validated wording.
- **`ErrorRecoveryService` now honours the user language** — resolves `AppLanguage` from the active `ProviderScope` via the surrounding `BuildContext` instead of hardcoding English.

### Changed
- **`SignInNotifier` analytics injection** — receives `AnalyticsService` directly instead of stashing `Ref`, matching the rest of the notifiers in the app.
- **`HomeScreen` tab-name drift guard** — tab name lists promoted to file-level consts with debug `assert`s that the widget list length matches, preventing silent drift when tabs are reordered.

## 1.0.6 - 2026-04-08

### Added
- **Orders test coverage (M-05)** — 42 tests across 3 test files
  - `order_model_test.dart` — OrderItem + OrderModel fromJson/toJson, round-trip, copyWith, constructor defaults, null id handling
  - `orders_api_service_test.dart` — all 4 endpoints (getUserOrders with/without role, getOrder, updateOrderStatus, cancelOrder) with mocked Dio
  - `orders_notifier_test.dart` — loadOrders (online, offline, cache fallback, error states, role param), updateOrderStatus (success, analytics, error, state immutability), cancelOrder (success, multi-order isolation, error, state immutability)
- Updated feature tracker: Orders now marked as `[x] Good` (3 test files)

## 1.0.5 - 2026-04-07

### Added
- **Marketplace test coverage (M-05)** — 49 tests across 4 test files
  - `marketplace_listing_test.dart` — fromJson, toJson, copyWith, computed properties (isAvailableNow, isProduce/isSupplies), enum fallbacks
  - `marketplace_filter_test.dart` — toQueryParameters, hasActiveFilters, activeFilterCount, copyWith with clear flags
  - `marketplace_api_service_test.dart` — all CRUD endpoints with mocked Dio
  - `marketplace_notifier_test.dart` — load/add/update/delete (success + error), sorting, offline fallback, local cache
- Updated feature tracker: inventory (already had 34 tests) and marketplace now marked as covered

## 1.0.4 - 2026-04-07

### Fixed
- **User-friendly error messages (M-03)** — raw API exceptions no longer surface to users
  - New `errorKeyFromException()` utility (`lib/core/utils/error_utils.dart`) maps DioException, SocketException, TimeoutException to translation keys
  - 11 bilingual error messages added (English + Setswana) — e.g. "No internet connection" / "Ga go na kgolagano ya inthanete"
  - Updated 18 catch blocks across 7 providers to return translation keys instead of `e.toString()`
  - Updated 17 error display sites across 12 screens to use `t(key, lang)` for bilingual output
  - `ErrorRecoveryService._getErrorMessage()` now uses the shared mapping
  - Updated inventory notifier tests to expect error keys

## 0.20.15 - 2026-04-07

### Added
- **Firebase Analytics (M-01)** — full usage tracking added to the mobile app
  - Centralized `AnalyticsService` (`lib/core/services/analytics_service.dart`) with typed methods for every event — no raw string event names scattered across the codebase
  - Automatic screen view tracking via `FirebaseAnalyticsObserver` on GoRouter (all auth/onboarding routes)
  - User properties: `user_type` (farmer/agriShop/merchant) set on every auth state change; `app_language` set on language selection
  - Onboarding funnel: `onboarding_start`, `onboarding_complete`, `user_type_selected`, `signup_complete`, `signin_complete`, `profile_setup_started`, `profile_setup_complete`, `profile_setup_skipped`
  - Feature adoption events: `crop_added`, `harvest_recorded`, `inventory_added`, `listing_created`, `purchase_recorded`, `order_status_updated`, `loss_calculated`, `report_exported`
  - Tab switch tracking: `tab_switch` with tab name on bottom-nav changes
  - No PII in any events — compliant with Botswana Data Protection Act 2018

## 0.20.14 - 2026-04-02

### Changed
- **Crop catalog corrections** — applied client-confirmed plant population updates for 12 crops (maize corn corrected from 350,000→50,000; plus tomatoes, carrots, bell peppers, cucumbers, watermelon, pumpkin, butternut, eggplant, sweet potatoes, zucchini)

## 0.20.13 - 2026-03-31

### Changed
- **Standardized app dialogs** — replaced 20 inconsistent inline `AlertDialog` implementations across 8 files with a unified `AppDialogs` utility (`lib/core/widgets/app_dialogs.dart`). Two types: `confirm()` for two-button confirmations (green or red action button based on `isDestructive` flag) and `info()` for single-button informational dialogs. Consistent border radius (16), button shape, and color usage throughout.

## 0.20.12 - 2026-03-31

### Changed
- **Total daily water requirements** — crop details screen now shows total daily water (litres), hourly pump rate, water rate (mm/day), and estimated plant count based on field size — helps farmers compare against water rights pump capacity
- **Crop catalog data update** — updated plant population per hectare and daily water requirement values for all 68 crops to match client-provided reference data (migration 013)

## 0.20.11 - 2026-03-30

### Added
- **Sold Fresh storage option** — farmers who sell produce fresh (unpackaged) can now select "Sold Fresh" as the storage type in both inventory and crop forms
- **"Heads" and "Cobs" yield units** — crops counted in heads (e.g. cabbage) or cobs (maize) can now be recorded with the correct unit in both Add Crop and Record Harvest
- **Maize cob hint** — when maize is selected in the crop form or harvest screen, an inline tip reminds farmers that maize produces 2 cobs per plant
- **Daily water requirements** — crop details screen now shows daily water requirement (mm) from the crop catalog when available
- **District map picker** — location selection during profile setup now includes a "View on Map" button that opens an interactive OpenStreetMap showing all 20 supported towns; tapping a town auto-selects it in the dropdown

### Fixed
- **Profile photo upload failing during registration** — added image validation and compression (via `ImageUtils`) before upload; actual Firebase error message now surfaces to the user instead of a generic fallback. Root cause: Firebase Storage security rules likely missing — see `docs/FIREBASE_SETUP.md` for required rules

### Docs
- Added `docs/FIREBASE_SETUP.md` documenting required Firebase Storage security rules for profile and marketplace photo uploads

## 0.20.10 - 2026-03-30

### Fixed
- **Google Sign In broken on Google Play** — root cause: Play App Signing re-signs the AAB with Google's own key; the Play App Signing certificate SHA-1 must be registered in Firebase Console and included in `google-services.json` for Android OAuth verification to succeed in production
- **Null safety bug in Google auth flow** — empty null-check on `googleAuthorization` followed by force-unwrap `!` would crash if scopes were denied; now throws a proper exception that surfaces as an `AuthFailure`
- **Raw exception shown on Google sign-in cancel** — `GoogleSignInException` now handled in `_toAuthFailure`; users see "Sign in was canceled." instead of the raw exception string

## 0.20.9 - 2026-03-26

### Changed
- **Color hygiene pass** — remove remaining tinted containers and replace off-palette hardcoded colors with AppColors constants across 6 files
  - `validation_hint_card.dart`: removed parametric color; card is now a consistent neutral grey (no rainbow hint cards)
  - `settings_screen.dart`: removed tinted Container wrapping the About dialog icon
  - `profile_setup_screen.dart`: removed red tinted bg/border from error message; alertRed applied to icon and text directly
  - `selection_card.dart`: removed green tint from selected card background; green border + icon remain as selection indicators
  - `offline_banner.dart`: replaced `Colors.amber.shade700`, `Colors.orange.shade700`, `Colors.red.shade700` with `AppColors.warmYellow` / `AppColors.alertRed`
  - `farmer_dashboard_screen.dart`: replaced all hardcoded `Color(0xFF...)` and `Colors.grey[X]` values with AppColors constants

## 0.20.8 - 2026-03-25

### Changed
- **Remove AI-tell colored container pattern** — eliminated ~30 instances of `Container(color: X.withAlpha())` wrapping icons, text badges, and status pills across 13 files. Icons now show their color directly; text labels use colored text without background fills; info sections use neutral grey instead of tinted backgrounds. Affected: stat cards, dashboards (quick actions, order tiles), inventory cards, notifications, activity timeline, marketplace listings/detail, crop details, loss calculator, onboarding slides, selection cards.

## 0.20.7 - 2026-03-22

### Added
- **Play Store release CI workflow** — new `play-store-release.yml` GitHub Actions workflow (manual dispatch) builds AAB with proper keystore secrets, matching the App Distribution pipeline
- **Startup server warm-up** — fire-and-forget health ping during app initialization to warm Cloud Run before users hit sign-in

### Fixed
- **Cloud Run cold start resilience** — retry interceptor now handles HTTP 502/503 responses (Cloud Run cold-start codes), reduced backoff from 3 retries/3s to 2 retries/2s
- **Dio timeout config was dead code** — `ApiConstants.connectionTimeout` (15s) and `requestTimeout` (45s) were defined but never wired to Dio; now applied instead of hardcoded 30s/30s
- **Image 404 crash** — added `onError` handlers to all `NetworkImage`/`DecorationImage` usages so broken Unsplash URLs fail gracefully instead of crashing the app
- **Cloud Run min-instances** — set `--min-instances=1` on backend deploy to eliminate cold starts

## 0.20.6 - 2026-03-22

### Added
- **Skeleton loaders for all loading states** — replace bare `CircularProgressIndicator` with shimmer-animated skeleton placeholders that match each card's layout
  - Reusable primitives: `ShimmerWrapper`, `SkeletonBox`, `SkeletonLine`, `SkeletonCircle` in `lib/core/widgets/skeleton_primitives.dart`
  - 6 composite skeletons: `StatCardSkeleton`, `CropCardSkeleton`, `InventoryItemCardSkeleton`, `MarketplaceListingSkeleton`, `OrderCardSkeleton`, `HarvestHistoryCardSkeleton`
  - Updated 9 screens: farmer/merchant/agrishop dashboards, crops, farmer/merchant inventory, marketplace, orders, reports
  - Added `shimmer: ^3.0.0` dependency

## 0.20.5 - 2026-03-08

### Fixed
- **Fix render overflows on dashboard, crops screen, and loss calculator**
  - CropCard: wrap crop name in `Expanded` with ellipsis to prevent long names pushing stage badge off-screen
  - Loss calculator: adjust harvest amount/unit flex ratio (3:2) so "Kilograms" dropdown fits
  - Crop details: reduce InfoCard grid aspect ratio (1.8→1.5) and add `maxLines: 2` so "1500.0 Kilograms" fits without bottom overflow
- **Register missing profile edit routes** — add `/profile/edit` and `/profile/edit-merchant` GoRoute entries so edit profile navigation works

## 0.20.4 - 2026-03-08

### Changed
- **Extract shared code into `agricola-core` package** — models, enums, API services, auth interfaces, i18n, and helpers extracted to a shared Dart package for reuse by the upcoming web dashboard
  - Mobile files re-export from core to maintain backward compatibility
  - Firebase-specific code (UserModel factories, AuthFailure mapping) moved to standalone functions in `user_model_firebase.dart`
  - `agricola_core` dependency points to GitHub repo (`agricola-dev/agricola-core`)
- **Add web dashboard feature tracker** — 73-item phased plan across 10 phases (setup through reports/export)

## 0.20.3 - 2026-03-07

### Fixed
- **Fix crop display names** — display proper localized names instead of snake_case keys
  - Added `cropDisplayName()` helper that looks up crop catalog entries and returns translated names (English/Setswana)
  - Falls back to title-casing the key if catalog not loaded
  - Updated 10 screens/widgets to use the helper instead of passing raw keys to `t()`

## 0.20.2 - 2026-03-07

### Changed
- **Standardize app color palette** — replace ad-hoc Colors.orange/blue/purple/teal/amber with AppColors constants across 25 files
  - All stat card icons use `AppColors.green` (primary accent)
  - Warning/attention states use `AppColors.warmYellow`
  - Error/loss/cancelled states use `AppColors.alertRed`
  - Neutral/inactive states use `AppColors.mediumGray`
  - Order statuses, crop statuses, condition colors, notification priorities all follow the same 4-color palette
  - Quick action icons unified to primary green instead of rainbow colors

## 0.20.1 - 2026-03-07

### Fixed
- **Sign-out/sign-in stale state** — switching accounts no longer shows previous user's data or wrong tab
  - Removed imperative `context.go('/')` from sign-out/delete-account; navigation now driven declaratively by go_router route guards
  - Dismiss dialogs before triggering sign-out to prevent context issues
  - All user-data providers (crops, inventory, marketplace, orders, purchases, analytics) watch `currentUserProvider` and auto-rebuild on user change
  - `selectedTabProvider` resets to dashboard (index 0) when user changes
  - Explicitly invalidate `profileSetupProvider` and `profileControllerProvider` on sign-out

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
