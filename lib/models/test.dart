class Test {
  final int id;
  final int student;           // نفس اسم الحقل في الـ API
  final int partNumber;
  final String grade;          // 'جيد' | 'جيد جدًا' | 'ممتاز'
  final DateTime date;
  final String? note;

  Test({
    required this.id,
    required this.student,
    required this.partNumber,
    required this.grade,
    required this.date,
    this.note,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['id'],
      student: json['student'],
      partNumber: json['part_number'],
      grade: json['grade'],
      date: DateTime.parse(json['date']),
      note: json['note'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student': student,
      'part_number': partNumber,
      'grade': grade,
      'date': date.toIso8601String().split('T').first, // حتى يقرأه DRF كـ Date
      'note': note,
    };
  }
}
