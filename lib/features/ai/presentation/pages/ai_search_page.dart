import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/router/app_router.dart';
import '../../../documents/domain/entities/document_entity.dart';
import '../../../documents/presentation/providers/document_provider.dart';
import '../../../documents/presentation/widgets/document_card.dart';

class AiSearchPage extends ConsumerStatefulWidget {
  const AiSearchPage({super.key});

  @override
  ConsumerState<AiSearchPage> createState() => _AiSearchPageState();
}

class _AiSearchPageState extends ConsumerState<AiSearchPage> {
  final _searchController = TextEditingController();

  final List<String> _suggestions = [
    'Show my passport',
    'Find insurance documents',
    'When does my licence expire?',
    'Show March electricity bill',
    'Find PAN card',
    'Show all warranties',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final searchState = ref.watch(documentSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Search'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    AppColors.accent.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Ask anything about your documents...',
                  prefixIcon: const Text('🤖', style: TextStyle(fontSize: 20)),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  suffixIcon: searchState.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.search_rounded),
                          onPressed: () => ref
                              .read(documentSearchProvider.notifier)
                              .search(_searchController.text),
                          color: AppColors.primary,
                        ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onSubmitted: (q) =>
                    ref.read(documentSearchProvider.notifier).search(q),
              ),
            ),
          ),
          Expanded(
            child: searchState.query.isEmpty
                ? _buildSuggestions()
                : searchState.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : searchState.results.isEmpty
                        ? _buildNoResults()
                        : _buildResults(searchState.results),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('✨', style: TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text('Try asking...', style: theme.textTheme.titleSmall),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions
                .map(
                  (s) => GestureDetector(
                    onTap: () {
                      _searchController.text = s;
                      ref.read(documentSearchProvider.notifier).search(s);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🔎', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          Text(
            'No documents found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Try a different search query',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.grey500),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(List<DocumentEntity> results) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final doc = results[index];
        return DocumentCard(
          document: doc,
          onTap: () => context.push('${AppRoutes.documents}/${doc.id}'),
        );
      },
    );
  }
}
