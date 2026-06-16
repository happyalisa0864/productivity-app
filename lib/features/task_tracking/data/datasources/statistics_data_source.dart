import 'package:productivity_app/features/task_tracking/data/models/task_statistics_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class StatisticsDataSource {
  Future<List<TaskStatisticsModel>> getAllStatistics();
  Future<void> saveStatistics(TaskStatisticsModel statistics);
  Future<void> removeStatisticsForTask(String taskId);
  Future<void> clearAllStatistics();
}

class SharedPreferencesStatisticsDataSource implements StatisticsDataSource {
  static const String key = 'task_statistics';
  final SharedPreferences prefs;

  SharedPreferencesStatisticsDataSource(this.prefs);

  @override
  Future<List<TaskStatisticsModel>> getAllStatistics() async {
    final list = prefs.getStringList(key);
    if (list == null || list.isEmpty) return [];
    return list.map((json) => TaskStatisticsModel.fromJson(json)).toList();
  }

  @override
  Future<void> saveStatistics(TaskStatisticsModel statistics) async {
    final list = await getAllStatistics();
    list.add(statistics);
    final jsonList = list.map((s) => s.toJson()).toList();
    await prefs.setStringList(key, jsonList);
  }

  @override
  Future<void> removeStatisticsForTask(String taskId) async {
    final list = await getAllStatistics();
    list.removeWhere((stat) => stat.taskId == taskId);
    final jsonList = list.map((s) => s.toJson()).toList();
    await prefs.setStringList(key, jsonList);
  }

  @override
  Future<void> clearAllStatistics() async {
    await prefs.remove(key);
  }
}

