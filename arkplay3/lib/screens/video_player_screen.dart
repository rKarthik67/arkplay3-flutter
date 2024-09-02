import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'dart:convert';

class VideoPlayerScreen extends StatefulWidget {
  final List<String> serverUrls;

  VideoPlayerScreen({required this.serverUrls});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late BetterPlayerController _betterPlayerController;
  int _currentServerIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    for (int i = 0; i < widget.serverUrls.length; i++) {
      try {
        String videoUrl = await _extractVideoUrl(widget.serverUrls[i]);
        _setupPlayer(videoUrl);
        return;
      } catch (e) {
        print("Failed to load video from server ${i + 1}: ${e.toString()}");
      }
    }
    setState(() {
      _isLoading = false;
      _errorMessage = "All servers failed to load video.";
    });
  }

  void _setupPlayer(String videoUrl) {
    BetterPlayerDataSource dataSource = BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      videoUrl,
    );
    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        autoPlay: true,
      ),
      betterPlayerDataSource: dataSource,
    );
    setState(() {
      _isLoading = false;
    });
  }

  Future<String> _extractVideoUrl(String iframeUrl) async {
    final response = await http.get(Uri.parse(iframeUrl));
    if (response.statusCode == 200) {
      final document = parse(response.body);

      // Try to find video source in various ways
      String? videoUrl = _findVideoSource(document);
      if (videoUrl != null) return videoUrl;

      // Look for a JSON object that might contain the video URL
      final scripts = document.querySelectorAll('script');
      for (var script in scripts) {
        final content = script.text;
        if (content.contains('var player') || content.contains('sources:')) {
          final match = RegExp(r'sources:\s*(\[.*?\])').firstMatch(content);
          if (match != null) {
            final sourcesJson = match.group(1);
            if (sourcesJson != null) {
              final sources = json.decode(sourcesJson) as List;
              if (sources.isNotEmpty) {
                return sources.first['file'] ?? sources.first['src'];
              }
            }
          }
        }
      }

      // If we still haven't found the video, look for m3u8 links
      final m3u8Match = RegExp(r'(https?://.*?\.m3u8)').firstMatch(response.body);
      if (m3u8Match != null) {
        return m3u8Match.group(0)!;
      }
    }
    throw Exception('Could not extract video URL from iframe');
  }

  String? _findVideoSource(var document) {
    // Check for video tag
    final videoElement = document.querySelector('video source');
    if (videoElement != null) {
      return videoElement.attributes['src'];
    }

    // Check for iframe
    final iframeElement = document.querySelector('iframe');
    if (iframeElement != null) {
      return iframeElement.attributes['src'];
    }

    // Check for jwplayer
    final jwplayerScript = document.querySelector('script[src*="jwplayer"]');
    if (jwplayerScript != null) {
      final match = RegExp(r'file:\s*"(.*?)"').firstMatch(document.body!.text);
      if (match != null) {
        return match.group(1);
      }
    }

    return null;
  }

  Future<void> _changeServer(int index) async {
    setState(() {
      _currentServerIndex = index;
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      String videoUrl = await _extractVideoUrl(widget.serverUrls[_currentServerIndex]);
      _setupPlayer(videoUrl);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Failed to load video: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Video Player'),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(child: Text(_errorMessage!))
                    : BetterPlayer(controller: _betterPlayerController),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.serverUrls.length,
              itemBuilder: (context, index) {
                return ElevatedButton(
                  onPressed: () => _changeServer(index),
                  child: Text('Server ${index + 1}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _betterPlayerController.dispose();
    super.dispose();
  }
}