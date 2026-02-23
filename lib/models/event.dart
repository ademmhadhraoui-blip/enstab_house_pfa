/// Modèle de données pour un événement de club
class Event {
  final String name;
  final String description;
  final String date;
  final String place;
  final String time;

  const Event({
    required this.name,
    required this.description,
    required this.date,
    required this.place,
    required this.time,
  });
}
