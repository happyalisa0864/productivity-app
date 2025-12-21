import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productivity_app/features/core/providers.dart';
import 'package:productivity_app/features/welcome/data/datasources/onboarding_local_data_source.dart';
import 'package:productivity_app/features/welcome/data/repositories/onboarding_repository_impl.dart';
import 'package:productivity_app/features/welcome/domain/repositories/onboarding_repository.dart';
import 'package:productivity_app/features/welcome/domain/usecases/complete_onboarding.dart';
import 'package:productivity_app/features/welcome/domain/usecases/is_onboarding_complete.dart';

final onboardingRepositoryProvider =
    FutureProvider<OnboardingRepository>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final local = SharedPreferencesOnboardingLocalDataSource(prefs);
  return OnboardingRepositoryImpl(local);
});

final isOnboardingCompleteProvider = FutureProvider<bool>((ref) async {
  final repo = await ref.watch(onboardingRepositoryProvider.future);
  return IsOnboardingComplete(repo)();
});

final completeOnboardingProvider = FutureProvider<CompleteOnboarding>((ref) async {
  final repo = await ref.watch(onboardingRepositoryProvider.future);
  return CompleteOnboarding(repo);
});
