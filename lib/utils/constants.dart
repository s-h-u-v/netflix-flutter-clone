import 'package:flutter/material.dart';

class Constants {
  // Colors
  static const Color primaryColor = Color(0xFFE50914); // Netflix Red
  static const Color backgroundColor = Color(0xFF000000); // Black
  static const Color surfaceColor = Color(0xFF141414); // Dark Gray

  // API Config Placeholder (TMDB style)
  static const String apiKey = 'REPLACE_WITH_TMDB_API_KEY';
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageUrl = 'https://image.tmdb.org/t/p/w500';
  static const String originalImageUrl = 'https://image.tmdb.org/t/p/original';

  // API Endpoints
  static const String trendingEnpoint = '/trending/movie/day';
  static const String topRatedEndpoint = '/movie/top_rated';
  static const String popularEndpoint = '/movie/popular';
}
