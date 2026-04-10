import 'dart:io';
import 'package:flutter/material.dart';
import 'package:enstabhouse/constants.dart';
import 'package:enstabhouse/models/academic_document.dart';
import 'package:enstabhouse/services/document_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';

/// Screen for uploading a new academic document (PDF).
///
/// **Admin-only** — this screen should only be navigated to by admin users.
/// Firestore security rules will also reject writes from non-admin users.
class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final DocumentService _documentService = DocumentService();

  // Form controllers
  final _titleCtrl = TextEditingController();
  final _studentNameCtrl = TextEditingController();
  final _supervisorCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  DocumentType _selectedType = DocumentType.pfa;
  File? _selectedFile;
  String? _selectedFileName;

  bool _isUploading = false;
  double _uploadProgress = 0;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _studentNameCtrl.dispose();
    _supervisorCtrl.dispose();
    _yearCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  /// Pick a PDF file from the device.
  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.single.path;
      if (path != null) {
        setState(() {
          _selectedFile = File(path);
          _selectedFileName = result.files.single.name;
        });
      }
    }
  }

  /// Upload the document: PDF to Storage → metadata to Firestore.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a PDF file')),
      );
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0;
    });

    try {
      // Upload PDF with progress tracking
      final uploadTask = _documentService.uploadPdfWithProgress(
        _selectedFile!,
        _selectedFileName!,
      );

      // Listen to upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        if (mounted) {
          setState(() {
            _uploadProgress =
                snapshot.bytesTransferred / snapshot.totalBytes;
          });
        }
      });

      // Wait for upload to complete
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Create the document metadata
      final document = AcademicDocument(
        title: _titleCtrl.text.trim(),
        type: _selectedType,
        studentName: _studentNameCtrl.text.trim().isNotEmpty
            ? _studentNameCtrl.text.trim()
            : null,
        supervisor: _supervisorCtrl.text.trim().isNotEmpty
            ? _supervisorCtrl.text.trim()
            : null,
        year: _yearCtrl.text.trim(),
        description: _descCtrl.text.trim(),
        fileUrl: downloadUrl,
        fileName: _selectedFileName!,
        uploadedBy: FirebaseAuth.instance.currentUser?.uid ?? '',
      );

      // Save metadata to Firestore
      await _documentService.addDocument(document);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document uploaded successfully ✓'),
            backgroundColor: kPrimaryColor,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading document: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _uploadProgress = 0;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: kPrimaryColor,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Upload Document',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Admin — Add a new academic document',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Document type selector
                      _sectionLabel('DOCUMENT TYPE'),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildTypeChip(DocumentType.pfa),
                          const SizedBox(width: 10),
                          _buildTypeChip(DocumentType.pfe),
                          const SizedBox(width: 10),
                          _buildTypeChip(DocumentType.collaboration),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // ── Title
                      _buildFormField(
                        controller: _titleCtrl,
                        label: 'Title',
                        hint: 'e.g. Étude de systèmes embarqués',
                        icon: Icons.title,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),

                      // ── Student name (optional)
                      _buildFormField(
                        controller: _studentNameCtrl,
                        label: 'Student Name (optional)',
                        hint: 'e.g. Ahmed Ben Ali',
                        icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 14),

                      // ── Supervisor (optional)
                      _buildFormField(
                        controller: _supervisorCtrl,
                        label: 'Supervisor (optional)',
                        hint: 'e.g. Prof. Fatma Trabelsi',
                        icon: Icons.school_outlined,
                      ),
                      const SizedBox(height: 14),

                      // ── Year
                      _buildFormField(
                        controller: _yearCtrl,
                        label: 'Academic Year',
                        hint: 'e.g. 2025-2026',
                        icon: Icons.calendar_today_outlined,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),

                      // ── Description
                      _buildFormField(
                        controller: _descCtrl,
                        label: 'Description',
                        hint: 'Brief description of the document...',
                        icon: Icons.description_outlined,
                        maxLines: 3,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null,
                      ),
                      const SizedBox(height: 20),

                      // ── PDF picker
                      _sectionLabel('PDF FILE'),
                      const SizedBox(height: 10),

                      if (_selectedFile != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border:
                                Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.picture_as_pdf,
                                  color: Colors.red.shade700, size: 22),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _selectedFileName ?? 'Selected file',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade700,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => setState(() {
                                  _selectedFile = null;
                                  _selectedFileName = null;
                                }),
                                child: Icon(Icons.close,
                                    color: Colors.red.shade400, size: 18),
                              ),
                            ],
                          ),
                        ),

                      GestureDetector(
                        onTap: _pickFile,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 18),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: kPrimaryColor.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.upload_file_outlined,
                                  color: kPrimaryColor, size: 22),
                              const SizedBox(width: 8),
                              Text(
                                _selectedFile == null
                                    ? 'Select PDF File'
                                    : 'Change PDF File',
                                style: const TextStyle(
                                  color: kPrimaryColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Upload progress indicator
                      if (_isUploading) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: _uploadProgress,
                            backgroundColor: Colors.grey.shade200,
                            color: kPrimaryColor,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Uploading: ${(_uploadProgress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ── Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isUploading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: kPrimaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _isUploading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Upload Document',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTypeChip(DocumentType type) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedType = type),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? kPrimaryColor : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? kPrimaryColor : Colors.grey.shade300,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: kPrimaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              type.displayLabel,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: kPrimaryColor, size: 20),
        labelStyle: const TextStyle(color: Colors.grey),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: kPrimaryColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
