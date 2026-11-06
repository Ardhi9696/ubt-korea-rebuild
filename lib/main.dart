import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';

void main() => runApp(const UbtKoreaRebuildApp());

/// Rekonstruksi belajar tampilan UBT EPS TOPIK Korea (v1.0.15).
/// Semua data dummy, tanpa backend, tanpa network call.
/// Warna dipilih sendiri (biru gelap + aksen teal) — bukan klon piksel app asli.
class UbtKoreaRebuildApp extends StatelessWidget {
  const UbtKoreaRebuildApp({super.key});

  static const Color darkBlue = Color(0xFF1F3864);
  static const Color accentTeal = Color(0xFF00897B);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UBT Korea Rebuild (Dummy)',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: darkBlue,
          primary: darkBlue,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: darkBlue,
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentTeal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
