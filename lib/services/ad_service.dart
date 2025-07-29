import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'premium_service.dart';

/// Strategic AdService for non-intrusive rewarded video ads
/// Implements frequency capping and time-based constraints to maintain good UX
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  static AdService get instance => _instance;

  SharedPreferences? _prefs;
  RewardedAd? _rewardedAd;
  BannerAd? _bannerAd;
  bool _isRewardedAdReady = false;
  bool _isBannerAdReady = false;
  bool _isLoadingAd = false;
  bool _isLoadingBannerAd = false;
  final PremiumService _premiumService = PremiumService();

  // Ad Unit IDs - Using test ads for development
  // TODO: Switch to production ad units before release
  static const String _rewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917'; // Google's test rewarded ad unit
  static const String _bannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111'; // Google's test banner ad unit

  // Frequency capping settings
  static const int _interactionFrequency = 4; // Show ad every 4th interaction
  static const int _minTimeBetweenAds = 60; // Minimum 60 seconds between ads

  // SharedPreferences keys
  static const String _interactionCountKey = 'ad_interaction_count';
  static const String _lastAdShowTimeKey = 'last_ad_show_time';

  /// Initialize the AdService
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();

    // Check if user has premium access
    final isPremium = await _premiumService.isPremiumUser();

    if (isPremium) {
      debugPrint('👑 Premium user detected - ads completely disabled');
      return; // Skip all ad initialization for premium users
    }

    // Initialize Mobile Ads SDK only for free users
    await MobileAds.instance.initialize();

    debugPrint(
        '🎬 AdService: Initialized with strategic rewarded ads for free users');
    debugPrint('🧪 Using test ad units for development');

    // Pre-load the first ad
    _loadRewardedAd();
  }

  /// Load rewarded ad
  void _loadRewardedAd() {
    if (_isLoadingAd) return;

    _isLoadingAd = true;
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          _isLoadingAd = false;
          debugPrint('✅ Rewarded ad loaded successfully');
        },
        onAdFailedToLoad: (error) {
          debugPrint('❌ Rewarded ad failed to load: $error');
          _isRewardedAdReady = false;
          _isLoadingAd = false;
          // Retry loading after a delay
          Future.delayed(const Duration(seconds: 30), () {
            _loadRewardedAd();
          });
        },
      ),
    );
  }

  /// Check if an ad should be shown based on frequency capping and time constraints
  Future<bool> shouldShowAd() async {
    // Always return false for premium users (no ads)
    final isPremium = await _premiumService.isPremiumUser();
    if (isPremium) {
      debugPrint('👑 Premium user - ad skipped');
      return false;
    }

    await _initPrefs();

    // Increment interaction count
    final currentCount = _prefs!.getInt(_interactionCountKey) ?? 0;
    final newCount = currentCount + 1;
    await _prefs!.setInt(_interactionCountKey, newCount);

    // Check frequency
    if (newCount % _interactionFrequency != 0) {
      return false;
    }

    // Check time constraint
    final lastShowTime = _prefs!.getInt(_lastAdShowTimeKey) ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    if (currentTime - lastShowTime < _minTimeBetweenAds) {
      debugPrint(
          '⏰ Ad blocked by time constraint (${currentTime - lastShowTime}s since last ad)');
      return false;
    }

    return true;
  }

  /// Show rewarded ad if conditions are met
  /// Returns true if ad was shown, false otherwise
  Future<bool> showRewardedAd({
    VoidCallback? onAdClosed,
    VoidCallback? onUserEarnedReward,
    VoidCallback? onAdFailed,
  }) async {
    // Premium users bypass all ads completely
    final isPremium = await _premiumService.isPremiumUser();
    if (isPremium) {
      debugPrint('👑 Premium user - ad bypassed, proceeding with action');
      onAdClosed?.call();
      return false;
    }

    // Check if we should show an ad
    if (!await shouldShowAd()) {
      onAdClosed?.call();
      return false;
    }

    // Check if ad is ready
    if (!_isRewardedAdReady || _rewardedAd == null) {
      debugPrint('⚠️ Rewarded ad not ready, skipping');
      onAdFailed?.call();
      onAdClosed?.call();
      return false;
    }

    debugPrint('🎬 Showing rewarded ad');

    bool adShown = false;

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('📺 Rewarded ad displayed');
        adShown = true;
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('🚪 Rewarded ad dismissed');
        ad.dispose();
        _isRewardedAdReady = false;
        _loadRewardedAd(); // Load next ad
        onAdClosed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('❌ Rewarded ad failed to show: $error');
        ad.dispose();
        _isRewardedAdReady = false;
        _loadRewardedAd(); // Load next ad
        onAdFailed?.call();
        onAdClosed?.call();
      },
    );

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('🎉 User earned reward: ${reward.amount} ${reward.type}');
          onUserEarnedReward?.call();
        },
      );

      if (adShown) {
        // Update last show time
        await _initPrefs();
        final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        await _prefs!.setInt(_lastAdShowTimeKey, currentTime);
      }

      return adShown;
    } catch (e) {
      debugPrint('❌ Exception showing rewarded ad: $e');
      onAdFailed?.call();
      onAdClosed?.call();
      return false;
    }
  }

  /// Get current interaction count (for debugging)
  Future<int> getInteractionCount() async {
    await _initPrefs();
    return _prefs!.getInt(_interactionCountKey) ?? 0;
  }

  /// Reset interaction counter (for testing)
  Future<void> resetInteractionCount() async {
    await _initPrefs();
    await _prefs!.setInt(_interactionCountKey, 0);
    debugPrint('🔄 Interaction count reset');
  }

  /// Check if using test ads
  bool isUsingTestAds() {
    return _rewardedAdUnitId.contains('3940256099942544');
  }

  /// Create a banner ad for display
  /// Returns null for premium users or if ad fails to load
  Future<BannerAd?> createBannerAd() async {
    // Premium users get no ads
    final isPremium = await _premiumService.isPremiumUser();
    if (isPremium) {
      debugPrint('👑 Premium user - banner ad skipped');
      return null;
    }

    if (_isLoadingBannerAd) {
      debugPrint('⏳ Banner ad already loading');
      return null;
    }

    _isLoadingBannerAd = true;

    try {
      final bannerAd = BannerAd(
        adUnitId: _bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('✅ Banner ad loaded successfully');
            _bannerAd = ad as BannerAd;
            _isBannerAdReady = true;
            _isLoadingBannerAd = false;
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('❌ Banner ad failed to load: $error');
            ad.dispose();
            _isBannerAdReady = false;
            _isLoadingBannerAd = false;
          },
          onAdOpened: (ad) {
            debugPrint('📱 Banner ad opened');
          },
          onAdClosed: (ad) {
            debugPrint('🚪 Banner ad closed');
          },
        ),
      );

      await bannerAd.load();
      return bannerAd;
    } catch (e) {
      debugPrint('❌ Exception creating banner ad: $e');
      _isLoadingBannerAd = false;
      return null;
    }
  }

  /// Dispose banner ad
  void disposeBannerAd() {
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdReady = false;
    _isLoadingBannerAd = false;
  }

  /// Get ad configuration info
  Future<Map<String, String>> getAdConfiguration() async {
    final isPremium = await _premiumService.isPremiumUser();
    return {
      'using_test_ads': isUsingTestAds().toString(),
      'rewarded_ad_unit': _rewardedAdUnitId,
      'banner_ad_unit': _bannerAdUnitId,
      'interaction_frequency': _interactionFrequency.toString(),
      'min_time_between_ads': _minTimeBetweenAds.toString(),
      'premium_user': isPremium.toString(),
      'ads_enabled': (!isPremium).toString(),
    };
  }

  /// Initialize SharedPreferences
  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Dispose all ads and clean up resources
  void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isRewardedAdReady = false;

    disposeBannerAd();

    debugPrint('🧹 AdService disposed');
  }
}
