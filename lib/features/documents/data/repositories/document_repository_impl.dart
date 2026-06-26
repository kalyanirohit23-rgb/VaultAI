import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as p;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/document_entity.dart';
import '../../domain/repositories/document_repository.dart';
import '../models/document_model.dart';

class DocumentRepositoryImpl implements DocumentRepository {
  DocumentRepositoryImpl({required this.supabase});

  final SupabaseClient supabase;
  final _logger = Logger();
  final _uuid = const Uuid();

  String get _userId => supabase.auth.currentUser?.id ?? '';

  @override
  Future<Either<Failure, List<DocumentEntity>>> getDocuments({
    String? category,
    String? searchQuery,
    int page = 0,
    bool favoritesOnly = false,
    bool archivedOnly = false,
  }) async {
    try {
      var query = supabase
          .from(AppConstants.documentsTable)
          .select()
          .eq('user_id', _userId)
          .eq('is_archived', archivedOnly);

      if (category != null && category.isNotEmpty) {
        query = query.eq('category', category) as dynamic;
      }
      if (favoritesOnly) {
        query = query.eq('is_favorite', true) as dynamic;
      }
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('title', '%$searchQuery%') as dynamic;
      }

      final response = await (query as dynamic)
          .order('created_at', ascending: false)
          .range(page * AppConstants.pageSize, (page + 1) * AppConstants.pageSize - 1);

      final documents = (response as List)
          .map((json) => DocumentModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(documents);
    } catch (e) {
      _logger.e('Error fetching documents', error: e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> getDocumentById(String id) async {
    try {
      final response = await supabase
          .from(AppConstants.documentsTable)
          .select()
          .eq('id', id)
          .eq('user_id', _userId)
          .single();

      return Right(DocumentModel.fromJson(response));
    } catch (e) {
      _logger.e('Error fetching document', error: e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> uploadDocument({
    required String filePath,
    required String title,
    required String category,
    String? notes,
    DateTime? expiryDate,
  }) async {
    try {
      final file = File(filePath);
      final extension = p.extension(filePath).replaceAll('.', '').toLowerCase();
      final fileSize = await file.length();
      final documentId = _uuid.v4();
      final storagePath = '$_userId/$documentId.$extension';

      // Upload file to Supabase storage
      await supabase.storage
          .from(AppConstants.documentsBucket)
          .upload(storagePath, file);

      final fileUrl = supabase.storage
          .from(AppConstants.documentsBucket)
          .getPublicUrl(storagePath);

      // Insert document record
      final documentData = {
        'id': documentId,
        'user_id': _userId,
        'title': title,
        'file_name': p.basename(filePath),
        'file_url': fileUrl,
        'file_type': extension,
        'file_size': fileSize,
        'category': category,
        'notes': notes,
        'expiry_date': expiryDate?.toIso8601String(),
        'is_favorite': false,
        'is_archived': false,
        'is_shared': false,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await supabase
          .from(AppConstants.documentsTable)
          .insert(documentData)
          .select()
          .single();

      return Right(DocumentModel.fromJson(response));
    } catch (e) {
      _logger.e('Error uploading document', error: e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, DocumentEntity>> updateDocument(DocumentEntity document) async {
    try {
      final model = document is DocumentModel
          ? document
          : DocumentModel(
              id: document.id,
              userId: document.userId,
              title: document.title,
              fileName: document.fileName,
              fileUrl: document.fileUrl,
              fileType: document.fileType,
              fileSize: document.fileSize,
              category: document.category,
              folderId: document.folderId,
              thumbnailUrl: document.thumbnailUrl,
              ocrText: document.ocrText,
              aiSummary: document.aiSummary,
              tags: document.tags,
              notes: document.notes,
              expiryDate: document.expiryDate,
              issueDate: document.issueDate,
              documentNumber: document.documentNumber,
              issuerName: document.issuerName,
              holderName: document.holderName,
              isFavorite: document.isFavorite,
              isArchived: document.isArchived,
              isShared: document.isShared,
              aiConfidenceScore: document.aiConfidenceScore,
              createdAt: document.createdAt,
              updatedAt: DateTime.now(),
              metadata: document.metadata,
            );

      final response = await supabase
          .from(AppConstants.documentsTable)
          .update(model.toJson())
          .eq('id', document.id)
          .eq('user_id', _userId)
          .select()
          .single();

      return Right(DocumentModel.fromJson(response));
    } catch (e) {
      _logger.e('Error updating document', error: e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocument(String id) async {
    try {
      // Get document to find storage path
      final doc = await getDocumentById(id);
      if (doc.isLeft()) return doc.map((_) {});

      // Delete from storage
      final document = doc.getOrElse(() => throw Exception());
      final storagePath = '$_userId/${id}.${document.fileType}';
      await supabase.storage
          .from(AppConstants.documentsBucket)
          .remove([storagePath]);

      // Delete from database
      await supabase
          .from(AppConstants.documentsTable)
          .delete()
          .eq('id', id)
          .eq('user_id', _userId);

      return const Right(null);
    } catch (e) {
      _logger.e('Error deleting document', error: e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleFavorite(String id, bool isFavorite) async {
    try {
      await supabase
          .from(AppConstants.documentsTable)
          .update({'is_favorite': isFavorite})
          .eq('id', id)
          .eq('user_id', _userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleArchive(String id, bool isArchived) async {
    try {
      await supabase
          .from(AppConstants.documentsTable)
          .update({'is_archived': isArchived})
          .eq('id', id)
          .eq('user_id', _userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> moveToFolder(String documentId, String? folderId) async {
    try {
      await supabase
          .from(AppConstants.documentsTable)
          .update({'folder_id': folderId})
          .eq('id', documentId)
          .eq('user_id', _userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DocumentEntity>>> getExpiringDocuments({
    int daysThreshold = 90,
  }) async {
    try {
      final threshold = DateTime.now().add(Duration(days: daysThreshold));
      final response = await supabase
          .from(AppConstants.documentsTable)
          .select()
          .eq('user_id', _userId)
          .eq('is_archived', false)
          .not('expiry_date', 'is', null)
          .lte('expiry_date', threshold.toIso8601String())
          .gte('expiry_date', DateTime.now().toIso8601String())
          .order('expiry_date', ascending: true);

      final documents = (response as List)
          .map((json) => DocumentModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(documents);
    } catch (e) {
      _logger.e('Error fetching expiring documents', error: e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<DocumentEntity>>> searchDocuments(String query) async {
    try {
      final response = await supabase
          .from(AppConstants.documentsTable)
          .select()
          .eq('user_id', _userId)
          .eq('is_archived', false)
          .or('title.ilike.%$query%,ocr_text.ilike.%$query%,notes.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(AppConstants.searchPageSize);

      final documents = (response as List)
          .map((json) => DocumentModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return Right(documents);
    } catch (e) {
      _logger.e('Error searching documents', error: e);
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> bulkDelete(List<String> ids) async {
    try {
      await supabase
          .from(AppConstants.documentsTable)
          .delete()
          .inFilter('id', ids)
          .eq('user_id', _userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> bulkArchive(List<String> ids) async {
    try {
      await supabase
          .from(AppConstants.documentsTable)
          .update({'is_archived': true})
          .inFilter('id', ids)
          .eq('user_id', _userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getDocumentStats() async {
    try {
      final response = await supabase
          .from(AppConstants.documentsTable)
          .select('category')
          .eq('user_id', _userId)
          .eq('is_archived', false);

      final stats = <String, int>{};
      for (final doc in (response as List)) {
        final category = (doc as Map<String, dynamic>)['category'] as String? ?? 'other';
        stats[category] = (stats[category] ?? 0) + 1;
      }

      return Right(stats);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<List<DocumentEntity>> get documentsStream {
    return supabase
        .from(AppConstants.documentsTable)
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('created_at', ascending: false)
        .map(
          (rows) => rows
              .map((json) => DocumentModel.fromJson(json))
              .toList(),
        );
  }
}
