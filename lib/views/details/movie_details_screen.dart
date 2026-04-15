import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/movie.dart';
import '../../../controllers/movie_provider.dart';
import '../player/video_player_screen.dart';
import '../../../services/settings_service.dart';
import '../../../services/download_service.dart';
import '../../../services/subscription_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/widgets/app_buttons.dart';

class MovieDetailsScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
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
                      color: AppColors.surface,
                      image: movie.backdropPath.isNotEmpty ? DecorationImage(
                        image: AssetImage(movie.backdropPath),
                        fit: BoxFit.cover,
                      ) : null,
                    ),
                    child: movie.backdropPath.isEmpty
                        ? const Center(child: Icon(Icons.movie, size: 80, color: AppColors.textMuted))
                        : null,
                  ),
                ),
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.background,
                        AppColors.background.withValues(alpha: 0.0),
                      ],
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
                      const Text(
                        'Match 98%',
                        style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        movie.rating.toStringAsFixed(1),
                        style: const TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Play Button
                  AppPrimaryButton(
                    onPressed: () {
                      final subscription = context.read<SubscriptionService>();

                      // Available demo videos in this app.
                      final allVideos = <String>[
                        'assets/videos/video_1.mp4',
                        'assets/videos/video_2.mp4',
                        'assets/videos/video_3.mp4',
                        'assets/videos/video_4.mp4',
                        'assets/videos/video_5.mp4',
                      ];

                      // Every movie is mapped to one of the 5 demo videos.
                      final mappedIndex = (movie.id % allVideos.length).clamp(0, allVideos.length - 1);

                      // Free plan can only watch the first 2 demo videos.
                      if (!subscription.isPro && mappedIndex >= 2) {
                        _showProRequiredSnack(context);
                        return;
                      }

                      final startIndex = mappedIndex;
                      final startUrl = allVideos[mappedIndex];

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerScreen(
                            videoUrl: startUrl,
                            playlist: allVideos,
                            startIndex: startIndex,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.play_arrow, size: 22, color: AppColors.textPrimary),
                        SizedBox(width: 10),
                        Text(
                          'Play',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  
                  Consumer2<DownloadService, SettingsService>(
                    builder: (context, downloads, settings, child) {
                      final isDownloaded = downloads.isDownloaded(movie.id);
                      final canDownload = downloads.canDownloadNow;

                      return AppSecondaryButton(
                        onPressed: () async {
                          if (isDownloaded) {
                            await context.read<DownloadService>().removeDownload(movie.id);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Removed from downloads')),
                            );
                            return;
                          }

                          if (!canDownload && settings.wifiOnlyDownloads) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Wi‑Fi required for download')),
                            );
                            return;
                          }

                          try {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Downloading...')),
                            );
                            await context.read<DownloadService>().downloadMovie(movie);
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Downloaded')),
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isDownloaded ? Icons.check_circle : Icons.file_download,
                              size: 20,
                              color: isDownloaded ? AppColors.success : AppColors.textPrimary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isDownloaded ? 'Downloaded' : 'Download',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Overview
                  Text(
                    movie.overview,
                    style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
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
              title: const Text('Rate this movie'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < rating ? Icons.star : Icons.star_border,
                      color: AppColors.pink,
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
                  child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('You rated this movie $rating stars!')),
                    );
                  },
                  child: const Text('Submit', style: TextStyle(color: AppColors.textPrimary)),
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
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Share via...',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildShareIcon(context, Icons.chat, 'WhatsApp', AppColors.success),
                  _buildShareIcon(context, Icons.camera_alt, 'Instagram', AppColors.pink),
                  _buildShareIcon(context, Icons.facebook, 'Facebook', AppColors.blue),
                  _buildShareIcon(context, Icons.copy, 'Copy Link', AppColors.textMuted),
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
            child: Icon(icon, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildAction(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: AppColors.textPrimary, size: 28),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 12)),
        ],
      ),
    );
  }

  void _showProRequiredSnack(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pro required: Free plan allows only 2 videos.'),
      ),
    );
  }
}
