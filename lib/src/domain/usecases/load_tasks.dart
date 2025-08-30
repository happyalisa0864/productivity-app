import 'package:productivity_app/src/domain/entities/task.dart';
import 'package:productivity_app/src/domain/repositories/task_repository.dart';

class LoadTasks {
  final TaskRepository repository;
  const LoadTasks(this.repository);

  Future<List<Task>> call() async {
    return repository.loadTasks();
  }
}
