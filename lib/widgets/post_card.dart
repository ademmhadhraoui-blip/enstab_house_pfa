import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enstabhouse/constants.dart';
import 'package:enstabhouse/models/post.dart';
import 'package:enstabhouse/services/post_service.dart';
import 'package:enstabhouse/widgets/create_post_sheet.dart';

/// Card widget that displays a single post in the feed.
class PostCard extends StatefulWidget {
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

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  final PostService _postService = PostService();
  late bool _isLiked;
  late int _likeCount;
  bool _isLiking = false;

  // Heart animation
  late AnimationController _heartAnimController;
  late Animation<double> _heartScaleAnim;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.currentUserId != null &&
        widget.post.likedBy.contains(widget.currentUserId);
    _likeCount = widget.post.likes;

    _heartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _heartScaleAnim = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.4), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.4, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _heartAnimController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync with latest Firestore data
    if (oldWidget.post.likes != widget.post.likes ||
        oldWidget.post.likedBy != widget.post.likedBy) {
      _isLiked = widget.currentUserId != null &&
          widget.post.likedBy.contains(widget.currentUserId);
      _likeCount = widget.post.likes;
    }
  }

  @override
  void dispose() {
    _heartAnimController.dispose();
    super.dispose();
  }

  /// Whether the current user is the author of this post.
  bool get _isOwner {
    if (widget.currentUserId == null || widget.currentUserId!.isEmpty) return false;
    if (widget.post.authorId != null &&
        widget.post.authorId!.isNotEmpty &&
        widget.post.authorId == widget.currentUserId) return true;
    if ((widget.post.authorId == null || widget.post.authorId!.isEmpty) &&
        widget.currentUserName != null &&
        widget.currentUserName!.isNotEmpty &&
        widget.post.author == widget.currentUserName) {
      return true;
    }
    return false;
  }

  bool get _canManage => _isOwner || widget.currentUserRole == 'admin';

  Future<void> _handleLike() async {
    if (widget.isVisitor || widget.currentUserId == null || widget.post.id == null) {
      if (widget.isVisitor && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Register to like posts')),
        );
      }
      return;
    }
    if (_isLiking) return;

    setState(() {
      _isLiking = true;
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
    });

    if (_isLiked) {
      _heartAnimController.forward(from: 0);
    }

    try {
      await _postService.toggleLike(widget.post.id!, widget.currentUserId!);
    } catch (_) {
      // Revert on error
      if (mounted) {
        setState(() {
          _isLiked = !_isLiked;
          _likeCount += _isLiked ? 1 : -1;
        });
      }
    } finally {
      if (mounted) setState(() => _isLiking = false);
    }
  }

  void _openComments() {
    if (widget.post.id == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CommentsSheet(
        postId: widget.post.id!,
        postService: _postService,
        currentUserId: widget.currentUserId,
        currentUserName: widget.currentUserName,
        isVisitor: widget.isVisitor,
        currentUserRole: widget.currentUserRole,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEvent = widget.post.postType == 'event';
    final isWorkshop = widget.post.postType == 'workshop';

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
                      'isVisitor': widget.isVisitor,
                      'clubName': widget.post.author,
                    });
              },
              child: Text(
                widget.post.author,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Text("${widget.post.category} · ${widget.post.timeAgo}"),
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
              widget.post.title,
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
              widget.post.description,
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
                    value: widget.post.eventDate ?? ''),
                _InfoRow(
                    icon: Icons.access_time_outlined,
                    label: 'Time',
                    value: widget.post.eventTime ?? ''),
                _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Place',
                    value: widget.post.eventPlace ?? ''),
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
                    value: widget.post.workshopTime ?? ''),
                _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'Place',
                    value: widget.post.workshopPlace ?? ''),
                _InfoRow(
                    icon: Icons.person_outline,
                    label: 'Instructor',
                    value: widget.post.workshopInstructor ?? ''),
              ],
            ),

          // ── Photos grid (event / workshop) — now loads from URLs
          if ((isEvent || isWorkshop) && widget.post.photos.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: widget.post.photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final photoUrl = widget.post.photos[index];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: photoUrl.startsWith('http')
                        ? Image.network(
                            photoUrl,
                            width: 240,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 240,
                              height: 180,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image,
                                  color: Colors.grey),
                            ),
                          )
                        : Image.asset(
                            photoUrl,
                            width: 240,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 240,
                              height: 180,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image,
                                  color: Colors.grey),
                            ),
                          ),
                  );
                },
              ),
            ),
          ],

          // ── Documents for normal posts
          if (!isEvent && !isWorkshop && widget.post.documents.isNotEmpty) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: widget.post.documents.map((filePath) {
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

          const SizedBox(height: 4),

          // ── INTERACTIVE Actions: Like & Comment
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Row(
              children: [
                // ── Like button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _handleLike,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          ScaleTransition(
                            scale: _heartScaleAnim,
                            child: Icon(
                              _isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 22,
                              color: _isLiked
                                  ? Colors.red
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '$_likeCount',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _isLiked
                                  ? Colors.red
                                  : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                // ── Comment button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _openComments,
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              size: 20, color: Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text(
                            '${widget.post.comments}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[600],
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
        authorName: widget.post.author,
        userRole: '',
        authorId: widget.currentUserId,
        existingPost: widget.post,
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
              if (widget.post.id != null) {
                await PostService().deletePost(widget.post.id!);
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
//  COMMENTS BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────

class _CommentsSheet extends StatefulWidget {
  final String postId;
  final PostService postService;
  final String? currentUserId;
  final String? currentUserName;
  final bool isVisitor;
  final String? currentUserRole;

  const _CommentsSheet({
    required this.postId,
    required this.postService,
    this.currentUserId,
    this.currentUserName,
    this.isVisitor = false,
    this.currentUserRole,
  });

  @override
  State<_CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<_CommentsSheet> {
  final TextEditingController _commentCtrl = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final text = _commentCtrl.text.trim();
    if (text.isEmpty) return;
    if (widget.currentUserId == null) return;

    setState(() => _isSending = true);

    try {
      await widget.postService.addComment(
        postId: widget.postId,
        authorId: widget.currentUserId!,
        authorName: widget.currentUserName ?? 'User',
        text: text,
      );
      _commentCtrl.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending comment: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle bar + title
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Column(
              children: [
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
                const SizedBox(height: 14),
                const Row(
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        color: kPrimaryColor, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Comments',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── Comments list
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: widget.postService.getComments(widget.postId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: kPrimaryColor),
                  );
                }

                final comments = snapshot.data ?? [];

                if (comments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          'No comments yet',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Be the first to comment!',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  itemCount: comments.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    final isOwner =
                        comment['authorId'] == widget.currentUserId;
                    final isAdmin = widget.currentUserRole == 'admin';
                    final createdAt = comment['createdAt'] as Timestamp?;
                    final time = createdAt != null
                        ? _formatTime(createdAt.toDate())
                        : '';

                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: kPrimaryColor.withValues(alpha: 0.15),
                          child: Text(
                            (comment['authorName'] as String? ?? 'U')
                                .substring(0, 1)
                                .toUpperCase(),
                            style: const TextStyle(
                              color: kPrimaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Comment body
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    comment['authorName'] ?? 'User',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                comment['text'] ?? '',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Delete button (owner or admin)
                        if (isOwner || isAdmin)
                          GestureDetector(
                            onTap: () async {
                              await widget.postService.deleteComment(
                                widget.postId,
                                comment['id'],
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Icon(Icons.close,
                                  size: 16, color: Colors.grey[400]),
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ),

          // ── Comment input
          if (!widget.isVisitor && widget.currentUserId != null) ...[
            const Divider(height: 1),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: kPrimaryColor,
                    child: Text(
                      (widget.currentUserName ?? 'U')
                          .substring(0, 1)
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _commentCtrl,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        hintStyle: TextStyle(
                            color: Colors.grey[400], fontSize: 14),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isSending ? null : _sendComment,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: kPrimaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: _isSending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.send,
                              color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Register to leave a comment',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
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
