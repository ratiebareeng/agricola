# Agricola Web Dashboard — Feature Tracker

> Last updated: 2026-03-22
> Dashboard repo: `agricola-dashboard` (Flutter Web)
> Shared package: `agricola-core` v1.0.0
> Backend: Pandamatenga (40+ API endpoints, production-ready)
> Deploy target: `dashboard.agricola-app.com`

## Status Legend

| Symbol | Meaning |
|--------|---------|
| [x] | Complete — fully functional |
| [~] | Partial — UI exists but incomplete or not connected to data |
| [ ] | Not started — no code exists |
| N/A | Not planned for MVP / descoped |

---

## Phase 0: Project Setup & Foundation

| # | Feature | Status | Notes |
|---|---------|--------|-------|
| 0.1 | Create `agricola-dashboard` Flutter project | [x] | `flutter create --platforms web agricola-dashboard` |
| 0.2 | Add `agricola_core` as path dependency | [x] | `path: ../agricola-core` |
| 0.3 | Firebase Web SDK setup | [x] | Firebase Auth for web (same Firebase project as mobile) |
| 0.4 | Web-specific `AuthTokenProvider` | [x] | Implements `agricola_core` `AuthTokenProvider` interface using Firebase Web SDK |
| 0.5 | Web `httpClientProvider` | [x] | Dio setup with auth interceptor, retry interceptor (from core), no Crashlytics |
| 0.6 | Environment config | [x] | Dev (localhost:8080) and prod (Render URL) — reuse `EnvironmentConfig` from core |
| 0.7 | Riverpod setup | [x] | `ProviderScope` in `main.dart` |
| 0.8 | CI/CD deployment | [x] | GitHub Actions → FTP deploy to Namecheap hosting |

**Phase 0 completion: 8/8 items done**

---

## Phase 1: Auth & Layout Shell

| # | Feature | Status | Notes |
|---|---------|--------|-------|
| 1.1 | Login screen | [x] | Email/password + Google Sign-In (Firebase Web) |
| 1.2 | Auth state management | [x] | `WebAuthRepository` + Riverpod `StreamProvider` wrapping Firebase `authStateChanges` |
| 1.3 | Route guards | [x] | GoRouter `redirect` — unauthenticated → `/login`, authenticated → `/dashboard` |
| 1.4 | Layout shell (sidebar + header) | [x] | `DashboardShell` with sidebar nav, header with breadcrumbs |
| 1.5 | Language toggle | [x] | Reusable `LanguageToggle` widget (compact + full), reuses `t()` from core |
| 1.6 | Role-based sidebar | [x] | Merchant sees orders/purchases, farmer sees crops/harvests |
| 1.7 | Logout | [x] | Signs out Firebase + Google, auth stream redirects to login |
| 1.8 | User profile display | [x] | `UserProfileTile` in sidebar footer — email, role badge, logout button |

**Phase 1 completion: 8/8 items done**

---

## Phase 2: Merchant Dashboard & Stats

| # | Feature | Status | Notes |
|---|---------|--------|-------|
| 2.1 | Dashboard home page | [x] | Responsive layout with header, stats grid, charts section. Role-based (merchant/farmer) |
| 2.2 | Analytics integration | [x] | `analyticsProvider` (FutureProvider) fetches from core's `AnalyticsApiService`, auto-refetches on period change |
| 2.3 | Stats cards | [x] | 12 role-based cards (6 merchant, 6 farmer) using reusable `StatCard` widget. Currency/weight/area formatters |
| 2.4 | Charts | [x] | `fl_chart` — merchant: revenue vs purchases bar + inventory donut. Farmer: crop status donut + yield vs loss bar |
| 2.5 | Recent activity feed | N/A | Descoped from Phase 2 — requires order/purchase data from Phases 5-6 |
| 2.6 | Period filter | [x] | Reusable `PeriodFilter` widget (SegmentedButton) — week/month/year/all_time, bilingual |

