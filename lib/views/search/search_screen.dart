import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/movie_provider.dart';
import '../../models/movie.dart';
import '../../theme/app_colors.dart';
import '../details/movie_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Movie> _searchResults = [];

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    final provider = Provider.of<MovieProvider>(context, listen: false);
    final allMovies = [
      ...provider.trendingMovies,
      ...provider.topRatedMovies,
      ...provider.popularMovies,
    ];

    // Removing duplicates and filtering locally since TMDB multi-search isn't fully set up yet
    final uniqueMovies = {for (var m in allMovies) m.id: m}.values;

    setState(() {
      _searchResults = uniqueMovies
          .where((m) => m.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search for a show, movie, genre, etc.',
            border: InputBorder.none,
            hintStyle: TextStyle(color: AppColors.textMuted),
          ),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 18),
        ),
      ),
      body: _searchResults.isEmpty ? _buildIdleState() : _buildSearchResults(),
    );
  }

  Widget _buildIdleState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search, size: 80, color: AppColors.textMuted),
          SizedBox(height: 16),
          Text(
            'Find your next watch',
            style: TextStyle(color: AppColors.textMuted, fontSize: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final movie = _searchResults[index];
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: SizedBox(
            width: 50,
            child: movie.posterPath.isNotEmpty
                ? Image.asset(movie.posterPath, fit: BoxFit.cover)
                : Container(
                    color: Colors.grey[800],
                    child: const Icon(Icons.movie, color: Colors.grey),
                  ),
          ),
          title: Text(movie.title, style: const TextStyle(color: Colors.white)),
          trailing: const Icon(
            Icons.play_circle_outline,
            color: Colors.white,
            size: 30,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => MovieDetailsScreen(movie: movie),
              ),
            );
          },
        );
      },
    );
  }
}
