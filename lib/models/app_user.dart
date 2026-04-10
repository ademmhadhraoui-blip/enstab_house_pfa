import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user in the ENSTAB House platform.
///
/// Each user has a role that determines their permissions:
/// - `student`        — read-only access, cannot post or manage documents
/// - `professor`      — can create posts in the Professors category
/// - `club`           — can create posts in the Clubs category
/// - `administration` — can create posts in the Admin category
/// - `admin`          — full system control: manage users, posts, documents
///
/// **Admin creation policy**: Admin users are NOT created through self-registration.
/// They must be manually set in the Firestore Console by updating the `role`
/// field of an existing user document to `'admin'`.
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String phone;
  final DateTime createdAt;

  /// All valid role values in the system.
  static const List<String> validRoles = [
    'student',
    'professor',
    'club',
    'administration',
    'admin',
  ];

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.createdAt,
  });

  // ─────────────────────────────────────────────────────────────────────────
  //  ROLE CHECKS
  // ─────────────────────────────────────────────────────────────────────────

  /// Whether this user has the admin role.
  bool get isAdmin => role == 'admin';

  /// Whether this user is a student.
  bool get isStudent => role == 'student';

  /// Whether this user is allowed to create posts.
  bool get canPost =>
      role == 'professor' ||
      role == 'club' ||
      role == 'administration' ||
      role == 'admin';

  /// Whether this user can edit/delete ANY post (not just their own).
  bool get canManageAllPosts => isAdmin;

  /// Whether this user can upload/update/delete academic documents.
  bool get canManageDocuments => isAdmin;

  /// Whether this user can assign roles to other users.
  bool get canAssignRoles => isAdmin;

  // ─────────────────────────────────────────────────────────────────────────
  //  SERIALIZATION
  // ─────────────────────────────────────────────────────────────────────────

  /// Convert this user to a Firestore-compatible map.
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'phone': phone,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  /// Create an [AppUser] from a Firestore document snapshot.
  factory AppUser.fromMap(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: (data['role'] as String?)?.toLowerCase() ?? 'student',
      phone: data['phone'] ?? '',
      createdAt: data['created_at'] != null
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// Returns a copy of this user with the given fields replaced.
  AppUser copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? phone,
    DateTime? createdAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Human-readable role name (capitalized).
  String get displayRole {
    if (role.isEmpty) return '';
    return role[0].toUpperCase() + role.substring(1);
  }

  @override
  String toString() => 'AppUser(uid: $uid, name: $name, role: $role)';
}
