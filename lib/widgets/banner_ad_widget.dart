import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';
import '../services/premium_service.dart';

/// A widget that displays a banner ad at the bottom of the screen
/// Automatically handles premium user logic and ad loading/disposal
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isPremiumUser = false;
  final AdService _adService = AdService.instance;
  final PremiumService _premiumService = PremiumService();

  @override
  void initState() {
    super.initState();
    _checkPremiumStatusAndLoadAd();
  }

  Future<void> _checkPremiumStatusAndLoadAd() async {
    // Check if user is premium
    final isPremium = await _premiumService.isPremiumUser();
    
    if (mounted) {
      setState(() {
        _isPremiumUser = isPremium;
      });
    }

    // Only load ad for non-premium users
    if (!isPremium) {
      _loadBannerAd();
    }
  }

  Future<void> _loadBannerAd() async {
    try {
      final bannerAd = await _adService.createBannerAd();
      
      if (bannerAd != null && mounted) {
        setState(() {
          _bannerAd = bannerAd;
          _isAdLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading banner ad in widget: $e');
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything for premium users
    if (_isPremiumUser) {
      return const SizedBox.shrink();
    }

    // Don't show anything if ad is not loaded
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ad label (required by AdMob policies)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              'Advertisement',
              style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          // Banner ad
          SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        ],
      ),
    );
  }
}

/// A banner ad widget specifically designed for settings pages
/// Includes additional styling and spacing appropriate for settings screens
class SettingsBannerAdWidget extends StatefulWidget {
  const SettingsBannerAdWidget({super.key});

  @override
  State<SettingsBannerAdWidget> createState() => _SettingsBannerAdWidgetState();
}

class _SettingsBannerAdWidgetState extends State<SettingsBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  bool _isPremiumUser = false;
  final AdService _adService = AdService.instance;
  final PremiumService _premiumService = PremiumService();

  @override
  void initState() {
    super.initState();
    _checkPremiumStatusAndLoadAd();
  }

  Future<void> _checkPremiumStatusAndLoadAd() async {
    // Check if user is premium
    final isPremium = await _premiumService.isPremiumUser();
    
    if (mounted) {
      setState(() {
        _isPremiumUser = isPremium;
      });
    }

    // Only load ad for non-premium users
    if (!isPremium) {
      _loadBannerAd();
    }
  }

  Future<void> _loadBannerAd() async {
    try {
      final bannerAd = await _adService.createBannerAd();
      
      if (bannerAd != null && mounted) {
        setState(() {
          _bannerAd = bannerAd;
          _isAdLoaded = true;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading settings banner ad: $e');
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Don't show anything for premium users
    if (_isPremiumUser) {
      return const SizedBox.shrink();
    }

    // Don't show anything if ad is not loaded
    if (!_isAdLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ad label with settings-appropriate styling
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 12,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                const SizedBox(width: 4),
                Text(
                  'Sponsored Content',
                  style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Banner ad
          Center(
            child: SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
          ),
          // Upgrade hint for non-premium users
          const SizedBox(height: 8),
          Text(
            'Upgrade to Premium for an ad-free experience',
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
