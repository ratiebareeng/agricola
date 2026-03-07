import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _offlineEnabledKey = 'offline_mode_enabled';

final offlineModeEnabledProvider =
    StateNotifierProvider<OfflineModeNotifier, bool>((ref) {
  return OfflineModeNotifier();
});

class OfflineModeNotifier extends StateNotifier<bool> {
  OfflineModeNotifier() : super(false) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_offlineEnabledKey) ?? false;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineEnabledKey, state);
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineEnabledKey, enabled);
  }
}
