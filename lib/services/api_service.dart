import '../models/movie.dart';

class ApiService {
  Future<List<Movie>> getTrendingMovies() async {
    return _getMockMovies();
  }

  Future<List<Movie>> getTopRatedMovies() async {
    return _getMockMovies();
  }

  Future<List<Movie>> getPopularMovies() async {
    return _getMockMovies();
  }

  List<Movie> _getMockMovies() {
    return [
      Movie(id: 1, title: 'The Haunting', overview: 'A terrifying night in an abandoned house.', posterPath: 'assets/images/poster_1.png', backdropPath: 'assets/images/poster_1.png', videoUrl: 'assets/videos/video_1.mp4', rating: 8.8),
      Movie(id: 2, title: 'College Days', overview: 'A hilarious take on university life.', posterPath: 'assets/images/poster_2.png', backdropPath: 'assets/images/poster_2.png', videoUrl: 'assets/videos/video_2.mp4', rating: 7.2),
      Movie(id: 3, title: 'Midnight in Paris', overview: 'A magical romantic comedy.', posterPath: 'assets/images/poster_3.png', backdropPath: 'assets/images/poster_3.png', videoUrl: 'assets/videos/video_3.mp4', rating: 8.5),
      Movie(id: 4, title: 'Dragon Epic', overview: 'Swords, magic, and destiny.', posterPath: 'assets/images/poster_4.png', backdropPath: 'assets/images/poster_4.png', videoUrl: 'assets/videos/video_4.mp4', rating: 9.0),
      Movie(id: 5, title: 'Cyber City Action', overview: 'Futuristic crime and neon blasters.', posterPath: 'assets/images/poster_5.png', backdropPath: 'assets/images/poster_5.png', videoUrl: 'assets/videos/video_5.mp4', rating: 8.4),
      Movie(id: 6, title: 'Noir Detective', overview: 'A gritty mystery in the rain.', posterPath: 'assets/images/poster_6.png', backdropPath: 'assets/images/poster_6.png', videoUrl: 'assets/videos/video_6.mp4', rating: 8.9),
    ];
  }
}
