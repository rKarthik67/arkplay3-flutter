import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/movie_item.dart'; // Import movie item widget
import '../models/movie.dart'; // Ensure you have the Movie class defined and imported

class MoviesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Movies'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // Implement genre filtering
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Trending Movies', context, (apiService) => apiService.getTrendingMovies()),
            _buildSection('Latest Releases', context, (apiService) => apiService.getLatestMovies()),
            _buildSection('Box Office', context, (apiService) => apiService.getBoxOfficeMovies()),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, BuildContext context, Future<List<Movie>> Function(ApiService) fetchFunction) {
    final apiService = Provider.of<ApiService>(context);

    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          FutureBuilder<List<Movie>>(
            future: fetchFunction(apiService),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Failed to load movies'));
              } else {
                return Container(
                  height: 300,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: snapshot.data?.length ?? 0,
                    itemBuilder: (context, index) {
                      return MovieItem(movie: snapshot.data![index]);
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
