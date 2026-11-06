import 'package:flutter/material.dart';

import 'examinee_info_screen.dart';

/// Login DUMMY — meniru layout login app Korea dari screenshot aslinya:
/// background gradient biru, kartu putih, logo kiri, form kanan.
/// Logo digambar sendiri (lingkaran biru + cloud + teks "DUMMY") — BUKAN
/// logo asli. Copyright ditulis dummy, bukan copyright perusahaan asli.
/// ID/password apa pun (yang tidak kosong) diterima; tanpa network call.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController =
      TextEditingController(text: 'dummy_peserta');
  final TextEditingController _passwordController =
      TextEditingController(text: 'dummy123');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_idController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi ID dan password dummy dulu.')),
      );
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ExamineeInfoScreen(username: _idController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF4FC3F7), Color(0xFF0288D1)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 14, 28, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      // Indikator status ala app asli (pojok kanan kartu).
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          Icon(Icons.wifi, size: 18, color: Colors.green),
                          SizedBox(width: 6),
                          Icon(
                            Icons.notifications_off,
                            size: 18,
                            color: Colors.red,
                          ),
                        ],
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          // Logo DUMMY (digambar sendiri, bukan aset asli).
                          const Expanded(
                            flex: 2,
                            child: _DummyLogo(),
                          ),
                          const SizedBox(width: 28),
                          Expanded(
                            flex: 3,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: <Widget>[
                                TextField(
                                  controller: _idController,
                                  decoration: InputDecoration(
                                    hintText: 'ID',
                                    hintStyle:
                                        TextStyle(color: Colors.grey[600]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  onSubmitted: (_) => _login(),
                                  decoration: InputDecoration(
                                    hintText: 'PASSWORD',
                                    hintStyle:
                                        TextStyle(color: Colors.grey[600]),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 12,
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () => setState(
                                        () => _obscurePassword =
                                            !_obscurePassword,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Center(
                                  child: SizedBox(
                                    width: 180,
                                    child: ElevatedButton(
                                      onPressed: _login,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF2196F3),
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 14,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                      child: const Text('LOGIN'),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'App Version: 0.1.0',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Copyright © 2026 Dummy Rebuild — '
                                  'for learning only.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Logo dummy: lingkaran biru muda + awan putih + teks "DUMMY".
/// Digambar dari widget Flutter, tanpa file gambar apa pun.
class _DummyLogo extends StatelessWidget {
  const _DummyLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: const BoxDecoration(
        color: Color(0xFF4FC3F7),
        shape: BoxShape.circle,
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Icon(Icons.cloud, size: 108, color: Colors.white),
          Text(
            'DUMMY',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0D47A1),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
