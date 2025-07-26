import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage premium user status and subscription validation
class PremiumService {
  static final PremiumService _instance = PremiumService._internal();
  factory PremiumService() => _instance;
  PremiumService._internal();

  static const String _premiumStatusKey = 'premium_status';
  static const String _subscriptionTypeKey = 'subscription_type';
  static const String _subscriptionExpiryKey = 'subscription_expiry';

  SharedPreferences? _prefs;

  /// Initialize the service
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Check if user has premium access
  Future<bool> isPremiumUser() async {
    await initialize();

    // Default to false for new users until they unlock premium
    // TODO: Replace with actual subscription validation logic when implementing real subscriptions
    final isPremium = _prefs!.getBool(_premiumStatusKey) ??
        false; // Default to false for new users

    if (isPremium) {
      // Check if subscription is still valid
      final expiryTimestamp = _prefs!.getInt(_subscriptionExpiryKey);
      if (expiryTimestamp != null) {
        final expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
        if (DateTime.now().isAfter(expiryDate)) {
          // Subscription expired, revoke premium status
          await _setPremiumStatus(false);
          return false;
        }
      }
    }

    return isPremium;
  }

  /// Set premium status (for testing or after successful purchase)
  Future<void> _setPremiumStatus(bool isPremium) async {
    await initialize();
    await _prefs!.setBool(_premiumStatusKey, isPremium);
  }

  /// Grant premium access (for testing purposes)
  Future<void> grantPremiumAccess({
    String subscriptionType = 'monthly',
    int durationDays = 30,
  }) async {
    await initialize();

    final expiryDate = DateTime.now().add(Duration(days: durationDays));

    await _prefs!.setBool(_premiumStatusKey, true);
    await _prefs!.setString(_subscriptionTypeKey, subscriptionType);
    await _prefs!
        .setInt(_subscriptionExpiryKey, expiryDate.millisecondsSinceEpoch);
  }

  /// Revoke premium access
  Future<void> revokePremiumAccess() async {
    await initialize();

    await _prefs!.setBool(_premiumStatusKey, false);
    await _prefs!.remove(_subscriptionTypeKey);
    await _prefs!.remove(_subscriptionExpiryKey);
  }

  /// Get subscription type
  Future<String?> getSubscriptionType() async {
    await initialize();
    return _prefs!.getString(_subscriptionTypeKey);
  }

  /// Get subscription expiry date
  Future<DateTime?> getSubscriptionExpiryDate() async {
    await initialize();
    final timestamp = _prefs!.getInt(_subscriptionExpiryKey);
    return timestamp != null
        ? DateTime.fromMillisecondsSinceEpoch(timestamp)
        : null;
  }

  /// Check if subscription is about to expire (within 7 days)
  Future<bool> isSubscriptionExpiringSoon() async {
    final expiryDate = await getSubscriptionExpiryDate();
    if (expiryDate == null) return false;

    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 7 && daysUntilExpiry > 0;
  }

  /// Get days remaining in subscription
  Future<int> getDaysRemaining() async {
    final expiryDate = await getSubscriptionExpiryDate();
    if (expiryDate == null) return 0;

    final daysRemaining = expiryDate.difference(DateTime.now()).inDays;
    return daysRemaining > 0 ? daysRemaining : 0;
  }

  /// Simulate subscription purchase (for testing)
  Future<bool> simulateSubscriptionPurchase(String subscriptionType) async {
    try {
      int durationDays;
      switch (subscriptionType.toLowerCase()) {
        case 'monthly':
          durationDays = 30;
          break;
        case 'yearly':
          durationDays = 365;
          break;
        default:
          durationDays = 30;
      }

      await grantPremiumAccess(
        subscriptionType: subscriptionType,
        durationDays: durationDays,
      );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reset premium status (for testing)
  Future<void> resetPremiumStatus() async {
    await revokePremiumAccess();
  }
}
