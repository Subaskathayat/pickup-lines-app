import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Privacy Policy',
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFABAB).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.privacy_tip,
                    color: Color(0xFFFFABAB),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Privacy Matters',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Last updated: ${_getLastUpdatedDate()}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              'Information We Collect',
              'We are committed to transparency about data collection. We collect the following types of information:\n\n'
                  'INFORMATION YOU PROVIDE:\n'
                  '• Favorite pickup lines (stored locally on your device)\n'
                  '• App settings and preferences (stored locally)\n'
                  '• Custom collections and content (stored locally)\n'
                  '• Support communications when you contact us\n\n'
                  'INFORMATION AUTOMATICALLY COLLECTED:\n'
                  '• Device information (model, operating system, app version)\n'
                  '• Usage analytics (features used, session duration, crash reports)\n'
                  '• Advertising identifiers (for non-premium users only)\n'
                  '• IP address and general location (country/region level)\n'
                  '• App performance and error logs',
            ),
            _buildSection(
              'How We Use Your Information',
              'We use collected information for the following purposes:\n\n'
                  'SERVICE PROVISION:\n'
                  '• Provide and maintain the App functionality\n'
                  '• Deliver daily pickup line notifications\n'
                  '• Sync your preferences across app sessions\n'
                  '• Process premium subscriptions\n\n'
                  'IMPROVEMENT AND ANALYTICS:\n'
                  '• Analyze usage patterns to improve user experience\n'
                  '• Fix bugs and enhance app performance\n'
                  '• Develop new features and content\n'
                  '• Conduct A/B testing for app optimization\n\n'
                  'ADVERTISING (FREE USERS ONLY):\n'
                  '• Display relevant advertisements through Google AdMob\n'
                  '• Measure ad performance and effectiveness\n'
                  '• Provide personalized ad experiences',
            ),
            _buildSection(
              'Data Storage and Security',
              'We implement appropriate security measures to protect your information:\n\n'
                  'LOCAL STORAGE:\n'
                  '• Favorites, settings, and preferences are stored locally on your device\n'
                  '• Local data is encrypted using device-level security\n'
                  '• You maintain full control over locally stored data\n\n'
                  'CLOUD STORAGE:\n'
                  '• Analytics data is stored securely with our service providers\n'
                  '• All data transmission uses industry-standard encryption (TLS/SSL)\n'
                  '• We do not store personal pickup line content on our servers\n'
                  '• Access to data is restricted to authorized personnel only\n\n'
                  'DATA RETENTION:\n'
                  '• Local data remains until you uninstall the app or clear data\n'
                  '• Analytics data is retained for up to 2 years for service improvement\n'
                  '• Account data is deleted within 30 days of account closure',
            ),
            _buildSection(
              'Third-Party Services and Data Sharing',
              'We integrate with the following third-party services, each with their own privacy practices:\n\n'
                  'GOOGLE ADMOB (FREE USERS ONLY):\n'
                  '• Collects advertising identifiers and device information\n'
                  '• Uses data for personalized advertising\n'
                  '• Subject to Google\'s Privacy Policy\n'
                  '• You can opt-out through device settings\n\n'
                  'ANALYTICS SERVICES:\n'
                  '• Google Analytics/Firebase for usage analytics\n'
                  '• Crash reporting services for app stability\n'
                  '• Performance monitoring tools\n\n'
                  'OTHER SERVICES:\n'
                  '• App stores (Google Play, Apple App Store) for distribution\n'
                  '• Social sharing platforms when you choose to share content\n'
                  '• Notification services for daily pickup lines\n\n'
                  'We do not sell, rent, or trade your personal information to third parties for their marketing purposes.',
            ),
            _buildSection(
              'Your Privacy Rights',
              'Depending on your location, you may have the following rights regarding your personal information:\n\n'
                  'GDPR RIGHTS (EU RESIDENTS):\n'
                  '• Right to access your personal data\n'
                  '• Right to rectification of inaccurate data\n'
                  '• Right to erasure ("right to be forgotten")\n'
                  '• Right to restrict processing\n'
                  '• Right to data portability\n'
                  '• Right to object to processing\n'
                  '• Right to withdraw consent\n\n'
                  'CCPA RIGHTS (CALIFORNIA RESIDENTS):\n'
                  '• Right to know what personal information is collected\n'
                  '• Right to delete personal information\n'
                  '• Right to opt-out of sale of personal information\n'
                  '• Right to non-discrimination for exercising privacy rights\n\n'
                  'TO EXERCISE YOUR RIGHTS:\n'
                  '• Contact us at privacy@pickuplines.app\n'
                  '• Use in-app settings to control data collection\n'
                  '• Uninstall the app to remove local data',
            ),
            _buildSection(
              'Children\'s Privacy (COPPA Compliance)',
              'Our App is not intended for children under 18 years of age, and we do not knowingly collect personal information from children under 13. The App contains mature content that is inappropriate for minors.\n\n'
                  'If you are a parent or guardian and believe your child under 13 has provided us with personal information:\n'
                  '• Contact us immediately at privacy@pickuplines.app\n'
                  '• We will delete such information from our records\n'
                  '• We will take steps to prevent future collection\n\n'
                  'Parents should monitor their children\'s internet usage and use parental controls to prevent access to age-inappropriate content.',
            ),
            _buildSection(
              'International Data Transfers',
              'Your information may be transferred to and processed in countries other than your own. We ensure adequate protection through:\n\n'
                  '• Standard Contractual Clauses approved by the European Commission\n'
                  '• Adequacy decisions for countries with equivalent privacy protection\n'
                  '• Other appropriate safeguards as required by applicable law\n\n'
                  'By using our App, you consent to the transfer of your information to these countries.',
            ),
            _buildSection(
              'Data Breach Notification',
              'In the event of a data breach that affects your personal information, we will:\n\n'
                  '• Notify affected users within 72 hours of discovery\n'
                  '• Report the breach to relevant authorities as required by law\n'
                  '• Provide details about what information was involved\n'
                  '• Explain steps we are taking to address the breach\n'
                  '• Offer guidance on protecting yourself from potential harm',
            ),
            _buildSection(
              'Changes to This Policy',
              'We may update this Privacy Policy from time to time to reflect changes in our practices, legal requirements, or App features. When we make material changes:\n\n'
                  '• We will update the "Last updated" date at the top of this policy\n'
                  '• We will notify users through the App or email (if provided)\n'
                  '• We will provide at least 30 days\' notice for material changes\n'
                  '• Continued use of the App after changes constitutes acceptance\n\n'
                  'We encourage you to review this Privacy Policy periodically to stay informed about how we protect your information.',
            ),
            _buildSection(
              'Contact Us',
              'If you have any questions, concerns, or requests regarding this Privacy Policy or our data practices, please contact us:\n\n'
                  '• Privacy Email: privacy@pickuplines.app\n'
                  '• General Support: support@pickuplines.app\n'
                  '• Through the App\'s customer support feature\n'
                  '• Mailing Address: [Your Business Address]\n\n'
                  'We will respond to your inquiry within 30 days of receipt.',
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'This privacy policy is effective as of the date listed above and applies to all users of the Pickup Lines app.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFFFFABAB),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  String _getLastUpdatedDate() {
    // Fixed last updated date for legal compliance
    // Update this date when making material changes to the privacy policy
    return 'January 1, 2025';
  }
}
