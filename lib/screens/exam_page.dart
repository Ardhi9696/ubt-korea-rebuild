import 'dart:async';

import 'package:flutter/material.dart';

import '../dummy_data.dart';
import '../main.dart';
import 'result_screen.dart';

/// Halaman ujian (dummy) — meniru `exam_page` di app Korea:
/// topbar detail peserta, timer mundur, soal + 4 pilihan,
/// audio play-once (simulasi Timer + progress bar, tanpa file audio),
/// kontrol kecepatan 0.75x/1.0x/1.25x/1.5x yang mengubah durasi simulasi,
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
    super.dispose();
  }

  String get _timerText {
    final minutes = _secondsLeft ~/ 60;
    final seconds = _secondsLeft % 60;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  /// Simulasi pemutaran audio: progress bar maju secepat `_speed`.
  /// Hanya 1x per soal — setelah selesai, tombol terkunci.
  void _playAudio() {
    if (_isPlayingAudio || _playedAudio.contains(_current.id)) return;
    if (_current.section != 'listening') return;
    setState(() {
      _isPlayingAudio = true;
      _audioProgress = 0.0;
    });
    final total = _current.audioSeconds.toDouble();
    _audioTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        _audioProgress += 0.1 * _speed / total;
        if (_audioProgress >= 1.0) {
          _audioProgress = 1.0;
          _isPlayingAudio = false;
          _playedAudio.add(_current.id);
          timer.cancel();
        }
      });
    });
  }

  void _stopAudio() {
    _audioTimer?.cancel();
    if (_isPlayingAudio) {
      setState(() {
        _isPlayingAudio = false;
        _audioProgress = 0.0;
      });
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
    _audioTimer?.cancel();
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
                      'Audio dummy: simulasi pemutaran (bukan file audio). '
                      'Kecepatan mengubah durasi simulasi.',
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
                    const Text('Kecepatan audio (dummy):'),
                    Wrap(
                      spacing: 8,
                      children: speeds
                          .map(
                            (s) => ChoiceChip(
                              label: Text('${s}x'),
                              selected: _speed == s,
                              onSelected: (_) =>
                                  setState(() => _speed = s),
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
