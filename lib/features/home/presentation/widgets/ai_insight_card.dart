import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

enum InsightType { info, warning, success, error }

class AiInsightCard extends StatelessWidget {
  const AiInsightCard({
    super.key,
    required this.icon,
    required this.message,
    required this.type,
    this.onTap,
  });

  final String icon;
  final String message;
  final InsightType type;
  final VoidCallback? onTap;

  Color _getColor() {
    switch (type) {
      case InsightType.info:
        return AppColors.info;
      case InsightType.warning:
        return AppColors.warning;
      case InsightType.success:
        return AppColors.success;
      case InsightType.error:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: color),
          ],
        ),
      ),
    );
  }
}
