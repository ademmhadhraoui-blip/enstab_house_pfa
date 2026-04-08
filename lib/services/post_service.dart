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
}
