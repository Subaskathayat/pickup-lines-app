import 'package:flutter/material.dart';
import '../services/premium_service.dart';
import '../utils/snackbar_utils.dart';
import 'premium_congratulations_screen.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Premium',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Premium Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.tertiary,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.diamond,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Upgrade to Premium',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Unlock all features and enjoy an ad-free experience',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Features Section
            const Text(
              'Premium Features',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            _buildFeatureItem(
              icon: Icons.block,
              title: 'Ad-Free Experience',
              description: 'Enjoy the app without any interruptions',
            ),
            _buildFeatureItem(
              icon: Icons.favorite,
              title: 'Unlimited Favorites',
              description: 'Save as many pickup lines as you want',
            ),
            _buildFeatureItem(
              icon: Icons.star,
              title: 'Exclusive Content',
              description: 'Access premium pickup lines and categories',
            ),
            _buildFeatureItem(
              icon: Icons.notifications,
              title: 'Custom Notifications',
              description: 'Get personalized daily pickup lines',
            ),
            _buildFeatureItem(
              icon: Icons.palette,
              title: 'Premium Themes',
              description: 'Unlock beautiful app themes and customizations',
            ),

            const SizedBox(height: 32),

            // Pricing Section
            const Text(
              'Choose Your Plan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),

            _buildPricingCard(
              context,
              title: 'Monthly',
              price: '\$2.99',
              period: '/month',
              description: 'Perfect for trying out premium features',
              isPopular: false,
              onTap: () => _handleMonthlyTap(context),
            ),
            const SizedBox(height: 12),
            _buildPricingCard(
              context,
              title: 'Yearly',
              price: '\$19.99',
              period: '/year',
              description: 'Best value - Save 44%!',
              isPopular: true,
              onTap: () => _handleYearlyTap(context),
            ),

            const SizedBox(height: 32),

            // Subscribe Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => _handleSubscription(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFABAB),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Start Premium',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Terms and Privacy
            Text(
              'By subscribing, you agree to our Terms of Service and Privacy Policy. Subscription automatically renews unless cancelled.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFABAB).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFFFFABAB),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    required String description,
    required bool isPopular,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isPopular
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
              : Theme.of(context).colorScheme.surface,
          border: Border.all(
            color: isPopular
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
            width: isPopular ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (isPopular)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'POPULAR',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                Text(
                  period,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubscription(BuildContext context) async {
    // For now, simulate successful subscription for demonstration
    try {
      await PremiumService().grantPremiumAccess();

      // Show congratulations screen after successful premium purchase
      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PremiumCongratulationsScreen(),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarUtils.showError(
          context,
          'Failed to process subscription: $e',
        );
      }
    }

    // TODO: Replace with actual subscription logic when ready
  }

  // Temporary premium testing functionality
  void _handleYearlyTap(BuildContext context) async {
    try {
      await PremiumService().grantPremiumAccess();

      // Show congratulations screen after successful premium purchase
      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PremiumCongratulationsScreen(),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarUtils.showError(
          context,
          'Failed to grant premium access: $e',
        );
      }
    }
  }

  void _handleMonthlyTap(BuildContext context) async {
    try {
      await PremiumService().revokePremiumAccess();
      if (context.mounted) {
        SnackBarUtils.showInfo(
          context,
          '🔒 Premium access revoked! (Testing Mode)',
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarUtils.showError(
          context,
          'Failed to revoke premium access: $e',
        );
      }
    }
  }
}
