import 'dart:io';
import 'package:flutter/material.dart';
import 'package:enstabhouse/constants.dart';
import 'package:enstabhouse/models/post.dart';
import 'package:enstabhouse/services/post_service.dart';
import 'package:enstabhouse/widgets/create_post_sheet.dart';

/// Card widget that displays a single post in the feed.
class PostCard extends StatelessWidget {
  final Post post;
  final bool isVisitor;
  final String? currentUserId;
  final String? currentUserName;
  final String? currentUserRole;

  const PostCard({
    super.key,
    required this.post,
    this.isVisitor = false,
    this.currentUserId,
    this.currentUserName,
    this.currentUserRole,
  });

  /// Whether the current user is the author of this post.
  bool get _isOwner {
    if (currentUserId == null || currentUserId!.isEmpty) return false;
    // Match by authorId (primary check)
    if (post.authorId != null && post.authorId!.isNotEmpty && post.authorId == currentUserId) return true;
    // Fallback: match by author name for old posts without authorId
    if ((post.authorId == null || post.authorId!.isEmpty) &&
        currentUserName != null &&
        currentUserName!.isNotEmpty &&
        post.author == currentUserName) {
      return true;
    }
    return false;
  }

  /// Whether the current user can manage (edit/delete) this post.
  /// Admins can manage ALL posts; owners can manage their own.
  bool get _canManage => _isOwner || currentUserRole == 'admin';

  @override
  Widget build(BuildContext context) {
    // DEBUG: uncomment to diagnose ownership issues
    // debugPrint('PostCard: author=${post.author}, authorId=${post.authorId}, currentUserId=$currentUserId, userName=$currentUserName, isOwner=$_isOwner');
    
    final isEvent = post.postType == 'event';
    final isWorkshop = post.postType == 'workshop';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: kPrimaryColor,
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/club',
                    arguments: {
                      'isVisitor': isVisitor,
                      'clubName': post.author,
                    });
              },
              child: Text(
                post.author,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Text("${post.category} · ${post.timeAgo}"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isEvent || isWorkshop)
                  _PostTypeBadge(
                    label: isEvent ? 'Event' : 'Workshop',
                    color: isEvent
                        ? const Color(0xFF1565C0)
                        : const Color(0xFF2E7D32),
                    icon: isEvent
                        ? Icons.event_outlined
                        : Icons.build_circle_outlined,
                  ),
                if (_canManage)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _openEditSheet(context);
                      } else if (value == 'delete') {
                        _confirmDelete(context);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20, color: kPrimaryColor),
                            SizedBox(width: 10),
                            Text('Modify'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 20, color: Colors.red),
                            SizedBox(width: 10),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // ── Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // ── Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.description,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          const SizedBox(height: 10),

          // ── Event info box
          if (isEvent)
            _InfoBox(
              color: const Color(0xFF1565C0),
              children: [
                _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: post.eventDate ?? ''),
                _InfoRow(
                    icon: Icons.access_time_outlined,
                    label: 'Time',
                    value: post.eventTime ?? ''),
                _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Place',
                    value: post.eventPlace ?? ''),
              ],
            ),

          // ── Workshop info box
          if (isWorkshop)
            _InfoBox(
              color: const Color(0xFF2E7D32),
              children: [
                _InfoRow(
                    icon: Icons.access_time_outlined,
                    label: 'Time',
                    value: post.workshopTime ?? ''),
                _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Place',
                    value: post.workshopPlace ?? ''),
                _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Instructor',
                    value: post.workshopInstructor ?? ''),
              ],
            ),

          // ── Photos grid (event / workshop)
          if ((isEvent || isWorkshop) && post.photos.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: post.photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(post.photos[index]),
                      width: 240,
                      height: 180,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
            ),
          ],

          // ── Documents for normal posts
          if (!isEvent && !isWorkshop && post.documents.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: post.documents.map((filePath) {
                  final fileName =
                      filePath.split('/').last.split('\\').last;
                  final ext = fileName.split('.').last.toLowerCase();
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(_getDocIcon(ext),
                            color: _getDocColor(ext), size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            fileName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          ext.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          const SizedBox(height: 12),

          // ── Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.favorite_border, size: 20),
                const SizedBox(width: 4),
                Text("${post.likes}"),
                const SizedBox(width: 16),
                const Icon(Icons.comment_outlined, size: 20),
                const SizedBox(width: 4),
                Text("${post.comments}"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Open edit bottom sheet
  void _openEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreatePostSheet(
        authorName: post.author,
        userRole: '',
        authorId: currentUserId,
        existingPost: post,
      ),
    );
  }

  // ── Confirm delete dialog
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('Delete post'),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this post  ?\n this action is irreversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (post.id != null) {
                await PostService().deletePost(post.id!);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Post deleted successfully.'),
                      backgroundColor: kPrimaryColor,
                    ),
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

  static IconData _getDocIcon(String ext) {
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

  static Color _getDocColor(String ext) {
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
}

// ─────────────────────────────────────────────────────────────────────────────
//  POST TYPE BADGE
// ─────────────────────────────────────────────────────────────────────────────
class _PostTypeBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;

  const _PostTypeBadge({
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  INFO BOX
// ─────────────────────────────────────────────────────────────────────────────
class _InfoBox extends StatelessWidget {
  final Color color;
  final List<Widget> children;

  const _InfoBox({required this.color, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(children: children),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  INFO ROW
// ─────────────────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 15, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
