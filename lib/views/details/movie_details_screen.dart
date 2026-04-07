import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/movie.dart';
import '../../../controllers/movie_provider.dart';
import '../player/video_player_screen.dart';

class MovieDetailsScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailsScreen({Key? key, required this.movie}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Image
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Hero(
                  tag: 'movie_${movie.id}',
                  child: Container(
                    height: 400,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      image: movie.backdropPath.isNotEmpty ? DecorationImage(
                        image: AssetImage(movie.backdropPath),
                        fit: BoxFit.cover,
                      ) : null,
                    ),
                    child: movie.backdropPath.isEmpty ? const Center(child: Icon(Icons.movie, size: 80, color: Colors.grey)) : null,
                  ),
                ),
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black, Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ],
            ),
            
            // Movie Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    movie.title,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('Match 98%', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Text(movie.rating.toStringAsFixed(1), style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Play Button
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    icon: const Icon(Icons.play_arrow, size: 28),
                    label: const Text('Play', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerScreen(videoUrl: movie.videoUrl),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  
                  // Download Button
                  Consumer<MovieProvider>(
                    builder: (context, provider, child) {
                      final isDownloaded = provider.isDownloaded(movie.id);
                      return ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        ),
                        icon: Icon(isDownloaded ? Icons.check_circle : Icons.file_download),
                        label: Text(isDownloaded ? 'Downloaded' : 'Download', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        onPressed: () {
                          provider.toggleDownload(movie);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(isDownloaded ? 'Removed from downloads' : 'Movie downloaded locally!')),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Overview
                  Text(
                    movie.overview,
                    style: const TextStyle(fontSize: 14, color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  
                  // Actions Container
                  Consumer<MovieProvider>(
                    builder: (context, provider, child) {
                      final isWatchlisted = provider.isInWatchlist(movie.id);
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildAction(
                            isWatchlisted ? Icons.check : Icons.add,
                            'My List',
                            () => provider.toggleWatchlist(movie),
                          ),
                          _buildAction(Icons.thumb_up_alt_outlined, 'Rate', () {
                            _showRatingDialog(context);
                          }),
                          _buildAction(Icons.share, 'Share', () {
                            _showShareModal(context);
                          }),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingDialog(BuildContext context) {
    int rating = 0;
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text('Rate this movie', style: TextStyle(color: Colors.white)),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: Colors.red,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        rating = index + 1;
                      });
                    },
                  );
                }),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('You rated this movie $rating stars!')),
                    );
                  },
                  child: const Text('Submit', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showShareModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Share via...', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareIcon(context, Icons.chat, 'WhatsApp', Colors.green),
                  _buildShareIcon(context, Icons.camera_alt, 'Instagram', Colors.purpleAccent),
                  _buildShareIcon(context, Icons.facebook, 'Facebook', Colors.blue),
                  _buildShareIcon(context, Icons.copy, 'Copy Link', Colors.grey),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShareIcon(BuildContext context, IconData icon, String label, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(label == 'Copy Link' ? 'Link copied to clipboard' : 'Shared seamlessly to $label!')),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
