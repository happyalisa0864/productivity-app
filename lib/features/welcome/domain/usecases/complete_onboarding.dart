import 'package:productivity_app/features/welcome/domain/repositories/onboarding_repository.dart';

class CompleteOnboarding {
  final OnboardingRepository repository;
  const CompleteOnboarding(this.repository);

  Future<void> call() => repository.setCompleted(true);
}
