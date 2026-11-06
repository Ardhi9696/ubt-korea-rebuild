import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../dummy_data.dart';
import '../main.dart';
import 'result_screen.dart';

/// Halaman ujian (dummy) — meniru `exam_page` di app Korea:
/// topbar detail peserta, timer mundur, soal + 4 pilihan,
/// audio play-once (file nada test `assets/audio/test_tone.mp3`,
/// diputar lewat MethodChannel + MediaPlayer bawaan Android di
/// MainActivity.kt — tanpa plugin pihak ketiga),
/// kontrol kecepatan 0.75x/1.0x/1.25x/1.5x yang mengubah kecepatan putar,
/// grid total soal (bottom sheet), submit manual + auto-submit saat waktu habis.
class ExamPage extends StatefulWidget {
  const ExamPage({super.key, required this.exam, required this.user});

  final DummyExam exam;
  final DummyUser user;

  @override
  State<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  /// Durasi ujian dummy: 10 menit.
  static const int examDurationSeconds = 10 * 60;

  /// Channel audio native (MainActivity.kt -> MediaPlayer).
  static const MethodChannel _audioChannel =
      MethodChannel('ubt_korea_rebuild/audio');

  /// Durasi file nada test (detik) — untuk progress bar saja;
  /// penguncian soal mengikuti callback selesai dari native.
  static const double _testToneSeconds = 11.2;

  static const List<double> speeds = <double>[0.75, 1.0, 1.25, 1.5];

  final Map<int, int> _answers = <int, int>{};

  /// Soal yang audionya sudah diputar (terkunci, tidak bisa diputar lagi).
  final Set<int> _playedAudio = <int>{};

  int _currentIndex = 0;
  int _secondsLeft = examDurationSeconds;
  Timer? _examTimer;
  Timer? _audioTimer;
  double _speed = 1.0;
  double _audioProgress = 0.0; // 0..1 untuk soal yang sedang diputar
  bool _isPlayingAudio = false;
  bool _submitted = false;

  DummyQuestion get _current => dummyQuestions[_currentIndex];

