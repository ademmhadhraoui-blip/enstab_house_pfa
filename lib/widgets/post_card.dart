import 'dart:io';
import 'package:flutter/material.dart';
import 'package:enstabhouse/constants.dart';
import 'package:enstabhouse/models/post.dart';

/// Card widget that displays a single post in the feed.
class PostCard extends StatelessWidget {
  final Post post;
  final bool isVisitor;

  const PostCard({super.key, required this.post, this.isVisitor = false});

  @override
  Widget build(BuildContext context) {
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
            trailing: (isEvent || isWorkshop)
                ? _PostTypeBadge(
                    label: isEvent ? 'Event' : 'Workshop',
                    color: isEvent
                        ? const Color(0xFF1565C0)
                        : const Color(0xFF2E7D32),
                    icon: isEvent
                        ? Icons.event_outlined
                        : Icons.build_circle_outlined,
                  )
                : null,
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
