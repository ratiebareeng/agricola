import 'dart:async';

import 'package:agricola/core/constants/api_constants.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final connectivityProvider =
    StateNotifierProvider<ConnectivityNotifier, ConnectivityStatus>((ref) {
      return ConnectivityNotifier();
    });

final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider) == ConnectivityStatus.online;
});

class ConnectivityNotifier extends StateNotifier<ConnectivityStatus> {
  static const _checkDebounce = Duration(seconds: 30);
  final Connectivity _connectivity = Connectivity();
  final Dio _pingDio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  DateTime? _lastCheck;

  ConnectivityNotifier() : super(ConnectivityStatus.checking) {
    _init();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _pingDio.close();
    super.dispose();
  }

  /// Force a reachability check (e.g. after user taps "retry").
  Future<void> recheckNow() async {
    _lastCheck = null;
    await _checkReachability();
  }

  Future<void> _checkReachability() async {
    final now = DateTime.now();
    if (_lastCheck != null && now.difference(_lastCheck!) < _checkDebounce) {
      return;
    }
    _lastCheck = now;

    state = ConnectivityStatus.checking;
    try {
      await _pingDio.head('${ApiConstants.baseUrl}/health');
      if (mounted) state = ConnectivityStatus.online;
    } catch (_) {
      if (mounted) state = ConnectivityStatus.offline;
    }
  }

  Future<void> _init() async {
    await _checkReachability();
    _subscription = _connectivity.onConnectivityChanged.listen(_onChanged);
  }

  void _onChanged(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      state = ConnectivityStatus.offline;
      return;
    }
    _checkReachability();
  }
}

enum ConnectivityStatus { online, offline, checking }
