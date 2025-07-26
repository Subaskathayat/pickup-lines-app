import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../lib/services/premium_service.dart';

void main() {
  group('Premium Service Tests', () {
    setUp(() async {
      // Clear SharedPreferences before each test
      SharedPreferences.setMockInitialValues({});
    });

    test('Premium service should grant and revoke access correctly', () async {
      final premiumService = PremiumService();
      
      // Initially should not be premium
      expect(await premiumService.isPremiumUser(), false);
      
      // Grant premium access
      await premiumService.grantPremiumAccess();
      expect(await premiumService.isPremiumUser(), true);
      
      // Check subscription details
      final subscriptionType = await premiumService.getSubscriptionType();
      expect(subscriptionType, 'monthly');
      
      final expiryDate = await premiumService.getSubscriptionExpiryDate();
      expect(expiryDate, isNotNull);
      expect(expiryDate!.isAfter(DateTime.now()), true);
      
      // Revoke premium access
      await premiumService.revokePremiumAccess();
      expect(await premiumService.isPremiumUser(), false);
    });

    test('Premium service should handle subscription expiry', () async {
      final premiumService = PremiumService();
      
      // Grant premium access with very short duration
      await premiumService.grantPremiumAccess(durationDays: -1); // Expired
      
      // Should not be premium due to expiry
      expect(await premiumService.isPremiumUser(), false);
    });

    test('Premium service should detect expiring subscriptions', () async {
      final premiumService = PremiumService();
      
      // Grant premium access expiring in 3 days
      await premiumService.grantPremiumAccess(durationDays: 3);
      
      expect(await premiumService.isPremiumUser(), true);
      expect(await premiumService.isSubscriptionExpiringSoon(), true);
      
      final daysRemaining = await premiumService.getDaysRemaining();
      expect(daysRemaining, lessThanOrEqualTo(3));
      expect(daysRemaining, greaterThanOrEqualTo(0));
    });

    test('Premium service should simulate subscription purchase', () async {
      final premiumService = PremiumService();
      
      // Test monthly subscription
      final monthlyResult = await premiumService.simulateSubscriptionPurchase('monthly');
      expect(monthlyResult, true);
      expect(await premiumService.isPremiumUser(), true);
      expect(await premiumService.getSubscriptionType(), 'monthly');
      
      // Reset and test yearly subscription
      await premiumService.resetPremiumStatus();
      final yearlyResult = await premiumService.simulateSubscriptionPurchase('yearly');
      expect(yearlyResult, true);
      expect(await premiumService.isPremiumUser(), true);
      expect(await premiumService.getSubscriptionType(), 'yearly');
    });

    tearDown(() async {
      // Clean up after each test
      await PremiumService().revokePremiumAccess();
    });
  });
}
