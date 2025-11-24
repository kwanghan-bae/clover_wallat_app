import 'dart:convert';

class HistoryModel {
  final int round;
  final List<int> numbers;
  final DateTime date;
  final String? note;
  final bool isChecked;
  final int rank;
  final int prize;

  HistoryModel({
    required this.round,
    required this.numbers,
    required this.date,
    this.note,
    this.isChecked = false,
    this.rank = 0,
    this.prize = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'round': round,
      'numbers': numbers,
      'date': date.toIso8601String(),
      'note': note,
      'isChecked': isChecked,
      'rank': rank,
      'prize': prize,
    };
  }

  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      round: map['round'],
      numbers: List<int>.from(map['numbers']),
      date: DateTime.parse(map['date']),
      note: map['note'],
      isChecked: map['isChecked'] ?? false,
      rank: map['rank'] ?? 0,
      prize: map['prize'] ?? 0,
    );
  }

  HistoryModel copyWith({
    int? round,
    List<int>? numbers,
    DateTime? date,
    String? note,
    bool? isChecked,
    int? rank,
    int? prize,
  }) {
    return HistoryModel(
      round: round ?? this.round,
      numbers: numbers ?? this.numbers,
      date: date ?? this.date,
      note: note ?? this.note,
      isChecked: isChecked ?? this.isChecked,
      rank: rank ?? this.rank,
      prize: prize ?? this.prize,
    );
  }

  String toJson() => json.encode(toMap());

  factory HistoryModel.fromJson(String source) =>
      HistoryModel.fromMap(json.decode(source));
}
