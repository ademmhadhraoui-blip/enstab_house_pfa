import 'dart:io';
import 'package:flutter/material.dart';
import 'package:enstabhouse/constants.dart';
import 'package:enstabhouse/models/post.dart';
import 'package:enstabhouse/services/post_service.dart';
import 'package:enstabhouse/services/cloudinary_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// Bottom sheet for creating or editing a post (normal / event / workshop).
class CreatePostSheet extends StatefulWidget {
  final String authorName;
  final String userRole;
  final String? authorId;
  final ValueChanged<Post>? onPostCreated;
  final Post? existingPost;

  const CreatePostSheet({
    super.key,
    required this.authorName,
    required this.userRole,
    this.authorId,
    this.onPostCreated,
    this.existingPost,
  });

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  String _postType = 'normal';
  bool _isSubmitting = false;

  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // Event fields
  final _eventDateCtrl = TextEditingController();
  final _eventTimeCtrl = TextEditingController();
  final _eventPlaceCtrl = TextEditingController();

  // Workshop fields
  final _wsTimeCtrl = TextEditingController();
  final _wsPlaceCtrl = TextEditingController();
  final _wsInstructorCtrl = TextEditingController();

  // Photos (for event / workshop)
  final List<File> _selectedPhotos = [];

  // Documents (for normal posts)
  final List<File> _selectedDocuments = [];

  final ImagePicker _imagePicker = ImagePicker();
  final PostService _postService = PostService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  bool get _isEditing => widget.existingPost != null;

  @override
  void initState() {
    super.initState();
    // Pre-fill fields if editing an existing post
    final ep = widget.existingPost;
    if (ep != null) {
      _postType = ep.postType;
      _titleCtrl.text = ep.title;
      _descCtrl.text = ep.description;
      _eventDateCtrl.text = ep.eventDate ?? '';
      _eventTimeCtrl.text = ep.eventTime ?? '';
      _eventPlaceCtrl.text = ep.eventPlace ?? '';
      _wsTimeCtrl.text = ep.workshopTime ?? '';
      _wsPlaceCtrl.text = ep.workshopPlace ?? '';
      _wsInstructorCtrl.text = ep.workshopInstructor ?? '';
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _eventDateCtrl.dispose();
    _eventTimeCtrl.dispose();
    _eventPlaceCtrl.dispose();
    _wsTimeCtrl.dispose();
    _wsPlaceCtrl.dispose();
    _wsInstructorCtrl.dispose();
    super.dispose();
  }

  String get _categoryForRole {
    switch (widget.userRole) {
      case 'professor':
        return 'Professors';
      case 'club':
        return 'Clubs';
      case 'administration':
        return 'Admin';
      case 'admin':
        return 'Admin';
      default:
        return 'General';
    }
  }

  // ── PICK PHOTOS
  Future<void> _pickPhotos() async {
    _showImageSourceDialog();
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Add Photos',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt, color: kPrimaryColor),
                ),
                title: const Text('Take a Photo'),
                subtitle: const Text('Use your camera',
                    style: TextStyle(fontSize: 12)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final granted = await _requestPermission(Permission.camera);
                  if (!granted) return;
                  final image = await _imagePicker.pickImage(
                      source: ImageSource.camera);
                  if (image != null) {
                    setState(() {
                      _selectedPhotos.add(File(image.path));
                    });
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.photo_library, color: kPrimaryColor),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Pick multiple photos',
                    style: TextStyle(fontSize: 12)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final granted = await _requestPermission(Permission.photos);
                  if (!granted) return;
                  final images = await _imagePicker.pickMultiImage();
                  if (images.isNotEmpty) {
                    setState(() {
                      _selectedPhotos
                          .addAll(images.map((i) => File(i.path)));
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── PICK DOCUMENTS
  Future<void> _pickDocuments() async {
    final granted = await _requestPermission(Permission.storage);
    if (!granted) return;
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: [
        'pdf', 'doc', 'docx', 'ppt', 'pptx', 'xls', 'xlsx', 'txt'
      ],
    );
    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _selectedDocuments.addAll(
          result.paths.where((p) => p != null).map((p) => File(p!)),
        );
      });
    }
  }

  /// Request a runtime permission and show a dialog if permanently denied.
  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isGranted || status.isLimited) return true;

