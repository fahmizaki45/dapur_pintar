import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() => runApp(const DapurPintarApp());

class DapurPintarApp extends StatelessWidget {
  const DapurPintarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dapur Pintar',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        scaffoldBackgroundColor: const Color(0xFFFFFBF8),
      ),
      home: const HomeScreen(),
    );
  }
}
