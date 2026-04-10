import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:enstabhouse/models/academic_document.dart';

/// Service responsible for academic document management.
///
/// Handles:
/// - Uploading PDF files to Firebase Storage
/// - Storing/retrieving document metadata in Firestore
/// - Filtering documents by type
/// - Deleting documents (both metadata and storage file)
///
/// **Security note**: All write operations (create, update, delete) are
/// restricted to admin users via Firestore security rules. Read access
/// is available to all authenticated users.
class DocumentService {
  final CollectionReference _documentsCollection =
      FirebaseFirestore.instance.collection('academic_documents');

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // ─────────────────────────────────────────────────────────────────────────
  //  FIREBASE STORAGE — PDF UPLOAD
  // ─────────────────────────────────────────────────────────────────────────

  /// Upload a PDF file to Firebase Storage.
  ///
  /// Files are stored under `documents/{timestamp}_{fileName}` to avoid
  /// naming collisions. Returns the public download URL.
  ///
  /// [file] — the local PDF file to upload.
  /// [fileName] — the original file name for the storage path.
  ///
  /// Throws a [FirebaseException] if upload fails.
  Future<String> uploadPdf(File file, String fileName) async {
    // Create a unique path with timestamp to prevent collisions
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath = 'documents/${timestamp}_$fileName';

    final ref = _storage.ref().child(storagePath);

    // Upload with metadata indicating PDF content type
    final uploadTask = ref.putFile(
      file,
      SettableMetadata(contentType: 'application/pdf'),
    );

    // Wait for upload to complete
    final snapshot = await uploadTask;

    // Return the download URL
    return await snapshot.ref.getDownloadURL();
  }

  /// Upload a PDF file with progress tracking.
  ///
  /// Returns an [UploadTask] that can be listened to for progress updates.
  /// After completion, call [UploadTask.snapshot.ref.getDownloadURL()] to
  /// get the download URL.
  UploadTask uploadPdfWithProgress(File file, String fileName) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final storagePath = 'documents/${timestamp}_$fileName';

    final ref = _storage.ref().child(storagePath);

    return ref.putFile(
      file,
      SettableMetadata(contentType: 'application/pdf'),
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

  /// Delete an academic document — removes both the Firestore metadata
  /// and the file from Firebase Storage.
  ///
  /// **Admin-only** — enforced by Firestore rules.
  ///
  /// [docId] — the Firestore document ID.
  /// [fileUrl] — the Firebase Storage download URL of the file to delete.
  Future<void> deleteDocument(String docId, String fileUrl) async {
    // Delete the file from Storage
    try {
      final ref = _storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (_) {
      // If the file is already deleted or URL is invalid, continue
      // with deleting the Firestore metadata
    }

    // Delete the metadata from Firestore
    await _documentsCollection.doc(docId).delete();
  }
}
