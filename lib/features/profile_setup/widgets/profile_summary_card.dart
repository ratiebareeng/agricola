import 'dart:io';

import 'package:agricola/core/providers/language_provider.dart';
import 'package:agricola/core/theme/app_theme.dart';
import 'package:agricola/features/profile_setup/providers/profile_setup_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileSummaryCard extends ConsumerWidget {
  const ProfileSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileSetupProvider);
    final currentLang = ref.watch(languageProvider);

    if (state.userType != UserType.farmer) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (state.photoPath != null)
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.green, width: 2),
                    image: DecorationImage(
                      image: FileImage(File(state.photoPath!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.person, size: 30, color: Colors.grey),
                ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('your_profile', currentLang),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t('farmer', currentLang),
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.location_on,
            t('location', currentLang),
            state.village == 'Other'
                ? state.customVillage.isNotEmpty
                      ? state.customVillage
                      : 'Not specified'
                : state.village.isNotEmpty
                ? state.village
                : 'Not specified',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.agriculture,
            t('crops', currentLang),
            state.selectedCrops.isEmpty
                ? 'Not specified'
                : state.selectedCrops.join(', '),
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.landscape,
            t('farm_size', currentLang),
            state.farmSize.isNotEmpty ? state.farmSize : 'Not specified',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.green),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
