import 'package:cloud_firestore/cloud_firestore.dart';

/// Types of academic documents managed in the platform.
///
/// Stored in Firestore as lowercase strings: `'pfa'`, `'pfe'`, `'collaboration'`.
enum DocumentType {
  pfa,
  pfe,
  collaboration;

  /// Convert this enum value to its Firestore string representation.
  String toFirestoreString() {
    switch (this) {
      case DocumentType.pfa:
        return 'pfa';
      case DocumentType.pfe:
        return 'pfe';
      case DocumentType.collaboration:
        return 'collaboration';
    }
  }

  /// Parse a Firestore string back to a [DocumentType] enum value.
  ///
  /// Defaults to [DocumentType.pfa] if the string is unrecognized.
  static DocumentType fromFirestoreString(String? value) {
    switch (value?.toLowerCase()) {
      case 'pfe':
        return DocumentType.pfe;
      case 'collaboration':
        return DocumentType.collaboration;
      case 'pfa':
      default:
        return DocumentType.pfa;
    }
  }

  /// Human-readable display label.
  String get displayLabel {
    switch (this) {
      case DocumentType.pfa:
        return 'PFA';
      case DocumentType.pfe:
        return 'PFE';
      case DocumentType.collaboration:
        return 'Collaboration';
    }
  }
}

/// Represents an academic document stored in the platform.
///
/// Documents are uploaded by admins and stored as PDFs in Firebase Storage.
/// Metadata is persisted in the `academic_documents` Firestore collection.
///
/// [studentName] and [supervisor] are optional because collaboration
/// documents may not have a specific student or supervisor.
class AcademicDocument {
  final String? id;
  final String title;
  final DocumentType type;
  final String? studentName;
  final String? supervisor;
  final String year;
  final String description;
  final String fileUrl;
  final String fileName;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String uploadedBy;

  AcademicDocument({
    this.id,
    required this.title,
    required this.type,
    this.studentName,
    this.supervisor,
    required this.year,
    required this.description,
    required this.fileUrl,
    required this.fileName,
    required this.uploadedBy,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // ─────────────────────────────────────────────────────────────────────────
  //  SERIALIZATION
  // ─────────────────────────────────────────────────────────────────────────

  /// Convert this document to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'type': type.toFirestoreString(),
      'studentName': studentName,
      'supervisor': supervisor,
      'year': year,
      'description': description,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'uploadedBy': uploadedBy,
    };
  }

  /// Create an [AcademicDocument] from a Firestore document snapshot.
  factory AcademicDocument.fromMap(Map<String, dynamic> data, String id) {
    return AcademicDocument(
      id: id,
      title: data['title'] ?? '',
      type: DocumentType.fromFirestoreString(data['type']),
      studentName: data['studentName'],
      supervisor: data['supervisor'],
      year: data['year'] ?? '',
      description: data['description'] ?? '',
      fileUrl: data['fileUrl'] ?? '',
      fileName: data['fileName'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      uploadedBy: data['uploadedBy'] ?? '',
    );
  }

  /// Returns a copy of this document with the given fields replaced.
  AcademicDocument copyWith({
    String? id,
    String? title,
    DocumentType? type,
    String? studentName,
    String? supervisor,
    String? year,
    String? description,
    String? fileUrl,
    String? fileName,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? uploadedBy,
  }) {
    return AcademicDocument(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      studentName: studentName ?? this.studentName,
      supervisor: supervisor ?? this.supervisor,
      year: year ?? this.year,
      description: description ?? this.description,
      fileUrl: fileUrl ?? this.fileUrl,
      fileName: fileName ?? this.fileName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      uploadedBy: uploadedBy ?? this.uploadedBy,
    );
  }

  @override
  String toString() =>
      'AcademicDocument(id: $id, title: $title, type: ${type.displayLabel})';
}
