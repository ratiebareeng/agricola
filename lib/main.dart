import 'dart:async';

import 'package:agricola/core/routing/app_router.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/core/database/app_database.dart';
import 'package:agricola/core/providers/database_provider.dart';
import 'package:agricola/features/profile/providers/profile_providers.dart';
import 'package:feedback/feedback.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

void main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);

    // Send all uncaught Flutter framework errors to Crashlytics.
    // NetworkImageLoadException (e.g. 404 from a stale image URL) is silently
    // handled at the widget level via DecorationImage.onError — treat it as
    // non-fatal so it doesn't flood the crash dashboard.
    FlutterError.onError = (errorDetails) {
      if (errorDetails.exception is NetworkImageLoadException) {
        FirebaseCrashlytics.instance.recordFlutterError(errorDetails, fatal: false);
        return;
      }
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Send all uncaught platform dispatcher errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    final sharedPreferences = await SharedPreferences.getInstance();
    final database = AppDatabase();

    // Evict stale cache on startup
    database.evictOldCache();

    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          databaseProvider.overrideWithValue(database),
        ],
        child: const BetterFeedback(child: AgricolaApp()),
      ),
    );
  }, (error, stack) {
    // Catch async errors outside Flutter framework
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}

class AgricolaApp extends ConsumerWidget {
  const AgricolaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = createRouter(ref);

    return MaterialApp.router(
      title: 'Agricola',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
