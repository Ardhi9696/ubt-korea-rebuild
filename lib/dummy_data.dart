/// Data DUMMY untuk rekonstruksi belajar.
///
/// Semua nama, soal, dan kunci jawaban dibuat sendiri dari nol.
/// Bukan dari app asli, bukan dari soal ujian resmi mana pun,
/// dan tidak ada network call — semuanya tinggal di file ini.

class DummyUser {
  const DummyUser({required this.name, required this.examineeNumber});

  final String name;
  final String examineeNumber;
}

const DummyUser dummyUser =
    DummyUser(name: 'Dummy Peserta', examineeNumber: 'DUMMY-0001');

class DummyExam {
  const DummyExam({
    required this.id,
    required this.title,
    required this.questionCount,
    required this.durationMinutes,
    required this.status,
  });

  final String id;
  final String title;
  final int questionCount;
  final int durationMinutes;
  final String status; // 'Tersedia' atau 'Selesai (dummy)'
}

const List<DummyExam> dummyExams = <DummyExam>[
  DummyExam(
    id: 'dummy-set-01',
    title: 'Dummy UBT Set 01 — Reading + Listening',
    questionCount: 10,
    durationMinutes: 10,
    status: 'Tersedia',
  ),
  DummyExam(
    id: 'dummy-set-02',
    title: 'Dummy UBT Set 02 — Latihan Reading',
    questionCount: 10,
    durationMinutes: 10,
    status: 'Tersedia',
  ),
  DummyExam(
    id: 'dummy-set-03',
    title: 'Dummy UBT Set 03 — Latihan Cepat',
    questionCount: 10,
    durationMinutes: 10,
    status: 'Selesai (dummy)',
  ),
];

class DummyQuestion {
  const DummyQuestion({
    required this.id,
    required this.section, // 'reading' atau 'listening'
    required this.text,
    required this.options,
    required this.correctIndex,
  });

  final int id;
  final String section;
  final String text;
  final List<String> options;
  final int correctIndex;
}

/// 10 soal dummy buatan sendiri: 5 reading + 5 listening.
/// Soal listening memakai satu file nada test yang sama
/// (`assets/audio/test_tone.mp3`, deret nada sine buatan sendiri) —
/// di app asli hanya ada suara, bukan teks.
const List<DummyQuestion> dummyQuestions = <DummyQuestion>[
  // ---- Reading (5) ----
  DummyQuestion(
    id: 1,
    section: 'reading',
    text: 'Kata ‘학교’ artinya …',
    options: <String>['Sekolah', 'Rumah sakit', 'Pasar', 'Stasiun'],
    correctIndex: 0,
  ),
  DummyQuestion(
    id: 2,
    section: 'reading',
    text: 'Lawan kata ‘크다’ adalah …',
    options: <String>['작다', '높다', '빠르다', '많다'],
    correctIndex: 0,
  ),
  DummyQuestion(
    id: 3,
    section: 'reading',
    text: '‘저는 어제 친구를 만났어요.’ — Kapan bertemu teman?',
    options: <String>['Hari ini', 'Kemarin', 'Besok', 'Minggu lalu'],
    correctIndex: 1,
  ),
  DummyQuestion(
    id: 4,
    section: 'reading',
    text: '‘물’ dalam bahasa Indonesia adalah …',
    options: <String>['Air', 'Api', 'Tanah', 'Udara'],
    correctIndex: 0,
  ),
  DummyQuestion(
    id: 5,
    section: 'reading',
    text: '‘감사합니다’ diucapkan ketika …',
    options: <String>[
      'Berterima kasih',
      'Meminta maaf',
      'Menyapa di pagi hari',
      'Berpamitan pulang',
    ],
    correctIndex: 0,
  ),
  // ---- Listening (5) ----
  DummyQuestion(
    id: 6,
    section: 'listening',
    text: '[Audio dummy] “사과를 먹어요.” — Apa yang dimakan?',
    options: <String>['Apel', 'Pisang', 'Roti', 'Nasi'],
    correctIndex: 0,
  ),
  DummyQuestion(
    id: 7,
    section: 'listening',
    text: '[Audio dummy] “지금 몇 시예요?” — “세 시예요.” — Jam berapa?',
    options: <String>['Jam 2', 'Jam 3', 'Jam 4', 'Jam 5'],
    correctIndex: 1,
  ),
  DummyQuestion(
    id: 8,
    section: 'listening',
    text: '[Audio dummy] “어디에 가요?” — “학교에 가요.” — Ke mana dia pergi?',
    options: <String>['Sekolah', 'Rumah', 'Pasar', 'Bank'],
    correctIndex: 0,
  ),
  DummyQuestion(
    id: 9,
    section: 'listening',
    text: '[Audio dummy] “이 사람은 누구예요?” — “선생님이에요.” — Siapa dia?',
    options: <String>['Guru', 'Dokter', 'Polisi', 'Koki'],
    correctIndex: 0,
  ),
  DummyQuestion(
    id: 10,
    section: 'listening',
    text: '[Audio dummy] “날씨가 어때요?” — “비가 와요.” — Bagaimana cuacanya?',
    options: <String>['Hujan', 'Cerah', 'Salju', 'Berangin'],
    correctIndex: 0,
  ),
];

class DummyScore {
  const DummyScore({
    required this.readingCorrect,
    required this.listeningCorrect,
  });

  final int readingCorrect; // dari 5
  final int listeningCorrect; // dari 5

  int get totalCorrect => readingCorrect + listeningCorrect;

  /// 10 soal x 10 poin = 100.
  int get totalScore => totalCorrect * 10;

  /// Ambang lulus dummy: 60.
  bool get passed => totalScore >= 60;
}

/// Hitung skor dari kunci dummy lokal.
DummyScore scoreDummyAnswers(Map<int, int> answers) {
  var reading = 0;
  var listening = 0;
  for (final q in dummyQuestions) {
    if (answers[q.id] == q.correctIndex) {
      if (q.section == 'reading') {
        reading++;
      } else {
        listening++;
      }
    }
  }
  return DummyScore(readingCorrect: reading, listeningCorrect: listening);
}
