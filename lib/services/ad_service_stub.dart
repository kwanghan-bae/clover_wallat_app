
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  /// 배너 광고 단위 ID
  String get bannerAdUnitId => '';

  /// 리워드 광고 단위 ID
  String get rewardedAdUnitId => '';

  /// AdMob 초기화
  Future<void> initialize() async {
    // Web: Do nothing
  }

  /// 배너 광고 생성 (Stub - returns null)
  dynamic createBannerAd({
    required Function(dynamic) onAdLoaded,
    required Function(dynamic, dynamic) onAdFailedToLoad,
  }) {
    return null;
  }

  /// 리워드 광고 표시 (Stub)
  Future<bool> showRewardedAd({
    required void Function(int amount) onUserEarnedReward,
  }) async {
    return false;
  }

  bool get isRewardedAdReady => false;

  void dispose() {}
}
