import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shared bottom-nav tab index.  Write to this from any child screen
/// to programmatically switch tabs (e.g. "View All" → Crops tab).
final selectedTabProvider = StateProvider<int>((ref) => 0);
