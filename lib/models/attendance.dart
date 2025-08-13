class Attendance {
  final int id;
  final int studentId;
  final DateTime date;
  final bool present;

  Attendance({
    required this.id,
    required this.studentId,
    required this.date,
    required this.present,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'],
      studentId: json['student'],
      date: DateTime.parse(json['date']),
      present: json['present'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student': studentId,
      'date': date.toIso8601String(),
      'present': present,
    };
  }
}
