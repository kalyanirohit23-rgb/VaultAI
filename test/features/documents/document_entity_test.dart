import 'package:flutter_test/flutter_test.dart';
import 'package:vault_ai/features/documents/domain/entities/document_entity.dart';
import 'package:vault_ai/features/documents/data/models/document_model.dart';

void main() {
  group('DocumentEntity', () {
    final baseDocument = DocumentEntity(
      id: 'doc-1',
      userId: 'user-1',
      title: 'My Passport',
      fileName: 'passport.jpg',
      fileUrl: 'https://example.com/passport.jpg',
      fileType: 'jpg',
      fileSize: 1024 * 1024,
      category: 'passport',
    );

    test('isExpired returns true for past expiry date', () {
      final doc = baseDocument.copyWith(
        expiryDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(doc.isExpired, isTrue);
    });

    test('isExpired returns false for future expiry date', () {
      final doc = baseDocument.copyWith(
        expiryDate: DateTime.now().add(const Duration(days: 365)),
      );
      expect(doc.isExpired, isFalse);
    });

    test('isExpiringSoon returns true within 90 days', () {
      final doc = baseDocument.copyWith(
        expiryDate: DateTime.now().add(const Duration(days: 60)),
      );
      expect(doc.isExpiringSoon, isTrue);
    });

    test('isExpiringSoon returns false beyond 90 days', () {
      final doc = baseDocument.copyWith(
        expiryDate: DateTime.now().add(const Duration(days: 120)),
      );
      expect(doc.isExpiringSoon, isFalse);
    });

    test('isPdf returns true for PDF documents', () {
      final doc = baseDocument.copyWith(fileType: 'pdf');
      expect(doc.isPdf, isTrue);
    });

    test('isImage returns true for image documents', () {
      expect(baseDocument.isImage, isTrue);
    });

    test('copyWith creates new instance with updated fields', () {
      final updated = baseDocument.copyWith(
        title: 'Updated Title',
        isFavorite: true,
      );
      expect(updated.title, equals('Updated Title'));
      expect(updated.isFavorite, isTrue);
      expect(updated.id, equals(baseDocument.id));
    });
  });

  group('DocumentModel', () {
    test('fromJson creates model from JSON', () {
      final json = {
        'id': 'doc-1',
        'user_id': 'user-1',
        'title': 'Test Document',
        'file_name': 'test.pdf',
        'file_url': 'https://example.com/test.pdf',
        'file_type': 'pdf',
        'file_size': 2048,
        'category': 'other',
        'is_favorite': false,
        'is_archived': false,
        'is_shared': false,
        'created_at': '2024-01-01T00:00:00Z',
      };

      final model = DocumentModel.fromJson(json);
      expect(model.id, equals('doc-1'));
      expect(model.title, equals('Test Document'));
      expect(model.fileType, equals('pdf'));
      expect(model.isPdf, isTrue);
    });

    test('toJson serializes model correctly', () {
      const model = DocumentModel(
        id: 'doc-1',
        userId: 'user-1',
        title: 'Test',
        fileName: 'test.pdf',
        fileUrl: 'https://example.com',
        fileType: 'pdf',
        fileSize: 1024,
        category: 'passport',
      );

      final json = model.toJson();
      expect(json['id'], equals('doc-1'));
      expect(json['title'], equals('Test'));
      expect(json['category'], equals('passport'));
    });
  });
}
