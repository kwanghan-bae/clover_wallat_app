import 'package:flutter/material.dart';

import 'package:clover_wallet_app/viewmodels/history_viewmodel.dart';

class StatisticsViewModel extends ChangeNotifier {
  final HistoryViewModel _historyViewModel;

  StatisticsViewModel({required HistoryViewModel historyViewModel})
      : _historyViewModel = historyViewModel;

  Map<int, int> get numberFrequency {
    final frequency = <int, int>{};
    for (var i = 1; i <= 45; i++) {
      frequency[i] = 0;
    }

    for (final entry in _historyViewModel.history) {
      for (final number in entry.numbers) {
        frequency[number] = (frequency[number] ?? 0) + 1;
      }
    }
    return frequency;
  }

  List<MapEntry<int, int>> get mostFrequentNumbers {
    final sorted = numberFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(5).toList();
  }

  List<MapEntry<int, int>> get leastFrequentNumbers {
    final sorted = numberFrequency.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return sorted.take(5).toList();
  }
}
