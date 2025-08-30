import 'package:flutter/material.dart';
import 'package:productivity_app/src/domain/entities/task.dart';
import 'package:productivity_app/src/presentation/utils/time_format.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;

  const TaskTile({
    super.key,
    required this.task,
    required this.onStart,
    required this.onPause,
    required this.onToggleComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = task.progress;
    final time = formatSeconds(task.remainingSeconds);

    return Card(
      child: ListTile(
        leading: IconButton(
          icon: Icon(task.isCompleted
              ? Icons.check_circle
              : Icons.radio_button_unchecked),
          color: task.isCompleted
              ? theme.colorScheme.primary
              : theme.colorScheme.outline,
          onPressed: onToggleComplete,
          tooltip: task.isCompleted ? 'Mark incomplete' : 'Mark complete',
        ),
        title: Text(
          task.title,
          style: task.isCompleted
              ? theme.textTheme.titleMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: theme.disabledColor,
                )
              : theme.textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LinearProgressIndicator(value: progress == 0 ? null : progress),
            const SizedBox(height: 6),
            Text(
              task.isCompleted ? 'Completed' : 'Remaining: $time',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(task.isRunning ? Icons.pause : Icons.play_arrow),
              onPressed: task.isCompleted
                  ? null
                  : (task.isRunning ? onPause : onStart),
              tooltip: task.isRunning ? 'Pause' : 'Start',
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
              tooltip: 'Delete',
            ),
          ],
        ),
      ),
    );
  }
}
