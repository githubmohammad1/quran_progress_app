import 'package:flutter/foundation.dart';
import '../models/progress.dart';
import '../services/api_service.dart';

class ProgressProvider with ChangeNotifier {
  final ApiService _api;
  ProgressProvider(this._api);

  final List<Progress> _items = [];
  bool _isLoading = false;

  List<Progress> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  Future<void> fetchProgress({DateTime? date}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final dateStr = date != null ? date.toIso8601String().split('T').first : null;
      final list = await _api.fetchProgress(date: dateStr);
      _items
        ..clear()
        ..addAll(list);
    } catch (e) {
      debugPrint('Fetch progress error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Set<int> recordedStudentIdsForDate(DateTime date) {
    final dateStr = date.toIso8601String().split('T').first;
    return _items
        .where((p) => p.date.toIso8601String().split('T').first == dateStr)
        .map((p) => p.student)
        .toSet();
  }

  Future<Progress?> markProgress({
    required int studentId,
    required DateTime date,
    required int pages,
  }) async {
    final exists = _items.any((p) =>
        p.student == studentId &&
        p.date.toIso8601String().split('T').first == date.toIso8601String().split('T').first);
    if (exists) return null;

    final created = await create(Progress(
      id: 0,
      student: studentId,
      date: date,
      pagesListened: pages,
    ));
    return created;
  }

  Future<Progress?> create(Progress progress) async {
    try {
      final created = await _api.createProgress(progress);
      _items.insert(0, created);
      notifyListeners();
      return created;
    } catch (e) {
      debugPrint('Create progress error: $e');
      return null;
    }
  }

  Future<bool> removeByStudentAndDate(int studentId, DateTime date) async {
    final dateStr = date.toIso8601String().split('T').first;
    final prog = _items.firstWhere(
      (p) =>
          p.student == studentId &&
          p.date.toIso8601String().split('T').first == dateStr,
      orElse: () => null as dynamic,
    );
    if (prog == null) return false;
    return remove(prog.id);
  }

  Future<bool> remove(int id) async {
    try {
      final ok = await _api.deleteProgress(id);
      if (ok) {
        _items.removeWhere((p) => p.id == id);
        notifyListeners();
      }
      return ok;
    } catch (e) {
      debugPrint('Delete progress error: $e');
      return false;
    }
  }
}
