import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart'; // Import your ApiService here
import 'dart:async';
import 'movie_detail_screen.dart'; // Import your MovieDetailScreen
import 'tv_show_detail_screen.dart'; // Import your TVShowDetailScreen
import '../models/movie.dart';
import '../models/tv_show.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class Debouncer {
  final int milliseconds;
  VoidCallback? action;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';
  final Debouncer _debouncer = Debouncer(milliseconds: 300);

  Future<void> _search(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _searchResults = [];
    });

    final apiService = Provider.of<ApiService>(context, listen: false);

    try {
      final results = await apiService.search(query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
        _isLoading = false;
      });
      print('Search error: $e'); // Log the error for debugging
    }
  }

  void _onResultTap(dynamic item) {
    final String mediaType = item['media_type'] ?? 'unknown';

    if (mediaType == 'movie') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MovieDetailScreen(
            movie: Movie.fromJson(item), // Create a Movie object from JSON
          ),
        ),
      );
    } else if (mediaType == 'tv') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TVShowDetailScreen(
            tvShow: TVShow.fromJson(item), // Create a TVShow object from JSON
          ),
        ),
      );
    }
  }

  Widget _buildResultItem(dynamic item) {
    final String title = item['title'] ?? item['name'] ?? 'Unknown';
    final String posterPath = item['poster_path'] ?? item['profile_path'] ?? '';
    final String mediaType = item['media_type'] ?? 'unknown';
    final String overview = item['overview'] ?? 'No overview available';

    return GestureDetector(
      onTap: () => _onResultTap(item),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: posterPath.isNotEmpty
                  ? Image.network(
                      'https://image.tmdb.org/t/p/w500${posterPath}',
                      width: 160,
                      height: 220,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 160,
                          height: 220,
                          color: Colors.grey,
                          child: Icon(Icons.error, color: Colors.white),
                        );
                      },
                    )
                  : Container(
                      width: 160,
                      height: 220,
                      color: Colors.grey,
                      child: Icon(Icons.movie, color: Colors.white),
                    ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    mediaType.toUpperCase(),
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    overview,
                    style: TextStyle(color: Colors.white),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search'),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Movies and TV Shows',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (query) {
                _debouncer.run(() => _search(query));
              },
            ),
          ),
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage.isNotEmpty
                    ? Center(child: Text(_errorMessage))
                    : _searchResults.isEmpty
                        ? Center(child: Text('No results found.'))
                        : ListView.builder(
                            itemCount: _searchResults.length,
                            itemBuilder: (context, index) {
                              return _buildResultItem(_searchResults[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
