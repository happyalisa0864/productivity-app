import 'package:flutter/material.dart';
import 'package:productivity_app/features/task_tracking/domain/entities/task.dart';
import 'package:productivity_app/features/core/utils/time_format.dart';
import 'package:productivity_app/features/core/utils/category_colors.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onToggleComplete;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const TaskTile({
    super.key,
    required this.task,
    required this.onStart,
    required this.onPause,
    required this.onToggleComplete,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final time = formatSeconds(task.remainingSeconds);
    final isCompleted = task.isCompleted;

    // Use category color for time limit pill
    // Background color stays the same regardless of completion status
    final categoryColor = CategoryColors.getColorForCategory(task.category);
    final badgeColor = categoryColor;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Checkbox
            GestureDetector(
              onTap: () {
                onToggleComplete();
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted
                        ? const Color(0xFFF5B8B1)
                        : const Color(0xFFD3D0CC),
                    width: 2,
                  ),
                  color: isCompleted
                      ? const Color(0xFFF5B8B1)
                      : Colors.transparent,
                ),
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        size: 18,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            const SizedBox(width: 16),
            // Task title area - tappable to edit
            Expanded(
              child: GestureDetector(
                onTap: () {
                  if (onEdit != null) {
                    onEdit!();
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        decoration:
                            isCompleted ? TextDecoration.lineThrough : null,
                        color: isCompleted
                            ? Colors.grey.shade500
                            : theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: badgeColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '${(task.totalSeconds / 60).round()} min',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? const Color(0xFF4E4A47).withOpacity(0.5) // Lighter text for completed tasks
                              : const Color(0xFF4E4A47), // Dark gray text for readability
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Play/Pause button - separate from card tap
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(
                    task.isRunning ? Icons.pause : Icons.play_arrow,
                    size: 28,
                  ),
                  onPressed: isCompleted
                      ? null
                      : () {
                          if (task.isRunning) {
                            onPause();
                          } else {
                            onStart();
                          }
                        },
                  tooltip: task.isRunning ? 'Pause' : 'Start',
                ),
                Text(
                  isCompleted ? 'Done' : time,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
