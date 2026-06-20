import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../documents/presentation/providers/document_provider.dart';
import '../../../documents/domain/entities/document_entity.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../../core/constants/app_constants.dart';

class RemindersPage extends ConsumerWidget {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final expiringDocs = ref.watch(expiringDocumentsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Reminders & Expiry', style: theme.textTheme.titleLarge),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_alarm_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: expiringDocs.when(
        data: (docs) => docs.isEmpty
            ? _buildEmptyState(context)
            : _buildDocumentList(context, docs),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildDocumentList(BuildContext context, List<DocumentEntity> docs) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: docs.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final doc = docs[index];
        final daysLeft = doc.expiryDate != null
            ? doc.expiryDate!.difference(DateTime.now()).inDays
            : 0;
        final isUrgent = daysLeft <= 7;
        final isSoon = daysLeft <= 30;
        final color = isUrgent
            ? AppColors.error
            : isSoon
                ? AppColors.warning
                : AppColors.success;
        final emoji = AppConstants.categoryIcons[doc.category] ?? '📄';

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 22))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      'Expires ${DateUtils.formatDate(doc.expiryDate!)}',
                      style: TextStyle(color: color, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$daysLeft days',
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('✅', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 16),
          Text(
            'All clear!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'No documents expiring in the next 90 days',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
