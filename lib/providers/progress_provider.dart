import 'package:flutter/material.dart';
import '../models/progress.dart';
import '../services/api_service.dart';

class ProgressProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  List<Progress> items = [];
  bool loading = false;

  Future<void> loadProgress() async {
    loading = true;
    notifyListeners();

    items = await _api.fetchProgressList();

    loading = false;
    notifyListeners();
  }

  Future<void> addProgress(Progress prog) async {
    final created = await _api.createProgress(prog);
    items.add(created);
    notifyListeners();
  }
}
