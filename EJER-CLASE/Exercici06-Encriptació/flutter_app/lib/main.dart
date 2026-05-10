import 'package:flutter/material.dart';
import 'ui/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RSA Tool',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F1117),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7C6AF7),
          surface: Color(0xFF1A1D27),
        ),
        tabBarTheme: const TabBarThemeData(
          indicatorColor: Color(0xFF7C6AF7),
          labelColor: Color(0xFF7C6AF7),
          unselectedLabelColor: Colors.white38,
        ),
        cardTheme: const CardThemeData(color: Color(0xFF1A1D27)),
      ),
      home: const HomePage(),
    );
  }
}