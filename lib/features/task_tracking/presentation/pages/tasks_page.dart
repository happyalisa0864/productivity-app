// main task list page, shows all tasks in a re-order-able list with add/delete options
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productivity_app/features/task_tracking/presentation/providers/task_providers.dart';
import 'package:productivity_app/features/task_tracking/presentation/widgets/add_task_dialog.dart';
import 'package:productivity_app/features/task_tracking/presentation/widgets/task_tile.dart';
import 'package:productivity_app/features/task_tracking/presentation/pages/timer_page.dart';
import 'package:productivity_app/features/task_tracking/presentation/pages/task_edit_page.dart';
import 'package:productivity_app/features/task_tracking/presentation/pages/notepad_page.dart';
import 'package:productivity_app/features/settings/presentation/pages/settings_page.dart';

// transition to slide the new page in from the left
PageRoute<T> _createLeftSlideRoute<T extends Object?>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.ease));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

const _titleStyle = TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3);

class TasksPage extends ConsumerWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasks = ref.watch(taskNotifierProvider).value ?? [];
    final notifier = ref.read(taskNotifierProvider.notifier);

    // sum remaining time across incomplete tasks to display at the top
    final totalRemainingSeconds = tasks.where((t) => !t.isCompleted).fold<int>(0, (sum, task) {
      // if remainingSeconds is negative (overtime), show 0 remaining
      return sum + task.remainingSeconds.clamp(0, task.totalSeconds);
    });
    final hours = totalRemainingSeconds ~/ 3600;
    final minutes = (totalRemainingSeconds % 3600) ~/ 60;
    final timeText = hours > 0 && minutes > 0
        ? 'Time Remaining: ${hours}h ${minutes}m' : hours > 0
        ? 'Time Remaining: ${hours}h' : minutes > 0
        ? 'Time Remaining: ${minutes}m' : 'Time Remaining: 0m';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Today's Tasks", style: _titleStyle),
            Text(timeText, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, fontWeight: FontWeight.normal)),
          ],
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.note),
          tooltip: 'Notepad',
          // custom transition (see above)
          onPressed: () => Navigator.of(context).push(_createLeftSlideRoute(const NotepadPage())),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsPage())),
          ),
        ],
      ),
      body: Stack(
        children: [
          // main task list (or empty state)
          if (tasks.isEmpty)
            const _EmptyTasksView()
          else
            ReorderableListView.builder(
              // START HERE
              padding: const EdgeInsets.only(top: 8, bottom: 120, left: 16, right: 16), 
              itemCount: tasks.length,
              onReorder: notifier.reorderTasks,
              proxyDecorator: (child, index, animation) => Material(color: Colors.transparent, child: child),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskTile(
                  key: ValueKey(task.id), // must have unique key for reordering
                  task: task,
                  onStart: () {
                    notifier.startTimer(task.id);
                    Navigator.of(context).push(_createLeftSlideRoute(TimerPage(taskId: task.id))); // start timer and navigate
                  },
                  onPause: () {
                    notifier.pauseTimer();
                    Navigator.of(context).push(_createLeftSlideRoute(TimerPage(taskId: task.id))); // show paused timer screen
                  },
                  onToggleComplete: () => notifier.toggleComplete(task.id),
                  onDelete: () => notifier.deleteTask(task.id),
                  onEdit: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => TaskEditPage(taskId: task.id))), // open edit form
                );
              },
            ),
          // Bottom-left FAB: delete all tasks (with confirmation)
          Positioned(
            left: 16, bottom: 50,
            child: FloatingActionButton(
              heroTag: 'clearAll',
              backgroundColor: const Color(0xFFF5B8B1), // Rose pink color
              onPressed: () async {
                // Show confirmation dialog
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Tasks'),
                    content: const Text('Are you sure you want to delete all tasks? This action cannot be undone.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                      TextButton(onPressed: () => Navigator.of(context).pop(true), style: TextButton.styleFrom(foregroundColor: Colors.red), child: const Text('Delete All')),
                    ],
                  ),
                );
                if (confirmed == true) await notifier.deleteAllTasks();
              },
              child: const Icon(Icons.delete_outline, color: Colors.white),
            ),
          ),
          // Bottom-right FAB: open the add-task dialog
          Positioned(
            right: 16, bottom: 50,
            child: FloatingActionButton(
              heroTag: 'addTask',
              onPressed: () async {
                final result = await showModalBottomSheet<AddTaskResult>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AddTaskDialog(),
                );
                if (result != null) {
                  await notifier.addTask(title: result.title, minutes: result.minutes, category: result.category);
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
            Icon(Icons.event_available_outlined, size: 96, color: Colors.black.withValues(alpha: 0.05)),
            const SizedBox(height: 24),
            Text('All clear!', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text("Looks like you're all caught up.\nAdd a new task to get started.", style: textTheme.bodyMedium?.copyWith(color: Colors.black.withValues(alpha: 0.6)), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
