import 'package:flutter/material.dart';
import '../models/movie.dart';
import '../services/api_service.dart';

class MovieProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Movie> _trendingMovies = [];
  List<Movie> _topRatedMovies = [];
  List<Movie> _popularMovies = [];
  List<Movie> _watchlist = [];
  List<Movie> _downloads = []; // New downloads tracker
  
  bool _isLoading = true;

  List<Movie> get trendingMovies => _trendingMovies;
  List<Movie> get topRatedMovies => _topRatedMovies;
  List<Movie> get popularMovies => _popularMovies;
  List<Movie> get watchlist => _watchlist;
  List<Movie> get downloads => _downloads;
  bool get isLoading => _isLoading;

  MovieProvider() {
    loadAllMovies();
  }

  Future<void> loadAllMovies() async {
    _isLoading = true;
    notifyListeners();

    try {
      _trendingMovies = await _apiService.getTrendingMovies();
      _topRatedMovies = await _apiService.getTopRatedMovies();
      _popularMovies = await _apiService.getPopularMovies();
    } catch (e) {
      print('Error loading movies: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void toggleWatchlist(Movie movie) {
    final isWatchlisted = _watchlist.any((m) => m.id == movie.id);

    if (isWatchlisted) {
      _watchlist.removeWhere((m) => m.id == movie.id);
    } else {
      _watchlist.add(movie);
    }
    notifyListeners();
  }

  bool isInWatchlist(int movieId) {
    return _watchlist.any((m) => m.id == movieId);
  }

  void toggleDownload(Movie movie) {
    final isDownloaded = _downloads.any((m) => m.id == movie.id);

    if (isDownloaded) {
      _downloads.removeWhere((m) => m.id == movie.id);
    } else {
      _downloads.add(movie);
    }
    notifyListeners();
  }

  bool isDownloaded(int movieId) {
    return _downloads.any((m) => m.id == movieId);
  }
}

