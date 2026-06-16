// Main task list screen — the home screen of the app.
// Shows all tasks in a reorderable list with add/delete FABs and navigation
// to the notepad, settings, timer, and task edit screens.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productivity_app/features/task_tracking/presentation/providers/task_providers.dart';
import 'package:productivity_app/features/task_tracking/presentation/widgets/add_task_dialog.dart';
import 'package:productivity_app/features/task_tracking/presentation/widgets/task_tile.dart';
import 'package:productivity_app/features/task_tracking/presentation/pages/timer_page.dart';
import 'package:productivity_app/features/task_tracking/presentation/pages/task_edit_page.dart';
import 'package:productivity_app/features/task_tracking/presentation/pages/notepad_page.dart';
import 'package:productivity_app/features/settings/presentation/pages/settings_page.dart';

// Custom page transition: slides the new page in from the left.
PageRoute<T> _createLeftSlideRoute<T extends Object?>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(-1.0, 0.0); // Start from left
      const end = Offset.zero;
      const curve = Curves.ease;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskNotifierProvider);
    final notifier = ref.read(taskNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: tasksAsync.when(
          loading: () => const Text(
            "Today's Tasks",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          error: (_, __) => const Text(
            "Today's Tasks",
            style: TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
          data: (tasks) {
            // Sum remaining time across incomplete tasks for the app bar subtitle
            final incompleteTasks = tasks.where((task) => !task.isCompleted).toList();
            final totalRemainingSeconds = incompleteTasks.fold<int>(
              0,
              (sum, task) {
                // For incomplete tasks, use remainingSeconds (clamped to >= 0)
                // If remainingSeconds is negative (overtime), show 0 remaining
                final remaining = task.remainingSeconds.clamp(0, task.totalSeconds);
                return sum + remaining;
              },
            );
            final hours = totalRemainingSeconds ~/ 3600;
            final minutes = (totalRemainingSeconds % 3600) ~/ 60;
            
            String timeText;
            if (hours > 0 && minutes > 0) {
              timeText = 'Time Remaining: ${hours}h ${minutes}m';
            } else if (hours > 0) {
              timeText = 'Time Remaining: ${hours}h';
            } else if (minutes > 0) {
              timeText = 'Time Remaining: ${minutes}m';
            } else {
              timeText = 'Time Remaining: 0m';
            }
            
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Today's Tasks",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                  ),
                ),
                Text(
                  timeText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            );
          },
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.note),
          onPressed: () {
            // Open the notepad with a left-slide transition
            Navigator.of(context).push(
              _createLeftSlideRoute(
                const NotepadPage(),
              ),
            );
          },
          tooltip: 'Notepad',
        ),
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
          // Main task list (or empty state)
          tasksAsync.when(
        loading: () => const _EmptyTasksView(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tasks) {
          if (tasks.isEmpty) {
            return const _EmptyTasksView();
          }
          return Column(
            children: [
              Expanded(
                // Drag to reorder tasks; each row is a TaskTile with action callbacks
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.only(
                    top: 8,
                    bottom: 120, // Extra padding to ensure last task is visible above FABs
                    left: 16,
                    right: 16,
                  ),
                  itemCount: tasks.length,
                  onReorder: (oldIndex, newIndex) {
                    notifier.reorderTasks(oldIndex, newIndex);
                  },
                  proxyDecorator: (child, index, animation) {
                    return Material(
                      color: Colors.transparent,
                      child: child,
                    );
                  },
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return TaskTile(
                      key: ValueKey(task.id), // CRITICAL: Must have unique key for reordering
                      task: task,
                      onStart: () {
                        // Start the timer and navigate to the timer screen
                        notifier.startTimer(task.id);
                        Navigator.of(context).push(
                          _createLeftSlideRoute(
                            TimerPage(taskId: task.id),
                          ),
                        );
                      },
                      onPause: () {
                        notifier.pauseTimer();
                        // Show the paused timer screen
                        Navigator.of(context).push(
                          _createLeftSlideRoute(
                            TimerPage(taskId: task.id),
                          ),
                        );
                      },
                      onToggleComplete: () {
                        notifier.toggleComplete(task.id);
                      },
                      onDelete: () {
                        notifier.deleteTask(task.id);
                      },
                      onEdit: () {
                        // Open the edit form for this task
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
          // Bottom-left FAB: delete all tasks (with confirmation)
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
          // Bottom-right FAB: open the add-task dialog
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

// Placeholder shown when the user has no tasks yet.
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
              color: Colors.black.withValues(alpha: 0.05),
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
                color: Colors.black.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
