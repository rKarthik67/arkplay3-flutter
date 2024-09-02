import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class DummyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dummy Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoPlayerScreen(),
              ),
            );
          },
          child: Text('Play Video'),
        ),
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  String videoUrl = '';

  @override
  void initState() {
    super.initState();
    final apiService = Provider.of<ApiService>(context, listen: false);
    apiService.extractVideoUrl('https://multiembed.mov/?video_id=1399&tmdb=1&s=1&e=1').then((url) {
      setState(() {
        print("url: $url");
        videoUrl = url;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
      ),
      body: videoUrl.isNotEmpty
          ? BetterPlayer.network(
              videoUrl,
              betterPlayerConfiguration: BetterPlayerConfiguration(
                aspectRatio: 16 / 9,
                fit: BoxFit.contain,
              ),
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}