import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/app_utils.dart';

class StorageUsageCard extends StatelessWidget {
  const StorageUsageCard({
    super.key,
    required this.usedBytes,
    required this.totalBytes,
  });

  final int usedBytes;
  final int totalBytes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percentage = StorageUtils.getUsagePercentage(usedBytes, totalBytes);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('💾', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 8),
              Text('Storage Usage', style: theme.textTheme.titleSmall),
              const Spacer(),
              Text(
                StorageUtils.formatStorageUsed(usedBytes, totalBytes),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.grey500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: AppColors.grey200,
              valueColor: AlwaysStoppedAnimation<Color>(
                percentage > 0.9 ? AppColors.error : AppColors.primary,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(percentage * 100).toStringAsFixed(0)}% used',
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.grey500),
          ),
        ],
      ),
    );
  }
}
