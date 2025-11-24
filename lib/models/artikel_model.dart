class Artikel {
  String id, title, date, image, name, description;

  Artikel({
    required this.id,
    required this.title,
    required this.date,
    required this.image,
    required this.name,
    required this.description,
  });

  factory Artikel.fromJson(Map<String, dynamic> json) {
    return Artikel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      date: json['date'] ?? '',
      image: json['image'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
