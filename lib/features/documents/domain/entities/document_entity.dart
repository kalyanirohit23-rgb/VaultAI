import 'package:equatable/equatable.dart';

/// Document entity
class DocumentEntity extends Equatable {
  const DocumentEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.fileName,
    required this.fileUrl,
    required this.fileType,
    required this.fileSize,
    required this.category,
    this.folderId,
    this.thumbnailUrl,
    this.ocrText,
    this.aiSummary,
    this.tags = const [],
    this.notes,
    this.expiryDate,
    this.issueDate,
    this.documentNumber,
    this.issuerName,
    this.holderName,
    this.isFavorite = false,
    this.isArchived = false,
    this.isShared = false,
    this.aiConfidenceScore,
    this.createdAt,
    this.updatedAt,
    this.metadata = const {},
  });

  final String id;
  final String userId;
  final String title;
  final String fileName;
  final String fileUrl;
  final String fileType;
  final int fileSize;
  final String category;
  final String? folderId;
  final String? thumbnailUrl;
  final String? ocrText;
  final String? aiSummary;
  final List<String> tags;
  final String? notes;
  final DateTime? expiryDate;
  final DateTime? issueDate;
  final String? documentNumber;
  final String? issuerName;
  final String? holderName;
  final bool isFavorite;
  final bool isArchived;
  final bool isShared;
  final double? aiConfidenceScore;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic> metadata;

  bool get isExpired {
    if (expiryDate == null) return false;
    return expiryDate!.isBefore(DateTime.now());
  }

  bool get isExpiringSoon {
    if (expiryDate == null) return false;
    final diff = expiryDate!.difference(DateTime.now());
    return !diff.isNegative && diff.inDays <= 90;
  }

  bool get isPdf => fileType.toLowerCase() == 'pdf';
  bool get isImage => ['jpg', 'jpeg', 'png', 'heic'].contains(fileType.toLowerCase());

  DocumentEntity copyWith({
    String? id,
    String? userId,
    String? title,
    String? fileName,
    String? fileUrl,
    String? fileType,
    int? fileSize,
    String? category,
    String? folderId,
    String? thumbnailUrl,
    String? ocrText,
    String? aiSummary,
    List<String>? tags,
    String? notes,
    DateTime? expiryDate,
    DateTime? issueDate,
    String? documentNumber,
    String? issuerName,
    String? holderName,
    bool? isFavorite,
    bool? isArchived,
    bool? isShared,
    double? aiConfidenceScore,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? metadata,
  }) {
    return DocumentEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
      fileUrl: fileUrl ?? this.fileUrl,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      category: category ?? this.category,
      folderId: folderId ?? this.folderId,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      ocrText: ocrText ?? this.ocrText,
      aiSummary: aiSummary ?? this.aiSummary,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      expiryDate: expiryDate ?? this.expiryDate,
      issueDate: issueDate ?? this.issueDate,
      documentNumber: documentNumber ?? this.documentNumber,
      issuerName: issuerName ?? this.issuerName,
      holderName: holderName ?? this.holderName,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      isShared: isShared ?? this.isShared,
      aiConfidenceScore: aiConfidenceScore ?? this.aiConfidenceScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        fileName,
        fileUrl,
        fileType,
        fileSize,
        category,
        folderId,
        thumbnailUrl,
        ocrText,
        aiSummary,
        tags,
        notes,
        expiryDate,
        issueDate,
        documentNumber,
        issuerName,
        holderName,
        isFavorite,
        isArchived,
        isShared,
        aiConfidenceScore,
        createdAt,
        updatedAt,
        metadata,
      ];
}
