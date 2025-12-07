import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productivity_app/features/core/presentation/pages/main_navigation.dart';
import 'package:productivity_app/features/welcome/presentation/pages/welcome_page.dart';
import 'package:productivity_app/features/welcome/presentation/providers/welcome_providers.dart';

class AppEntry extends ConsumerWidget {
  const AppEntry({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completeAsync = ref.watch(isOnboardingCompleteProvider);

    return completeAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Failed to load app state'),
              const SizedBox(height: 8),
              Text(e.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(isOnboardingCompleteProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      data: (completed) => completed ? const MainNavigation() : const WelcomePage(),
    );
  }
}
