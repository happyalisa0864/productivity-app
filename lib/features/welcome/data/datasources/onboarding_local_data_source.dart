import 'package:shared_preferences/shared_preferences.dart';

abstract class OnboardingLocalDataSource {
  Future<bool> getCompleted();
  Future<void> setCompleted(bool value);
}

class SharedPreferencesOnboardingLocalDataSource
    implements OnboardingLocalDataSource {
  static const String key = 'onboarding_completed';
  final SharedPreferences prefs;
  SharedPreferencesOnboardingLocalDataSource(this.prefs);

  @override
  Future<bool> getCompleted() async {
    return prefs.getBool(key) ?? false;
  }

  @override
  Future<void> setCompleted(bool value) async {
    await prefs.setBool(key, value);
  }
}
