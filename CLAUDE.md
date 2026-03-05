# Agricola — project context for Claude

## What it is
Flutter mobile app (SDK ^3.9.0) for smallholder farmers in Botswana. Farmers manage crops, track harvests, and trade on a marketplace. Merchants and AgriShops are also supported user types.

---

## Directory layout

```
lib/
  core/
    config/          — environment config (dev/prod base URLs)
    constants/       — ApiConstants, validation rules, storage keys
    network/         — Dio client setup, auth interceptor
    providers/       — app-wide providers: language, nav, onboarding, initialization
    routing/         — go_router config, route guards
    screens/         — splash screen
    theme/           — AppColors, AppTheme (primary green = 0xFF2D6A4F)
    utils/           — ImageUtils (profile image compression)
    widgets/         — shared widgets (AppPrimaryButton, etc.)
  data/auth/         — Firebase auth data layer
  domain/            — enums, shared domain types (UserType, MerchantType)
  features/          — feature-first folders, each contains screens/, providers/, models/, data/, widgets/
    auth             — sign-in, sign-up, registration
    crops            — crop CRUD (the most developed feature)
    home             — HomeScreen (bottom nav shell), dashboard screens per user type
    inventory        — farmer & merchant inventory
    marketplace      — shared marketplace
    onboarding       — welcome + onboarding flow
    orders           — AgriShop orders
    profile          — profile screen
    profile_setup    — first-time profile setup flow
```

---

## Navigation — two-tier system

### Tier 1: go_router (auth / top-level flow)
Defined in `lib/core/routing/app_router.dart`. Handles the pre-auth and post-auth routing:
- `/splash` → `/` (welcome) → `/sign-in` or `/register` → `/profile-setup` → `/home`
- `RouteGuards.redirect()` checks auth state and redirects automatically.
- Once at `/home`, the user stays there; all in-app navigation is tier 2.

### Tier 2: bottom-nav tabs + Navigator.push (within the app)
- `HomeScreen` (`lib/features/home/screens/home_screen.dart`) is the bottom-nav shell.
- Active tab is driven by `selectedTabProvider` — a `StateProvider<int>` in `lib/core/providers/nav_provider.dart`.
- **To switch tabs programmatically** (e.g. a "View All" button jumping to another tab): write to `selectedTabProvider`. Do NOT use `Navigator.push` or `context.go` for this.
- **To push a new screen within the current tab** (e.g. crop details): use `Navigator.push` with `MaterialPageRoute`.

### Farmer tab indices (hardcoded in HomeScreen)
| Index | Screen |
|-------|--------|
| 0 | FarmerDashboardScreen |
| 1 | MarketplaceScreen |
| 2 | CropsScreen |
| 3 | FarmerInventoryScreen |
| 4 | ProfileScreen |

AgriShop and Merchant have different tab orders — check `home_screen.dart` widgetOptions lists.

---

## State management — Riverpod patterns

- **Async backend data**: `StateNotifierProvider` wrapping a `StateNotifier<AsyncValue<T>>`. The notifier auto-fetches on init and exposes CRUD methods that return `String?` (null = success, non-null = error message). Screens watch the provider and use `AsyncValue.when(data/loading/error)`.
  - Example: `cropNotifierProvider` in `lib/features/crops/providers/crop_providers.dart`
- **Simple shared state**: `StateProvider<T>` for things like selected tab index or language.
- **Providers live in** `lib/features/<feature>/providers/` or `lib/core/providers/`.

---

## Backend (Pandamatenga)

- Dart/Shelf server with PostgreSQL, hosted on Render in prod.
- Dev: `localhost:8080` (iOS sim) or `10.0.2.2:8080` (Android emulator) — handled automatically in `ApiConstants.baseUrl`.
- Auth: Firebase JWT tokens are injected into every Dio request via an interceptor in `lib/core/network/`.
- API endpoints are centralised in `lib/core/constants/api_constants.dart`:
  - `api/v1/crops`, `api/v1/harvests`, `api/v1/inventory`, `api/v1/marketplace`, `api/v1/profiles`

---

## Internationalization

- Two languages: English and Setswana (`AppLanguage` enum in `language_provider.dart`).
- Translation function: `t(key, lang)` — defined at the bottom of `lib/core/providers/language_provider.dart`. All string maps live in that same file.
- Every user-facing string in widgets should go through `t()`. Watch `languageProvider` in the widget's `build()` to get the current language.

---

## User types

Determined from Firebase user data (not local cache). Checked in `HomeScreen.build()`:
- **Farmer** — `user.userType == UserType.farmer`
- **AgriShop** — `user.merchantType == MerchantType.agriShop`
- **Merchant** — everyone else

Each type gets a different set of dashboard + nav tabs.

---

## Shared code conventions

- **Don't duplicate helpers.** If a utility is used by more than one screen, extract it to a shared location. Example: `lib/features/crops/crop_helpers.dart` has `cropStage()`, `cropProgress()`, `formatCropDate()`, `imageUrlForCrop()` — used by both the dashboard and the crops screen.
- **Theme colour**: primary green is `const Color(0xFF2D6A4F)` everywhere. Also available as `AppColors.green` from `lib/core/theme/app_theme.dart`.
- **Card layout pattern**: sticky-button screens use `Column` + `Expanded(SingleChildScrollView(...))` + `Padding(button)` — not `Stack`/`Positioned`.

---

## Crops feature — the most developed feature (good reference)

```
lib/features/crops/
  data/
    crop_api_service.dart   — GET/POST/PUT/DELETE against /api/v1/crops
  models/
    crop_model.dart         — CropModel (id, cropType, fieldName, dates, yield, etc.)
  providers/
    crop_providers.dart     — cropNotifierProvider (StateNotifier<AsyncValue<List<CropModel>>>)
  screens/
    crops_screen.dart       — full crop list + sticky "Add" button (Crops tab)
    add_edit_crop_screen.dart — 3-step stepper form, single-crop only
    crop_details_screen.dart  — view/edit/delete a single crop
  crop_helpers.dart         — shared pure functions (stage, progress, date, image URL)
```

- Add Crop form enforces **single-crop selection** (each crop type has a different harvest duration).
- Dashboard previews max 3 crops; "View All" switches to the Crops tab via `selectedTabProvider`.
