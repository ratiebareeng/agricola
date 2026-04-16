import 'package:agricola/core/widgets/agri_kit.dart';
import 'package:agricola/features/debug/providers/health_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HealthCheckPage extends ConsumerStatefulWidget {
  const HealthCheckPage({super.key});

  @override
  ConsumerState<HealthCheckPage> createState() => _HealthCheckPageState();
}

class _HealthCheckPageState extends ConsumerState<HealthCheckPage> {
  @override
  Widget build(BuildContext context) {
    final healthState = ref.watch(healthStatusProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Health Check')),
      body: _buildBody(context, healthState),
    );
  }

  Widget _buildBody(BuildContext context, HealthState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'Health Check Failed',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.error ?? ''),

            const SizedBox(height: 16),
            _checkHealthButton('Retry'),
          ],
        ),
      );
    }

    if (state.healthStatus) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 64),
            const SizedBox(height: 16),
            Text(
              'Health Check Passed',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('The harvest is bountiful.'),
            const SizedBox(height: 16),
            _checkHealthButton(null),
          ],
        ),
      );
    }

    if (state.healthStatus == false) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Press the button to check health'),
            const SizedBox(height: 16),
            _checkHealthButton(null),
          ],
        ),
      );
    }

    return const Center(
      child: Text('Check health status', style: TextStyle(color: Colors.grey)),
    );
  }

  Widget _checkHealthButton(String? label) {
    return SizedBox(
      width: 200,
      child: AgriStadiumButton(
        onPressed: () {
          ref.read(healthStatusProvider.notifier).getHealth();
        },
        label: label ?? 'Check Health',
        isPrimary: false,
      ),
    );
  }
}
