import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/movie_provider.dart';
import '../../theme/app_colors.dart';
import '../search/search_screen.dart';
import '../profile/profile_screen.dart';
import '../profile/watchlist_screen.dart';
import 'widgets/movie_carousel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeBody(), // We'll extract the current body into HomeBody below
    const SearchScreen(),
    const WatchlistScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // If it's not the Home tab, don't show the transparent app bar to avoid overlapping.
    return Scaffold(
      extendBodyBehindAppBar: _currentIndex == 0,
      appBar: _currentIndex == 0 ? AppBar(
        title: const Text(
          'MOVIEFLIX',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
      ) : null,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Watchlist'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MovieProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.purpleLight),
          );
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Placeholder for Hero Banner
              Container(
                height: 500,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/hero_banner.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black, Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.center,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              MovieCarousel(title: 'Trending Now', movies: provider.trendingMovies),
              MovieCarousel(title: 'Top Rated', movies: provider.topRatedMovies),
              MovieCarousel(title: 'Popular', movies: provider.popularMovies),
              MovieCarousel(title: 'My Watchlist', movies: provider.watchlist),
              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}

