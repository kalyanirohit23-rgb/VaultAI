import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/app_utils.dart';
import '../providers/document_provider.dart';

class DocumentDetailPage extends ConsumerStatefulWidget {
  const DocumentDetailPage({super.key, required this.documentId});

  final String documentId;

  @override
  ConsumerState<DocumentDetailPage> createState() => _DocumentDetailPageState();
}

class _DocumentDetailPageState extends ConsumerState<DocumentDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // For now use a simple FutureProvider for the specific document
    final documentAsync = ref.watch(
      _documentByIdProvider(widget.documentId),
    );

    return Scaffold(
      body: documentAsync.when(
        data: (document) {
          if (document == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('📄', style: TextStyle(fontSize: 64)),
                  const SizedBox(height: 16),
                  const Text('Document not found'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.pop(),
                    child: const Text('Go Back'),
                  ),
                ],
              ),
            );
          }

          final emoji = AppConstants.categoryIcons[document.category] ?? '📄';
          final categoryColor =
              AppColors.categoryColors[document.category] ?? AppColors.grey500;

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          categoryColor,
                          categoryColor.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(emoji, style: const TextStyle(fontSize: 72)),
                    ),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      document.isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: Colors.white,
                    ),
                    onPressed: () => ref
                        .read(documentsProvider.notifier)
                        .toggleFavorite(document.id),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (action) => _handleAction(action, document.id),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'share', child: Text('Share')),
                      const PopupMenuItem(value: 'archive', child: Text('Archive')),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete', style: TextStyle(color: AppColors.error)),
                      ),
                    ],
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(document.title, style: theme.textTheme.headlineSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _InfoChip(
                            icon: '📂',
                            label: AppConstants.categoryDisplayNames[document.category] ??
                                document.category,
                            color: categoryColor,
                          ),
                          _InfoChip(
                            icon: '📦',
                            label: FileUtils.formatFileSize(document.fileSize),
                          ),
                          if (document.expiryDate != null)
                            _InfoChip(
                              icon: '⏰',
                              label: DateUtils.formatDate(document.expiryDate!),
                              color: document.isExpired
                                  ? AppColors.error
                                  : document.isExpiringSoon
                                      ? AppColors.warning
                                      : AppColors.success,
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Details'),
                          Tab(text: 'OCR Text'),
                          Tab(text: 'AI Summary'),
                        ],
                      ),
                      SizedBox(
                        height: 300,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Details tab
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (document.documentNumber != null)
                                    _DetailRow(
                                        label: 'Document Number',
                                        value: document.documentNumber!),
                                  if (document.holderName != null)
                                    _DetailRow(
                                        label: 'Holder', value: document.holderName!),
                                  if (document.issuerName != null)
                                    _DetailRow(
                                        label: 'Issuer', value: document.issuerName!),
                                  if (document.issueDate != null)
                                    _DetailRow(
                                        label: 'Issue Date',
                                        value: DateUtils.formatDate(document.issueDate!)),
                                  if (document.expiryDate != null)
                                    _DetailRow(
                                        label: 'Expiry Date',
                                        value: DateUtils.formatDate(document.expiryDate!)),
                                  if (document.notes != null && document.notes!.isNotEmpty)
                                    _DetailRow(
                                        label: 'Notes', value: document.notes!),
                                  _DetailRow(
                                    label: 'Added',
                                    value: document.createdAt != null
                                        ? DateUtils.formatDateTime(document.createdAt!)
                                        : 'Unknown',
                                  ),
                                ],
                              ),
                            ),
                            // OCR text tab
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: document.ocrText != null
                                  ? SingleChildScrollView(
                                      child: Text(document.ocrText!))
                                  : const Center(
                                      child: Text('No OCR text available')),
                            ),
                            // AI Summary tab
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: document.aiSummary != null
                                  ? Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: AppColors.primary.withValues(alpha: 0.2),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Row(
                                            children: [
                                              Text('🤖',
                                                  style: TextStyle(fontSize: 16)),
                                              SizedBox(width: 8),
                                              Text(
                                                'AI Summary',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                          Text(document.aiSummary!),
                                        ],
                                      ),
                                    )
                                  : const Center(
                                      child: Text('No AI summary available')),
                            ),
                          ],
                        ),
                      ),
                      if (document.tags.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text('Tags', style: theme.textTheme.titleSmall),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: document.tags
                              .map(
                                (tag) => Chip(
                                  label: Text(tag, style: const TextStyle(fontSize: 12)),
                                  padding: EdgeInsets.zero,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                // Open document
                              },
                              icon: const Icon(Icons.open_in_new_rounded),
                              label: const Text('Open'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                // Share document
                              },
                              icon: const Icon(Icons.share_outlined),
                              label: const Text('Share'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Go Back'),
          ),
        ),
      ),
    );
  }

  void _handleAction(String action, String documentId) {
    switch (action) {
      case 'delete':
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Document'),
            content: const Text('Are you sure you want to delete this document?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(documentsProvider.notifier).deleteDocument(documentId);
                  context.pop();
                },
                style: TextButton.styleFrom(foregroundColor: AppColors.error),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        break;
      case 'archive':
        ref.read(documentsProvider.notifier).toggleArchive(documentId);
        context.pop();
        break;
    }
  }
}

// Provider to get a single document
final _documentByIdProvider = FutureProvider.family(
  (ref, String id) async {
    final repo = ref.watch(documentRepositoryProvider);
    final result = await repo.getDocumentById(id);
    return result.fold((_) => null, (doc) => doc);
  },
);

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, this.color});

  final String icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.grey500;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: chipColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.grey500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
