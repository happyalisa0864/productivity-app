import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productivity_app/features/welcome/presentation/pages/app_entry.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Productivity App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF5B8B1), // soft coral / pastel rose
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFFAF7F5),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAF7F5),
          foregroundColor: Color(0xFF4E4A47),
          elevation: 0,
          centerTitle: true,
        ),
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: const Color(0xFF4E4A47),
              displayColor: const Color(0xFF4E4A47),
            ),
        cardTheme: CardThemeData(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 1,
          margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFF5B8B1),
          foregroundColor: Colors.white,
        ),
      ),
      home: const AppEntry(),
    );
  }
}

