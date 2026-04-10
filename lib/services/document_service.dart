import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enstabhouse/models/academic_document.dart';
import 'package:enstabhouse/services/cloudinary_service.dart';

/// Service responsible for academic document management.
///
/// Handles:
/// - Uploading PDF files to Cloudinary
/// - Storing/retrieving document metadata in Firestore
/// - Filtering documents by type
/// - Deleting documents (metadata only — Cloudinary unsigned presets
///   do not support client-side deletion)
///
/// **Security note**: All write operations (create, update, delete) are
/// restricted to admin users via Firestore security rules. Read access
/// is available to all authenticated users.
class DocumentService {
  final CollectionReference _documentsCollection =
      FirebaseFirestore.instance.collection('academic_documents');

  final CloudinaryService _cloudinary = CloudinaryService();

  // ─────────────────────────────────────────────────────────────────────────
  //  CLOUDINARY — PDF UPLOAD
  // ─────────────────────────────────────────────────────────────────────────

  /// Upload a PDF file to Cloudinary.
  ///
  /// Files are stored under the `documents` folder in Cloudinary.
  /// Returns the public `secure_url`.
  ///
  /// [file] — the local PDF file to upload.
  /// [fileName] — the original file name.
  ///
  /// Throws an [Exception] if upload fails.
  Future<String> uploadPdf(File file, String fileName) async {
    return await _cloudinary.uploadFile(file, fileName, folder: 'documents');
  }

  /// Upload a PDF file with progress tracking.
  ///
  /// [onProgress] receives a value between 0.0 and 1.0.
  /// Returns the `secure_url` of the uploaded file.
  Future<String> uploadPdfWithProgress(
    File file,
    String fileName, {
    void Function(double progress)? onProgress,
  }) async {
    return await _cloudinary.uploadFileWithProgress(
      file,
      fileName,
      folder: 'documents',
      onProgress: onProgress,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  FIRESTORE — CRUD OPERATIONS
  // ─────────────────────────────────────────────────────────────────────────

  /// Add a new academic document to Firestore.
  ///
  /// The [doc] must have a valid [fileUrl] (from [uploadPdf]).
  /// **Admin-only** — enforced by Firestore rules.
  Future<void> addDocument(AcademicDocument doc) async {
    await _documentsCollection.add(doc.toMap());
  }

  /// Real-time stream of all academic documents, ordered by creation date
  /// (newest first).
  Stream<List<AcademicDocument>> getDocuments() {
    return _documentsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AcademicDocument.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  /// Real-time stream of documents filtered by [DocumentType].
  Stream<List<AcademicDocument>> getDocumentsByType(DocumentType type) {
    return _documentsCollection
        .where('type', isEqualTo: type.toFirestoreString())
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AcademicDocument.fromMap(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
      }).toList();
    });
  }

  /// Update an existing academic document's metadata.
  ///
  /// **Admin-only** — enforced by Firestore rules.
  Future<void> updateDocument(AcademicDocument doc) async {
    if (doc.id == null) return;
    // Always set updatedAt when modifying
    final data = doc.toMap();
    data['updatedAt'] = Timestamp.fromDate(DateTime.now());
    await _documentsCollection.doc(doc.id).update(data);
  }

  /// Delete an academic document — removes the Firestore metadata.
  ///
  /// Note: Cloudinary files uploaded via unsigned presets cannot be deleted
  /// from the client. Use the Cloudinary dashboard or Admin API (server-side)
  /// to clean up orphaned files if needed.
  ///
  /// **Admin-only** — enforced by Firestore rules.
  ///
  /// [docId] — the Firestore document ID.
  /// [fileUrl] — kept for API compatibility (no longer used for deletion).
  Future<void> deleteDocument(String docId, String fileUrl) async {
    // Delete the metadata from Firestore
    await _documentsCollection.doc(docId).delete();
  }
}
