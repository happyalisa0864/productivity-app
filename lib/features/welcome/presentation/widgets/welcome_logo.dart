import 'package:flutter/material.dart';

class WelcomeLogo extends StatelessWidget {
  const WelcomeLogo({super.key});

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFF5B8B1);
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                accent.withOpacity(0.18),
                accent.withOpacity(0.04),
              ],
            ),
          ),
          child: Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.8),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.timer_outlined,
                size: 60,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Calm Timer',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: const Color(0xFF4E4A47),
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'Focus with gentle structure',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF8B8680),
                letterSpacing: 0.6,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
