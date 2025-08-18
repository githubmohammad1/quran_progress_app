import 'package:flutter/foundation.dart';
import '../models/attendance.dart';
import '../services/api_service.dart';

class AttendanceProvider with ChangeNotifier {
  final ApiService _api;
  AttendanceProvider(this._api);

  final List<Attendance> _items = [];
  bool _isLoading = false;

  List<Attendance> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  // جلب سجلات الحضور (اختياريًا بتاريخ محدد)
Future<void> fetchAttendances({DateTime? date}) async {
  _isLoading = true;
  notifyListeners();
  try {
    final dateStr =
        date != null ? date.toIso8601String().split('T').first : null;

    // جلب القائمة من الـ API
    final list = await _api.fetchAttendances(date: dateStr);

    // إضافة قيمة isPresent = true لكل سجل تم إرجاعه
    final withPresence = list
        .map((a) => Attendance(
              id: a.id,
              student: a.student,
              date: a.date,
              dayName: a.dayName,
              isPresent: true, // حاضر لأن عنده سجل
            ))
        .toList();

    _items
      ..clear()
      ..addAll(withPresence);

  } catch (e) {
    debugPrint('Fetch attendances error: $e');
  } finally {
    _isLoading = false;
    notifyListeners();
  }
}

// مجموعة IDs للطلاب الحاضرين في تاريخ معيّن اعتمادًا على العناصر الحالية
Set<int> presentStudentIdsForDate(DateTime date) {
  final dateStr = date.toIso8601String().split('T').first;
  return _items
      .where((a) => a.date.toIso8601String().split('T').first == dateStr)
      .map((a) => a.student)
      .toSet();
}
  Future<Attendance?> create(Attendance a) async {
    try {
      final created = await _api.createAttendance(a);
      _items.insert(0, created);
      notifyListeners();
      return created;
    } catch (e) {
      debugPrint('Create attendance error: $e');
      return null;
    }
  }

  Future<Attendance?> update(Attendance a) async {
    try {
      final updated = await _api.updateAttendance(a);
      final idx = _items.indexWhere((x) => x.id == a.id);
      if (idx != -1) _items[idx] = updated;
      notifyListeners();
      return updated;
    } catch (e) {
      debugPrint('Update attendance error: $e');
      return null;
    }
  }

  Future<bool> remove(int id) async {
    try {
      final ok = await _api.deleteAttendance(id);
      if (ok) {
        _items.removeWhere((x) => x.id == id);
        notifyListeners();
      }
      return ok;
    } catch (e) {
      debugPrint('Delete attendance error: $e');
      return false;
    }
  }

  // تعليم "حاضر" لطالب معيّن بتاريخ معيّن
  Future<Attendance?> markPresent({
    required int studentId,
    required DateTime date,
    required String dayName,
  }) async {
    // تجنّب التكرار لنفس اليوم
    final dateStr = date.toIso8601String().split('T').first;
    final exists = _items.any((a) =>
        a.student == studentId &&
        a.date.toIso8601String().split('T').first == dateStr);
    if (exists) return null; // بالفعل حاضر

    final created = await create(
      Attendance(id: 0, student: studentId, date: date, dayName: dayName),
    );
    return created;
  }

  // إلغاء "حاضر" لهذا الطالب في هذا التاريخ (يصبح غائب)
  Future<bool> unmarkPresent({
    required int studentId,
    required DateTime date,
  }) async {
    final dateStr = date.toIso8601String().split('T').first;
    final att = _items.firstWhere(
      (a) =>
          a.student == studentId &&
          a.date.toIso8601String().split('T').first == dateStr,
      orElse: () => null as dynamic,
    );
    if (att == null) return false;
    return await remove(att.id);
  }
}
