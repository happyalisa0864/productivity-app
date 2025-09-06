import 'package:productivity_app/features/welcome/data/datasources/onboarding_local_data_source.dart';
import 'package:productivity_app/features/welcome/domain/repositories/onboarding_repository.dart';

class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource local;
  OnboardingRepositoryImpl(this.local);

  @override
  Future<bool> isCompleted() => local.getCompleted();

  @override
  Future<void> setCompleted(bool value) => local.setCompleted(value);
}
