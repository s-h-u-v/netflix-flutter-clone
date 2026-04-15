import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:movie_app/controllers/auth_provider.dart';
import 'package:movie_app/controllers/movie_provider.dart';
import 'package:movie_app/main.dart';

void main() {
  testWidgets('MovieApp renders MaterialApp', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => MovieProvider()),
        ],
        child: const MovieApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
