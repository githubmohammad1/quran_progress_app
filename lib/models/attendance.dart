class Attendance {
  final int id;
  final int student; // FK رقم الطالب
  final DateTime date;
  final String dayName;
  final bool isPresent;

  Attendance({
    required this.id,
    required this.student,
    required this.date,
    required this.dayName,
    this.isPresent = false,
  });

  factory Attendance.fromJson(Map<String, dynamic> j) {
    return Attendance(
      id: j['id'] as int,
      student: j['student'] as int,
      date: DateTime.parse(j['date'] as String),
      dayName: j['day_name'] as String,
      isPresent: j['is_present'] ?? true,
    );
    
  }
  factory Attendance.empty() {
    return Attendance(
      id: 0,
      student: 0,
      date: DateTime(2000),
      dayName: '',
      isPresent: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student': student,
      'date': date.toIso8601String().split('T').first, // YYYY-MM-DD
      'day_name': dayName,
    };
  }

  Attendance copyWith({
    int? id,
    int? student,
    DateTime? date,
    String? dayName,
  }) {
    return Attendance(
      id: id ?? this.id,
      student: student ?? this.student,
      date: date ?? this.date,
      dayName: dayName ?? this.dayName,
    );
  }
}