**Phase 2 completion: 5/5 items done (1 descoped)**

---

## Phase 3: Inventory Management (Merchant)

| # | Feature | Status | Notes |
|---|---------|--------|-------|
| 3.1 | Inventory list (data table) | [x] | Sortable, searchable DataTable. `InventoryController` (AsyncNotifier) |
| 3.2 | Inventory detail view | [x] | Inline detail in table rows |
| 3.3 | Add inventory item | [x] | Form dialog with validation — crop type, quantity, unit, storage, condition |
| 3.4 | Edit inventory item | [x] | Pre-filled form dialog, PUT via core service |
| 3.5 | Delete inventory item | [x] | Confirmation dialog, DELETE via core service |
| 3.6 | Condition badges | [x] | `ConditionBadge` widget using consolidated `BadgeColors` palette |
| 3.7 | Bulk actions | [ ] | Select multiple items, bulk delete/update condition — deferred |

**Phase 3 completion: 6/7 items done (1 deferred)**

---

## Phase 4: Marketplace Listings (Merchant)

| # | Feature | Status | Notes |
|---|---------|--------|-------|
| 4.1 | My listings table | [x] | Sortable, searchable DataTable filtered by `sellerId`. `MyListingsController` (AsyncNotifier) |
| 4.2 | Create listing | [x] | Form dialog: title, description, type, category, price, unit, quantity, location, crop status, harvest date |
| 4.3 | Edit listing | [x] | Pre-filled form dialog, update via PUT |
| 4.4 | Delete listing | [x] | Confirmation dialog, DELETE via core service |
| 4.5 | Link from inventory | [x] | "List on Marketplace" action on inventory rows, pre-fills form from `InventoryModel` |
| 4.6 | Listing status toggle | [ ] | Requires `isActive` field on `MarketplaceListing` in core — deferred |
| 4.7 | Image upload | [ ] | Requires `firebase_storage` + `ImageUploadService` — deferred |
| 4.8 | Browse all marketplace | [x] | Responsive grid with filter bar (search, type dropdown), `BrowseListingsController` |

**Phase 4 completion: 6/8 items done (2 deferred)**

---

## Phase 5: Orders (AgriShop)

| # | Feature | Status | Notes |
|---|---------|--------|-------|
| 5.1 | Orders table (seller view) | [x] | `GET /api/v1/orders?role=seller`. `OrdersController` (AsyncNotifier), sortable DataTable |
| 5.2 | Order detail view | [x] | Dialog with items table, buyer info, total, timestamps. `OrderStatusBadge` using `BadgeColors` |
| 5.3 | Status progression | [x] | pending → confirmed → shipped → delivered (or cancelled). Quick-action buttons + detail dialog actions |
| 5.4 | Order status filters | [x] | Status dropdown filter + search by ID/status/buyer/item title. Sort by date/status/amount |
| 5.5 | Order notifications | [ ] | New order alerts (polling or WebSocket — future) |

**Phase 5 completion: 4/5 items done (1 deferred)**

---

## Phase 6: Purchases (Merchant)

| # | Feature | Status | Notes |
|---|---------|--------|-------|
| 6.1 | Purchases table | [x] | `GET /api/v1/purchases`. `PurchasesController` (AsyncNotifier), sortable DataTable |
| 6.2 | Add purchase record | [x] | Form dialog: seller, crop type, quantity, unit, price per unit, auto-total, date, notes |
| 6.3 | Edit purchase | [x] | Pre-filled form dialog, PUT via core service |
| 6.4 | Delete purchase | [x] | Confirmation dialog, DELETE via core service |
| 6.5 | Purchase summary stats | [x] | 4 `StatCard` widgets: total spend, average purchase, top supplier, purchase frequency |

**Phase 6 completion: 5/5 items done**

---

## Phase 7: Profile & Settings

