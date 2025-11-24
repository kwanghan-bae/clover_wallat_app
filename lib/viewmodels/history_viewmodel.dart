import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clover_wallet_app/models/history_model.dart';
import 'package:clover_wallet_app/services/winning_check_service.dart';

class HistoryViewModel extends ChangeNotifier {
  final WinningCheckService _winningCheckService;
  List<HistoryModel> _history = [];
  List<HistoryModel> get history => _history;

  HistoryViewModel({required WinningCheckService winningCheckService})
      : _winningCheckService = winningCheckService {
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

  Future<void> checkEntry(int index) async {
    final entry = _history[index];
    try {
      final result = await _winningCheckService.checkWinnings(entry.round, entry.numbers);
      final isWinner = result['isWinner'] as bool;
      final rank = result['rank'] as int;
      final prize = result['prize'] as int;

      final updatedEntry = entry.copyWith(
        isChecked: true,
        rank: isWinner ? rank : 0,
        prize: isWinner ? prize : 0,
      );

      _history[index] = updatedEntry;
      notifyListeners();
      await _saveHistory();
    } catch (e) {
      // print('Error checking winnings: $e');
      // Handle error
    }
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> historyJson =
        _history.map((item) => item.toJson()).toList();
    await prefs.setStringList('lotto_history', historyJson);
  }
}
