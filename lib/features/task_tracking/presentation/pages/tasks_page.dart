import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productivity_app/features/task_tracking/presentation/providers/task_providers.dart';
import 'package:productivity_app/features/task_tracking/presentation/widgets/add_task_dialog.dart';
import 'package:productivity_app/features/task_tracking/presentation/widgets/task_tile.dart';
import 'package:productivity_app/features/task_tracking/presentation/pages/timer_page.dart';
import 'package:productivity_app/features/task_tracking/presentation/pages/task_edit_page.dart';
import 'package:productivity_app/features/settings/presentation/pages/settings_page.dart';

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskNotifierProvider);
    final notifier = ref.read(taskNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Today's Tasks",
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsPage(),
                ),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Stack(
        children: [
          tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tasks) {
          if (tasks.isEmpty) {
            return const _EmptyTasksView();
          }
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskTile(
                      task: task,
                      onStart: () {
                        print('DEBUG: onStart called for task ${task.id}');
                        // Start timer without awaiting - fire and forget
                        notifier.startTimer(task.id);
                        // Navigate immediately
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TimerPage(taskId: task.id),
                          ),
                        );
                        print('DEBUG: Navigation pushed');
                      },
                      onPause: () {
                        print('DEBUG: onPause called');
                        notifier.pauseTimer();
                        // Navigate to timer screen to show paused state
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TimerPage(taskId: task.id),
                          ),
                        );
                      },
                      onToggleComplete: () {
                        print('DEBUG: onToggleComplete called');
                        notifier.toggleComplete(task.id);
                      },
                      onDelete: () {
                        print('DEBUG: onDelete called');
                        notifier.deleteTask(task.id);
                      },
                      onEdit: () {
                        print('DEBUG: onEdit called for task ${task.id}');
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => TaskEditPage(taskId: task.id),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
          // Floating action buttons overlay
          Positioned(
            left: 16,
            bottom: 50,
            child: FloatingActionButton(
              heroTag: "clearAll",
              onPressed: () async {
                // Show confirmation dialog
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Tasks'),
                    content: const Text(
                      'Are you sure you want to delete all tasks? This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete All'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await notifier.deleteAllTasks();
                }
              },
              backgroundColor: const Color(0xFFF5B8B1), // Rose pink color
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
          ),
          Positioned(
            right: 16,
            bottom: 50,
            child: FloatingActionButton(
              heroTag: "addTask",
              onPressed: () async {
                final result = await showModalBottomSheet<AddTaskResult>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AddTaskDialog(),
                );
                if (result != null) {
                  await notifier.addTask(
                    title: result.title,
                    minutes: result.minutes,
                    category: result.category,
                  );
                }
              },
              child: const Icon(Icons.add, size: 32),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyTasksView extends StatelessWidget {
  const _EmptyTasksView();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.event_available_outlined,
              size: 96,
              color: Colors.black.withOpacity(0.05),
            ),
            const SizedBox(height: 24),
            Text(
              'All clear!',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              "Looks like you're all caught up.\nAdd a new task to get started.",
              style: textTheme.bodyMedium?.copyWith(
                color: Colors.black.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
