import 'dart:async';

import 'package:flutter/material.dart';

import '../dummy_data.dart';
import 'setup_device_screen.dart';

/// Info peserta (dummy) + countdown 5 detik sebelum lanjut.
/// Meniru `examinee_information` + `countdown_cubit` di app Korea.
class ExamineeInfoScreen extends StatefulWidget {
  const ExamineeInfoScreen({super.key, required this.username});

  final String username;

  @override
  State<ExamineeInfoScreen> createState() => _ExamineeInfoScreenState();
}

class _ExamineeInfoScreenState extends State<ExamineeInfoScreen> {
  final TextEditingController _nameController =
      TextEditingController(text: dummyUser.name);
  final TextEditingController _numberController =
      TextEditingController(text: dummyUser.examineeNumber);

  Timer? _countdownTimer;
  int? _countdown; // null = belum mulai; 5..0 = sedang menghitung

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _nameController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    if (_countdown != null) return;
    if (_nameController.text.trim().isEmpty ||
        _numberController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi nama dan nomor peserta dummy dulu.')),
      );
      return;
    }
    setState(() => _countdown = 5);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _countdown = _countdown! - 1;
        if (_countdown! <= 0) {
          timer.cancel();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute<void>(
              builder: (_) => SetupDeviceScreen(
                user: DummyUser(
                  name: _nameController.text.trim(),
                  examineeNumber: _numberController.text.trim(),
                ),
              ),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool counting = _countdown != null;
    return Scaffold(
      appBar: AppBar(title: const Text('Informasi Peserta (Dummy)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Login sebagai: ${widget.username} (dummy)'),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama peserta',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _numberController,
              decoration: const InputDecoration(
                labelText: 'Nomor peserta',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            if (counting)
              Column(
                children: <Widget>[
                  Text(
                    '$_countdown',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('Ujian dummy dimulai…'),
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ],
              )
            else
              ElevatedButton(
                onPressed: _startCountdown,
                child: const Text('Mulai Countdown (5 detik)'),
              ),
          ],
        ),
      ),
    );
  }
}
