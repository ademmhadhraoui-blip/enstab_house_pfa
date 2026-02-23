/// Modèle de données pour une publication (post) du feed
class Post {
  final String author;
  final String category;
  final String time;
  final String title;
  final String description;
  final int likes;
  final int comments;

  const Post({
    required this.author,
    required this.category,
    required this.time,
    required this.title,
    required this.description,
    required this.likes,
    required this.comments,
  });
}
