import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../widgets/tv_show_item.dart'; // Import TV show item widget
import '../models/tv_show.dart'; // Import TV show model class

class TVShowsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final apiService = Provider.of<ApiService>(context); // Access ApiService using Provider

    return Scaffold(
      appBar: AppBar(
        title: Text('TV Shows'),
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
            _buildSection('Trending TV Shows', context, apiService.getTrendingTVShows),
            _buildSection('IMDB: Popular TV Shows', context, apiService.getPopularTVShows),
            _buildSection('Upcoming TV Shows', context, apiService.getUpcomingTVShows),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, BuildContext context, Future<List<TVShow>> Function() fetchFunction) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Consumer<ApiService>(
            builder: (context, apiService, child) {
              return FutureBuilder<List<TVShow>>(
                future: fetchFunction(),
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
    );
  }
}
