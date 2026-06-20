import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/repositories/document_repository_impl.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/document_repository.dart';

// Repository provider
final documentRepositoryProvider = Provider<DocumentRepository>((ref) {
  return DocumentRepositoryImpl(supabase: Supabase.instance.client);
});

// Documents list provider
final documentsProvider = StateNotifierProvider<DocumentsController, DocumentsState>((ref) {
  return DocumentsController(
    repository: ref.watch(documentRepositoryProvider),
  );
});

// Category filter provider
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

// Expiring documents provider
final expiringDocumentsProvider = FutureProvider<List<DocumentEntity>>((ref) async {
  final repo = ref.watch(documentRepositoryProvider);
  final result = await repo.getExpiringDocuments(daysThreshold: 90);
  return result.fold((_) => [], (docs) => docs);
});

// Document search provider
final documentSearchProvider = StateNotifierProvider<DocumentSearchController, DocumentSearchState>((ref) {
  return DocumentSearchController(repository: ref.watch(documentRepositoryProvider));
});

// Document stats provider
final documentStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.watch(documentRepositoryProvider);
  final result = await repo.getDocumentStats();
  return result.fold((_) => {}, (stats) => stats);
});

// Selected documents for bulk operations
final selectedDocumentsProvider = StateProvider<Set<String>>((ref) => {});

// Documents state
class DocumentsState {
  const DocumentsState({
    this.documents = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.page = 0,
  });

  final List<DocumentEntity> documents;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int page;

  DocumentsState copyWith({
    List<DocumentEntity>? documents,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? page,
  }) {
    return DocumentsState(
      documents: documents ?? this.documents,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}

class DocumentsController extends StateNotifier<DocumentsState> {
  DocumentsController({required this.repository}) : super(const DocumentsState()) {
    loadDocuments();
  }

  final DocumentRepository repository;

  Future<void> loadDocuments({
    String? category,
    bool refresh = false,
  }) async {
    if (state.isLoading) return;

    final page = refresh ? 0 : state.page;
    state = state.copyWith(isLoading: true, error: null);

    final result = await repository.getDocuments(
      category: category,
      page: page,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (docs) => state = state.copyWith(
        isLoading: false,
        documents: refresh ? docs : [...state.documents, ...docs],
        hasMore: docs.length >= 20,
        page: page + 1,
      ),
    );
  }

  Future<void> refresh({String? category}) async {
    state = const DocumentsState();
    await loadDocuments(category: category, refresh: true);
  }

  Future<void> deleteDocument(String id) async {
    final result = await repository.deleteDocument(id);
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) => state = state.copyWith(
        documents: state.documents.where((d) => d.id != id).toList(),
      ),
    );
  }

  Future<void> toggleFavorite(String id) async {
    final document = state.documents.firstWhere((d) => d.id == id);
    final result = await repository.toggleFavorite(id, !document.isFavorite);
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) => state = state.copyWith(
        documents: state.documents
            .map((d) => d.id == id ? d.copyWith(isFavorite: !d.isFavorite) : d)
            .toList(),
      ),
    );
  }

  Future<void> toggleArchive(String id) async {
    final document = state.documents.firstWhere((d) => d.id == id);
    final result = await repository.toggleArchive(id, !document.isArchived);
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) => state = state.copyWith(
        documents: state.documents.where((d) => d.id != id).toList(),
      ),
    );
  }

  Future<void> bulkDelete(List<String> ids) async {
    final result = await repository.bulkDelete(ids);
    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) => state = state.copyWith(
        documents: state.documents.where((d) => !ids.contains(d.id)).toList(),
      ),
    );
  }
}

// Document search state
class DocumentSearchState {
  const DocumentSearchState({
    this.results = const [],
    this.isLoading = false,
    this.query = '',
    this.error,
  });

  final List<DocumentEntity> results;
  final bool isLoading;
  final String query;
  final String? error;
}

class DocumentSearchController extends StateNotifier<DocumentSearchState> {
  DocumentSearchController({required this.repository}) : super(const DocumentSearchState());

  final DocumentRepository repository;

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const DocumentSearchState();
      return;
    }

    state = DocumentSearchState(query: query, isLoading: true);

    final result = await repository.searchDocuments(query);
    result.fold(
      (failure) => state = DocumentSearchState(
        query: query,
        error: failure.message,
      ),
      (docs) => state = DocumentSearchState(
        query: query,
        results: docs,
      ),
    );
  }

  void clear() {
    state = const DocumentSearchState();
  }
}
