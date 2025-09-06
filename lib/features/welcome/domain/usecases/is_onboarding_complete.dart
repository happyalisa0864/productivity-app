import 'package:productivity_app/features/welcome/domain/repositories/onboarding_repository.dart';

class IsOnboardingComplete {
  final OnboardingRepository repository;
  const IsOnboardingComplete(this.repository);

  Future<bool> call() => repository.isCompleted();
}
