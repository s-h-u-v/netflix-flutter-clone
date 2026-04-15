import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'views/auth/login_screen.dart';
import 'views/home/home_screen.dart';
import 'controllers/auth_provider.dart';
import 'controllers/movie_provider.dart';
import 'services/settings_service.dart';
import 'services/download_service.dart';
import 'services/subscription_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MovieProvider()),
        ChangeNotifierProvider(
          create: (_) => SettingsService()..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => SubscriptionService()..load(),
        ),
        ChangeNotifierProxyProvider<SettingsService, DownloadService>(
          create: (context) => DownloadService(
            settings: context.read<SettingsService>(),
          )..load(),
          update: (context, settings, previous) {
            // Keep existing instance; it reads settings dynamically.
            return previous ?? DownloadService(settings: settings)..load();
          },
        ),
      ],
      child: const MovieApp(),
    ),
  );
}

class MovieApp extends StatelessWidget {
  const MovieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movieflix',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isInitLoading) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(child: CircularProgressIndicator(color: Colors.red)),
            );
          }
          return auth.user != null ? const HomeScreen() : const LoginScreen();
        },
      ),
    );
  }
}
