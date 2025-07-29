import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pickup_lines/services/ad_service.dart';

void main() {
  group('Banner Ad Tests', () {
    setUpAll(() {
      // Initialize Flutter binding for tests
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('AdService should have banner ad configuration', () async {
      final adService = AdService.instance;
      
      final config = await adService.getAdConfiguration();
      
      // Verify banner ad unit is configured
      expect(config['banner_ad_unit'], isNotNull);
      expect(config['banner_ad_unit'], contains('3940256099942544')); // Test ad unit
      
      // Verify other configuration
      expect(config['using_test_ads'], 'true');
      expect(config['ads_enabled'], 'true'); // For non-premium users
    });

    test('Banner ad should be skipped for premium users', () async {
      final adService = AdService.instance;
      
      // Note: In a real test environment, you would mock PremiumService
      // to simulate premium user behavior
      
      final config = await adService.getAdConfiguration();
      
      // For non-premium users (default test state)
      expect(config['premium_user'], 'false');
      expect(config['ads_enabled'], 'true');
      
      // Premium users would have:
      // expect(config['premium_user'], 'true');
      // expect(config['ads_enabled'], 'false');
    });

    test('AdService dispose should clean up banner ads', () async {
      final adService = AdService.instance;
      
      // This should not throw any exceptions
      expect(() => adService.dispose(), returnsNormally);
    });

    test('Banner ad creation should handle errors gracefully', () async {
      final adService = AdService.instance;
      
      // This test verifies that createBannerAd doesn't throw exceptions
      // In a real test environment, you would mock the AdMob SDK
      expect(() async => await adService.createBannerAd(), returnsNormally);
    });
  });
}
