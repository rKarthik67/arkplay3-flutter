import '../models/season.dart'; // Ensure this import path is correct

class TVShow {
  final int id;
  final String name; // Use 'name' for the title of the TV show
  final String overview;
  final String posterPath;
  final String backdropPath;
  final double voteAverage;
  final List<Season> seasons; // Include the seasons list

  TVShow({
    required this.id,
    required this.name, // Use 'name' for the title of the TV show
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.seasons, // Include the seasons list
  });

  factory TVShow.fromJson(Map<String, dynamic> json) {
    var seasonList = json['seasons'] as List? ?? []; // Handle null values
    List<Season> seasons = seasonList.map((i) => Season.fromJson(i)).toList();

    return TVShow(
      id: json['id'],
      name: json['name'],
      overview: json['overview'],
      posterPath: json['poster_path'],
      backdropPath: json['backdrop_path'],
      voteAverage: (json['vote_average'] as num).toDouble(), // Ensure proper type conversion
      seasons: seasons, // Include the seasons list
    );
  }
}
