import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:enstabhouse/constants.dart';
import 'package:enstabhouse/models/post.dart';
import 'package:enstabhouse/screens/settings/account_settings_screen.dart';
import 'package:enstabhouse/screens/settings/help_support_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});


  static const List<Post> posts = [
    Post(
      author: "Photography Club",
      category: "Clubs",
      time: "2h",
      title: "Annual Photography Exhibition 2026",
      description: "Join us for our biggest exhibition yet!",
      likes: 234,
      comments: 45,
    ),
    Post(
      author: "Office of the Registrar",
      category: "Admin",
      time: "4h",
      title: "Spring Semester Registration Opens",
      description: "Registration for Spring 2026 courses is now open.",
      likes: 120,
      comments: 30,
    ),
    Post(
      author: "Electronix",
      category: "Clubs",
      time: "3h",
      title: "Recruiting",
      description: "We are recruiting new members",
      likes: 120,
      comments: 20,
    ),
    Post(
      author: "ACM",
      category: "Clubs",
      time: "4h",
      title: "Bootcamp",
      description: "Introduction to AI",
      likes: 50,
      comments: 10,
    ),
    Post(
      author: "Professor Bilel",
      category: "Professors",
      time: "4h",
      title: "java course",
      description: "Here you find java course",
      likes: 20,
      comments: 10,
    ),
    Post(
      author: "Ahmed Ahmed",
      category: "Fundraising",
      time: "8h",
      title: "university decoration",
      description: "we need your help to decorate our university",
      likes: 20,
      comments: 10,
    ),
  ];

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {


  String selectedCategory = 'All';
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final _auth = FirebaseAuth.instance ;

  void  getCurrentUser() async {
    final user = await _auth.currentUser ;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<Post> get filteredPosts {
    if (selectedCategory == 'All') {
      return HomeFeedScreen.posts;
    }
    return HomeFeedScreen.posts
        .where((post) => post.category == selectedCategory)
        .toList();
  }

  void _openMenuOverlay(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Menu",
      barrierColor: Colors.black.withValues(alpha: 0.4),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            // 🔴 Header
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
                    // 🔍 SEARCH MODE: full-width text field
                        ? Row(
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
                              hintStyle: const TextStyle(
                                color: Colors.white70,
                              ),
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
                    )
                    //  NORMAL MODE: title + icons
                        : Row(
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
                            setState(() {
                              isSearching = true;
                            });
                          },
                          child: const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            // NOTIFICATIONS
                          },
                          child: const Icon(
                            Icons.notifications,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            showGeneralDialog(
                              context: context,
                              barrierDismissible: true,
                              barrierLabel: 'Menu',
                              barrierColor: Colors.transparent,
                              transitionDuration: const Duration(milliseconds: 300),
                              pageBuilder: (context, _, __) => const MenuOverlay(),
                              transitionBuilder: (context, animation, _, child) {
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
                          },
                          child: const Icon(
                            Icons.menu,
                            color: Colors.white,
                            size: 30.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Campus Community",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            // 🟡 Filters
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

            // 📄 Feed list
            Expanded(
              child: ListView.builder(
                itemCount: filteredPosts.length,
                itemBuilder: (context, index) {
                  return PostCard(post: filteredPosts[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Helper pour construire un chip de filtre (évite la répétition)
  Widget _buildFilterChip(String category) {
    return FilterChipWidget(
      text: category,
      selected: selectedCategory == category,
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
    );
  }
}

//
// 🟡 FILTER CHIP
//
class FilterChipWidget extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const FilterChipWidget({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? kPrimaryColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

//
// 📄 POST CARD
//
class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
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
          // Header
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: kPrimaryColor,
              child: Icon(Icons.camera_alt, color: Colors.white),
            ),
            title: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/club');
              },
              child: Text(
                post.author,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            subtitle: Text("${post.category} · ${post.time}"),
          ),

          // Title
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

          const SizedBox(height: 8),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              post.description,
              style: const TextStyle(color: Colors.black54),
            ),
          ),

          const SizedBox(height: 12),

          // Image placeholder
          Container(
            height: 180,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
          ),

          const SizedBox(height: 12),

          // Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite_border),
                    const SizedBox(width: 4),
                    Text("${post.likes}"),
                    const SizedBox(width: 16),
                    const Icon(Icons.comment_outlined),
                    const SizedBox(width: 4),
                    Text("${post.comments}"),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

//
// 📋 MENU OVERLAY
//
class MenuOverlay extends StatelessWidget {
  const MenuOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 🫧 Left 15% — blurred background
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: MediaQuery.of(context).size.width * 0.15,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: Container(
                color: Colors.black.withValues(alpha: 0.35),
              ),
            ),
          ),
        ),

        // 📋 Right 85% — menu panel
        Align(
          alignment: Alignment.centerRight,
          child: FractionallySizedBox(
            widthFactor: 0.85,
            child: Material(
              color: Colors.white,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
                      decoration: const BoxDecoration(color: kPrimaryColor),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "My Account",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Menu items
                    const SizedBox(height: 8),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.settings_outlined,
                      label: "Account Settings",
                      destination: const AccountSettingsScreen(),
                    ),
                    _buildMenuItem(
                      context: context,
                      icon: Icons.help_outline,
                      label: "Help & Support",
                      destination: const HelpSupportScreen(),
                    ),

                    const Divider(height: 32, indent: 16, endIndent: 16),

                    // 🚪 Log Out
                    ListTile(
                      leading: const Icon(Icons.logout, color: kPrimaryColor),
                      title: const Text(
                        "Log Out",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: kPrimaryColor,
                        ),
                      ),
                      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
                      onTap: () {
                        // Fermer le menu et vider toute la pile de navigation
                        // puis aller au login screen
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/login',
                          (route) => false, // supprime toutes les routes
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    Color color = Colors.black87,
    required Widget destination,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => destination),
        );
      },
    );
  }
}
