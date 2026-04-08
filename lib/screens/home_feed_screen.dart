import 'package:flutter/material.dart';
import 'package:enstabhouse/constants.dart';
import 'package:enstabhouse/models/post.dart';
import 'package:enstabhouse/services/post_service.dart';
import 'package:enstabhouse/widgets/post_card.dart';
import 'package:enstabhouse/widgets/filter_chip_widget.dart';
import 'package:enstabhouse/widgets/create_post_sheet.dart';
import 'package:enstabhouse/widgets/menu_overlay.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  String selectedCategory = 'All';
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final _auth = FirebaseAuth.instance;
  final PostService _postService = PostService();

  // User role and name loaded from Firestore
  String? _userRole;
  String? _userName;

  bool get isVisitor => _auth.currentUser?.isAnonymous ?? false;

  bool get _canPost {
    if (isVisitor || _userRole == null) return false;
    return _userRole == 'professor' ||
        _userRole == 'club' ||
        _userRole == 'administration';
  }

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final user = _auth.currentUser;
    if (user == null || user.isAnonymous) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          _userRole = (doc.data()?['role'] as String?)?.toLowerCase();
          _userName = doc.data()?['name'] as String?;
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openMenuOverlay(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Menu",
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const MenuOverlay();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  void _openCreatePost() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CreatePostSheet(
        authorName: _userName ??
            _auth.currentUser?.displayName ??
            'User',
        userRole: _userRole ?? '',
      ),
    );
  }

  /// Filters a list of posts based on current category and visitor status.
  List<Post> _filterPosts(List<Post> posts) {
    if (isVisitor) {
      return posts.where((post) => post.category == 'Clubs').toList();
    }
    if (selectedCategory == 'All') return posts;
    return posts.where((post) => post.category == selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: _canPost
          ? FloatingActionButton.extended(
              onPressed: _openCreatePost,
              backgroundColor: kPrimaryColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'New Post',
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isSearching
                        ? _buildSearchBar()
                        : _buildHeaderRow(),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Campus Community",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            // ─── Filters — hidden for visitors
            if (!isVisitor)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 40.0,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip("All"),
                      const SizedBox(width: 8),
                      _buildFilterChip("Clubs"),
                      const SizedBox(width: 8),
                      _buildFilterChip("Admin"),
                      const SizedBox(width: 8),
                      _buildFilterChip("Professors"),
                      const SizedBox(width: 8),
                      _buildFilterChip("Fundraising"),
                      const SizedBox(width: 8),
                      _buildFilterChip("Press"),
                      const SizedBox(width: 8),
                      _buildFilterChip("Alumni"),
                    ],
                  ),
                ),
              ),

            // ─── Visitor banner
            if (isVisitor)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  border: Border.all(color: Colors.orange.shade200),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.orange.shade700, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You are browsing as a visitor. Register to access all features.',
                        style: TextStyle(
                            color: Colors.orange.shade800, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            // ─── Feed list (StreamBuilder from Firestore)
            Expanded(
              child: StreamBuilder<List<Post>>(
                stream: _postService.getPosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
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
                              'Error loading posts',
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

                  final posts = snapshot.data ?? [];
                  final filteredPosts = _filterPosts(posts);

                  if (filteredPosts.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.article_outlined,
                              size: 48, color: Colors.grey[400]),
                          const SizedBox(height: 12),
                          Text(
                            'No posts yet',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Be the first to share something!',
                            style: TextStyle(
                                fontSize: 13, color: Colors.grey[500]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      return PostCard(
                          post: filteredPosts[index], isVisitor: isVisitor);
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

  // ── Search mode header
  Widget _buildSearchBar() {
    return Row(
      key: const ValueKey('search'),
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              isSearching = false;
              _searchController.clear();
            });
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            size: 28,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            cursorColor: Colors.white,
            decoration: InputDecoration(
              hintText: 'Search here...',
              hintStyle: const TextStyle(color: Colors.white70),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.2),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Normal mode header
  Widget _buildHeaderRow() {
    return Row(
      key: const ValueKey('normal'),
      children: [
        const Text(
          "University News",
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            setState(() => isSearching = true);
          },
          child: const Icon(Icons.search, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: () {
            // NOTIFICATIONS
          },
          child: const Icon(Icons.notifications,
              color: Colors.white, size: 30),
        ),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: () => _openMenuOverlay(context),
          child: const Icon(Icons.menu, color: Colors.white, size: 30.0),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String category) {
    return FilterChipWidget(
      text: category,
      selected: selectedCategory == category,
      onTap: () => setState(() => selectedCategory = category),
    );
  }
}
