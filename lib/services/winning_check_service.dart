

class WinningCheckService {
  // Mock implementation for MVP as backend requires userId
  // In a real app, this would call /v1/lotto/check-winnings
  Future<Map<String, dynamic>> checkWinnings(int round, List<int> numbers) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    // Simple mock logic: if numbers contain '7', it's a winner!
    if (numbers.contains(7)) {
      return {
        'isWinner': true,
        'rank': 5,
        'prize': 5000,
        'message': '축하합니다! 5등 당첨입니다.',
      };
    } else {
      return {
        'isWinner': false,
        'rank': 0,
        'prize': 0,
        'message': '아쉽게도 낙첨되었습니다.',
      };
    }
  }
}
