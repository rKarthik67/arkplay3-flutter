class Season {
  final int id;
  final String posterPath;
  final int seasonNumber;

  Season({
    required this.id,
    required this.posterPath,
    required this.seasonNumber,
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id'],
      posterPath: json['poster_path'],
      seasonNumber: json['season_number'],
    );
  }
}
