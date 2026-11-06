import 'package:flutter/material.dart';

import '../dummy_data.dart';
import '../main.dart';
import 'exam_list_screen.dart';
import 'exam_page.dart';

/// Hasil ujian (dummy) — meniru `view_result` di app Korea.
/// Skor dihitung dari kunci dummy lokal: reading x/5, listening x/5,
/// total 100, ambang lulus dummy 60.
class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.exam,
    required this.user,
    required this.score,
    required this.answers,
    required this.autoSubmitted,
  });

  final DummyExam exam;
  final DummyUser user;
  final DummyScore score;
  final Map<int, int> answers;
  final bool autoSubmitted;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Ujian (Dummy)'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              '${user.name} (${user.examineeNumber})',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(exam.title),
            if (autoSubmitted)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Card(
                  color: Color(0xFFFFF3E0),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      'Dikirim otomatis karena waktu habis (dummy).',
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),
            Center(
              child: Column(
                children: <Widget>[
                  Text(
                    '${score.totalScore}',
                    style: const TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('/ 100 (dummy)'),
                  const SizedBox(height: 8),
                  Chip(
                    label: Text(
                      score.passed ? 'LULUS (dummy)' : 'BELUM LULUS (dummy)',
                    ),
                    backgroundColor: score.passed
                        ? UbtKoreaRebuildApp.accentTeal
                        : Colors.grey[300],
                    labelStyle: TextStyle(
                      color: score.passed ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text('Reading'),
                        Text('${score.readingCorrect} / 5 benar'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const Text('Listening'),
                        Text('${score.listeningCorrect} / 5 benar'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Pembahasan (dummy):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ...dummyQuestions.map((q) {
              final mine = answers[q.id];
              final correct = mine == q.correctIndex;
              return Card(
                child: ListTile(
                  leading: Icon(
                    correct ? Icons.check_circle : Icons.cancel,
                    color: correct ? Colors.green : Colors.red,
                  ),
                  title: Text(q.text),
                  subtitle: Text(
                    'Jawabanmu: ${mine == null ? '(tidak dijawab)' : q.options[mine]}\n'
                    'Kunci: ${q.options[q.correctIndex]}',
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => ExamPage(exam: exam, user: user),
                  ),
                );
              },
              child: const Text('Kerjakan Lagi (dummy)'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => ExamListScreen(user: user),
                  ),
                );
              },
              child: const Text('Kembali ke Daftar Ujian'),
            ),
          ],
        ),
      ),
    );
  }
}
