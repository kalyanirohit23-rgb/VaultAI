import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_utils.dart';
import '../../domain/entities/document_entity.dart';

class DocumentCard extends StatelessWidget {
  const DocumentCard({
    super.key,
    required this.document,
    required this.onTap,
    this.onFavorite,
    this.onDelete,
    this.isSelected = false,
    this.onLongPress,
  });

  final DocumentEntity document;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onDelete;
  final bool isSelected;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final emoji = AppConstants.categoryIcons[document.category] ?? '📄';
    final categoryColor = AppColors.categoryColors[document.category] ?? AppColors.grey500;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : (isDark ? AppColors.cardDark : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : AppColors.grey200),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // File type icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: categoryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 12),
              // Document info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: theme.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: categoryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            AppConstants.categoryDisplayNames[document.category] ??
                                document.category,
                            style: TextStyle(
                              color: categoryColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          FileUtils.formatFileSize(document.fileSize),
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    if (document.expiryDate != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            document.isExpired
                                ? Icons.error_outline
                                : Icons.schedule_outlined,
                            size: 12,
                            color: document.isExpired
                                ? AppColors.error
                                : document.isExpiringSoon
                                    ? AppColors.warning
                                    : AppColors.grey500,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            DateUtils.formatExpiryStatus(document.expiryDate),
                            style: TextStyle(
                              fontSize: 11,
                              color: document.isExpired
                                  ? AppColors.error
                                  : document.isExpiringSoon
                                      ? AppColors.warning
                                      : AppColors.grey500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Actions
              Column(
                children: [
                  if (onFavorite != null)
                    IconButton(
                      icon: Icon(
                        document.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: document.isFavorite ? AppColors.error : AppColors.grey400,
                        size: 20,
                      ),
                      onPressed: onFavorite,
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                    ),
                  if (document.fileType.toLowerCase() == 'pdf')
                    const Icon(Icons.picture_as_pdf_outlined,
                        size: 16, color: AppColors.error)
                  else
                    const Icon(Icons.image_outlined,
                        size: 16, color: AppColors.info),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
