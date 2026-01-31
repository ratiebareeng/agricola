# Environment Configuration Guide

This guide explains how to use and switch between different environments (development, production) in the Agricola Flutter app.

## Overview

The app supports two environments:

| Environment | Backend URL | Purpose |
|-------------|-------------|---------|
| **Development** | `http://localhost:8080` (or Android: `http://10.0.2.2:8080`) | Local development with backend running on your machine |
| **Production** | `https://pandamatenga-api.onrender.com` | Production backend deployed on Render |

## Quick Start

### Method 1: Change Environment Constant (Recommended)

1. Open [`lib/core/config/environment.dart`](lib/core/config/environment.dart)
2. Find this line (around line 13):
   ```dart
   static const AppEnvironment currentEnvironment = AppEnvironment.development;
   ```
3. Change it to your desired environment:
   ```dart
   // For local development
   static const AppEnvironment currentEnvironment = AppEnvironment.development;

   // For production testing
   static const AppEnvironment currentEnvironment = AppEnvironment.production;
   ```
4. **Hot restart** the app (stop and run again)

### Method 2: Use Command Line Flag

Run the app with an environment variable:

```bash
# Development
flutter run --dart-define=ENVIRONMENT=development

# Production
flutter run --dart-define=ENVIRONMENT=production
```

This overrides the constant in `environment.dart` without modifying code.

## Environment Details

### Development Environment

**When to use:** Local development and testing

**Features:**
- Connects to local backend at `http://localhost:8080`
- Android emulator automatically uses `http://10.0.2.2:8080`
- Verbose logging enabled
- Shows "DEV" banner (if using `EnvironmentBanner`)
- 30 second API timeout

**Testing on Physical Device:**

If testing on a physical device, set your machine's local IP:

1. Find your IP address:
   ```bash
   # macOS/Linux
   ifconfig | grep "inet " | grep -v 127.0.0.1

   # Windows
   ipconfig
   ```

2. Update `environment.dart`:
   ```dart
   class _DevelopmentConfig {
     static const String? localIpOverride = '192.168.1.100'; // Your IP here
     // ...
   }
   ```

3. Ensure your backend is running and accessible on your network

### Production Environment

**When to use:** Testing against the live backend

**Features:**
- Connects to Render backend at `https://pandamatenga-api.onrender.com`
- Logging disabled (less verbose)
- No environment banner
- 45 second API timeout (to handle Render cold starts)

**Note:** Production backend may take 30-60 seconds to respond on first request if it's been idle (Render free tier spins down).

## Using Environment Info in Your App

### Add Environment Banner

Show a "DEV" banner in development mode:

```dart
// In main.dart
import 'package:agricola/core/widgets/environment_banner.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => EnvironmentBanner(child: child!),
      // ... rest of your app
    );
  }
}
```

### Add Environment Info Card

Display environment details in settings or profile screen:

```dart
import 'package:agricola/core/widgets/environment_banner.dart';

// In your settings screen
EnvironmentInfoCard()
```

Shows:
- Current environment
- API base URL
- Timeout configuration
- Logging status

### Add Environment Switcher Button (Debug Only)

For quick environment info during development:

```dart
// Temporarily add to a screen for testing
EnvironmentSwitcherButton()
```

## File Structure

```
lib/core/
├── config/
│   └── environment.dart          # Environment configuration
├── constants/
│   └── api_constants.dart        # API endpoints (uses environment config)
└── widgets/
    └── environment_banner.dart   # UI components for environment info
```

## API Configuration

The environment system automatically configures:

- **Base URL:** `ApiConstants.baseUrl`
- **Timeout:** `ApiConstants.requestTimeout`
- **Logging:** `EnvironmentConfig.enableLogging`

All API calls using `ApiConstants.baseUrl` will automatically use the correct backend URL.

## Common Tasks

### Switch to Production for Testing

```bash
# Option 1: Edit environment.dart
# Change: currentEnvironment = AppEnvironment.production

# Option 2: Command line
flutter run --dart-define=ENVIRONMENT=production
```

### Switch Back to Development

```bash
# Option 1: Edit environment.dart
# Change: currentEnvironment = AppEnvironment.development

# Option 2: Command line
flutter run --dart-define=ENVIRONMENT=development
```

### Check Current Environment

Add this temporarily to any screen:

```dart
print('Environment: ${EnvironmentConfig.environmentName}');
print('API URL: ${ApiConstants.baseUrl}');
```

Or use the `EnvironmentInfoCard()` widget.

### Test Health Check

```dart
import 'package:http/http.dart' as http;
import 'package:agricola/core/constants/api_constants.dart';

// Test if backend is reachable
final response = await http.get(Uri.parse(ApiConstants.healthUrl));
print('Health check: ${response.statusCode}');
print('Response: ${response.body}');
```

## Troubleshooting

### "Connection refused" on Android Emulator

**Problem:** Android emulator can't reach `localhost`

**Solution:** The app automatically uses `10.0.2.2` for Android emulators, which maps to your host machine's `localhost`. Make sure your backend is running on port 8080.

### "Connection refused" on Physical Device

**Problem:** Physical device can't reach `localhost`

**Solution:** Set `localIpOverride` in `environment.dart` to your computer's IP address on the local network.

### Production backend times out

**Problem:** First request to production takes 60+ seconds

**Solution:** This is normal for Render free tier. The backend "spins down" after 15 minutes of inactivity. Subsequent requests will be fast. Consider:
- Increasing `apiTimeout` for production
- Adding a loading indicator for first request
- Upgrading to Render paid tier (no spin-down)

### Environment doesn't change

**Problem:** Changed `currentEnvironment` but still using old environment

**Solution:** You must **hot restart** (stop and run again), not just hot reload. Environment is set at app initialization.

### How to verify which environment is active

```dart
// Add this to your app's initialization
print('🌍 Environment: ${EnvironmentConfig.environmentName}');
print('🔗 API URL: ${ApiConstants.baseUrl}');
```

Or add the `EnvironmentBanner` widget which shows "DEV" in development mode.

## Best Practices

1. **Keep development as default** in `environment.dart` - prevents accidentally committing production config
2. **Use command line flags** for production testing - no code changes needed
3. **Add environment banner** in development - visual confirmation of environment
4. **Never commit production as default** - other developers expect development mode
5. **Document any new environment configs** in this file

## Adding New Environments (Future)

To add a new environment (e.g., staging):

1. Add to enum in `environment.dart`:
   ```dart
   enum AppEnvironment {
     development,
     staging,    // New
     production,
   }
   ```

2. Create config class:
   ```dart
   class _StagingConfig {
     final String apiBaseUrl = 'https://staging-api.example.com';
     final Duration apiTimeout = const Duration(seconds: 30);
     final bool enableLogging = true;
   }
   ```

3. Update switch statements in `EnvironmentConfig`

4. Update this README

## Related Files

- **Environment Config:** [`lib/core/config/environment.dart`](lib/core/config/environment.dart)
- **API Constants:** [`lib/core/constants/api_constants.dart`](lib/core/constants/api_constants.dart)
- **Environment Widgets:** [`lib/core/widgets/environment_banner.dart`](lib/core/widgets/environment_banner.dart)
- **Backend README:** [`../pandamatenga/DEPLOYMENT.md`](../pandamatenga/DEPLOYMENT.md)

## Support

For backend deployment issues, see [`pandamatenga/DEPLOYMENT.md`](../pandamatenga/DEPLOYMENT.md)

For environment configuration questions, check this guide or ask the team.

---

**Current Backend Status:**
- Development: `http://localhost:8080` (run locally)
- Production: `https://pandamatenga-api.onrender.com` ✅ Live
