import 'package:productivity_app/features/task_tracking/data/datasources/local_data_source.dart';
import 'package:productivity_app/features/task_tracking/data/models/task_model.dart';
import 'package:productivity_app/features/task_tracking/domain/entities/task.dart';
import 'package:productivity_app/features/task_tracking/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final LocalDataSource local;
  TaskRepositoryImpl(this.local);

  @override
  Future<List<Task>> loadTasks() async {
    final raw = await local.readTasksJson();
    return raw.map((e) => TaskModel.fromJson(e).toEntity()).toList();
  }

  @override
  Future<void> saveTasks(List<Task> tasks) async {
    final jsonList = tasks.map((t) => TaskModel.fromEntity(t).toJson()).toList();
    await local.writeTasksJson(jsonList);
  }
}
