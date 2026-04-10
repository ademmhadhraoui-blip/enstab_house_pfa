import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:enstabhouse/models/app_user.dart';

/// Service responsible for user management operations.
///
/// Provides methods for fetching user profiles and admin-level operations
/// such as listing all users and assigning roles.
///
/// **Security note**: Role changes are enforced at the Firestore security rules
/// level. Only users with `role == 'admin'` can modify the `role` field of
/// any user document.
class UserService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');

  // ─────────────────────────────────────────────────────────────────────────
  //  READ OPERATIONS
  // ─────────────────────────────────────────────────────────────────────────

  /// Fetch a single user by their UID.
  ///
  /// Returns `null` if the document does not exist.
  Future<AppUser?> getUserById(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      return null;
    }
  }

  /// Fetch the currently authenticated user's profile.
  ///
  /// Returns `null` if no user is signed in or the document doesn't exist.
  Future<AppUser?> getCurrentUser() async {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null || firebaseUser.isAnonymous) return null;
    return getUserById(firebaseUser.uid);
  }

  /// Real-time stream of the current user's profile.
  ///
  /// Useful for keeping the UI updated when the admin changes a user's role.
  Stream<AppUser?> currentUserStream() {
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null || firebaseUser.isAnonymous) {
      return Stream.value(null);
    }
    return _usersCollection.doc(firebaseUser.uid).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    });
  }

  /// Real-time stream of all users, ordered by creation date (newest first).
  ///
  /// **Admin-only operation** — the UI must guard access, and Firestore rules
  /// enforce that non-admin users cannot list all documents in bulk.
  Stream<List<AppUser>> getAllUsers() {
    return _usersCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  ADMIN OPERATIONS
  // ─────────────────────────────────────────────────────────────────────────

  /// Update a user's role.
  ///
  /// Only admins are allowed to call this. Firestore security rules will
  /// reject the write if the caller is not an admin.
  ///
  /// [uid] — the target user's UID.
  /// [newRole] — must be one of [AppUser.validRoles].
  Future<void> updateUserRole(String uid, String newRole) async {
    assert(AppUser.validRoles.contains(newRole),
        'Invalid role: $newRole. Must be one of ${AppUser.validRoles}');
    await _usersCollection.doc(uid).update({'role': newRole});
  }

  /// Delete a user document from Firestore.
  ///
  /// **Admin-only**. This does NOT delete the Firebase Auth account — that
  /// requires the Firebase Admin SDK (server-side).
  Future<void> deleteUser(String uid) async {
    await _usersCollection.doc(uid).delete();
  }
}
