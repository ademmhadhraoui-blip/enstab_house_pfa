import 'package:flutter/material.dart';
import 'package:enstabhouse/constants.dart';
import 'package:enstabhouse/models/academic_document.dart';
import 'package:enstabhouse/services/document_service.dart';
import 'package:enstabhouse/screens/documents/upload_document_screen.dart';
import 'package:url_launcher/url_launcher.dart';

/// Screen displaying a searchable, filterable list of academic documents.
///
/// All authenticated users can browse documents. The upload FAB is only
/// visible to admin users (controlled by the [isAdmin] parameter).
class DocumentsScreen extends StatefulWidget {
  final bool isAdmin;

  const DocumentsScreen({super.key, this.isAdmin = false});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  final DocumentService _documentService = DocumentService();

  /// Currently selected filter: null = All
  DocumentType? _selectedFilter;

  /// Search query for local filtering
  String _searchQuery = '';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  /// Opens a document's PDF URL externally (browser or native PDF reader).
  Future<void> _openDocument(AcademicDocument doc) async {
    final uri = Uri.parse(doc.fileUrl);
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open the document')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening document: $e')),
        );
      }
    }
  }

  /// Confirm and delete a document (admin only).
  void _confirmDelete(AcademicDocument doc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('Delete Document'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${doc.title}"?\n\n'
          'This will remove the file from storage. This action is irreversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _documentService.deleteDocument(doc.id!, doc.fileUrl);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Document deleted successfully'),
                      backgroundColor: kPrimaryColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error deleting document: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Filter documents by search query.
  List<AcademicDocument> _applySearch(List<AcademicDocument> documents) {
    if (_searchQuery.isEmpty) return documents;
    final query = _searchQuery.toLowerCase();
    return documents.where((doc) {
      return doc.title.toLowerCase().contains(query) ||
          (doc.studentName?.toLowerCase().contains(query) ?? false) ||
          (doc.supervisor?.toLowerCase().contains(query) ?? false) ||
          doc.year.contains(query) ||
          doc.description.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Choose the stream based on filter
    final stream = _selectedFilter == null
        ? _documentService.getDocuments()
        : _documentService.getDocumentsByType(_selectedFilter!);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const UploadDocumentScreen(),
                  ),
                );
              },
              backgroundColor: kPrimaryColor,
              icon: const Icon(Icons.upload_file, color: Colors.white),
              label: const Text(
                'Upload',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              elevation: 4,
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: kPrimaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Academic Documents',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'PFA • PFE • Collaborations',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  // Search bar
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _searchQuery = v),
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: InputDecoration(
                      hintText: 'Search documents...',
                      hintStyle: const TextStyle(color: Colors.white70),
                      prefixIcon: const Icon(Icons.search,
                          color: Colors.white70, size: 20),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.15),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ─── Filter chips
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildFilterChip('All', null),
                    const SizedBox(width: 8),
                    _buildFilterChip('PFA', DocumentType.pfa),
                    const SizedBox(width: 8),
                    _buildFilterChip('PFE', DocumentType.pfe),
                    const SizedBox(width: 8),
                    _buildFilterChip('Collaboration', DocumentType.collaboration),
                  ],
                ),
              ),
            ),

            // ─── Document list
            Expanded(
              child: StreamBuilder<List<AcademicDocument>>(
                stream: stream,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: kPrimaryColor),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.error_outline,
                                size: 48, color: Colors.red.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'Error loading documents',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${snapshot.error}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final documents = _applySearch(snapshot.data ?? []);

                  if (documents.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.folder_open,
                              size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            'No documents found',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _searchQuery.isNotEmpty
                                ? 'Try a different search term'
                                : 'Documents will appear here once uploaded',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: documents.length,
                    itemBuilder: (context, index) {
                      return _DocumentCard(
                        document: documents[index],
                        isAdmin: widget.isAdmin,
                        onOpen: () => _openDocument(documents[index]),
                        onDelete: () => _confirmDelete(documents[index]),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, DocumentType? type) {
    final isSelected = _selectedFilter == type;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
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
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  DOCUMENT CARD
// ─────────────────────────────────────────────────────────────────────────────

class _DocumentCard extends StatelessWidget {
  final AcademicDocument document;
  final bool isAdmin;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  const _DocumentCard({
    required this.document,
    required this.isAdmin,
    required this.onOpen,
    required this.onDelete,
  });

  Color get _typeColor {
    switch (document.type) {
      case DocumentType.pfa:
        return const Color(0xFF1565C0);
      case DocumentType.pfe:
        return const Color(0xFF6A1B9A);
      case DocumentType.collaboration:
        return const Color(0xFF2E7D32);
    }
  }

  IconData get _typeIcon {
    switch (document.type) {
      case DocumentType.pfa:
        return Icons.school_outlined;
      case DocumentType.pfe:
        return Icons.workspace_premium_outlined;
      case DocumentType.collaboration:
        return Icons.handshake_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: InkWell(
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row: type badge + admin actions
              Row(
                children: [
                  // Type badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _typeColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border:
                          Border.all(color: _typeColor.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(_typeIcon, size: 13, color: _typeColor),
                        const SizedBox(width: 4),
                        Text(
                          document.type.displayLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: _typeColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Year badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      document.year,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Admin actions
                  if (isAdmin)
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (value) {
                        if (value == 'delete') onDelete();
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline,
                                  size: 20, color: Colors.red),
                              SizedBox(width: 10),
                              Text('Delete',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 10),

              // ── Title
              Text(
                document.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),

              // ── Description
              if (document.description.isNotEmpty)
                Text(
                  document.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              const SizedBox(height: 10),

              // ── Metadata row
              Wrap(
                spacing: 16,
                runSpacing: 6,
                children: [
                  if (document.studentName != null &&
                      document.studentName!.isNotEmpty)
                    _MetaChip(
                      icon: Icons.person_outline,
                      label: document.studentName!,
                    ),
                  if (document.supervisor != null &&
                      document.supervisor!.isNotEmpty)
                    _MetaChip(
                      icon: Icons.school_outlined,
                      label: document.supervisor!,
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // ── File row
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.picture_as_pdf,
                        color: Colors.red.shade700, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        document.fileName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.open_in_new,
                        size: 16, color: Colors.red.shade400),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  META CHIP
// ─────────────────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
