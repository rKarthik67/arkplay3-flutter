import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/tv_show.dart';
import '../screens/tv_show_detail_screen.dart';  // Import the detail screen

class TVShowItem extends StatelessWidget {
  final TVShow tvShow;

  TVShowItem({required this.tvShow});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TVShowDetailScreen(tvShow: tvShow),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,  // Center align the entire column
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0), // Adjust the radius as needed
              child: CachedNetworkImage(
                imageUrl: 'https://image.tmdb.org/t/p/w500${tvShow.posterPath}',
                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
                height: 220,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 8),
            Center(
              child: Text(
                tvShow.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,  // Center the text
              ),
            ),
            SizedBox(height: 4),
            Center(
              child: Text(
                'Rating: ${tvShow.voteAverage}',
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,  // Center the text
              ),
            ),
          ],
        ),
      ),
    );
  }
}
