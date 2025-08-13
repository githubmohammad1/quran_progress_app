import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

// استيراد النماذج
import '../models/student.dart';
import '../models/test.dart';
import '../models/attendance.dart';
import '../models/announcement.dart';
import '../models/payment.dart';
import '../models/progress.dart';

class ApiService {
  // Singleton
  static final ApiService _instance = ApiService._internal();
  factory ApiService({required String baseUrl}) => _instance;

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: apiBase,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  static const String baseHost =
      'https://mohammadpythonanywher1.pythonanywhere.com';
  static const String apiBase = '$baseHost/api/v1/';

  late final Dio _dio;

  // -------------------------
  // Students
  // -------------------------
  Future<List<Student>> fetchStudents() async {
    final res = await _dio.get('students/');
    return (res.data as List)
        .map((e) => Student.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Student> fetchStudent(int id) async {
    final res = await _dio.get('students/$id/');
    return Student.fromJson(res.data as Map<String, dynamic>);
  }

Future<Student> createStudent(Student student) async {
  final data = Map<String, dynamic>.from(student.toJson());

  // لا ترسل id عند الإنشاء
  data.remove('id');

  // تأكد من تنسيق التاريخ
  if (data['registration_date'] is String) {
    final s = data['registration_date'] as String;
    data['registration_date'] = s.contains('T') ? s.split('T').first : s;
  }

  // حوّل الفراغ إلى null للحقول الاختيارية
  for (final k in ['father_name', 'mother_name', 'phone_number', 'email', 'address']) {
    final v = data[k];
    if (v == null) continue;
    if (v is String && v.trim().isEmpty) data[k] = null;
  }

  try {
    final res = await _dio.post('students/', data: data);
    return Student.fromJson(res.data as Map<String, dynamic>);
  } on DioException catch (e) {
    // اطبع تفاصيل الخطأ من السيرفر لتعرف الحقل المسبب
    debugPrint('Create student failed: ${e.response?.statusCode} ${e.response?.data}');
    rethrow;
  }
}

Future<Student> updateStudent(Student student) async {
  final data = Map<String, dynamic>.from(student.toJson());
  data.remove('id');

  if (data['registration_date'] is String) {
    final s = data['registration_date'] as String;
    data['registration_date'] = s.contains('T') ? s.split('T').first : s;
  }
  for (final k in ['father_name', 'mother_name', 'phone_number', 'email', 'address']) {
    final v = data[k];
    if (v == null) continue;
    if (v is String && v.trim().isEmpty) data[k] = null;
  }

  try {
    final res = await _dio.put('students/${student.id}/', data: data);
    return Student.fromJson(res.data as Map<String, dynamic>);
  } on DioException catch (e) {
    debugPrint('Update student failed: ${e.response?.statusCode} ${e.response?.data}');
    rethrow;
  }
}

  Future<bool> deleteStudent(int id) async {
    final res = await _dio.delete('students/$id/');
    return res.statusCode == 204 || res.statusCode == 200;
  }

  // -------------------------
  // Tests
  // -------------------------
  Future<List<Test>> fetchTests() async {
    final res = await _dio.get('tests/');
    return (res.data as List)
        .map((e) => Test.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Test> fetchTest(int id) async {
    final res = await _dio.get('tests/$id/');
    return Test.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Test> createTest(Test test) async {
    final res = await _dio.post('tests/', data: test.toJson());
    return Test.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Test> updateTest(Test test) async {
    final res = await _dio.put('tests/${test.id}/', data: test.toJson());
    return Test.fromJson(res.data as Map<String, dynamic>);
  }

  Future<bool> deleteTest(int id) async {
    final res = await _dio.delete('tests/$id/');
    return res.statusCode == 204 || res.statusCode == 200;
  }

  // -------------------------
  // Attendance
  // -------------------------
Future<List<Attendance>> fetchAttendances({String? date}) async {
  final res = await _dio.get(
    'attendances/',
    queryParameters: { if (date != null) 'date': date },
  );
  final data = res.data;
  if (data is List) {
    return data
        .map((e) => Attendance.fromJson(e as Map<String, dynamic>))
        .toList();
  } else if (data is Map && data.containsKey('results')) {
    return (data['results'] as List)
        .map((e) => Attendance.fromJson(e as Map<String, dynamic>))
        .toList();
  } else {
    return [];
  }
}

Future<Attendance> createAttendance(Attendance attendance) async {
  final data = Map<String, dynamic>.from(attendance.toJson());
  data.remove('id');
  final res = await _dio.post('attendances/', data: data);
  return Attendance.fromJson(res.data as Map<String, dynamic>);
}

Future<Attendance> updateAttendance(Attendance attendance) async {
  final data = Map<String, dynamic>.from(attendance.toJson());
  data.remove('id');
  final res = await _dio.put('attendances/${attendance.id}/', data: data);
  return Attendance.fromJson(res.data as Map<String, dynamic>);
}

Future<bool> deleteAttendance(int id) async {
  final res = await _dio.delete('attendances/$id/');
  return res.statusCode == 204 || res.statusCode == 200;
}
  // -------------------------
// Announcements
// -------------------------
Future<List<Announcement>> fetchAnnouncements({int? page}) async {
  final res = await _dio.get(
    'announcements/',
    queryParameters: { if (page != null) 'page': page },
  );
  final data = res.data;
  if (data is List) {
    return data.map((e) => Announcement.fromJson(e as Map<String, dynamic>)).toList();
  } else if (data is Map && data.containsKey('results')) {
    return (data['results'] as List)
        .map((e) => Announcement.fromJson(e as Map<String, dynamic>))
        .toList();
  } else {
    return [];
  }
}

Future<Announcement> fetchAnnouncement(int id) async {
  final res = await _dio.get('announcements/$id/');
  return Announcement.fromJson(res.data as Map<String, dynamic>);
}

Future<Announcement> createAnnouncement(Announcement a) async {
  final data = Map<String, dynamic>.from(a.toJson());
  data.remove('id');
  data.remove('date'); // لا نرسل date
  final res = await _dio.post('announcements/', data: data);
  return Announcement.fromJson(res.data as Map<String, dynamic>);
}

Future<Announcement> updateAnnouncement(Announcement a) async {
  final data = Map<String, dynamic>.from(a.toJson());
  data.remove('id');
  data.remove('date');
  final res = await _dio.put('announcements/${a.id}/', data: data);
  return Announcement.fromJson(res.data as Map<String, dynamic>);
}

Future<bool> deleteAnnouncement(int id) async {
  final res = await _dio.delete('announcements/$id/');
  return res.statusCode == 204 || res.statusCode == 200;
}

  // -------------------------
  // Payments
  // -------------------------
  Future<List<Payment>> fetchPayments() async {
    final res = await _dio.get('payments/');
    return (res.data as List)
        .map((e) => Payment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Payment> fetchPayment(int id) async {
    final res = await _dio.get('payments/$id/');
    return Payment.fromJson(res.data as Map<String, dynamic>);
  }

 Future<Payment> createPayment(Payment payment) async {
  final data = Map<String, dynamic>.from(payment.toJson());
  data.remove('id'); // لا ترسل ID عند الإنشاء
  final res = await _dio.post('payments/', data: data);
  return Payment.fromJson(res.data as Map<String, dynamic>);
}

Future<Payment> updatePayment(Payment payment) async {
  final data = Map<String, dynamic>.from(payment.toJson());
  data.remove('id');
  final res = await _dio.put('payments/${payment.id}/', data: data);
  return Payment.fromJson(res.data as Map<String, dynamic>);
}

  Future<bool> deletePayment(int id) async {
    final res = await _dio.delete('payments/$id/');
    return res.statusCode == 204 || res.statusCode == 200;
  }

  // -------------------------
  // Progress
  // -------------------------
 Future<List<Progress>> fetchProgress({String? date}) async {
  final res = await _dio.get(
    'progress/',
    queryParameters: { if (date != null) 'date': date },
  );
  final data = res.data;
  if (data is List) {
    return data.map((e) => Progress.fromJson(e)).toList();
  } else if (data is Map && data.containsKey('results')) {
    return (data['results'] as List)
        .map((e) => Progress.fromJson(e))
        .toList();
  } else {
    return [];
  }
}

Future<Progress> createProgress(Progress progress) async {
  final data = Map<String, dynamic>.from(progress.toJson());
  data.remove('id');
  final res = await _dio.post('progress/', data: data);
  return Progress.fromJson(res.data);
}

Future<Progress> updateProgress(Progress progress) async {
  final data = Map<String, dynamic>.from(progress.toJson());
  data.remove('id');
  final res = await _dio.put('progress/${progress.id}/', data: data);
  return Progress.fromJson(res.data);
}

Future<bool> deleteProgress(int id) async {
  final res = await _dio.delete('progress/$id/');
  return res.statusCode == 204 || res.statusCode == 200;
}
}
