import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productivity_app/features/home/data/datasources/local_data_source.dart';
import 'package:productivity_app/features/home/data/repositories/task_repository_impl.dart';
import 'package:productivity_app/features/home/domain/repositories/task_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

final repositoryProvider = FutureProvider<TaskRepository>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final local = SharedPreferencesLocalDataSource(prefs);
  return TaskRepositoryImpl(local);
});
