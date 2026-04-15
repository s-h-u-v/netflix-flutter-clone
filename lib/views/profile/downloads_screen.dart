import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../services/download_service.dart';
import '../../services/settings_service.dart';
import '../player/video_player_screen.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Downloads'),
        backgroundColor: Constants.backgroundColor,
      ),
      body: Consumer2<DownloadService, SettingsService>(
        builder: (context, downloads, settings, child) {
          if (!downloads.isLoaded || !settings.isLoaded) {
            return const Center(
              child: CircularProgressIndicator(color: Constants.primaryColor),
            );
          }

          if (settings.wifiOnlyDownloads && !downloads.isOnWifi) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Connect to Wi‑Fi to access downloads.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 18),
                ),
              ),
            );
          }

          if (downloads.downloads.isEmpty) {
            return const Center(
              child: Text(
                'You have no downloaded videos.',
                style: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.7,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: downloads.downloads.length,
            itemBuilder: (context, index) {
              final item = downloads.downloads[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => VideoPlayerScreen(
                        videoUrl: item.localPath,
                        playlist: const [],
                        startIndex: 0,
                        isLocalFile: true,
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: item.posterPath.isNotEmpty
                      ? Image.asset(item.posterPath, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey[800],
                          child: Center(
                            child: Text(
                              item.title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
