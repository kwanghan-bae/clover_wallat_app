import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter/foundation.dart';
import 'package:clover_wallet_app/utils/platform_check.dart';

/// 광고 관리 서비스 (싱글톤)
/// Google AdMob을 통한 배너 및 리워드 광고 관리
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  bool _isInitialized = false;
  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  // 테스트 광고 ID (프로덕션 배포 전 실제 ID로 교체 필요)
  // Android Real ID
  static const String _androidBannerAdUnitId = 'ca-app-pub-2084827050289409/7528691485';
  // Reward Ad removed as per user request
  static const String _androidRewardedAdUnitId = ''; // Unused
  
  // iOS 테스트 ID
  static const String _iosBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716';
  static const String _iosRewardedAdUnitId = 'ca-app-pub-3940256099942544/1712485313';

  /// 배너 광고 단위 ID
  String get bannerAdUnitId {
    if (kIsWeb) return ''; // Web not supported
    if (isAndroid) {
      return _androidBannerAdUnitId;
    } else if (isIOS) {
      return _iosBannerAdUnitId;
    }
    // Return empty or throw based on preference, but throwing might crash if called on other platforms
    return ''; 
  }

  /// 리워드 광고 단위 ID
  String get rewardedAdUnitId {
    if (kIsWeb) return ''; // Web not supported
    if (isAndroid) {
      return _androidRewardedAdUnitId;
    } else if (isIOS) {
      return _iosRewardedAdUnitId;
    }
    return '';
  }

  /// AdMob 초기화
  Future<void> initialize() async {
    if (kIsWeb) return; // Web skipping

    if (_isInitialized) return;
    
    await MobileAds.instance.initialize();
    _isInitialized = true;
    
    if (kDebugMode) {
      print('AdMob 초기화 완료');
    }
    
    // 리워드 광고 미리 로드
    _loadRewardedAd();
  }

  /// 배너 광고 생성
  BannerAd? createBannerAd({
    required void Function(Ad) onAdLoaded,
    required void Function(Ad, LoadAdError) onAdFailedToLoad,
  }) {
    if (kIsWeb) return null;

    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: onAdLoaded,
        onAdFailedToLoad: onAdFailedToLoad,
      ),
    );
  }

  /// 리워드 광고 로드
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          if (kDebugMode) {
            print('리워드 광고 로드 완료');
          }
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdReady = false;
          if (kDebugMode) {
            print('리워드 광고 로드 실패: ${error.message}');
          }
        },
      ),
    );
  }

  /// 리워드 광고가 준비되었는지 확인
  bool get isRewardedAdReady => _isRewardedAdReady;

  /// 리워드 광고 표시
  /// [onUserEarnedReward] 사용자가 광고를 끝까지 시청했을 때 호출
  Future<bool> showRewardedAd({
    required void Function(int amount) onUserEarnedReward,
  }) async {
    if (!_isRewardedAdReady || _rewardedAd == null) {
      if (kDebugMode) {
        print('리워드 광고가 준비되지 않음');
      }
      return false;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _isRewardedAdReady = false;
        _loadRewardedAd(); // 다음 광고 미리 로드
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _isRewardedAdReady = false;
        _loadRewardedAd();
      },
    );

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onUserEarnedReward(reward.amount.toInt());
      },
    );

    return true;
  }

  /// 리소스 정리
  void dispose() {
    _rewardedAd?.dispose();
  }
}
