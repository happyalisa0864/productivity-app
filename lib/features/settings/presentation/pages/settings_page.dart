import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:productivity_app/features/task_tracking/presentation/pages/statistics_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final background = const Color(0xFFFAF7F5);
    final textColor = const Color(0xFF4E4A47);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // Statistics Section
          _SectionHeader(title: 'Statistics'),
          _SettingsCard(
            children: [
              _SettingsItem(
                icon: Icons.bar_chart,
                title: 'View Statistics',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const StatisticsPage(),
                    ),
                  );
                },
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: textColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Support & Feedback Section
          _SectionHeader(title: 'Support & Feedback'),
          _SettingsCard(
            children: [
              _SettingsItem(
                icon: Icons.help_center,
                title: 'Help Center',
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: textColor.withOpacity(0.5),
                ),
              ),
              _Divider(),
              _SettingsItem(
                icon: Icons.feedback,
                title: 'Send Feedback',
                onTap: () async {
                  final Uri url = Uri.parse(
                    'https://docs.google.com/forms/d/e/1FAIpQLSd4BHYuExDT6xuNMED3v068Owo_fhfVpZAnTvnt6vh7RxrPUA/viewform?usp=publish-editor',
                  );
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not open feedback form'),
                        ),
                      );
                    }
                  }
                },
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: textColor.withOpacity(0.5),
                ),
              ),
              _Divider(),
              _SettingsItem(
                icon: Icons.star,
                title: 'Rate the App',
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: textColor.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          // Version
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(
                color: textColor.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ),
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
    final textColor = const Color(0xFF4E4A47);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          color: textColor.withOpacity(0.8),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final surfaceColor = const Color(0xFFFDF2E8);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget trailing;
  final VoidCallback? onTap;
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = const Color(0xFF4E4A47);
    final primary = const Color(0xFFE6C0C0);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: textColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          trailing,
        ],
      ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 76,
      color: Colors.black.withOpacity(0.05),
    );
  }
}

