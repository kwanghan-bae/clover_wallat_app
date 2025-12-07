class BadgeModel {
  final String code;
  final String displayName;
  final String description;
  final String emoji;

  BadgeModel({
    required this.code,
    required this.displayName,
    required this.description,
    required this.emoji,
  });

  factory BadgeModel.fromCode(String code) {
    switch (code) {
      case 'FIRST_WIN':
        return BadgeModel(
          code: code,
          displayName: '첫 당첨',
          description: '첫 번째 당첨을 축하합니다!',
          emoji: '🎉',
        );
      case 'LUCKY_1ST':
        return BadgeModel(
          code: code,
          displayName: '1등 당첨자',
          description: '1등에 당첨되었습니다!',
          emoji: '🏆',
        );
      case 'FREQUENT_PLAYER':
        return BadgeModel(
          code: code,
          displayName: '단골 플레이어',
          description: '10회 이상 참여하셨습니다',
          emoji: '🎯',
        );
      case 'VETERAN':
        return BadgeModel(
          code: code,
          displayName: '베테랑',
          description: '50회 이상 참여하셨습니다',
          emoji: '⭐',
        );
      case 'DREAM_MASTER':
        return BadgeModel(
          code: code,
          displayName: '꿈 해몽 전문가',
          description: '꿈 해몽 방식으로 구매',
          emoji: '💭',
        );
      case 'SAJU_EXPERT':
        return BadgeModel(
          code: code,
          displayName: '사주 전문가',
          description: '사주 방식으로 구매',
          emoji: '🔮',
        );
      case 'STATS_GENIUS':
        return BadgeModel(
          code: code,
          displayName: '통계 천재',
          description: '통계 분석 방식으로 구매',
          emoji: '📊',
        );
      case 'HOROSCOPE_BELIEVER':
        return BadgeModel(
          code: code,
          displayName: '별자리 신봉자',
          description: '별자리 방식으로 구매',
          emoji: '♈',
        );
      case 'NATURE_LOVER':
        return BadgeModel(
          code: code,
          displayName: '자연 애호가',
          description: '풍수지리 방식으로 구매',
          emoji: '🌿',
        );
      default:
        return BadgeModel(
          code: code,
          displayName: '알 수 없는 뱃지',
          description: '',
          emoji: '❓',
        );
    }
  }

  static List<BadgeModel> fromCodes(List<String> codes) {
    return codes.map((code) => BadgeModel.fromCode(code)).toList();
  }
}
