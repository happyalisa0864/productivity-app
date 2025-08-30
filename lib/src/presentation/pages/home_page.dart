import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productivity_app/src/presentation/providers/task_providers.dart';
import 'package:productivity_app/src/presentation/widgets/add_task_dialog.dart';
import 'package:productivity_app/src/presentation/widgets/task_tile.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskNotifierProvider);
    final notifier = ref.read(taskNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do with Timer'),
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tasks) {
          if (tasks.isEmpty) {
            return const Center(
              child: Text('No tasks yet. Tap + to add one.'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskTile(
                task: task,
                onStart: () => notifier.startTimer(task.id),
                onPause: () => notifier.pauseTimer(),
                onToggleComplete: () => notifier.toggleComplete(task.id),
                onDelete: () => notifier.deleteTask(task.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await showDialog<AddTaskResult>(
            context: context,
            builder: (_) => const AddTaskDialog(),
          );
          if (result != null) {
            await notifier.addTask(title: result.title, minutes: result.minutes);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
