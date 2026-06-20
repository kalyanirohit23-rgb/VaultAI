import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/utils/app_utils.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../documents/domain/entities/document_entity.dart';
import '../../../documents/presentation/providers/document_provider.dart';
import '../../../documents/presentation/widgets/document_card.dart';
import '../../../reminders/presentation/providers/reminder_provider.dart';
import '../widgets/ai_insight_card.dart';
import '../widgets/expiry_alert_card.dart';
import '../widgets/home_stats_card.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/storage_usage_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = ref.watch(currentUserProvider);
    final documentsState = ref.watch(documentsProvider);
    final expiringDocs = ref.watch(expiringDocumentsProvider);
    final docStats = ref.watch(documentStatsProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.refresh(currentUserProvider);
          ref.read(documentsProvider.notifier).refresh();
          ref.refresh(expiringDocumentsProvider);
        },
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context, theme, user),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Stats row
                    docStats.when(
                      data: (stats) => HomeStatsCard(stats: stats),
                      loading: () => const _StatsShimmer(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 20),
                    // Quick actions
                    _buildQuickActions(context),
                    const SizedBox(height: 20),
                    // Expiring documents
                    expiringDocs.when(
                      data: (docs) => docs.isEmpty
                          ? const SizedBox.shrink()
                          : _buildExpirySection(docs),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    // AI Insights
                    const SizedBox(height: 20),
                    _buildAiInsights(),
                    const SizedBox(height: 20),
                    // Storage usage
                    user.when(
                      data: (u) => u != null
                          ? StorageUsageCard(
                              usedBytes: u.storageUsed,
                              totalBytes: 1024 * 1024 * 1024, // 1GB free
                            )
                          : const SizedBox.shrink(),
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 20),
                    // Recent documents
                    Text(
                      'Recent Documents',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            // Recent documents list
            if (documentsState.isLoading && documentsState.documents.isEmpty)
              const SliverToBoxAdapter(child: _DocumentsShimmer())
            else if (documentsState.documents.isEmpty)
              SliverToBoxAdapter(child: _buildEmptyState(context))
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == documentsState.documents.length) {
                        if (documentsState.hasMore) {
                          ref.read(documentsProvider.notifier).loadDocuments();
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }
                        return const SizedBox(height: 80);
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: DocumentCard(
                          document: documentsState.documents[index],
                          onTap: () => context.push(
                            '${AppRoutes.documents}/${documentsState.documents[index].id}',
                          ),
                          onFavorite: () => ref
                              .read(documentsProvider.notifier)
                              .toggleFavorite(documentsState.documents[index].id),
                        ),
                      );
                    },
                    childCount: documentsState.documents.length +
                        (documentsState.hasMore ? 1 : 1),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, ThemeData theme, AsyncValue user) {
    return SliverAppBar(
      floating: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      title: user.when(
        data: (u) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good ${_getGreeting()} 👋',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.grey500,
              ),
            ),
            Text(
              u?.displayName?.split(' ').first ?? 'Welcome',
              style: theme.textTheme.titleLarge,
            ),
          ],
        ),
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const Text('VaultAI'),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded),
          onPressed: () => context.push(AppRoutes.aiSearch),
          tooltip: 'Search',
        ),
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {},
          tooltip: 'Notifications',
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            QuickActionButton(
              icon: Icons.document_scanner_outlined,
              label: 'Scan',
              color: AppColors.primary,
              onTap: () => context.push(AppRoutes.scanner),
            ),
            QuickActionButton(
              icon: Icons.upload_file_outlined,
              label: 'Upload',
              color: AppColors.secondary,
              onTap: () => context.push(AppRoutes.documentUpload),
            ),
            QuickActionButton(
              icon: Icons.search_rounded,
              label: 'AI Search',
              color: AppColors.accent,
              onTap: () => context.push(AppRoutes.aiSearch),
            ),
            QuickActionButton(
              icon: Icons.smart_toy_outlined,
              label: 'AI Chat',
              color: AppColors.accentGold,
              onTap: () => context.push(AppRoutes.aiAssistant),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExpirySection(List<DocumentEntity> docs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              'Expiring Soon',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            TextButton(
              onPressed: () => context.go(AppRoutes.reminders),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: docs.take(5).length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return ExpiryAlertCard(
                document: docs[index],
                onTap: () => context.push('${AppRoutes.documents}/${docs[index].id}'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAiInsights() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('🧠', style: TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              'AI Insights',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        const AiInsightCard(
          icon: '🛂',
          message: 'Your vault is secured with end-to-end encryption.',
          type: InsightType.info,
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Text('📂', style: TextStyle(fontSize: 72)),
          const SizedBox(height: 16),
          Text(
            'No documents yet',
            style: Theme.of(context).textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your first document or scan one with your camera',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.grey500,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.documentUpload),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Document'),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }
}

class _StatsShimmer extends StatelessWidget {
  const _StatsShimmer();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

class _DocumentsShimmer extends StatelessWidget {
  const _DocumentsShimmer();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            height: 90,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.grey100,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
