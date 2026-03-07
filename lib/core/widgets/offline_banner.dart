import 'package:agricola/core/database/sync/sync_service.dart';
import 'package:agricola/core/providers/connectivity_provider.dart';
import 'package:agricola/core/providers/database_provider.dart';
import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/providers/offline_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineEnabled = ref.watch(offlineModeEnabledProvider);
    if (!offlineEnabled) return const SizedBox.shrink();

    final connectivity = ref.watch(connectivityProvider);
    final isSyncing = ref.watch(isSyncingProvider);
    final lang = ref.watch(languageProvider);
    final pendingCount = ref.watch(pendingSyncCountProvider);

    // Online + syncing in progress — show amber sync banner
    if (connectivity == ConnectivityStatus.online && isSyncing) {
      return Material(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.amber.shade700,
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  t('syncing', lang),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Online and not syncing — hide
    if (connectivity == ConnectivityStatus.online) {
      return const SizedBox.shrink();
    }

    final pendingText = pendingCount.whenOrNull(
          data: (count) => count > 0
              ? ' (${t('pendingChanges', lang)}: $count)'
              : '',
        ) ??
        '';

    return Material(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: connectivity == ConnectivityStatus.checking
            ? Colors.orange.shade700
            : Colors.red.shade700,
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              Icon(
                connectivity == ConnectivityStatus.checking
                    ? Icons.sync
                    : Icons.cloud_off,
                color: Colors.white,
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  connectivity == ConnectivityStatus.checking
                      ? t('checkingConnection', lang)
                      : '${t('offlineMode', lang)}$pendingText',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (connectivity == ConnectivityStatus.offline)
                GestureDetector(
                  onTap: () =>
                      ref.read(connectivityProvider.notifier).recheckNow(),
                  child: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
