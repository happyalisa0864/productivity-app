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
      backgroundColor: const Color(0xFFFFFDD7), // pale yellow background
      appBar: AppBar(
        title: const Text('MainScreen'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              const WelcomeLogo(),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: GetStartedButton(
                  onPressed: () async {
                    // mark onboarding as completed then navigate to Home
                    final complete = await ref.read(completeOnboardingProvider.future);
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
      ),
    );
  }
}
