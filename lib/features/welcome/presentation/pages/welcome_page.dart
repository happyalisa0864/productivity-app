import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productivity_app/features/task_tracking/presentation/pages/tasks_page.dart';
import 'package:productivity_app/features/welcome/presentation/providers/welcome_providers.dart';
import 'package:productivity_app/features/welcome/presentation/widgets/get_started_button.dart';
import 'package:productivity_app/features/welcome/presentation/widgets/welcome_logo.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F5),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const WelcomeLogo(),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'A calm space to focus on what matters most.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.black.withOpacity(0.6),
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                bottom: 40,
              ),
              child: GetStartedButton(
                onPressed: () async {
                  // mark onboarding as completed then navigate to Home
                  final complete =
                      await ref.read(completeOnboardingProvider.future);
                  await complete();
                  if (!context.mounted) return;
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const TasksPage()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
