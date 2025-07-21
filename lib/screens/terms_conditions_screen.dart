import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms & Conditions',
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
                    Icons.description,
                    color: Color(0xFFFFABAB),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Terms of Service',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Effective date: ${_getEffectiveDate()}',
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
              'Acceptance of Terms',
              'By downloading, installing, or using the Pickup Lines app, you agree to be bound by these Terms and Conditions. If you do not agree to these terms, please do not use our app.',
            ),
            
            _buildSection(
              'Description of Service',
              'Pickup Lines is a mobile application that provides users with a collection of pickup lines organized by categories. The app includes features such as:\n\n'
              '• Browse pickup lines by category\n'
              '• Save favorite pickup lines\n'
              '• Daily pickup line feature\n'
              '• Share pickup lines with others\n'
              '• Customizable app settings',
            ),
            
            _buildSection(
              'User Responsibilities',
              'As a user of our app, you agree to:\n\n'
              '• Use the app for lawful purposes only\n'
              '• Respect others when using pickup lines\n'
              '• Not use the content for commercial purposes without permission\n'
              '• Not attempt to reverse engineer or modify the app\n'
              '• Provide accurate information when contacting support',
            ),
            
            _buildSection(
              'Content and Intellectual Property',
              'All pickup lines, app design, and functionality are owned by us or our licensors. You may:\n\n'
              '• Use the pickup lines for personal, non-commercial purposes\n'
              '• Share individual pickup lines through the app\'s sharing features\n\n'
              'You may not:\n\n'
              '• Copy or redistribute the entire collection\n'
              '• Use our content in other apps or websites\n'
              '• Claim ownership of our content',
            ),
            
            _buildSection(
              'Privacy and Data',
              'Your privacy is important to us. Please review our Privacy Policy to understand how we collect, use, and protect your information. By using our app, you consent to our data practices as described in the Privacy Policy.',
            ),
            
            _buildSection(
              'Disclaimers',
              'The pickup lines in this app are for entertainment purposes only. We do not guarantee:\n\n'
              '• The effectiveness of any pickup line\n'
              '• That using pickup lines will result in romantic success\n'
              '• That all content is appropriate for every situation\n\n'
              'Use pickup lines respectfully and at your own discretion.',
            ),
            
            _buildSection(
              'Limitation of Liability',
              'To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, special, or consequential damages resulting from your use of the app, including but not limited to social embarrassment or relationship issues.',
            ),
            
            _buildSection(
              'App Availability',
              'We strive to keep the app available at all times, but we do not guarantee uninterrupted service. We may:\n\n'
              '• Temporarily suspend the app for maintenance\n'
              '• Update or modify features\n'
              '• Discontinue the service with reasonable notice',
            ),
            
            _buildSection(
              'Updates and Changes',
              'We may update these Terms and Conditions from time to time. Continued use of the app after changes constitutes acceptance of the new terms. We will notify users of significant changes through the app or other means.',
            ),
            
            _buildSection(
              'Termination',
              'You may stop using the app at any time by uninstalling it from your device. We may terminate or suspend access to our service immediately, without prior notice, for conduct that we believe violates these Terms.',
            ),
            
            _buildSection(
              'Contact Information',
              'If you have any questions about these Terms and Conditions, please contact us:\n\n'
              '• Email: legal@pickuplines.app\n'
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
                      'These terms and conditions are effective as of the date listed above and govern your use of the Pickup Lines app.',
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

  String _getEffectiveDate() {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }
}
