import 'dart:convert';

enum LottoGameStatus {
  PENDING,
  WINNING_1,
  WINNING_2,
  WINNING_3,
  WINNING_4,
  WINNING_5,
  LOSING,
}

class LottoGame {
  final int id;
  final LottoGameStatus status;
  final int number1;
  final int number2;
  final int number3;
  final int number4;
  final int number5;
  final int number6;
  final DateTime createdAt;

  LottoGame({
    required this.id,
    required this.status,
    required this.number1,
    required this.number2,
    required this.number3,
    required this.number4,
    required this.number5,
    required this.number6,
    required this.createdAt,
  });

  factory LottoGame.fromJson(Map<String, dynamic> json) {
    return LottoGame(
      id: json['id'] ?? 0,
      status: _parseStatus(json['status']),
      number1: json['number1'] ?? 0,
      number2: json['number2'] ?? 0,
      number3: json['number3'] ?? 0,
      number4: json['number4'] ?? 0,
      number5: json['number5'] ?? 0,
      number6: json['number6'] ?? 0,
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  static LottoGameStatus _parseStatus(String? status) {
    if (status == null) return LottoGameStatus.PENDING;
    try {
      return LottoGameStatus.values.firstWhere(
        (e) => e.toString().split('.').last == status,
        orElse: () => LottoGameStatus.PENDING,
      );
    } catch (e) {
      return LottoGameStatus.PENDING;
    }
  }
  
  List<int> get numbers => [number1, number2, number3, number4, number5, number6];
}
