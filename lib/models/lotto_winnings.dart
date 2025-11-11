class LottoWinnings {
  final String message;
  final List<int>? winningNumbers;
  final List<UserWinningTicket>? userWinningTickets;

  LottoWinnings({
    required this.message,
    this.winningNumbers,
    this.userWinningTickets,
  });

  factory LottoWinnings.fromJson(Map<String, dynamic> json) {
    return LottoWinnings(
      message: json['message'],
      winningNumbers: json['winningNumbers'] != null
          ? List<int>.from(json['winningNumbers'])
          : null,
      userWinningTickets: json['userWinningTickets'] != null
          ? (json['userWinningTickets'] as List)
              .map((ticket) => UserWinningTicket.fromJson(ticket))
              .toList()
          : null,
    );
  }
}

class UserWinningTicket {
  final int round;
  final List<int> userNumbers;
  final List<int> matchedNumbers;
  final String rank;

  UserWinningTicket({
    required this.round,
    required this.userNumbers,
    required this.matchedNumbers,
    required this.rank,
  });

  factory UserWinningTicket.fromJson(Map<String, dynamic> json) {
    return UserWinningTicket(
      round: json['round'],
      userNumbers: List<int>.from(json['userNumbers']),
      matchedNumbers: List<int>.from(json['matchedNumbers']),
      rank: json['rank'],
    );
  }
}
