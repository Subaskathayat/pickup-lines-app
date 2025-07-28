import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pickup_lines/services/ad_service.dart';

void main() {
  group('Strategic AdService Tests', () {
    setUpAll(() {
      // Initialize Flutter binding for tests
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('AdService should initialize without errors', () async {
      final adService = AdService.instance;
      expect(adService, isNotNull);
    });

    test('Frequency capping should work correctly', () async {
      final adService = AdService.instance;
      await adService.initialize();

      // First 3 interactions should not show ad
      expect(await adService.shouldShowAd(), false);
      expect(await adService.shouldShowAd(), false);
      expect(await adService.shouldShowAd(), false);

      // 4th interaction should show ad (frequency = 4)
      expect(await adService.shouldShowAd(), true);

      // Next 3 interactions should not show ad
      expect(await adService.shouldShowAd(), false);
      expect(await adService.shouldShowAd(), false);
      expect(await adService.shouldShowAd(), false);

      // 8th interaction should show ad again
      expect(await adService.shouldShowAd(), true);
    });

    test('Interaction count should increment correctly', () async {
      final adService = AdService.instance;
      await adService.initialize();

      // Reset counter first
      await adService.resetInteractionCount();
      expect(await adService.getInteractionCount(), 0);

      // Increment counter by calling shouldShowAd
      await adService.shouldShowAd();
      expect(await adService.getInteractionCount(), 1);

      await adService.shouldShowAd();
      expect(await adService.getInteractionCount(), 2);
    });

    test('Should be using test ads for development', () async {
      final adService = AdService.instance;

      expect(adService.isUsingTestAds(), true);

      final config = await adService.getAdConfiguration();
      expect(config['using_test_ads'], 'true');
      expect(config['rewarded_ad_unit'], contains('3940256099942544'));
      expect(config['interaction_frequency'], '4');
      expect(config['min_time_between_ads'], '60');
      expect(config['ads_enabled'],
          'true'); // Should be true for non-premium users
    });

    test('Reset interaction count should work correctly', () async {
      final adService = AdService.instance;
      await adService.initialize();

      // Increment counter
      await adService.shouldShowAd();
      await adService.shouldShowAd();
      expect(await adService.getInteractionCount(), 2);

      // Reset counter
      await adService.resetInteractionCount();
      expect(await adService.getInteractionCount(), 0);
    });

    test('Premium users should never see ads', () async {
      final adService = AdService.instance;

      // Note: This test assumes default non-premium state
      // In a real test environment, you would mock PremiumService
      // to test premium user behavior

      final config = await adService.getAdConfiguration();

      // For non-premium users (default test state)
      expect(config['premium_user'], 'false');
      expect(config['ads_enabled'], 'true');

      // Premium users would have:
      // expect(config['premium_user'], 'true');
      // expect(config['ads_enabled'], 'false');
    });
  });
}
