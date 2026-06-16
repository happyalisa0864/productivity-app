// Settings screen with links to statistics, help, feedback, and app rating.
import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:productivity_app/features/task_tracking/presentation/pages/statistics_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const _background = Color(0xFFFAF7F5);
  static const _textColor = Color(0xFF4E4A47);
  static const _helpUrl = 'https://docs.google.com/forms/d/e/1FAIpQLSdNbAcPYqY71YoEdY3k43VUPDsGoP6_SjJC1hH6akhUJo-t-A/viewform?usp=publish-editor';
  static const _feedbackUrl = 'https://docs.google.com/forms/d/e/1FAIpQLSd4BHYuExDT6xuNMED3v068Owo_fhfVpZAnTvnt6vh7RxrPUA/viewform?usp=publish-editor';

  Future<void> _openUrl(BuildContext context, Uri url, String errorMessage) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final chevron = Icon(Icons.arrow_forward_ios, size: 16, color: _textColor.withValues(alpha: 0.5));

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _textColor,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        title: const Text('Settings', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          const _SectionHeader(title: 'Statistics'),
          _SettingsCard(children: [
            _SettingsItem(
              icon: Icons.bar_chart,
              title: 'View Statistics',
              trailing: chevron,
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const StatisticsPage())),
            ),
          ]),
          const SizedBox(height: 24),
          const _SectionHeader(title: 'Support & Feedback'),
          _SettingsCard(children: [
            _SettingsItem(
              icon: Icons.help_center,
              title: 'Help Center',
              trailing: chevron,
              onTap: () => _openUrl(context, Uri.parse(_helpUrl), 'Could not open help center'),
            ),
            const _Divider(),
            _SettingsItem(
              icon: Icons.feedback,
              title: 'Send Feedback',
              trailing: chevron,
              onTap: () => _openUrl(context, Uri.parse(_feedbackUrl), 'Could not open feedback form'),
            ),
            const _Divider(),
            _SettingsItem(
              icon: Icons.star,
              title: 'Rate the App',
              trailing: chevron,
              onTap: () async {
                final inAppReview = InAppReview.instance;
                if (await inAppReview.isAvailable()) {
                  inAppReview.requestReview();
                } else {
                  final url = Uri.parse(Platform.isIOS
                      ? 'https://apps.apple.com/app/idYOUR_APP_ID'
                      : 'https://play.google.com/store/apps/details?id=com.example.productivity_app');
                  await _openUrl(context, url, 'Could not open app store');
                }
              },
            ),
          ]),
          const SizedBox(height: 32),
          Center(child: Text('Version 1.0.0', style: TextStyle(color: _textColor.withValues(alpha: 0.5), fontSize: 12))),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(title, style: TextStyle(color: const Color(0xFF4E4A47).withValues(alpha: 0.8), fontSize: 18, fontWeight: FontWeight.w600)),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(color: const Color(0xFFFDF2E8), borderRadius: BorderRadius.circular(16)),
      child: Column(children: children),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;
  const _SettingsItem({required this.icon, required this.title, required this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF4E4A47);
    const primary = Color(0xFFE6C0C0);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: primary.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: textColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(title, style: const TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500))),
          trailing,
        ]),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, thickness: 1, indent: 76, color: Colors.black.withValues(alpha: 0.05));
  }
}
