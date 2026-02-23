/// Modèle de données pour un workshop de club
class Workshop {
  final String name;
  final String description;
  final String time;
  final String place;
  final String instructor;

  const Workshop({
    required this.name,
    required this.description,
    required this.time,
    required this.place,
    required this.instructor,
  });
}
