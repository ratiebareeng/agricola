import 'package:agricola/core/services/server_wake_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider to force server wake-up (bypasses cache)
final forceServerWakeProvider = FutureProvider.autoDispose<bool>((ref) async {
  return ServerWakeService.forceWake();
});

/// Provider to check if server is currently reachable
final isServerAwakeProvider = FutureProvider.autoDispose<bool>((ref) async {
  return ServerWakeService.isServerAwake();
});

/// Provider for server wake status during app startup.
/// Used by the splash screen to proactively warm up the backend.
final serverStatusProvider = FutureProvider.autoDispose<bool>((ref) async {
  return ServerWakeService.ensureServerAwake();
});

/// Provider for tracking detailed server status during startup
final serverWakeStatusProvider =
    StateNotifierProvider<ServerWakeStatusNotifier, ServerWakeState>((ref) {
      return ServerWakeStatusNotifier();
    });

/// State for server wake-up process
class ServerWakeState {
  final ServerWakeStatus status;
  final String message;
  final int attemptCount;
  final int maxAttempts;

  const ServerWakeState({
    this.status = ServerWakeStatus.checking,
    this.message = 'Checking server status...',
    this.attemptCount = 0,
    this.maxAttempts = 3,
  });

  ServerWakeState copyWith({
    ServerWakeStatus? status,
    String? message,
    int? attemptCount,
    int? maxAttempts,
  }) {
    return ServerWakeState(
      status: status ?? this.status,
      message: message ?? this.message,
      attemptCount: attemptCount ?? this.attemptCount,
      maxAttempts: maxAttempts ?? this.maxAttempts,
    );
  }
}

/// Notifier for managing server wake-up status
class ServerWakeStatusNotifier extends StateNotifier<ServerWakeState> {
  ServerWakeStatusNotifier() : super(const ServerWakeState());

  /// Increment attempt count
  void incrementAttempt() {
    state = state.copyWith(
      attemptCount: state.attemptCount + 1,
      message: 'Retrying... (${state.attemptCount + 1}/${state.maxAttempts})',
    );
  }

  /// Reset to initial state
  void reset() {
    state = const ServerWakeState();
  }

  /// Update status manually (for fine-grained control)
  void updateStatus(ServerWakeStatus status, String message) {
    state = state.copyWith(status: status, message: message);
  }

  /// Start the server wake-up process
  Future<bool> wakeServer() async {
    state = state.copyWith(
      status: ServerWakeStatus.checking,
      message: 'Connecting to server...',
      attemptCount: 0,
    );

    // Check if server is already awake
    final isAwake = await ServerWakeService.isServerAwake();
    if (isAwake) {
      state = state.copyWith(
        status: ServerWakeStatus.ready,
        message: 'Connected!',
      );
      return true;
    }

    // Server needs wake-up
    state = state.copyWith(
      status: ServerWakeStatus.waking,
      message: 'Server is starting up...',
    );

    final success = await ServerWakeService.ensureServerAwake();

    if (success) {
      state = state.copyWith(
        status: ServerWakeStatus.ready,
        message: 'Server is ready!',
      );
    } else {
      state = state.copyWith(
        status: ServerWakeStatus.failed,
        message: 'Could not connect to server',
      );
    }

    return success;
  }
}
