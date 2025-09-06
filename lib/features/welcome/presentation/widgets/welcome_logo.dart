import 'package:flutter/material.dart';

class WelcomeLogo extends StatelessWidget {
  const WelcomeLogo({super.key});

  @override
  Widget build(BuildContext context) {
    // Placeholder logo composed of an icon and styled texts.
    // Replace with Image.asset when you add actual assets.
    final purple = const Color(0xFF8E7CC3);
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Icon(Icons.local_cafe, size: 120, color: purple),
        const SizedBox(height: 8),
        Text(
          'ZONED.IN',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: purple,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'FIND YOUR FOCUS',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: purple.withOpacity(0.85),
                letterSpacing: 1.5,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