  @override
  void initState() {
    super.initState();
    _audioChannel.setMethodCallHandler((call) async {
      if (call.method == 'onAudioCompleted' && mounted) {
        _markAudioPlayed();
      }
    });
    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        if (_secondsLeft > 0) {
          _secondsLeft--;
        } else {
          timer.cancel();
          _doSubmit(auto: true);
        }
      });
    });
  }

  @override
  void dispose() {
    _examTimer?.cancel();
    _audioTimer?.cancel();
    _audioChannel.setMethodCallHandler(null);
    _stopNativeAudio();
    super.dispose();
  }

  /// Dipanggil saat native melaporkan audio selesai (atau gagal diputar).
  void _markAudioPlayed() {
    _audioTimer?.cancel();
    if (!mounted) return;
    setState(() {
      _isPlayingAudio = false;
      _audioProgress = 1.0;
      _playedAudio.add(_current.id);
    });
  }

  Future<void> _stopNativeAudio() async {
    try {
      await _audioChannel.invokeMethod<void>('stopAudio');
    } catch (_) {
      // Abaikan: native tidak punya audio yang sedang jalan.
    }
  }

  String get _timerText {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Pemutaran audio test nyata (nada dummy, bukan musik) via native.
  /// Hanya 1x per soal — setelah selesai, tombol terkunci.
  /// Progress bar digerakkan Timer lokal; penguncian mengikuti
  /// callback selesai dari native (atau Timer kalau callback telat).
  /// Kalau channel gagal, soal langsung ditandai sudah diputar
  /// supaya ujian tidak macet.
  Future<void> _playAudio() async {
    if (_isPlayingAudio || _playedAudio.contains(_current.id)) return;
    if (_current.section != 'listening') return;
    setState(() {
      _isPlayingAudio = true;
      _audioProgress = 0.0;
    });
    _audioTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (!_isPlayingAudio) {
        timer.cancel();
        return;
      }
      setState(() {
        _audioProgress += 0.1 * _speed / _testToneSeconds;
        if (_audioProgress >= 1.0) {
          _audioProgress = 1.0;
          timer.cancel();
          _isPlayingAudio = false;
          _playedAudio.add(_current.id);
        }
      });
    });
    try {
      await _audioChannel.invokeMethod<void>(
        'playTestTone',
        <String, Object>{'speed': _speed},
      );
    } catch (_) {
      if (!mounted) return;
      _markAudioPlayed();
    }
  }

  void _stopAudio() {
    _audioTimer?.cancel();
    _stopNativeAudio();
    if (_isPlayingAudio) {
      setState(() {
        _isPlayingAudio = false;
        _audioProgress = 0.0;
      });
    }
  }

  Future<void> _setNativeSpeed(double speed) async {
    try {
      await _audioChannel.invokeMethod<void>(
        'setSpeed',
        <String, Object>{'speed': speed},
      );
    } catch (_) {
      // Abaikan: native tidak sedang memutar.
    }
  }

  void _goToQuestion(int index) {
    _stopAudio();
    setState(() {
      _currentIndex = index;
      _audioProgress = 0.0;
    });
  }

  void _openQuestionGrid() {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: dummyQuestions.length,
          itemBuilder: (context, index) {
            final q = dummyQuestions[index];
            final answered = _answers.containsKey(q.id);
            final isCurrent = index == _currentIndex;
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isCurrent
                    ? UbtKoreaRebuildApp.darkBlue
                    : (answered
                        ? UbtKoreaRebuildApp.accentTeal
                        : Colors.grey[300]),
                foregroundColor:
                    (isCurrent || answered) ? Colors.white : Colors.black87,
                padding: EdgeInsets.zero,
              ),
              onPressed: () {
                Navigator.pop(context);
                _goToQuestion(index);
              },
              child: Text('${index + 1}'),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmSubmit() async {
    if (_submitted) return;
    final unanswered = dummyQuestions.length - _answers.length;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kirim jawaban?'),
        content: Text(
          'Kamu sudah menjawab ${_answers.length} dari '
          '${dummyQuestions.length} soal.\n'
          '${unanswered > 0 ? '$unanswered soal belum dijawab.\n' : ''}'
          'Setelah dikirim, jawaban tidak bisa diubah lagi. (Dummy)',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
    if (confirmed == true) _doSubmit(auto: false);
  }

  void _doSubmit({required bool auto}) {
    if (_submitted) return;
    _submitted = true;
    _examTimer?.cancel();
    _stopAudio();
    final score = scoreDummyAnswers(_answers);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(
          exam: widget.exam,
          user: widget.user,
          score: score,
          answers: Map<int, int>.of(_answers),
          autoSubmitted: auto,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isListening = _current.section == 'listening';
    final bool audioPlayed = _playedAudio.contains(_current.id);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exam.title),
        actions: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Text(
                _timerText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Topbar detail peserta (meniru `topbar_examinee_details`).
          Container(
            width: double.infinity,
            color: const Color(0xFFE8EEF7),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: <Widget>[
                const Icon(Icons.person),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${widget.user.name} (${widget.user.examineeNumber})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Chip(
                  label: Text(
                    'Soal ${_currentIndex + 1}/${dummyQuestions.length}',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Chip(
                    label: Text(
                      isListening ? 'LISTENING (dummy)' : 'READING (dummy)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _current.text,
                    style: const TextStyle(fontSize: 18),
                  ),
                  if (isListening) ...<Widget>[
                    const SizedBox(height: 16),
                    const Text(
                      'Audio test (nada dummy, bukan musik): diputar 1x, '
                      'terkunci setelah selesai. Kecepatan mengubah '
                      'kecepatan putar.',
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(value: _audioProgress),
                    const SizedBox(height: 8),
                    Row(
                      children: <Widget>[
                        ElevatedButton.icon(
                          onPressed: (audioPlayed || _isPlayingAudio)
                              ? null
                              : _playAudio,
                          icon: const Icon(Icons.play_arrow),
                          label: Text(
                            audioPlayed
                                ? 'Sudah diputar 1x (terkunci)'
                                : (_isPlayingAudio
                                    ? 'Memutar…'
                                    : 'Putar Audio (1x)'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('Kecepatan audio:'),
                    Wrap(
                      spacing: 8,
                      children: speeds
                          .map(
                            (s) => ChoiceChip(
                              label: Text('${s}x'),
                              selected: _speed == s,
                              onSelected: (_) {
                                setState(() => _speed = s);
                                if (_isPlayingAudio) {
                                  _setNativeSpeed(s);
                                }
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    'Pilih jawaban:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  RadioGroup<int>(
                    groupValue: _answers[_current.id],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _answers[_current.id] = v);
                      }
                    },
                    child: Column(
                      children: List<Widget>.generate(
                        _current.options.length,
                        (i) => RadioListTile<int>(
                          title: Text(_current.options[i]),
                          value: i,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bar bawah: navigasi soal + grid + submit.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    tooltip: 'Soal sebelumnya',
                    onPressed: _currentIndex > 0
                        ? () => _goToQuestion(_currentIndex - 1)
                        : null,
                  ),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _openQuestionGrid,
                      icon: const Icon(Icons.grid_view),
                      label: const Text('Grid Soal'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    tooltip: 'Soal berikutnya',
                    onPressed: _currentIndex < dummyQuestions.length - 1
                        ? () => _goToQuestion(_currentIndex + 1)
                        : null,
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _confirmSubmit,
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
