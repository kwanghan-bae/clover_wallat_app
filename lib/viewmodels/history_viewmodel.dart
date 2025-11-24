import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clover_wallet_app/models/history_model.dart';

class HistoryViewModel extends ChangeNotifier {
  List<HistoryModel> _history = [];
  List<HistoryModel> get history => _history;

  HistoryViewModel() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? historyJson = prefs.getStringList('lotto_history');

    if (historyJson != null) {
      _history = historyJson
          .map((item) => HistoryModel.fromJson(item))
          .toList();
      // Sort by date descending
      _history.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    }
  }

  Future<void> addEntry(HistoryModel entry) async {
    _history.insert(0, entry);
    notifyListeners();
    await _saveHistory();
  }

  Future<void> deleteEntry(int index) async {
    _history.removeAt(index);
    notifyListeners();
    await _saveHistory();
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyJson =
        _history.map((item) => item.toJson()).toList();
    await prefs.setStringList('lotto_history', historyJson);
  }
}
