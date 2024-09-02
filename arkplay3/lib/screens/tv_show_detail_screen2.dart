import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:better_player/better_player.dart';
import '../models/tv_show.dart';
import '../models/cast.dart';
import '../models/season.dart';
import '../models/episode.dart';
import '../services/api_service.dart';

class TVShowDetailScreen extends StatefulWidget {
  final TVShow tvShow;

  TVShowDetailScreen({required this.tvShow});

  @override
  _TVShowDetailScreenState createState() => _TVShowDetailScreenState();
}

class _TVShowDetailScreenState extends State<TVShowDetailScreen> {
  late Future<List<Cast>> _castFuture;
  late Future<List<Season>> _seasonsFuture;
  List<Episode> _episodes = [];
  int? _selectedSeasonId;
  Episode? _selectedEpisode;
  List<String> _serverUrls = [];

  @override
  void initState() {
    super.initState();
    _castFuture = Provider.of<ApiService>(context, listen: false)
        .getTVShowCast(widget.tvShow.id);
    _seasonsFuture = Provider.of<ApiService>(context, listen: false)
        .getTVShowSeasons(widget.tvShow.id);
    _onSeasonSelected(1);
  }

  void _onSeasonSelected(int seasonId) async {
    setState(() {
      _selectedSeasonId = seasonId;
      _selectedEpisode = null;
      _serverUrls = [];
    });

    final episodes = await Provider.of<ApiService>(context, listen: false)
        .getSeasonEpisodes(widget.tvShow.id, seasonId);
    setState(() {
      _episodes = episodes;
      if (_episodes.isNotEmpty) {
        _selectedEpisode = _episodes[0];
        _updateServerUrls(_selectedEpisode!);
      }
    });
  }

  void _onEpisodeSelected(Episode episode) {
    setState(() {
      _selectedEpisode = episode;
      _updateServerUrls(episode);
    });
  }

  void _updateServerUrls(Episode episode) {
    final tvShowId = widget.tvShow.id;
    final seasonNumber = _selectedSeasonId ?? 1;
    final episodeNumber = episode.episodeNumber;
    final urls = [
      'https://2embed.biz/embed/series?tmdb=$tvShowId&sea=$seasonNumber&epi=$episodeNumber',
      'https://api.123movie.cc/tmdb_api.php?se=$seasonNumber&ep=$episodeNumber&tmdb=$tvShowId&server_name=vcu',
      'https://www.2embed.to/embed/tmdb/tv?id=$tvShowId&s=$seasonNumber&e=$episodeNumber',
      'https://onionflix.org/embed/series?tmdb=$tvShowId&sea=$seasonNumber&epi=$episodeNumber',
      'https://hub.smashystream.com/embed/series?tmdb=$tvShowId&sea=$seasonNumber&epi=$episodeNumber',
      'https://embedworld.xyz/public/embed/series?tmdb=$tvShowId&sea=$seasonNumber&epi=$episodeNumber',
      'https://cinedb.top/embed/series?tmdb=$tvShowId&sea=$seasonNumber&epi=$episodeNumber',
      'https://fembed.ro/embed/series?tmdb=$tvShowId&sea=$seasonNumber&epi=$episodeNumber',
      'https://moviehab.com/embed/series?tmdb=$tvShowId&sea=$seasonNumber&epi=$episodeNumber',
      'https://vidsrc.me/embed/$tvShowId/$seasonNumber-$episodeNumber/',
      'https://databasegdriveplayer.us/player.php?type=series&tmdb=$tvShowId&season=$seasonNumber&episode=$episodeNumber',
      'https://openvids.io/tmdb/episode/$tvShowId-$seasonNumber-$episodeNumber'
    ];
    setState(() {
      _serverUrls = urls;
    });
  }

  void _openPlayer(String url) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: Image.network(
              'https://image.tmdb.org/t/p/original${widget.tvShow.backdropPath}',
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
                    widget.tvShow.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Overview:',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.tvShow.overview,
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
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
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  FutureBuilder<List<Cast>>(
                    future: _castFuture,
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
                                      style: TextStyle(
                                          fontSize: 12, color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                    Text(
                                      'as ${actor.character}',
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.grey),
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
                  SizedBox(height: 16),
                  Text(
                    'Seasons:',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  FutureBuilder<List<Season>>(
                    future: _seasonsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Failed to load seasons'));
                      } else {
                        final seasons = snapshot.data ?? [];
                        return SizedBox(
                          height: 250,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: seasons.length,
                            itemBuilder: (context, index) {
                              final season = seasons[index];
                              return GestureDetector(
                                onTap: () =>
                                    _onSeasonSelected(season.seasonNumber),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 120,
                                        height: 180,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          image: DecorationImage(
                                            image: NetworkImage(
                                              season.posterPath.isNotEmpty
                                                  ? 'https://image.tmdb.org/t/p/w500${season.posterPath}'
                                                  : 'https://via.placeholder.com/120x180',
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Season ${season.seasonNumber}',
                                        style: TextStyle(
                                            fontSize: 12, color: Colors.white),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      }
                    },
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Episodes:',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 8),
                  if (_episodes.isNotEmpty) ...[
                    SizedBox(
                      height: 250,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _episodes.length,
                        itemBuilder: (context, index) {
                          final episode = _episodes[index];
                          return GestureDetector(
                            onTap: () => _onEpisodeSelected(episode),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 120,
                                    height: 180,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: NetworkImage(
                                          episode.stillPath.isNotEmpty
                                              ? 'https://image.tmdb.org/t/p/w500${episode.stillPath}'
                                              : 'https://via.placeholder.com/120x180',
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Episode ${episode.episodeNumber}',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Available on:',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    SizedBox(
                      height: 60,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _serverUrls.length,
                        itemBuilder: (context, index) {
                          final url = _serverUrls[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ElevatedButton(
                              onPressed: () => _openPlayer(url),
                              child: Text('Server ${index + 1}'),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerScreen extends StatelessWidget {
  final String url;

  VideoPlayerScreen({required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Video Player')),
      body: Center(
        child: BetterPlayer.network(
          url,
          betterPlayerConfiguration: BetterPlayerConfiguration(
            aspectRatio: 16 / 9,
            autoPlay: true,
            looping: true,
          ),
        ),
      ),
    );
  }
}
