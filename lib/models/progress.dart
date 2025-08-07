class Progress {
  final int id;
  final int student;
  final String date;
  final int pagesListened;

  Progress({
    required this.id,
    required this.student,
    required this.date,
    required this.pagesListened,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      id: json['id'],
      student: json['student'],
      date: json['date'],
      pagesListened: json['pages_listened'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'student': student, 'date': date, 'pages_listened': pagesListened};
  }
}