    if (status.isPermanentlyDenied && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.security, color: kPrimaryColor, size: 24),
              SizedBox(width: 10),
              Text('Permission Required'),
            ],
          ),
          content: const Text(
            'This permission is required to continue. '
            'Please enable it in your device settings.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: kPrimaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Open Settings',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
    return false;
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty || _descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in title and description.')),
      );
      return;
    }
    if (_postType == 'event') {
      if (_eventDateCtrl.text.trim().isEmpty ||
          _eventTimeCtrl.text.trim().isEmpty ||
          _eventPlaceCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all event details.')),
        );
        return;
      }
    }
    if (_postType == 'workshop') {
      if (_wsTimeCtrl.text.trim().isEmpty ||
          _wsPlaceCtrl.text.trim().isEmpty ||
          _wsInstructorCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please fill in all workshop details.')),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);

    try {
      // ── Upload files to Cloudinary before saving
      List<String> photoUrls = [];
      List<String> documentUrls = [];

      if (_postType == 'event' || _postType == 'workshop') {
        for (final photo in _selectedPhotos) {
          final fileName = photo.path.split('/').last.split('\\').last;
          final url = await _cloudinaryService.uploadFile(
            photo,
            fileName,
            folder: 'posts/photos',
          );
          photoUrls.add(url);
        }
      }

      if (_postType == 'normal') {
        for (final doc in _selectedDocuments) {
          final fileName = doc.path.split('/').last.split('\\').last;
          final url = await _cloudinaryService.uploadFile(
            doc,
            fileName,
            folder: 'posts/documents',
          );
          documentUrls.add(url);
        }
      }

      if (_isEditing) {
        // ── UPDATE existing post
        final updated = widget.existingPost!.copyWith(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          postType: _postType,
          eventDate: _postType == 'event' ? _eventDateCtrl.text.trim() : null,
          eventTime: _postType == 'event' ? _eventTimeCtrl.text.trim() : null,
          eventPlace: _postType == 'event' ? _eventPlaceCtrl.text.trim() : null,
          workshopTime:
              _postType == 'workshop' ? _wsTimeCtrl.text.trim() : null,
          workshopPlace:
              _postType == 'workshop' ? _wsPlaceCtrl.text.trim() : null,
          workshopInstructor:
              _postType == 'workshop' ? _wsInstructorCtrl.text.trim() : null,
          photos: photoUrls.isNotEmpty
              ? photoUrls
              : widget.existingPost!.photos,
          documents: documentUrls.isNotEmpty
              ? documentUrls
              : widget.existingPost!.documents,
        );

        await _postService.updatePost(updated);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post modified successfully'),
              backgroundColor: kPrimaryColor,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        // ── CREATE new post
        final post = Post(
          authorId: widget.authorId,
          author: widget.authorName,
          category: _categoryForRole,
          time: '',
          createdAt: DateTime.now(),
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          likes: 0,
          comments: 0,
          postType: _postType,
          eventDate: _postType == 'event' ? _eventDateCtrl.text.trim() : null,
          eventTime: _postType == 'event' ? _eventTimeCtrl.text.trim() : null,
          eventPlace: _postType == 'event' ? _eventPlaceCtrl.text.trim() : null,
          workshopTime:
              _postType == 'workshop' ? _wsTimeCtrl.text.trim() : null,
          workshopPlace:
              _postType == 'workshop' ? _wsPlaceCtrl.text.trim() : null,
          workshopInstructor:
              _postType == 'workshop' ? _wsInstructorCtrl.text.trim() : null,
          photos: photoUrls,
          documents: documentUrls,
        );

        await _postService.addPost(post);
        widget.onPostCreated?.call(post);
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── Author row
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: kPrimaryColor,
                  child: Text(
                    widget.authorName.isNotEmpty
                        ? widget.authorName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.authorName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      _categoryForRole,
                      style: const TextStyle(
                        color: kPrimaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── POST TYPE SELECTOR
            _sectionLabel('POST TYPE'),
            const SizedBox(height: 10),
            Row(
              children: [
                _TypeChip(
                  label: 'Normal',
                  icon: Icons.article_outlined,
                  selected: _postType == 'normal',
                  onTap: () => setState(() {
                    _postType = 'normal';
                    _selectedPhotos.clear();
                  }),
                ),
                const SizedBox(width: 10),
                _TypeChip(
                  label: 'Event',
                  icon: Icons.event_outlined,
                  selected: _postType == 'event',
                  onTap: () => setState(() {
                    _postType = 'event';
                    _selectedDocuments.clear();
                  }),
                ),
                const SizedBox(width: 10),
                _TypeChip(
                  label: 'Workshop',
                  icon: Icons.build_outlined,
                  selected: _postType == 'workshop',
                  onTap: () => setState(() {
                    _postType = 'workshop';
                    _selectedDocuments.clear();
                  }),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Common fields
            _buildField(
              controller: _titleCtrl,
              label: 'Title',
              hint: 'Enter post title',
              icon: Icons.title,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _descCtrl,
              label: 'Description',
              hint: 'Write something...',
              icon: Icons.description_outlined,
              maxLines: 3,
            ),

            // ── EVENT FIELDS
            if (_postType == 'event') ...[
              const SizedBox(height: 20),
              _sectionLabel('EVENT DETAILS'),
              const SizedBox(height: 10),
              _buildField(
                controller: _eventDateCtrl,
                label: 'Date',
                hint: 'e.g. 25 March 2026',
                icon: Icons.calendar_today_outlined,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _eventTimeCtrl,
                label: 'Time',
                hint: 'e.g. 14:00',
                icon: Icons.access_time_outlined,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _eventPlaceCtrl,
                label: 'Place',
                hint: 'e.g. Main Hall, ENSTAB',
                icon: Icons.location_on_outlined,
              ),
            ],

            // ── WORKSHOP FIELDS
            if (_postType == 'workshop') ...[
              const SizedBox(height: 20),
              _sectionLabel('WORKSHOP DETAILS'),
              const SizedBox(height: 10),
              _buildField(
                controller: _wsTimeCtrl,
                label: 'Time',
                hint: 'e.g. 10:00',
                icon: Icons.access_time_outlined,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _wsPlaceCtrl,
                label: 'Place',
                hint: 'e.g. Lab 3, Building B',
                icon: Icons.location_on_outlined,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _wsInstructorCtrl,
                label: 'Instructor',
                hint: 'e.g. Prof. John Doe',
                icon: Icons.person_outline,
              ),
            ],

            // ── PHOTO PICKER (for event / workshop)
            if (_postType == 'event' || _postType == 'workshop') ...[
              const SizedBox(height: 20),
              _sectionLabel('PHOTOS'),
              const SizedBox(height: 10),
              // Photo grid preview
              if (_selectedPhotos.isNotEmpty) ...[
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedPhotos.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              _selectedPhotos[index],
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPhotos.removeAt(index);
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
              // Add photo button
              GestureDetector(
                onTap: _pickPhotos,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: kPrimaryColor.withValues(alpha: 0.3),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate_outlined,
                          color: kPrimaryColor, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        _selectedPhotos.isEmpty
                            ? 'Add Photos'
                            : 'Add More Photos',
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
            ],

            // ── DOCUMENT PICKER (for normal posts)
            if (_postType == 'normal') ...[
              const SizedBox(height: 20),
              _sectionLabel('DOCUMENTS'),
              const SizedBox(height: 10),
              // Document list preview
              if (_selectedDocuments.isNotEmpty) ...[
                ...List.generate(_selectedDocuments.length, (index) {
                  final file = _selectedDocuments[index];
                  final fileName =
                      file.path.split('/').last.split('\\').last;
                  final ext = fileName.split('.').last.toLowerCase();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: _docColor(ext).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            _docIcon(ext),
                            color: _docColor(ext),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                ext.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedDocuments.removeAt(index);
                            });
                          },
                          child: Icon(Icons.close,
                              color: Colors.grey[400], size: 18),
                        ),
                      ],
                    ),
                  );
                }),
              ],
              // Add document button
              GestureDetector(
                onTap: _pickDocuments,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.blue.shade200,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.attach_file,
                          color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _selectedDocuments.isEmpty
                            ? 'Attach Documents'
                            : 'Attach More Documents',
                        style: TextStyle(
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 24),

            // ── Submit button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        _isEditing ? 'Modify post ' : 'Publish Post',
                        style: const TextStyle(
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

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
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
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }

  Color _docColor(String ext) {
    switch (ext) {
      case 'pdf':
        return Colors.red.shade700;
      case 'doc':
      case 'docx':
        return Colors.blue.shade700;
      case 'ppt':
      case 'pptx':
        return Colors.orange.shade700;
      case 'xls':
      case 'xlsx':
        return Colors.green.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  IconData _docIcon(String ext) {
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      default:
        return Icons.insert_drive_file;
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  POST TYPE CHIP
// ─────────────────────────────────────────────────────────────────────────────
class _TypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? kPrimaryColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? kPrimaryColor : Colors.grey.shade300,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: kPrimaryColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: selected ? Colors.white : Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.grey[700],
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
