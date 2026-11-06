import 'dart:async';

import 'package:flutter/material.dart';

import '../dummy_data.dart';
import 'exam_list_screen.dart';

/// Setup perangkat (dummy), meniru `setup_device` di app Korea:
/// cek brightness + tes volume suara.
/// - Slider brightness mengubah overlay gelap/terang layar (simulasi).
/// - Tes suara = simulasi pemutaran 5 detik, tanpa file audio.
/// - Gate headset seperti Korea: tombol Lanjut hanya aktif kalau
///   headset (simulasi) ON — kalau OFF, muncul peringatan.
class SetupDeviceScreen extends StatefulWidget {
  const SetupDeviceScreen({super.key, required this.user});

  final DummyUser user;

  @override
  State<SetupDeviceScreen> createState() => _SetupDeviceScreenState();
}

class _SetupDeviceScreenState extends State<SetupDeviceScreen> {
  double _brightness = 0.8; // 0.2 .. 1.0
  double _volume = 70; // 0 .. 100
  bool _headsetConnected = false;

  Timer? _soundTestTimer;
  double _soundTestProgress = 0.0; // 0..1
  bool _soundTestRunning = false;

  @override
  void dispose() {
    _soundTestTimer?.cancel();
    super.dispose();
  }

  void _runSoundTest() {
    if (_soundTestRunning) return;
    setState(() {
      _soundTestRunning = true;
      _soundTestProgress = 0.0;
    });
    _soundTestTimer =
        Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _soundTestProgress += 0.1 / 5; // simulasi 5 detik
        if (_soundTestProgress >= 1.0) {
          _soundTestProgress = 1.0;
          _soundTestRunning = false;
          timer.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Perangkat (Dummy)')),
      body: Stack(
        children: <Widget>[
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Peserta: ${widget.user.name} '
                  '(${widget.user.examineeNumber})',
                ),
                const SizedBox(height: 24),
                const Text(
                  'Kecerahan Layar (simulasi)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: <Widget>[
                    const Icon(Icons.brightness_low),
                    Expanded(
                      child: Slider(
                        value: _brightness,
                        min: 0.2,
                        max: 1.0,
                        divisions: 8,
                        label: '${(_brightness * 100).round()}%',
                        onChanged: (v) => setState(() => _brightness = v),
                      ),
                    ),
                    const Icon(Icons.brightness_high),
                  ],
                ),
                const Text(
                  'Geser slider — layar jadi lebih gelap / terang '
                  '(overlay simulasi, bukan kecerahan beneran).',
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tes Volume Suara (simulasi)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: <Widget>[
                    const Icon(Icons.volume_down),
                    Expanded(
                      child: Slider(
                        value: _volume,
                        min: 0,
                        max: 100,
                        divisions: 10,
                        label: '${_volume.round()}%',
                        onChanged: (v) => setState(() => _volume = v),
                      ),
                    ),
                    const Icon(Icons.volume_up),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _soundTestRunning ? null : _runSoundTest,
                  icon: const Icon(Icons.play_arrow),
                  label: Text(
                    _soundTestRunning
                        ? 'Memutar suara dummy…'
                        : 'Putar Suara Tes (simulasi 5 dtk)',
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: _soundTestProgress),
                if (!_soundTestRunning && _soundTestProgress >= 1.0)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text('Tes suara selesai (dummy).'),
                  ),
                const SizedBox(height: 24),
                SwitchListTile(
                  title: const Text('Headset tersambung (simulasi)'),
                  subtitle: const Text(
                    'Di app Korea, audio tidak bisa diputar sebelum '
                    'headset tersambung.',
                  ),
                  value: _headsetConnected,
                  onChanged: (v) => setState(() => _headsetConnected = v),
                ),
                if (!_headsetConnected)
                  const Card(
                    color: Color(0xFFFFEBEE),
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: Text(
                        'Headset belum tersambung — hubungkan headset '
                        '(nyalakan saklar simulasi di atas) untuk lanjut.',
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _headsetConnected
                      ? () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute<void>(
                              builder: (_) =>
                                  ExamListScreen(user: widget.user),
                            ),
                          );
                        }
                      : null,
                  child: const Text('Lanjut ke Daftar Ujian'),
                ),
              ],
            ),
          ),
          // Overlay gelap simulasi brightness (di atas konten, tapi
          // tidak menghalangi sentuhan).
          IgnorePointer(
            child: Container(
              color: Colors.black.withValues(alpha: (1 - _brightness) * 0.75),
            ),
          ),
        ],
      ),
    );
  }
}