| # | Feature | Status | Notes |
|---|---------|--------|-------|
| 7.1 | Profile page | [x] | View + edit (farmer & merchant). Create flow for incomplete profiles. `ProfileController` (AsyncNotifier), `ProfileInfoCard` + `ProfileChipsCard` widgets |
| 7.2 | Profile photo upload | [ ] | Deferred — needs backend multipart support |
| 7.3 | Change password | [x] | Firebase password reset email (uses existing `sendPasswordResetEmail`) |
| 7.4 | Language setting | [x] | localStorage persistence via `package:web`. `LanguageNotifier` (StateNotifier), survives page refresh |
| 7.5 | Account deletion | [x] | Two-step confirmation (type email to confirm), deletes backend profile + Firebase account |

**Phase 7 completion: 4/5 items done (1 deferred)**

---

## Phase 8: Farmer Dashboard (Lower Priority)

Farmers primarily use the mobile app. Web dashboard is a secondary access point.

| # | Feature | Status | Notes |
|---|---------|--------|-------|
| 8.1 | Farmer dashboard stats | [x] | Already role-aware from Phase 2 — 6 farmer stat cards + crop overview pie + yield vs loss bar chart |
| 8.2 | Crops table | [x] | Sortable DataTable with CRUD, catalog-aware dropdown, `CropStageBadge` + progress bar. `CropController` (AsyncNotifier) |
| 8.3 | Crop detail view | [x] | Inline in table rows + navigate to harvests via `?cropId=` query param |
| 8.4 | Harvests table | [x] | Crop selector dropdown, crop summary card, add/delete (no edit — API limitation). `QualityBadge`, `HarvestController` |
| 8.5 | Farmer inventory | [x] | Shared with merchant (Phase 3) — sidebar already shows inventory for both roles, API scopes to user |
| 8.6 | Loss calculator | [x] | `LossCalcController` (AsyncNotifier), sortable DataTable, form dialog with dynamic loss stages, detail dialog with regional comparison + prevention tips. `LossSeverityBadge` using `BadgeColors` |
| 8.7 | Data export (CSV/PDF) | [ ] | Moved to Phase 9 — fits naturally with Reports & Export |

**Phase 8 completion: 6/7 items done (1 moved to Phase 9)**

---

## Phase 9: Reports & Data Export

| # | Feature | Status | Notes |
|---|---------|--------|-------|
| 9.1 | Reports page | [x] | Analytics dashboard with stats grid, charts (fl_chart), and role-based data tables |
| 9.2 | Date range picker | [x] | Custom period via PeriodFilter "Custom" segment → `showDateRangePicker()`, client-side table filtering |
| 9.3 | CSV export | [x] | Web-native blob download — crops, harvests, inventory, purchases, orders with bilingual headers |
| 9.4 | PDF export | [x] | Farm summary (farmer) / business summary (merchant) — `pdf` package, blob download |
| 9.5 | Print view | [x] | `window.print()` via `web` package |

**Phase 9 completion: 5/5 items done**

---

## Cross-Cutting Concerns

| Feature | Status | Notes |
|---------|--------|-------|
| Bilingual UI (EN/SW) | [x] | `LanguageToggle` widget + `t(key, lang)` from core. Added missing dashboard keys. |
| Firebase Auth (Web SDK) | [x] | `WebAuthRepository` + `WebAuthTokenProvider`. Same Firebase project as mobile. |
| Responsive design | [ ] | Desktop-first, tablet-friendly |
| Data tables | [x] | Sortable, searchable, paginated DataTables for inventory, marketplace, orders, purchases, crops, harvests, loss calculator. Shared `TablePaginationBar` widget with rows-per-page (10/25/50), prev/next navigation, bilingual labels. |
| Loading states | [x] | `AppPrimaryButton`/`AppSecondaryButton` have built-in loading spinners. Shimmer skeleton loaders for all card types (stat, crop, inventory, marketplace, order, harvest) across 9 screens. |
| Error handling | [~] | `LoginController` surfaces errors via `AsyncValue`. Snackbar in login. Global error boundary not yet. |
| Form validation | [~] | `AppTextField` supports validators. `ValidationRules` from core not yet wired. |
| Breadcrumbs | [x] | `DashboardHeader` builds breadcrumbs from GoRouter path segments |
| Dark mode | N/A | Post-MVP |

