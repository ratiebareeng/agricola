import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authTokenProvider = FutureProvider.autoDispose<String?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    return null;
  }

  // Get fresh token from Firebase (auto-refreshes if expired)
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  final firebaseUser = firebaseAuth.currentUser;

  if (firebaseUser == null) {
    return null;
  }

  return await firebaseUser.getIdToken();
});

/// Helper extension for easy token access in services
extension ApiAuthExtension on Ref {
  Future<String?> getAuthToken() => read(authTokenProvider.future);
}
