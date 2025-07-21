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
              'We collect minimal information to provide you with the best experience:\n\n'
              '• App usage analytics to improve our service\n'
              '• Crash reports to fix bugs and improve stability\n'
              '• Your favorite pickup lines (stored locally on your device)\n'
              '• Settings and preferences (stored locally)',
            ),
            
            _buildSection(
              'How We Use Your Information',
              'Your information is used to:\n\n'
              '• Provide and maintain our service\n'
              '• Improve app functionality and user experience\n'
              '• Send you notifications (if enabled)\n'
              '• Provide customer support\n'
              '• Ensure app security and prevent abuse',
            ),
            
            _buildSection(
              'Data Storage and Security',
              'We take your privacy seriously:\n\n'
              '• Most data is stored locally on your device\n'
              '• We use industry-standard encryption\n'
              '• No personal pickup lines are shared with third parties\n'
              '• Anonymous usage data may be collected for analytics',
            ),
            
            _buildSection(
              'Third-Party Services',
              'Our app may use third-party services:\n\n'
              '• Analytics services (Google Analytics, Firebase)\n'
              '• Advertising networks (if ads are enabled)\n'
              '• App stores (Google Play, Apple App Store)\n'
              '• Social sharing platforms',
            ),
            
            _buildSection(
              'Your Rights',
              'You have the right to:\n\n'
              '• Access your personal data\n'
              '• Request data deletion\n'
              '• Opt-out of analytics\n'
              '• Disable notifications\n'
              '• Contact us with privacy concerns',
            ),
            
            _buildSection(
              'Children\'s Privacy',
              'Our app is not intended for children under 13. We do not knowingly collect personal information from children under 13. If you are a parent and believe your child has provided us with personal information, please contact us.',
            ),
            
            _buildSection(
              'Changes to This Policy',
              'We may update this Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page and updating the "Last updated" date.',
            ),
            
            _buildSection(
              'Contact Us',
              'If you have any questions about this Privacy Policy, please contact us:\n\n'
              '• Email: privacy@pickuplines.app\n'
              '• Through the app\'s customer support feature',
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
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}
