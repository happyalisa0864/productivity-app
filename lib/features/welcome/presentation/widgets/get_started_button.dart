import 'package:flutter/material.dart';

class GetStartedButton extends StatelessWidget {
  final VoidCallback onPressed;
  const GetStartedButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFBDE0FE),
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
      ),
      child: const Text('Get Started'),
    );
  }
}
