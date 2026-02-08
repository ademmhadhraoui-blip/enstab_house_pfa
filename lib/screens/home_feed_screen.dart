import 'package:flutter/material.dart';

class HomeFeedScreen extends StatelessWidget {
  const HomeFeedScreen({super.key});

  // 🔹 Fake posts (simulation des publications utilisateurs)
  static final List<Post> posts = [
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
      category: "Administration",
      time: "4h",
      title: "Spring Semester Registration Opens",
      description: "Registration for Spring 2026 courses is now open.",
      likes: 120,
      comments: 30,
    ),
  ];

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
              color: Color(0xFF9E0815),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:  [
                  Row(
                    children: [
                      Text(
                        "University News",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 60.0,) ,
                      GestureDetector(
                        onTap: () {
                          //SEARCH
                        },
                        child: Icon(Icons.search ,
                          color: Colors.white ,
                          size: 30,
                        ),
                      ) ,
                      SizedBox(width: 30.0) ,
                      GestureDetector(
                        onTap: (){
                          //NOTIFICATIONS
                        },
                        child: Icon(Icons.notifications ,
                        color: Colors.white,
                        size: 30,),
                      ) ,
                      SizedBox(width: 30.0) ,
                      GestureDetector(
                        onTap: (){
                          //MENU
                        },
                        child: Icon(Icons.menu ,
                        color: Colors.white,
                        size: 30.0,
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    "Campus Community",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            // 🟡 Filters
            Padding(
              padding: const EdgeInsets.all(16),
              child: Expanded(
                child: SizedBox(
                  height: 40.0,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: const [
                      FilterChipWidget(text: "All", selected: true),
                      SizedBox(width: 8),
                      FilterChipWidget(text: "Clubs", selected: false),
                      SizedBox(width: 8),
                      FilterChipWidget(text: "Admin", selected: false),
                      SizedBox( width: 8.0,) ,
                      FilterChipWidget(text: "Professors", selected: false) ,
                      SizedBox(width: 8.0,) ,
                      FilterChipWidget(text: "Fundraising", selected: false) ,
                      SizedBox(width: 8.0,) ,
                      FilterChipWidget(text: "Press", selected: false) ,
                      SizedBox(width: 8.0,) ,
                      FilterChipWidget(text: "Alumini", selected: false)


                    ],
                  ),
                ),
              ),
            ),

            // 📄 Feed list
            Expanded(
              child: ListView.builder(
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  return PostCard(post: posts[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//
// 🔹 MODEL POST
//
class Post {
  final String author;
  final String category;
  final String time;
  final String title;
  final String description;
  final int likes;
  final int comments;

  Post({
    required this.author,
    required this.category,
    required this.time,
    required this.title,
    required this.description,
    required this.likes,
    required this.comments,
  });
}

//
// 🟡 FILTER CHIP
//
class FilterChipWidget extends StatelessWidget {
  final String text;
  final bool selected;

  const FilterChipWidget({
    super.key,
    required this.text,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? Color(0xFF9E0815) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: selected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

//
// 📄 POST CARD (DYNAMIQUE)
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
            color: Colors.black.withOpacity(0.05),
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
              backgroundColor: Color(0xFF9E0815),
              child: Icon(Icons.camera_alt, color: Colors.white),
            ),
            title: Text(
              post.author,
              style: const TextStyle(fontWeight: FontWeight.bold),
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
                const Icon(Icons.share_outlined),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
