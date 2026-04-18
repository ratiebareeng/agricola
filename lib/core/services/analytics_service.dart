import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics;

  AnalyticsService(this._analytics);

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // --- User properties ---

  Future<void> setUserId(String? uid) =>
      _analytics.setUserId(id: uid);

  Future<void> setUserType(String userType) =>
      _analytics.setUserProperty(name: 'user_type', value: userType);

  Future<void> setLanguage(String language) =>
      _analytics.setUserProperty(name: 'app_language', value: language);

  // --- Onboarding funnel ---

  Future<void> logOnboardingStart() =>
      _analytics.logEvent(name: 'onboarding_start');

  Future<void> logOnboardingComplete() =>
      _analytics.logEvent(name: 'onboarding_complete');

  Future<void> logUserTypeSelected({required String userType}) =>
      _analytics.logEvent(
        name: 'user_type_selected',
        parameters: {'user_type': userType},
      );

  Future<void> logSignupComplete({required String method}) =>
      _analytics.logEvent(
        name: 'signup_complete',
        parameters: {'method': method},
      );

  Future<void> logSigninComplete({required String method}) =>
      _analytics.logEvent(
        name: 'signin_complete',
        parameters: {'method': method},
      );

  Future<void> logProfileSetupStarted({required String userType}) =>
      _analytics.logEvent(
        name: 'profile_setup_started',
        parameters: {'user_type': userType},
      );

  Future<void> logProfileSetupComplete({required String userType}) =>
      _analytics.logEvent(
        name: 'profile_setup_complete',
        parameters: {'user_type': userType},
      );

  Future<void> logProfileSetupSkipped() =>
      _analytics.logEvent(name: 'profile_setup_skipped');

  // --- Feature adoption ---

  Future<void> logCropAdded({required String cropType}) =>
      _analytics.logEvent(
        name: 'crop_added',
        parameters: {'crop_type': cropType},
      );

  Future<void> logHarvestRecorded() =>
      _analytics.logEvent(name: 'harvest_recorded');

  Future<void> logInventoryAdded({required String itemName}) =>
      _analytics.logEvent(
        name: 'inventory_added',
        parameters: {'item_name': itemName},
      );

  Future<void> logListingCreated() =>
      _analytics.logEvent(name: 'listing_created');

  Future<void> logPurchaseRecorded() =>
      _analytics.logEvent(name: 'purchase_recorded');

  Future<void> logOrderCreated() =>
      _analytics.logEvent(name: 'order_created');

  Future<void> logOrderStatusUpdated({required String status}) =>
      _analytics.logEvent(
        name: 'order_status_updated',
        parameters: {'new_status': status},
      );

  Future<void> logLossCalculated() =>
      _analytics.logEvent(name: 'loss_calculated');

  Future<void> logReportExported({required String format}) =>
      _analytics.logEvent(
        name: 'report_exported',
        parameters: {'format': format},
      );

  // --- Navigation ---

  Future<void> logTabSwitch({required String tabName}) =>
      _analytics.logEvent(
        name: 'tab_switch',
        parameters: {'tab_name': tabName},
      );
}
