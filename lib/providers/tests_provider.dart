import 'package:flutter/foundation.dart';
import '../models/test.dart';
import '../services/api_service.dart';

class TestsProvider extends ChangeNotifier {
  final ApiService api;
  TestsProvider(this.api);

  final List<Test> _items = [];
  bool _loading = false;
  String? _error;

  List<Test> get items => List.unmodifiable(_items);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> fetch() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // ✅ تعديل الاسم ليتوافق مع ApiService
      final data = await api.fetchTests();
      _items
        ..clear()
        ..addAll(data);
    } catch (e) {
      _error = 'تعذر تحميل البيانات';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> create(Test t) async {
    try {
      // ✅ تعديل الاسم
      final created = await api.createTest(t);
      _items.insert(0, created);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> update(Test t) async {
    try {
      // ✅ تعديل الاسم
      final updated = await api.updateTest(t);
      final idx = _items.indexWhere((e) => e.id == updated.id);
      if (idx != -1) {
        _items[idx] = updated;
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    try {
      // ✅ تعديل الاسم
      final ok = await api.deleteTest(id);
      if (ok) {
        _items.removeWhere((e) => e.id == id);
        notifyListeners();
      }
    } catch (e) {
      rethrow;
    }
  }
}
