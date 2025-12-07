import 'package:flutter/material.dart';

class GetStartedButton extends StatelessWidget {
  final VoidCallback onPressed;
  const GetStartedButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF5B8B1),
          foregroundColor: const Color(0xFF4E4A47),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
          elevation: 0,
        ),
        child: const Text('Get Started'),
      ),
    );
  }
}
