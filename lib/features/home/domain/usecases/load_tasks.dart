import 'package:productivity_app/features/home/domain/entities/task.dart';
import 'package:productivity_app/features/home/domain/repositories/task_repository.dart';

class LoadTasks {
  final TaskRepository repository;
  const LoadTasks(this.repository);

  Future<List<Task>> call() async {
    return repository.loadTasks();
  }
}
