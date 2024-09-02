import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';
import '../models/tv_show.dart';
import '../models/cast.dart';
import '../models/season.dart';
import '../models/episode.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class ApiService {
  static const String _apiKey = '5a917d25f7c40ac92b4317c99a46600d';
  static const String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Movie>> getTrendingMovies() async {
    final response = await http.get(Uri.parse('$_baseUrl/trending/movie/week?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }

  Future<List<Movie>> getTopRatedMovies() async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/top_rated?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }

  Future<List<Movie>> getLatestMovies() async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/upcoming?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }

  Future<List<Movie>> getBoxOfficeMovies() async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/popular?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'];
      return results.map((movie) => Movie.fromJson(movie)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    final response = await http.get(Uri.parse('$_baseUrl/movie/$movieId/credits?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['cast'];
      return results.map((castMember) => Cast.fromJson(castMember)).toList();
    } else {
      throw Exception('Failed to load cast');
    }
  }

  Future<List<TVShow>> getTrendingTVShows() async {
    final response = await http.get(Uri.parse('$_baseUrl/trending/tv/week?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'];
      return results.map((show) => TVShow.fromJson(show)).toList();
    } else {
      throw Exception('Failed to load TV shows');
    }
  }

  Future<List<TVShow>> getTopRatedTVShows() async {
    final response = await http.get(Uri.parse('$_baseUrl/tv/top_rated?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'];
      return results.map((show) => TVShow.fromJson(show)).toList();
    } else {
      throw Exception('Failed to load TV shows');
    }
  }

  Future<List<TVShow>> getPopularTVShows() async {
    final response = await http.get(Uri.parse('$_baseUrl/tv/popular?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'];
      return results.map((show) => TVShow.fromJson(show)).toList();
    } else {
      throw Exception('Failed to load TV shows');
    }
  }

  Future<List<TVShow>> getUpcomingTVShows() async {
    final response = await http.get(Uri.parse('$_baseUrl/tv/airing_today?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['results'];
      return results.map((show) => TVShow.fromJson(show)).toList();
    } else {
      throw Exception('Failed to load TV shows');
    }
  }

  Future<List<Season>> getTVShowSeasons(int tvShowId) async {
    final response = await http.get(Uri.parse('$_baseUrl/tv/$tvShowId?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['seasons'];
      return results.map((season) => Season.fromJson(season)).toList();
    } else {
      throw Exception('Failed to load seasons');
    }
  }

  Future<List<Cast>> getTVShowCast(int tvShowId) async {
    final response = await http.get(Uri.parse('$_baseUrl/tv/$tvShowId/credits?api_key=$_apiKey'));
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['cast'];
      return results.map((castMember) => Cast.fromJson(castMember)).toList();
    } else {
      throw Exception('Failed to load cast');
    }
  }

  Future<List<Episode>> getSeasonEpisodes(int tvShowId, int seasonId) async {
    final response = await http.get(Uri.parse('$_baseUrl/tv/$tvShowId/season/$seasonId?api_key=$_apiKey'));
    print("response in api_service: ${response.body}");
    if (response.statusCode == 200) {
      final List results = json.decode(response.body)['episodes'];
      return results.map((episode) => Episode.fromJson(episode)).toList();
    } else {
      throw Exception('Failed to load episodes');
    }
  }

  Future<List<dynamic>> search(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl/search/multi?api_key=$_apiKey&query=$query'));
    // print("response in api_service: ${response.body}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print("response in api_service search querry: ${data['results']}");
      return data['results'];
    } else {
      throw Exception('Failed to load search results');
    }
  }
  

  

  Future<String> extractVideoUrl(String iframeUrl) async {
  final response = await http.get(Uri.parse(iframeUrl));
  print("response body of extractvideourl: ${response.body}");
  if (response.statusCode == 200) {
    var document = parser.parse(response.body);
    var iframeElement = document.querySelector('iframe#player_iframe');
    if (iframeElement != null) {
      var iframeSrc = iframeElement.attributes['src'];
      print("iframeSrc response: ${iframeSrc}");
      if (iframeSrc != null) {
        return iframeSrc;
      }
    }
  }
  return '';
}

  Future<String> fetchVideoUrlFromIframe(String iframeSrc) async {
    final iframeResponse = await http.get(Uri.parse(iframeSrc));
    print("response body of fetchVideoUrlFromIframe: ${iframeResponse.body}");
    if (iframeResponse.statusCode == 200) {
      var iframeDocument = parser.parse(iframeResponse.body);
      var videoElement = iframeDocument.querySelector('video');
      print("videoElement response: ${videoElement}");
      if (videoElement != null) {
        var videoSrc = videoElement.attributes['src'];
        return videoSrc ?? '';
      }
    }
    return '';
  }

}
