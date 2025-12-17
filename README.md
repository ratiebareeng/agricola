# Agricola - Farm Management App

A modern farm management application built with Flutter, designed specifically for farmers and agricultural merchants in Botswana.

## 🌾 Features Implemented

### DONE: 1. Onboarding & Welcome
- Multi-language support (English & Setswana)
- Beautiful onboarding screens with local context
- Smooth animations and transitions

### DONE: 2. User Registration & Authentication
- Email/password authentication
- Social login options (Google, Facebook)
- User type selection (Farmer/AgriMerchant)
- Clean, modern UI

### DONE: 3. Farmer Dashboard
- Quick stats overview (fields, harvests, inventory, losses)
- Recent activity feed
- Crop management quick access
- Bilingual interface

### DONE: 4. Crop Management
- Add/Edit crops with detailed information
- Track planting to harvest cycle
- Record harvests with quality ratings
- Visual crop cards with status indicators

### DONE: 5. Profile Setup Wizard
Complete multi-step wizard for farmer profile completion:

#### Step 1: Location Selection
- Dropdown with 20+ Botswana villages/towns
- Custom location input for "Other"
- Smart validation

#### Step 2: Primary Crops
- Multi-select from categorized crops
- 4 categories: Grains, Legumes, Vegetables, Fruits
- Visual selection feedback

#### Step 3: Farm Size
- 4 size categories (< 1 Ha to 10+ Ha)
- Card-based selection UI
- Required field validation

#### Step 4: Profile Photo
- Image picker from gallery
- Circular avatar preview
- Optional step
- Optimized uploads (1024x1024, 85% quality)

### DONE: 6. Profile Management ⭐ NEW
Beautiful profile screens for both farmers and merchants:

#### Farmer Profile
- Expandable header with gradient background
- Profile photo upload with camera overlay
- Profile information (email, phone, location)
- Farm details (size, primary crops)
- Quick actions (reports, history, export)
- Settings menu with language toggle
- Logout functionality

#### Merchant Profile
- Business-focused header with logo
- Business statistics dashboard (4 key metrics)
- Business details (name, products, location)
- Supplier management quick access
- Purchase history overview
- Same settings and quick actions
- Professional merchant-specific UI

## 📱 Tech Stack

- **Framework**: Flutter 3.x
- **Language**: Dart 3.x
- **State Management**: Riverpod
- **Routing**: GoRouter
- **Storage**: SharedPreferences
- **Image Handling**: image_picker

## 🗂️ Project Structure

```
lib/
├── core/
│   ├── providers/          # Global providers (language, theme)
│   ├── theme/             # App theme & colors
│   └── widgets/           # Reusable widgets
├── features/
│   ├── auth/              # Authentication
│   ├── onboarding/        # Welcome & onboarding
│   ├── home/              # Dashboard & home screens
│   ├── crops/             # Crop management
│   ├── inventory/         # Inventory tracking
│   ├── profile_setup/     # Profile setup wizard
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   └── widgets/
│   └── profile/           # Profile management ⭐ NEW
│       └── screens/
│           ├── profile_screen.dart
│           ├── farmer_profile_screen.dart
│           └── merchant_profile_screen.dart
└── main.dart
```

## 📚 Documentation

Comprehensive documentation available in `/docs`:

- [`profile_setup_wizard.md`](docs/profile_setup_wizard.md) - Feature overview
- [`profile_setup_examples.md`](docs/profile_setup_examples.md) - Code examples
- [`profile_setup_visual_guide.md`](docs/profile_setup_visual_guide.md) - UI mockups
- [`PROFILE_SETUP_SUMMARY.md`](docs/PROFILE_SETUP_SUMMARY.md) - Implementation summary

## 🚀 Getting Started

### Prerequisites

```bash
flutter --version  # Flutter 3.x or higher
dart --version     # Dart 3.x or higher
```

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/agricola.git
cd agricola
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## 🌍 Localization

Full support for:
- **English** - Primary language
- **Setswana** - Local language

All UI elements, crop names, and messages are fully translated.

## 🎨 Design System

- **Primary Color**: Green (#4CAF50)
- **Background**: White
- **Cards**: Rounded corners (12-16px)
- **Typography**: Google Fonts
- **Icons**: Material Icons

## 📝 Key Features in Detail

### Profile Setup Wizard
The crown jewel of the onboarding experience:

```dart
// Navigate to profile setup
context.go('/profile-setup?type=farmer');

// Access profile data
final profile = ref.watch(profileSetupProvider);
```

Features:
- Step-by-step guided flow
- Progress indicator
- Field validation
- Skip option
- Back navigation
- Bilingual support

### Crop Management
Track your crops from planting to harvest:

```dart
CropModel(
  cropType: 'Maize',
  fieldName: 'North Field',
  fieldSize: 5.0,
  plantingDate: DateTime.now(),
  expectedHarvestDate: DateTime.now().add(Duration(days: 90)),
)
```

### Inventory Tracking
Monitor harvested produce with quality ratings and storage methods.

## 🔄 User Flow

```
Welcome Screen
    ↓
Onboarding (3 screens)
    ↓
Registration (Farmer/Merchant)
    ↓
Sign Up
    ↓
Profile Setup Wizard (4 steps) ⭐
    ↓
Dashboard
    ↓
Crop Management / Inventory / Analytics
```

## 🛠️ Development

### Run tests
```bash
flutter test
```

### Build for production
```bash
# Android
flutter build apk --release

# iOS
flutter build ios --release
```

### Code generation (if using freezed/json_serializable)
```bash
flutter pub run build_runner build
```

## 📦 Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.6.1      # State management
  go_router: ^14.6.0            # Routing
  google_fonts: ^6.2.1          # Typography
  shared_preferences: ^2.3.3    # Local storage
  image_picker: ^1.0.7          # Photo selection
```

## 🎯 Roadmap

### Phase 1: MVP (Current) ✅
- [x] Onboarding
- [x] Authentication
- [x] Profile Setup Wizard
- [x] Farmer Dashboard
- [x] Crop Management
- [x] Basic Inventory

### Phase 2: Enhanced Features
- [ ] Firebase integration
- [ ] Real-time data sync
- [ ] Weather integration
- [ ] Market prices
- [ ] Community features

### Phase 3: Advanced Features
- [ ] GPS farm mapping
- [ ] AI crop recommendations
- [ ] Disease detection
- [ ] Marketplace integration
- [ ] Financial tracking

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👥 Team

Built with ❤️ for farmers in Botswana

## 📞 Support

For issues and questions, please open an issue on GitHub.

---

**Status**: 🟢 Active Development | MVP Complete | Production Ready
