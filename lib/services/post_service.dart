import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enstabhouse/models/post.dart';

/// Service responsable de la gestion des posts dans Firestore.
class PostService {
  final CollectionReference _postsCollection =
      FirebaseFirestore.instance.collection('posts');

  /// Ajoute un nouveau post dans Firestore.
  Future<void> addPost(Post post) async {
    await _postsCollection.add(post.toMap());
  }

  /// Retourne un stream temps réel de tous les posts, triés par date décroissante.
  Stream<List<Post>> getPosts() {
    return _postsCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Post.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// Retourne un stream de posts filtrés par catégorie.
  Stream<List<Post>> getPostsByCategory(String category) {
    return _postsCollection
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return Post.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  /// Met à jour un post existant dans Firestore.
  Future<void> updatePost(Post post) async {
    if (post.id == null) return;
    await _postsCollection.doc(post.id).update(post.toMap());
  }

  /// Supprime un post par son ID Firestore.
  Future<void> deletePost(String postId) async {
    await _postsCollection.doc(postId).delete();
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  LIKES
  // ─────────────────────────────────────────────────────────────────────────

  /// Toggle like: add or remove the user's UID from the `likedBy` array.
  ///
  /// Uses atomic arrayUnion / arrayRemove so concurrent likes don't collide.
  /// Also updates the `likes` counter for display.
  Future<bool> toggleLike(String postId, String userId) async {
    final docRef = _postsCollection.doc(postId);
    final doc = await docRef.get();
    if (!doc.exists) return false;

    final data = doc.data() as Map<String, dynamic>;
    final likedBy = List<String>.from(data['likedBy'] ?? []);
    final isLiked = likedBy.contains(userId);

    if (isLiked) {
      // Unlike
      await docRef.update({
        'likedBy': FieldValue.arrayRemove([userId]),
        'likes': FieldValue.increment(-1),
      });
      return false; // now unliked
    } else {
      // Like
      await docRef.update({
        'likedBy': FieldValue.arrayUnion([userId]),
        'likes': FieldValue.increment(1),
      });
      return true; // now liked
    }
  }

  /// Check if a user has already liked a post.
  Future<bool> hasLiked(String postId, String userId) async {
    final doc = await _postsCollection.doc(postId).get();
    if (!doc.exists) return false;
    final data = doc.data() as Map<String, dynamic>;
    final likedBy = List<String>.from(data['likedBy'] ?? []);
    return likedBy.contains(userId);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  COMMENTS
  // ─────────────────────────────────────────────────────────────────────────

  /// Add a comment to a post.
  ///
  /// Comments are stored in a subcollection: `posts/{postId}/comments`.
  /// Also increments the `comments` counter on the post document.
  Future<void> addComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String text,
  }) async {
    final commentData = {
      'authorId': authorId,
      'authorName': authorName,
      'text': text,
      'createdAt': Timestamp.fromDate(DateTime.now()),
    };

    // Add comment to subcollection
    await _postsCollection.doc(postId).collection('comments').add(commentData);

    // Increment counter on the post
    await _postsCollection.doc(postId).update({
      'comments': FieldValue.increment(1),
    });
  }

  /// Real-time stream of comments for a specific post, newest first.
  Stream<List<Map<String, dynamic>>> getComments(String postId) {
    return _postsCollection
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  /// Delete a comment (by its author or an admin).
  ///
  /// Also decrements the `comments` counter on the post document.
  Future<void> deleteComment(String postId, String commentId) async {
    await _postsCollection
        .doc(postId)
        .collection('comments')
        .doc(commentId)
        .delete();

    await _postsCollection.doc(postId).update({
      'comments': FieldValue.increment(-1),
    });
  }
}
