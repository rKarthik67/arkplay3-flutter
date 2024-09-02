import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart'; // Import url_launcher
import '../models/movie.dart';
import '../models/cast.dart';
import '../services/api_service.dart';

class MovieDetailScreen extends StatelessWidget {
  final Movie movie;

  MovieDetailScreen({required this.movie});

  void _launchURL(BuildContext context, String url) async {
    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        print('Could not launch $url');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not launch $url'),
        ));
      }
    } catch (e) {
      print('Error launching URL: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error launching URL'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Image.network(
            'https://image.tmdb.org/t/p/original${movie.backdropPath}',
            fit: BoxFit.cover,
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
              ],
            ),
          ),
        ),
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 300),
                Text(
                  movie.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Colors.white),
                ),
                SizedBox(height: 16),
                Text(
                  'Overview:',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  movie.overview,
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        final movieId = movie.id;
                        final urls = [
                          'https://vidsrc.xyz/embed/movie/$movieId',
                          'https://multiembed.mov/directstream.php?video_id=$movieId&tmdb=1',
                          'https://multiembed.mov/?video_id=$movieId&tmdb=1',
                          'https://moviesapi.club/movie/$movieId',
                          'https://player.smashy.stream/movie/$movieId',
                        ];
                        _launchURL(context, urls[0]);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 239, 11, 11),
                      ),
                      child: Text('Play'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Added to Watchlist'),
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                      ),
                      child: Text('Watchlist'),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Text(
                  'Cast:',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white),
                ),
                SizedBox(height: 8),
                FutureBuilder<List<Cast>>(
                  future: Provider.of<ApiService>(context, listen: false).getMovieCast(movie.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Failed to load cast'));
                    } else {
                      final cast = snapshot.data ?? [];
                      return SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: cast.length,
                          itemBuilder: (context, index) {
                            final actor = cast[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  CircleAvatar(
                                    radius: 50,
                                    backgroundImage: NetworkImage(
                                      actor.profilePath.isNotEmpty
                                          ? 'https://image.tmdb.org/t/p/w200${actor.profilePath}'
                                          : 'https://via.placeholder.com/100',
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    actor.name,
                                    style: TextStyle(fontSize: 12, color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                  Text(
                                    'as ${actor.character}',
                                    style: TextStyle(fontSize: 10, color: Colors.grey),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
