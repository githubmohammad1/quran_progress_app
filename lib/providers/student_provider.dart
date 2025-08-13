// lib/providers/student_provider.dart
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/student.dart';
import '../services/api_service.dart';

class StudentProvider extends ChangeNotifier {
  final ApiService _api = ApiService(baseUrl: '');

  List<Student> _items = [];
  bool _isLoading = false;
  String? _error;

  List<Student> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAll({bool force = true}) async {
    if (_items.isNotEmpty && !force) return;
    _setLoading(true);
    try {
      _items = await _api.fetchStudents();
      _error = null;
    } on DioException catch (e) {
      _error = _msg(e);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<Student?> create(Student s) async {
    try {
      final created = await _api.createStudent(s);
      _items.insert(0, created);
      notifyListeners();
      return created;
    } on DioException catch (e) {
      _error = _msg(e);
      notifyListeners();
      return null;
    }
  }

  Future<Student?> update(Student s) async {
    try {
      final updated = await _api.updateStudent(s);
      final i = _items.indexWhere((x) => x.id == updated.id);
      if (i >= 0) {
        _items[i] = updated;
      } else {
        _items.insert(0, updated);
      }
      notifyListeners();
      return updated;
    } on DioException catch (e) {
      _error = _msg(e);
      notifyListeners();
      return null;
    }
  }

  Future<bool> remove(int id) async {
    try {
      final ok = await _api.deleteStudent(id);
      if (ok) {
        _items.removeWhere((x) => x.id == id);
        notifyListeners();
      }
      return ok;
    } on DioException catch (e) {
      _error = _msg(e);
      notifyListeners();
      return false;
    }
  }

  Student? getById(int id) {
    try { return _items.firstWhere((s) => s.id == id); } catch (_) { return null; }
  }

  void _setLoading(bool v) { _isLoading = v; notifyListeners(); }

  String _msg(DioException e) {
    final sc = e.response?.statusCode;
    final detail = e.response?.data?.toString() ?? '';
    return 'خطأ${sc != null ? ' ($sc)' : ''}: ${e.message ?? ''} $detail';
  }
}
