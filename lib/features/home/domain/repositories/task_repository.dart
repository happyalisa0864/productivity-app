import 'package:productivity_app/features/home/domain/entities/task.dart';

abstract class TaskRepository {
  Future<List<Task>> loadTasks();
  Future<void> saveTasks(List<Task> tasks);
}
