import 'package:flutter/material.dart';
import 'package:enstabhouse/constants.dart';
import 'package:enstabhouse/models/post.dart';
import 'package:enstabhouse/services/post_service.dart';
import 'package:enstabhouse/widgets/post_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ClubMainPage extends StatefulWidget {
  const ClubMainPage({super.key});

  @override
  State<ClubMainPage> createState() => _ClubMainPageState();
}

class _ClubMainPageState extends State<ClubMainPage> {
  String selectedTab = "Feed";
  bool isVisitor = false;
  String clubName = "Club";
  final PostService _postService = PostService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map) {
      if (args['isVisitor'] == true) {
        isVisitor = true;
      }
      if (args['clubName'] != null) {
        clubName = args['clubName'] as String;
      }
    }
  }

  /// Filter posts for this club's tabs
  List<Post> _filterForTab(List<Post> clubPosts) {
    switch (selectedTab) {
      case "Events":
        return clubPosts.where((p) => p.postType == 'event').toList();
      case "Workshops":
        return clubPosts.where((p) => p.postType == 'workshop').toList();
      default:
        return clubPosts;
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
              height: 150,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: kPrimaryColor,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20, top: 20),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                            size: 35,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Text(
                            clubName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),

                    //  Chips de filtrage
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildChip("Feed"),
                        const SizedBox(width: 25),
                        _buildChip("Events"),
                        const SizedBox(width: 25),
                        _buildChip("Workshops"),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // 📄 Body dynamique — StreamBuilder from Firestore
            Expanded(
              child: StreamBuilder<List<Post>>(
                stream: _postService.getPosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: kPrimaryColor),
                    );
                  }

                  final allPosts = snapshot.data ?? [];
                  final clubPosts = allPosts
                      .where((post) => post.author == clubName)
                      .toList();
                  final tabPosts = _filterForTab(clubPosts);

                  if (tabPosts.isEmpty) {
                    return _buildEmptyState(selectedTab == "Events"
                        ? "No events yet"
                        : selectedTab == "Workshops"
                            ? "No workshops yet"
                            : "No posts yet");
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: tabPosts.length,
                    itemBuilder: (context, index) {
                      return PostCard(
                        post: tabPosts[index],
                        isVisitor: isVisitor,
                        currentUserId: FirebaseAuth.instance.currentUser?.uid,
                      );
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

  // 🔹 Construit un chip de filtrage
  Widget _buildChip(String text) {
    final bool isSelected = selectedTab == text;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = text;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? kPrimaryDarkColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}
