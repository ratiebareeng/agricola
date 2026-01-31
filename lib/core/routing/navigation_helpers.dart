import 'package:agricola/domain/auth/models/user_model.dart';

/// Helper class for determining navigation destinations after authentication
class NavigationHelpers {
  /// Determine where to navigate after successful authentication
  ///
  /// Logic:
  /// - If user is null or anonymous → /home (anonymous home screen)
  /// - If profile incomplete → /profile-setup
  /// - If profile complete → /home (routes to user-type dashboard)
  static String getPostAuthDestination(UserModel? user) {
    // Anonymous users go to home (shows anonymous UI)
    if (user == null || user.isAnonymous) {
      return '/home';
    }

    // Profile incomplete → profile setup
    if (!user.isProfileComplete) {
      return '/profile-setup';
    }

    // Profile complete → home (HomeScreen routes to correct dashboard)
    return '/home';
  }
}