---

## Backend API Coverage

All endpoints are production-ready in Pandamatenga. No backend work needed for MVP.

| Endpoint | Web Dashboard Usage |
|----------|-------------------|
| `GET /api/v1/analytics` | Dashboard stats (Phase 2) |
| `GET/POST/PUT/DELETE /api/v1/inventory` | Inventory CRUD (Phase 3) |
| `GET/POST/PUT/DELETE /api/v1/marketplace` | Marketplace CRUD (Phase 4) |
| `GET/PUT /api/v1/orders` | Order management (Phase 5) |
| `GET/POST/PUT/DELETE /api/v1/purchases` | Purchase records (Phase 6) |
| `GET/PUT /api/v1/profiles` | Profile management (Phase 7) |
| `GET/POST/PUT/DELETE /api/v1/crops` | Farmer crops (Phase 8) — DONE |
| `GET/POST/DELETE /api/v1/harvests` | Farmer harvests (Phase 8) — DONE |
| `GET /api/v1/crop-catalog` | Crop catalog (Phase 8, crop form dropdown) — DONE |
| `POST /api/v1/loss-calculator` | Loss calculations (Phase 8) |
| `POST /api/v1/feedback` | User feedback |

---

## Shared Code from `agricola_core`

The dashboard reuses these from the shared package (no duplication needed):

| Layer | Files | Used In |
|-------|-------|---------|
| Models | 16 (CropModel, InventoryModel, OrderModel, etc.) | All phases |
| API Services | 11 (Dio-based HTTP clients) | All phases |
| Constants | ApiConstants, AppConstants, ValidationRules | All phases |
| Network | BaseApiService, AuthInterceptor, RetryInterceptor | Phase 0 |
| Enums | UserType, MerchantType, AppLanguage | All phases |
| i18n | Translations map + `t()` function | All phases |
| Helpers | cropHelpers, lossCalculatorHelpers, profileValidators | Phases 7-8 |

---

## Summary

| Phase | Done | Total | % |
|-------|------|-------|---|
| Phase 0: Setup & Foundation | 8 | 8 | 100% |
| Phase 1: Auth & Layout Shell | 8 | 8 | 100% |
| Phase 2: Dashboard & Stats | 5 | 5 | 100% |
| Phase 3: Inventory | 6 | 7 | 86% |
| Phase 4: Marketplace | 6 | 8 | 75% |
| Phase 5: Orders | 4 | 5 | 80% |
| Phase 6: Purchases | 5 | 5 | 100% |
| Phase 7: Profile & Settings | 4 | 5 | 80% |
| Phase 8: Farmer Dashboard | 6 | 7 | 86% |
| Phase 9: Reports & Export | 5 | 5 | 100% |
| Cross-Cutting | 5 | 9 | 56% |
| **Overall** | **69** | **72** | **96%** |

---

## Priority Recommendations

### High Priority (get merchants onboarded first)
1. **Phase 0** — Project setup, auth, deployment pipeline
2. **Phase 1** — Auth + layout shell (everything depends on this)
3. **Phase 2** — Dashboard stats (first thing users see)
4. **Phase 3** — Inventory management (core merchant workflow)

### Medium Priority (complete merchant experience)
5. **Phase 4** — Marketplace listings
6. **Phase 5** — Orders (AgriShop users)
7. **Phase 6** — Purchase records

### Lower Priority (polish + farmer access)
8. **Phase 7** — Profile & settings
9. **Phase 9** — Reports & export
10. **Phase 8** — Farmer dashboard (mobile is primary)
