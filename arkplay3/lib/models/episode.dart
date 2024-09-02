class Episode {
  final int id;
  final String name;
  final int episodeNumber;
  final String stillPath;
  final String overview;

  Episode({
    required this.id,
    required this.episodeNumber,
    required this.stillPath,
    required this.name,
    required this.overview,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id'],
      name: json['name'],
      episodeNumber: json['episode_number'],
      overview: json['overview'],
      stillPath: json['still_path'] ?? '',
    );
  }
}
