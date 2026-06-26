import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/document_entity.dart';

abstract class DocumentRepository {
  Future<Either<Failure, List<DocumentEntity>>> getDocuments({
    String? category,
    String? searchQuery,
    int page = 0,
    bool favoritesOnly = false,
    bool archivedOnly = false,
  });

  Future<Either<Failure, DocumentEntity>> getDocumentById(String id);

  Future<Either<Failure, DocumentEntity>> uploadDocument({
    required String filePath,
    required String title,
    required String category,
    String? notes,
    DateTime? expiryDate,
  });

  Future<Either<Failure, DocumentEntity>> updateDocument(DocumentEntity document);

  Future<Either<Failure, void>> deleteDocument(String id);

  Future<Either<Failure, void>> toggleFavorite(String id, bool isFavorite);

  Future<Either<Failure, void>> toggleArchive(String id, bool isArchived);

  Future<Either<Failure, void>> moveToFolder(String documentId, String? folderId);

  Future<Either<Failure, List<DocumentEntity>>> getExpiringDocuments({int daysThreshold = 90});

  Future<Either<Failure, List<DocumentEntity>>> searchDocuments(String query);

  Future<Either<Failure, void>> bulkDelete(List<String> ids);

  Future<Either<Failure, void>> bulkArchive(List<String> ids);

  Future<Either<Failure, Map<String, int>>> getDocumentStats();

  Stream<List<DocumentEntity>> get documentsStream;
}
