import 'package:flutter/foundation.dart';
import '../services/api_service.dart';
import '../models/announcement.dart';

class AnnouncementProvider with ChangeNotifier {
  final ApiService _api;
  AnnouncementProvider(this._api);

  final List<Announcement> _items = [];
  bool _isLoading = false;

  List<Announcement> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  Future<void> fetchAnnouncements() async {
    _isLoading = true; notifyListeners();
    try {
      final list = await _api.fetchAnnouncements();
      _items
        ..clear()
        ..addAll(list);
    } catch (e) {
      debugPrint('Fetch announcements error: $e');
    } finally {
      _isLoading = false; notifyListeners();
    }
  }

  Future<Announcement?> create(Announcement a) async {
    try {
      final created = await _api.createAnnouncement(a);
      _items.insert(0, created);
      notifyListeners();
      return created;
    } catch (e) {
      debugPrint('Create announcement error: $e');
      return null;
    }
  }

  Future<Announcement?> update(Announcement a) async {
    try {
      final updated = await _api.updateAnnouncement(a);
      final i = _items.indexWhere((x) => x.id == a.id);
      if (i != -1) _items[i] = updated;
      notifyListeners();
      return updated;
    } catch (e) {
      debugPrint('Update announcement error: $e');
      return null;
    }
  }

  Future<bool> remove(int id) async {
    try {
      final ok = await _api.deleteAnnouncement(id);
      if (ok) {
        _items.removeWhere((x) => x.id == id);
        notifyListeners();
      }
      return ok;
    } catch (e) {
      debugPrint('Delete announcement error: $e');
      return false;
    }
  }
}
