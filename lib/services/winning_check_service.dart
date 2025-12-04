

import 'package:clover_wallet_app/services/lotto_info_service.dart';

class WinningCheckService {
  final LottoInfoService _lottoInfoService = LottoInfoService();

  Future<Map<String, dynamic>> checkWinnings(int round, List<int> numbers) async {
    try {
      final drawResult = await _lottoInfoService.getDrawResult(round);
      
      final winningNumbers = [
        drawResult['drwtNo1'],
        drawResult['drwtNo2'],
        drawResult['drwtNo3'],
        drawResult['drwtNo4'],
        drawResult['drwtNo5'],
        drawResult['drwtNo6'],
      ];
      final bonusNumber = drawResult['bnusNo'];
      
      int matchCount = 0;
      for (final number in numbers) {
        if (winningNumbers.contains(number)) {
          matchCount++;
        }
      }
      
      final bool matchBonus = numbers.contains(bonusNumber);
      
      int rank = 0;
      int prize = 0;
      String message = '아쉽게도 낙첨되었습니다.';
      
      if (matchCount == 6) {
        rank = 1;
        prize = drawResult['firstWinamnt'];
        message = '축하합니다! 1등 당첨입니다!';
      } else if (matchCount == 5 && matchBonus) {
        rank = 2;
        prize = 50000000;
        message = '축하합니다! 2등 당첨입니다!';
      } else if (matchCount == 5) {
        rank = 3;
        prize = 1500000;
        message = '축하합니다! 3등 당첨입니다!';
      } else if (matchCount == 4) {
        rank = 4;
        prize = 50000;
        message = '축하합니다! 4등 당첨입니다!';
      } else if (matchCount == 3) {
        rank = 5;
        prize = 5000;
        message = '축하합니다! 5등 당첨입니다!';
      }
      
      return {
        'isWinner': rank > 0,
        'rank': rank,
        'prize': prize,
        'message': message,
      };
    } catch (e) {
      return {
        'isWinner': false,
        'rank': 0,
        'prize': 0,
        'message': '당첨 확인 중 오류가 발생했습니다.',
      };
    }
  }
}
