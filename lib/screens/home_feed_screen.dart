import 'package:enstabhouse/screens/club_main_page/club_workshops.dart';
import 'package:flutter/material.dart';
import 'package:enstabhouse/screens/club_main_page/club_events.dart';


class HomeFeedScreen extends StatefulWidget {
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
        comments: 20
    ) ,
    Post(author: "ACM",
        category: "Clubs",
        time: "4h",
        title: "Bootcamp",
        description:"Introduction to AI" ,
        likes: 50,
        comments: 10,
    ),
    Post(author: "Professor Bilel",
        category: "Professors",
        time: "4h", title: "java course ",
        description: "Here you find java course ",
        likes: 20,
        comments: 10 ,
    ) ,
    Post(author: " Ahmed Ahmed ",
        category: "Fundraising",
        time: "8h",
        title: "university decoration  ",
        description: "we need your help to decorate our university",
        likes: 20,
        comments: 10,
    ),
  ];

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  String SelectedCategory = 'All' ;
  List<Post> SelectedList(){
      if(SelectedCategory == 'All'){
        return HomeFeedScreen.posts;
      } return HomeFeedScreen.posts
          .where((post) => post.category == SelectedCategory)
          .toList();

  }
  void _openMenuOverlay(context){
    showGeneralDialog(context: context,
      barrierDismissible: true ,
      barrierLabel: "Menu" ,
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 300) ,
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

    ) ;
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
                          // Navigator.push(context, MaterialPageRoute(builder: (context)=>ClubsPages()) ) ;
                          //MENU
                          // _openMenuOverlay(context) ;
                          Navigator.push(context, MaterialPageRoute(builder: (context) =>ClubWorkshops())) ;
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
              child: SizedBox(
                height: 40.0,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children:  [
                    FilterChipWidget(text: "All", selected: SelectedCategory =="All" , onTap:(){
                      setState(() {
                        SelectedCategory = 'All' ;
                      });
                    }
                    ),
                    SizedBox(width: 8),
                    FilterChipWidget(text: "Clubs", selected: SelectedCategory == 'Clubs' , onTap: (){
                      setState(() {
                        SelectedCategory = 'Clubs' ;
                      });
                      },
                    ),
                    SizedBox(width: 8),
                    FilterChipWidget(text: "Admin", selected: SelectedCategory == 'Admin' , onTap: (){
                      setState(() {
                        SelectedCategory ='Admin' ;
                      });
                    },
                    ),
                    SizedBox( width: 8.0,) ,
                    FilterChipWidget(text: "Professors", selected: SelectedCategory == 'Professors' , onTap: (){
                      setState(() {
                        SelectedCategory = 'Professors' ;
                      });
                    },
                    ) ,
                    SizedBox(width: 8.0,) ,
                    FilterChipWidget(text: "Fundraising", selected: SelectedCategory == 'Fundraising' , onTap: (){
                      setState(() {
                        SelectedCategory = 'Fundraising' ;
                      });
                    },
                    ) ,
                    SizedBox(width: 8.0,) ,
                    FilterChipWidget(text: "Press", selected: SelectedCategory == 'Press' , onTap: (){
                     setState(() {
                       SelectedCategory= 'Press' ;
                     });
                    },
                    ) ,
                    SizedBox(width: 8.0,) ,
                    FilterChipWidget(text: "Alumini", selected: SelectedCategory == 'Alumini' , onTap: (){
                      setState(() {
                        SelectedCategory= 'Alumini' ;
                      });
                    },
                    )
                  ],
                ),
              ),
            ),

            // 📄 Feed list
            Expanded(
              child: ListView.builder(
                itemCount: SelectedList().length,
                itemBuilder: (context, index) {
                  return PostCard(post:SelectedList()[index]);
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
  final VoidCallback onTap;


  const FilterChipWidget({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap ,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        onTap() ;
      },
      child: Container(
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class MenuOverlay extends StatelessWidget {
  const MenuOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
        child:  FractionallySizedBox(
        widthFactor: 0.85,
        child: Material(
          color: Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: const BoxDecoration(
                    color: Color(0xFF9E0815),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20 , top: 20),
                    child: const Text(
                      "My account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0,) ,

                Align(
                  alignment: AlignmentGeometry.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("Personal Information" ,
                    style: TextStyle(
                      color: Colors.blueGrey ,
                      fontSize: 23,
                    ),
                    ),
                  ),
                ) ,
                SizedBox(height: 20.0,) ,
                Container(
                  height: 60,
                  width: 300,
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(15) ,
                  ),
                )
              ],
            ),
          ),
        ),
        ),
        );

  }
}



