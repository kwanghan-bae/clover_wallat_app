import 'dart:convert';

class HistoryModel {
  final int round;
  final List<int> numbers;
  final DateTime date;
  final String? note;

  HistoryModel({
    required this.round,
    required this.numbers,
    required this.date,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'round': round,
      'numbers': numbers,
      'date': date.toIso8601String(),
      'note': note,
    };
  }

  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      round: map['round'],
      numbers: List<int>.from(map['numbers']),
      date: DateTime.parse(map['date']),
      note: map['note'],
    );
  }

  String toJson() => json.encode(toMap());

  factory HistoryModel.fromJson(String source) =>
      HistoryModel.fromMap(json.decode(source));
}
