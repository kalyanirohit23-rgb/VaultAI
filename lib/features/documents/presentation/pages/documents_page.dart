import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../providers/document_provider.dart';
import '../widgets/document_card.dart';
import '../widgets/category_filter_chip.dart';

class DocumentsPage extends ConsumerStatefulWidget {
  const DocumentsPage({super.key});

  @override
  ConsumerState<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends ConsumerState<DocumentsPage> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final documentsState = ref.watch(documentsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final searchState = ref.watch(documentSearchProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search documents...',
                  border: InputBorder.none,
                ),
                onChanged: (q) =>
                    ref.read(documentSearchProvider.notifier).search(q),
              )
            : Text('My Documents', style: theme.textTheme.titleLarge),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(documentSearchProvider.notifier).clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => context.push(AppRoutes.documentUpload),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Category filters
          if (!_isSearching) ...[
            const SizedBox(height: 4),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: AppConstants.documentCategories.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return CategoryFilterChip(
                      label: 'All',
                      emoji: '📂',
                      isSelected: selectedCategory == null,
                      onSelected: () {
                        ref.read(selectedCategoryProvider.notifier).state = null;
                        ref.read(documentsProvider.notifier).refresh();
                      },
                    );
                  }
                  final category = AppConstants.documentCategories[index - 1];
                  return CategoryFilterChip(
                    label: AppConstants.categoryDisplayNames[category] ?? category,
                    emoji: AppConstants.categoryIcons[category] ?? '📄',
                    isSelected: selectedCategory == category,
                    onSelected: () {
                      ref.read(selectedCategoryProvider.notifier).state = category;
                      ref.read(documentsProvider.notifier).refresh(category: category);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Documents list
          Expanded(
            child: _isSearching
                ? _buildSearchResults(searchState)
                : _buildDocumentsList(documentsState),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.documentUpload),
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  Widget _buildDocumentsList(DocumentsState state) {
    if (state.isLoading && state.documents.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('❌', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(state.error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.read(documentsProvider.notifier).refresh(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.documents.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(documentsProvider.notifier).refresh(
            category: ref.read(selectedCategoryProvider),
          ),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: state.documents.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == state.documents.length) {
            ref.read(documentsProvider.notifier).loadDocuments(
                  category: ref.read(selectedCategoryProvider),
                );
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }
          final doc = state.documents[index];
          return DocumentCard(
            document: doc,
            onTap: () => context.push('${AppRoutes.documents}/${doc.id}'),
            onFavorite: () =>
                ref.read(documentsProvider.notifier).toggleFavorite(doc.id),
            onDelete: () =>
                ref.read(documentsProvider.notifier).deleteDocument(doc.id),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(DocumentSearchState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🔍', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            Text('Search your documents'),
          ],
        ),
      );
    }

    if (state.results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🔎', style: TextStyle(fontSize: 64)),
            SizedBox(height: 16),
            Text('No documents found'),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: state.results.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final doc = state.results[index];
        return DocumentCard(
          document: doc,
          onTap: () => context.push('${AppRoutes.documents}/${doc.id}'),
          onFavorite: () =>
              ref.read(documentsProvider.notifier).toggleFavorite(doc.id),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📭', style: TextStyle(fontSize: 72)),
            const SizedBox(height: 16),
            Text(
              'No documents found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Add documents to your vault',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey500,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, controller) => Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              const Text('Sort by'),
              // Add sort options here
            ],
          ),
        ),
      ),
    );
  }
}
