import 'package:flutter/material.dart';
import 'package:agricola/core/config/environment.dart';
import 'package:agricola/core/constants/api_constants.dart';

/// Environment indicator banner
///
/// Shows a colored banner at the top of the app indicating the current environment.
/// Only visible in development mode.
///
/// Usage:
/// ```dart
/// MaterialApp(
///   builder: (context, child) => EnvironmentBanner(child: child!),
///   ...
/// )
/// ```
class EnvironmentBanner extends StatelessWidget {
  final Widget child;

  const EnvironmentBanner({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Only show banner in development
    if (EnvironmentConfig.isProduction) {
      return child;
    }

    return Banner(
      message: 'DEV',
      location: BannerLocation.topEnd,
      color: Colors.green.shade700,
      child: child,
    );
  }
}

/// Environment info widget
///
/// Shows detailed environment information for debugging.
/// Useful to add to settings or profile screens.
///
/// Usage:
/// ```dart
/// EnvironmentInfoCard()
/// ```
class EnvironmentInfoCard extends StatelessWidget {
  const EnvironmentInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: EnvironmentConfig.isProduction
                      ? Colors.blue
                      : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  'Environment Info',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _InfoRow(
              label: 'Environment',
              value: EnvironmentConfig.environmentName.toUpperCase(),
              valueColor: EnvironmentConfig.isProduction
                  ? Colors.blue
                  : Colors.green,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'API Base URL',
              value: ApiConstants.baseUrl,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'API Timeout',
              value: '${EnvironmentConfig.apiTimeout.inSeconds}s',
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Logging',
              value: EnvironmentConfig.enableLogging ? 'Enabled' : 'Disabled',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: valueColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
      ],
    );
  }
}

/// Quick environment switcher button (for development only)
///
/// Shows a floating action button that displays the current environment
/// and instructions on how to switch.
class EnvironmentSwitcherButton extends StatelessWidget {
  const EnvironmentSwitcherButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _showEnvironmentDialog(context),
      icon: Icon(
        EnvironmentConfig.isProduction ? Icons.cloud : Icons.computer,
      ),
      label: Text(EnvironmentConfig.environmentName.toUpperCase()),
      backgroundColor:
          EnvironmentConfig.isProduction ? Colors.blue : Colors.green,
    );
  }

  void _showEnvironmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Environment Configuration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current: ${EnvironmentConfig.environmentName.toUpperCase()}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'API: ${ApiConstants.baseUrl}',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Text(
              'To switch environments:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. Open lib/core/config/environment.dart\n'
              '2. Change currentEnvironment to:\n'
              '   - AppEnvironment.development\n'
              '   - AppEnvironment.production\n'
              '3. Hot restart the app',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Text(
              'Or use command line:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.grey[200],
              child: const Text(
                'flutter run --dart-define=ENVIRONMENT=production',
                style: TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
