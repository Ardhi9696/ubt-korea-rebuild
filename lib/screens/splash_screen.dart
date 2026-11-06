import 'package:flutter/material.dart';

import '../main.dart';
import 'login_screen.dart';

/// Splash dummy: tampil 2 detik lalu masuk ke Login.
/// Ikon bawaan Flutter saja — tanpa logo/aset app asli.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UbtKoreaRebuildApp.darkBlue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const <Widget>[
            Icon(Icons.school, size: 88, color: Colors.white),
            SizedBox(height: 24),
            Text(
              'UBT Korea Rebuild',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '(Dummy)',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            SizedBox(height: 16),
            Chip(
              label: Text('DUMMY — rekonstruksi belajar'),
              backgroundColor: Colors.white24,
              labelStyle: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 32),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
