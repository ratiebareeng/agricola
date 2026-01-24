import 'package:agricola/features/auth/providers/auth_controller.dart';
import 'package:agricola/features/profile/domain/models/profile_response.dart';
import 'package:agricola/features/profile/providers/profile_providers.dart';
import 'package:agricola/features/profile/providers/profile_state_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current profile (convenience provider)
final currentProfileProvider = Provider<ProfileResponse?>((ref) {
  return ref.watch(profileControllerProvider).profile;
});

/// Profile loading state
final isProfileLoadingProvider = Provider<bool>((ref) {
  return ref.watch(profileControllerProvider).isLoading;
});

/// Profile controller provider
final profileControllerProvider =
    StateNotifierProvider<ProfileStateNotifier, ProfileState>((ref) {
      return ProfileStateNotifier(
        repository: ref.watch(profileRepositoryProvider),
        authController: ref.watch(authControllerProvider.notifier),
        ref: ref,
      );
    });

/// Profile error message
final profileErrorProvider = Provider<String?>((ref) {
  return ref.watch(profileControllerProvider).errorMessage;
});
