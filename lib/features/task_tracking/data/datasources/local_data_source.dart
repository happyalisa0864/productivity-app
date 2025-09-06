import 'package:shared_preferences/shared_preferences.dart';

abstract class LocalDataSource {
  Future<List<String>> readTasksJson();
  Future<void> writeTasksJson(List<String> tasksJson);
}

class SharedPreferencesLocalDataSource implements LocalDataSource {
  static const String key = 'tasks';
  final SharedPreferences prefs;
  SharedPreferencesLocalDataSource(this.prefs);

  @override
  Future<List<String>> readTasksJson() async {
    final list = prefs.getStringList(key);
    return list ?? <String>[];
  }

  @override
  Future<void> writeTasksJson(List<String> tasksJson) async {
    await prefs.setStringList(key, tasksJson);
  }
}
