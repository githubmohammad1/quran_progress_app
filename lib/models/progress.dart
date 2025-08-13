class Progress {
  final int id;
  final int student;
  final DateTime date;
  final int pagesListened; // 1-5

  Progress({
    required this.id,
    required this.student,
    required this.date,
    required this.pagesListened,
  });

  factory Progress.fromJson(Map<String, dynamic> j) {
    final rawPages = j['pages_listened'];
    int parsedPages;
    if (rawPages is int) {
      parsedPages = rawPages;
    } else if (rawPages is String) {
      parsedPages = int.tryParse(rawPages) ?? 1;
    } else {
      parsedPages = 1;
    }

    return Progress(
      id: j['id'] as int,
      student: j['student'] as int,
      date: DateTime.parse(j['date'] as String),
      pagesListened: parsedPages,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student': student,
      'date': date.toIso8601String().split('T').first,
      'pages_listened': pagesListened,
    };
  }

  Progress copyWith({
    int? id,
    int? student,
    DateTime? date,
    int? pagesListened,
  }) {
    return Progress(
      id: id ?? this.id,
      student: student ?? this.student,
      date: date ?? this.date,
      pagesListened: pagesListened ?? this.pagesListened,
    );
  }
}
