import 'package:agricola/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CropCard extends StatelessWidget {
  final String name;
  final String stage;
  final String plantedDate;
  final double progress;
  final String imageUrl;
  final bool isSynced;

  const CropCard({
    super.key,
    required this.name,
    required this.stage,
    required this.plantedDate,
    required this.progress,
    required this.imageUrl,
    this.isSynced = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.grey[200],
              image: imageUrl.isEmpty
                  ? null
                  : DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                      onError: (_, __) {},
                    ),
            ),
            child: imageUrl.isEmpty
                ? Icon(
                    Icons.local_florist_outlined,
                    color: Colors.grey[500],
                    size: 32,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!isSynced)
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Tooltip(
                              message: 'Pending sync',
                              child: Icon(
                                Icons.cloud_upload_outlined,
                                size: 14,
                                color: AppColors.warmYellow,
                              ),
                            ),
                          ),
                        Text(
                          stage,
                          style: const TextStyle(
                            color: AppColors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Planted: $plantedDate',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.green,
                    ),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
