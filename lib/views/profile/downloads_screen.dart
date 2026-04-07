import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/movie_provider.dart';
import '../../utils/constants.dart';
import '../details/movie_details_screen.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Downloads'),
        backgroundColor: Constants.backgroundColor,
      ),
      body: Consumer<MovieProvider>(
        builder: (context, provider, child) {
          if (provider.downloads.isEmpty) {
            return const Center(
              child: Text(
                'You have no downloaded movies.',
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
            itemCount: provider.downloads.length,
            itemBuilder: (context, index) {
              final movie = provider.downloads[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => MovieDetailsScreen(movie: movie)),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: movie.posterPath.isNotEmpty
                      ? Image.asset(
                          movie.posterPath,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey[800],
                          child: Center(
                            child: Text(
                              movie.title,
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
