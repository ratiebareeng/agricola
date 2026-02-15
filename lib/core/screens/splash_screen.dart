import 'dart:async';

import 'package:agricola/core/providers/app_initialization_provider.dart';
import 'package:agricola/core/providers/server_status_provider.dart';
import 'package:agricola/core/services/server_wake_service.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/features/auth/providers/auth_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Minimum duration the splash screen should be shown (in milliseconds)
/// This ensures a smooth UX and allows backend to warm up
const int _minSplashDuration = 2000;

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _minDurationElapsed = false;
  bool _navigationTriggered = false;
  bool _serverWakeStarted = false;
  String _statusMessage = 'Initializing...';

  @override
  Widget build(BuildContext context) {
    // Watch server status (value used to trigger rebuilds)
    ref.watch(serverWakeStatusProvider);

    // Watch for state changes and check if we should navigate
    ref.listen(appInitializationProvider, (_, __) {
      _checkAndNavigate();
    });
    ref.listen(unifiedAuthStateProvider, (_, __) {
      _checkAndNavigate();
    });
    ref.listen(serverWakeStatusProvider, (_, state) {
      if (mounted) {
        setState(() {
          _statusMessage = state.message;
        });
        if (state.status == ServerWakeStatus.ready ||
            state.status == ServerWakeStatus.failed) {
          _checkAndNavigate();
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          // Background Decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: AppColors.green.withAlpha(25),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.earthBrown.withAlpha(25),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.green.withAlpha(105),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.agriculture_rounded,
                    size: 80,
                    color: AppColors.green,
                  ),
                ),
                const SizedBox(height: 32),

                // App Title
                Text(
                  'Agricola',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.green,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Empowering Farmers',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.earthBrown,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 48),

                // Loading Indicator
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.green),
                ),
                const SizedBox(height: 16),

                // Status Message
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    _statusMessage,
                    key: ValueKey(_statusMessage),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.earthBrown.withAlpha(180),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    // Start server wake-up process
    _startServerWake();

    // Start minimum duration timer
    Timer(const Duration(milliseconds: _minSplashDuration), () {
      if (mounted) {
        setState(() {
          _minDurationElapsed = true;
        });
        _checkAndNavigate();
      }
    });
  }

  /// Start the server wake-up process in background
  void _startServerWake() {
    if (_serverWakeStarted) return;
    _serverWakeStarted = true;

    // Use post-frame callback to ensure ref is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(serverWakeStatusProvider.notifier).wakeServer();
      }
    });
  }

  void _checkAndNavigate() {
    if (_navigationTriggered) return;

    final initAsync = ref.read(appInitializationProvider);
    final authState = ref.read(unifiedAuthStateProvider);
    final serverState = ref.read(serverWakeStatusProvider);

    // Check if server wake has completed (successfully or failed)
    // We don't block on server wake - it's best effort
    final serverWakeComplete =
        serverState.status == ServerWakeStatus.ready ||
        serverState.status == ServerWakeStatus.failed;

    // Only navigate if min duration has elapsed and states are ready
    // Server wake is non-blocking - we continue even if it fails
    if (_minDurationElapsed &&
        initAsync is AsyncData<AppInitializationState> &&
        !authState.isLoading &&
        serverWakeComplete) {
      _navigationTriggered = true;

      // Trigger router re-evaluation by forcing a refresh
      // The route guards will handle the actual navigation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          // Navigate to sign-in as a trigger for route guards to re-evaluate
          // Route guards will redirect to the appropriate screen
          context.go('/sign-in');
        }
      });
    }
  }
}
