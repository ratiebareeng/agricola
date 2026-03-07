import 'package:agricola/features/auth/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared bottom-nav tab index.  Write to this from any child screen
/// to programmatically switch tabs (e.g. "View All" → Crops tab).
final selectedTabProvider = StateProvider<int>((ref) {
  // Watch current user to reset tab to 0 (dashboard) when user changes
  ref.watch(currentUserProvider);
  return 0;
});
