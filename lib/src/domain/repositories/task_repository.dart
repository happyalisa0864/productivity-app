import 'package:productivity_app/src/domain/entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> loadTasks();
  Future<void> saveTasks(List<Task> tasks);
}
