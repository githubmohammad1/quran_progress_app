import 'package:flutter/foundation.dart';
import '../models/payment.dart';
import '../services/api_service.dart';

class PaymentProvider with ChangeNotifier {
  final ApiService _api;
  PaymentProvider(this._api);

  final List<Payment> _items = [];
  bool _isLoading = false;

  List<Payment> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  /// جلب كل الدفعات من الـ API
  Future<void> fetchPayments({int? studentId}) async {
    _isLoading = true;
    notifyListeners();
    try {
      final list = await _api.fetchPayments();
      _items
        ..clear()
        ..addAll(list);
    } catch (e) {
      debugPrint('Fetch payments error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// جلب دفعة واحدة وتحديثها في القائمة إن كانت موجودة
  Future<Payment?> fetchPayment(int id) async {
    try {
      final payment = await _api.fetchPayment(id);
      final idx = _items.indexWhere((p) => p.id == id);
      if (idx != -1) {
        _items[idx] = payment;
        notifyListeners();
      }
      return payment;
    } catch (e) {
      debugPrint('Fetch payment error: $e');
      return null;
    }
  }

  /// إضافة دفعة جديدة
  Future<Payment?> create(Payment payment) async {
    try {
      final created = await _api.createPayment(payment);
      _items.insert(0, created);
      notifyListeners();
      return created;
    } catch (e) {
      debugPrint('Create payment error: $e');
      return null;
    }
  }

  /// تعديل دفعة
  Future<Payment?> update(Payment payment) async {
    try {
      final updated = await _api.updatePayment(payment);
      final idx = _items.indexWhere((p) => p.id == payment.id);
      if (idx != -1) {
        _items[idx] = updated;
        notifyListeners();
      }
      return updated;
    } catch (e) {
      debugPrint('Update payment error: $e');
      return null;
    }
  }

  /// حذف دفعة
  Future<bool> remove(int id) async {
    try {
      final ok = await _api.deletePayment(id);
      if (ok) {
        _items.removeWhere((p) => p.id == id);
        notifyListeners();
      }
      return ok;
    } catch (e) {
      debugPrint('Delete payment error: $e');
      return false;
    }
  }
}
