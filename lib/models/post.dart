import 'package:cloud_firestore/cloud_firestore.dart';

/// Modèle de données pour une publication (post) du feed
class Post {
  final String? id;
  final String? authorId;
  final String author;
  final String category;
  final String time;
  final String title;
  final String description;
  final int likes;
  final int comments;

  // Post type: 'normal', 'event', 'workshop'
  final String postType;

  // Event-specific fields
  final String? eventDate;
  final String? eventTime;
  final String? eventPlace;

  // Workshop-specific fields
  final String? workshopTime;
  final String? workshopPlace;
  final String? workshopInstructor;

  // Photos paths (for event / workshop posts)
  final List<String> photos;

  // Document paths (for normal posts)
  final List<String> documents;

  // User IDs who liked this post
  final List<String> likedBy;

  // Timestamp for ordering
  final DateTime createdAt;

  Post({
    this.id,
    this.authorId,
    required this.author,
    required this.category,
    required this.time,
    required this.title,
    required this.description,
    required this.likes,
    required this.comments,
    this.postType = 'normal',
    this.eventDate,
    this.eventTime,
    this.eventPlace,
    this.workshopTime,
    this.workshopPlace,
    this.workshopInstructor,
    this.photos = const [],
    this.documents = const [],
    this.likedBy = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Convert Post to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'authorId': authorId,
      'author': author,
      'category': category,
      'time': time,
      'title': title,
      'description': description,
      'likes': likes,
      'comments': comments,
      'postType': postType,
      'eventDate': eventDate,
      'eventTime': eventTime,
      'eventPlace': eventPlace,
      'workshopTime': workshopTime,
      'workshopPlace': workshopPlace,
      'workshopInstructor': workshopInstructor,
      'photos': photos,
      'documents': documents,
      'likedBy': likedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Create a Post from a Firestore document snapshot.
  factory Post.fromMap(Map<String, dynamic> data, String id) {
    return Post(
      id: id,
      authorId: data['authorId'],
      author: data['author'] ?? '',
      category: data['category'] ?? '',
      time: data['time'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      postType: data['postType'] ?? 'normal',
      eventDate: data['eventDate'],
      eventTime: data['eventTime'],
      eventPlace: data['eventPlace'],
      workshopTime: data['workshopTime'],
      workshopPlace: data['workshopPlace'],
      workshopInstructor: data['workshopInstructor'],
      photos: List<String>.from(data['photos'] ?? []),
      documents: List<String>.from(data['documents'] ?? []),
      likedBy: List<String>.from(data['likedBy'] ?? []),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Returns a copy of this Post with the given fields replaced.
  Post copyWith({
    String? id,
    String? authorId,
    String? author,
    String? category,
    String? time,
    String? title,
    String? description,
    int? likes,
    int? comments,
    String? postType,
    String? eventDate,
    String? eventTime,
    String? eventPlace,
    String? workshopTime,
    String? workshopPlace,
    String? workshopInstructor,
    List<String>? photos,
    List<String>? documents,
    List<String>? likedBy,
    DateTime? createdAt,
  }) {
    return Post(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      author: author ?? this.author,
      category: category ?? this.category,
      time: time ?? this.time,
      title: title ?? this.title,
      description: description ?? this.description,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      postType: postType ?? this.postType,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      eventPlace: eventPlace ?? this.eventPlace,
      workshopTime: workshopTime ?? this.workshopTime,
      workshopPlace: workshopPlace ?? this.workshopPlace,
      workshopInstructor: workshopInstructor ?? this.workshopInstructor,
      photos: photos ?? this.photos,
      documents: documents ?? this.documents,
      likedBy: likedBy ?? this.likedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return ' ${difference.inHours} h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} j ago';
    } else {
      return '${(difference.inDays / 7).floor()} w ago';
    }
  }
}
