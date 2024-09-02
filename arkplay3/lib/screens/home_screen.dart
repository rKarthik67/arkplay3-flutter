import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/movie.dart';
import '../models/tv_show.dart';
import '../services/api_service.dart';
import '../widgets/movie_item.dart';
import '../widgets/tv_show_item.dart';
import '../widgets/hero_slide.dart';  // Import the HeroSlide widget

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            pinned: true,
            title: Text(
              'ARK PLAY',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            expandedHeight: 500,  // Match the height of HeroSlide
            flexibleSpace: FlexibleSpaceBar(
              background: HeroSlide(),
              title: null, // No title here, it is placed in the AppBar
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Trending Movies', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                Consumer<ApiService>(
                  builder: (context, apiService, child) {
                    return FutureBuilder<List<Movie>>(
                      future: apiService.getTrendingMovies(),
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
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Top Rated Movies', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                Consumer<ApiService>(
                  builder: (context, apiService, child) {
                    return FutureBuilder<List<Movie>>(
                      future: apiService.getTopRatedMovies(),
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
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Trending TV Shows', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                Consumer<ApiService>(
                  builder: (context, apiService, child) {
                    return FutureBuilder<List<TVShow>>(
                      future: apiService.getTrendingTVShows(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Failed to load TV shows'));
                        } else {
                          return Container(
                            height: 300,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data?.length ?? 0,
                              itemBuilder: (context, index) {
                                return TVShowItem(tvShow: snapshot.data![index]);
                              },
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Top Rated TV Shows', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ),
                Consumer<ApiService>(
                  builder: (context, apiService, child) {
                    return FutureBuilder<List<TVShow>>(
                      future: apiService.getTopRatedTVShows(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(child: Text('Failed to load TV shows'));
                        } else {
                          return Container(
                            height: 300,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: snapshot.data?.length ?? 0,
                              itemBuilder: (context, index) {
                                return TVShowItem(tvShow: snapshot.data![index]);
                              },
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
