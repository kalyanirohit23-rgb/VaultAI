import '../../domain/entities/document_entity.dart';

class DocumentModel extends DocumentEntity {
  const DocumentModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.fileName,
    required super.fileUrl,
    required super.fileType,
    required super.fileSize,
    required super.category,
    super.folderId,
    super.thumbnailUrl,
    super.ocrText,
    super.aiSummary,
    super.tags,
    super.notes,
    super.expiryDate,
    super.issueDate,
    super.documentNumber,
    super.issuerName,
    super.holderName,
    super.isFavorite,
    super.isArchived,
    super.isShared,
    super.aiConfidenceScore,
    super.createdAt,
    super.updatedAt,
    super.metadata,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json) {
    return DocumentModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      fileName: json['file_name'] as String,
      fileUrl: json['file_url'] as String,
      fileType: json['file_type'] as String,
      fileSize: json['file_size'] as int? ?? 0,
      category: json['category'] as String? ?? 'other',
      folderId: json['folder_id'] as String?,
      thumbnailUrl: json['thumbnail_url'] as String?,
      ocrText: json['ocr_text'] as String?,
      aiSummary: json['ai_summary'] as String?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : const [],
      notes: json['notes'] as String?,
      expiryDate: json['expiry_date'] != null
          ? DateTime.tryParse(json['expiry_date'] as String)
          : null,
      issueDate: json['issue_date'] != null
          ? DateTime.tryParse(json['issue_date'] as String)
          : null,
      documentNumber: json['document_number'] as String?,
      issuerName: json['issuer_name'] as String?,
      holderName: json['holder_name'] as String?,
      isFavorite: json['is_favorite'] as bool? ?? false,
      isArchived: json['is_archived'] as bool? ?? false,
      isShared: json['is_shared'] as bool? ?? false,
      aiConfidenceScore: json['ai_confidence_score'] != null
          ? (json['ai_confidence_score'] as num).toDouble()
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : const {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'file_name': fileName,
      'file_url': fileUrl,
      'file_type': fileType,
      'file_size': fileSize,
      'category': category,
      'folder_id': folderId,
      'thumbnail_url': thumbnailUrl,
      'ocr_text': ocrText,
      'ai_summary': aiSummary,
      'tags': tags,
      'notes': notes,
      'expiry_date': expiryDate?.toIso8601String(),
      'issue_date': issueDate?.toIso8601String(),
      'document_number': documentNumber,
      'issuer_name': issuerName,
      'holder_name': holderName,
      'is_favorite': isFavorite,
      'is_archived': isArchived,
      'is_shared': isShared,
      'ai_confidence_score': aiConfidenceScore,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }
}
