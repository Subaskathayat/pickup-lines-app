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
              'By downloading, installing, accessing, or using the Pickup Lines mobile application ("App"), you acknowledge that you have read, understood, and agree to be bound by these Terms and Conditions ("Terms"). These Terms constitute a legally binding agreement between you and us. If you do not agree to these Terms, you must not download, install, access, or use the App.',
            ),
            _buildSection(
              'Age Restrictions and Mature Content',
              'This App contains romantic and flirtatious content, including some categories with mature themes. By using this App, you represent and warrant that:\n\n'
                  '• You are at least 18 years of age or the age of majority in your jurisdiction\n'
                  '• You have the legal capacity to enter into this agreement\n'
                  '• You understand that some content may be of an adult nature\n'
                  '• You will not allow minors to access mature content categories\n'
                  '• You acknowledge that age verification may be required for certain content\n\n'
                  'We reserve the right to verify your age and restrict access to age-inappropriate content.',
            ),
            _buildSection(
              'Description of Service',
              'Pickup Lines is a mobile application that provides users with a curated collection of pickup lines, conversation starters, and romantic content organized by categories. The App includes features such as:\n\n'
                  '• Browse pickup lines by various categories including mature content\n'
                  '• Save and organize favorite pickup lines\n'
                  '• Daily pickup line notifications and features\n'
                  '• Share pickup lines through social platforms\n'
                  '• Premium subscription features and ad-free experience\n'
                  '• Customizable app settings and themes\n'
                  '• Age verification for mature content categories',
            ),
            _buildSection(
              'User Responsibilities and Conduct',
              'As a user of our App, you agree to:\n\n'
                  '• Use the App and its content for personal, non-commercial purposes only\n'
                  '• Respect others and obtain consent before using pickup lines\n'
                  '• Not use pickup lines in a harassing, threatening, or inappropriate manner\n'
                  '• Comply with all applicable laws and regulations in your jurisdiction\n'
                  '• Not attempt to reverse engineer, decompile, or modify the App\n'
                  '• Not use automated systems to access or scrape content from the App\n'
                  '• Provide accurate information when contacting support\n'
                  '• Report any inappropriate use or content to us promptly\n\n'
                  'You acknowledge that pickup lines are for entertainment purposes and should be used respectfully and consensually.',
            ),
            _buildSection(
              'Content and Intellectual Property',
              'All pickup lines, app design, functionality, graphics, text, and other content in the App are owned by us or our licensors and are protected by copyright, trademark, and other intellectual property laws. You are granted a limited, non-exclusive, non-transferable license to:\n\n'
                  '• Use the pickup lines for personal, non-commercial purposes only\n'
                  '• Share individual pickup lines through the App\'s built-in sharing features\n'
                  '• Access and use the App in accordance with these Terms\n\n'
                  'You may not:\n\n'
                  '• Copy, reproduce, or redistribute the entire collection or substantial portions\n'
                  '• Use our content in other applications, websites, or commercial ventures\n'
                  '• Modify, adapt, or create derivative works based on our content\n'
                  '• Remove or alter any copyright, trademark, or proprietary notices\n'
                  '• Claim ownership of our content or present it as your own work',
            ),
            _buildSection(
              'Privacy and Data Protection',
              'Your privacy is important to us. We are committed to protecting your personal information and complying with applicable privacy laws including GDPR and CCPA. Please review our Privacy Policy, which is incorporated into these Terms by reference, to understand:\n\n'
                  '• What information we collect and how we use it\n'
                  '• How we protect your data and maintain security\n'
                  '• Your rights regarding your personal information\n'
                  '• Our use of third-party services like AdMob for advertising\n\n'
                  'By using our App, you consent to our data practices as described in the Privacy Policy.',
            ),
            _buildSection(
              'Third-Party Services and Advertising',
              'Our App integrates with third-party services to enhance functionality:\n\n'
                  '• Google AdMob for advertising (free users only)\n'
                  '• Analytics services for app improvement\n'
                  '• Social sharing platforms\n'
                  '• Notification services\n\n'
                  'These services have their own terms and privacy policies. We are not responsible for the practices of third-party services, and you should review their terms before use.',
            ),
            _buildSection(
              'Disclaimers and Content Warnings',
              'The pickup lines and content in this App are for entertainment purposes only. We provide this content "as is" without warranties of any kind. We do not guarantee:\n\n'
                  '• The effectiveness, appropriateness, or success of any pickup line\n'
                  '• That using pickup lines will result in romantic or social success\n'
                  '• That all content is suitable for every situation or audience\n'
                  '• The accuracy, completeness, or reliability of any content\n\n'
                  'WARNING: Some content may be of a mature or adult nature. Use all content respectfully, consensually, and at your own discretion. We strongly advise obtaining consent before using any pickup lines and being mindful of social contexts.',
            ),
            _buildSection(
              'Limitation of Liability',
              'TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, WE SHALL NOT BE LIABLE FOR ANY INDIRECT, INCIDENTAL, SPECIAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES, INCLUDING BUT NOT LIMITED TO:\n\n'
                  '• Social embarrassment or relationship issues\n'
                  '• Loss of data or content\n'
                  '• Business interruption or lost profits\n'
                  '• Emotional distress or personal injury\n'
                  '• Any damages arising from misuse of pickup lines\n\n'
                  'Our total liability to you for all claims shall not exceed the amount you paid for premium features (if any) in the 12 months preceding the claim. Some jurisdictions do not allow the exclusion of certain warranties or limitation of liability, so these limitations may not apply to you.',
            ),
            _buildSection(
              'Indemnification',
              'You agree to indemnify, defend, and hold harmless us, our affiliates, officers, directors, employees, and agents from and against any claims, liabilities, damages, losses, costs, or expenses arising out of or relating to:\n\n'
                  '• Your use of the App or its content\n'
                  '• Your violation of these Terms\n'
                  '• Your violation of any rights of another party\n'
                  '• Your misuse of pickup lines or inappropriate conduct',
            ),
            _buildSection(
              'App Availability and Modifications',
              'We strive to keep the App available at all times, but we do not guarantee uninterrupted service. We reserve the right to:\n\n'
                  '• Temporarily suspend the App for maintenance or updates\n'
                  '• Modify, update, or discontinue features at any time\n'
                  '• Change subscription pricing or premium features\n'
                  '• Remove or modify content categories\n'
                  '• Discontinue the service with 30 days\' notice\n\n'
                  'We are not liable for any interruption of service or loss of access.',
            ),
            _buildSection(
              'Updates and Changes to Terms',
              'We may update these Terms and Conditions from time to time to reflect changes in our practices, legal requirements, or App features. When we make material changes, we will:\n\n'
                  '• Update the "Effective Date" at the top of these Terms\n'
                  '• Notify users through the App or email (if provided)\n'
                  '• Provide reasonable notice before changes take effect\n\n'
                  'Continued use of the App after changes constitutes acceptance of the new Terms. If you do not agree to the updated Terms, you must stop using the App.',
            ),
            _buildSection(
              'Termination',
              'Either party may terminate this agreement at any time:\n\n'
                  '• You may stop using the App by uninstalling it from your device\n'
                  '• We may terminate or suspend your access immediately for violations of these Terms\n'
                  '• We may terminate the service entirely with reasonable notice\n\n'
                  'Upon termination, your right to use the App ceases immediately, but these Terms shall survive termination to the extent necessary to enforce our respective rights and obligations.',
            ),
            _buildSection(
              'Governing Law and Disputes',
              'These Terms shall be governed by and construed in accordance with the laws of [Your Jurisdiction], without regard to conflict of law principles. Any disputes arising from these Terms or your use of the App shall be resolved through binding arbitration in accordance with the rules of [Arbitration Organization], except that either party may seek injunctive relief in court for intellectual property violations.',
            ),
            _buildSection(
              'Contact Information',
              'If you have any questions about these Terms and Conditions, please contact us:\n\n'
                  '• Email: legal@pickuplines.app\n'
                  '• Support: support@pickuplines.app\n'
                  '• Through the App\'s customer support feature\n'
                  '• Mailing Address: [Your Business Address]',
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
    // Fixed effective date for legal compliance
    // Update this date when making material changes to the terms
    return 'January 1, 2025';
  }
}
