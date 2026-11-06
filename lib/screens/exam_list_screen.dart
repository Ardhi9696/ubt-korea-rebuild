import 'package:flutter/material.dart';

import '../dummy_data.dart';
import 'exam_page.dart';

/// Daftar ujian dummy — meniru `exam_list` di app Korea.
/// Semua ujian memakai bank soal dummy yang sama (10 soal).
class ExamListScreen extends StatelessWidget {
  const ExamListScreen({super.key, required this.user});

  final DummyUser user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Ujian (Dummy)')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: <Widget>[
                const Icon(Icons.person),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${user.name} (${user.examineeNumber})',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const Chip(label: Text('DUMMY')),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: dummyExams.length,
              itemBuilder: (context, index) {
                final exam = dummyExams[index];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading:
                        const Icon(Icons.assignment, size: 36),
                    title: Text(exam.title),
                    subtitle: Text(
                      '${exam.questionCount} soal • '
                      '${exam.durationMinutes} menit',
                    ),
                    trailing: Chip(label: Text(exam.status)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute<void>(
                          builder: (_) =>
                              ExamPage(exam: exam, user: user),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
