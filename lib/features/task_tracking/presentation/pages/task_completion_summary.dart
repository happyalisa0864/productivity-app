import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productivity_app/features/core/utils/time_format.dart';
import 'package:productivity_app/features/task_tracking/presentation/providers/task_providers.dart';
import 'package:productivity_app/features/core/presentation/pages/main_navigation.dart';
import 'package:productivity_app/features/task_tracking/presentation/pages/timer_page.dart';

class TaskCompletionSummary extends ConsumerWidget {
  final String taskId;
  final int timeSpent;

  const TaskCompletionSummary({
    super.key,
    required this.taskId,
    required this.timeSpent,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final taskAsync = ref.watch(taskByIdProvider(taskId));
    final allTasksAsync = ref.watch(taskNotifierProvider);
    final accent = const Color(0xFFFADCD9);
    final background = const Color(0xFFFAF7F5);
    final textColor = const Color(0xFF5D5C61);

    return taskAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
      data: (task) {
        if (task == null) {
          return const Scaffold(
            body: Center(child: Text('Task not found')),
          );
        }

        final completedTime = DateTime.now();
        final timeSpentFormatted = formatSeconds(timeSpent);

        return Scaffold(
          backgroundColor: background,
          body: SafeArea(
            child: Column(
              children: [
                // Close button
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const MainNavigation(),
                        ),
                        (route) => false,
                      );
                    },
                  ),
                ),
                // Celebratory graphic
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withValues(alpha: 0.3),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withValues(alpha: 0.6),
                        ),
                        child: const Icon(
                          Icons.auto_awesome,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                // Headline
                Text(
                  'Great work!',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                // Body text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    "You've successfully completed:",
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: textColor.withValues(alpha: 0.8),
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                // Summary card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Time Spent: $timeSpentFormatted',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: textColor.withValues(alpha: 0.7),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Completed on: ${_formatDateTime(completedTime)}',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: textColor.withValues(alpha: 0.7),
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Action buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: allTasksAsync.when(
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                    data: (allTasks) {
                      // Find next incomplete task
                      final incompleteTasks = allTasks
                          .where((t) => !t.isCompleted && t.id != taskId)
                          .toList();
                      final hasNextTask = incompleteTasks.isNotEmpty;
                      final nextTask = hasNextTask ? incompleteTasks.first : null;

                      return Column(
                        children: [
                          // Primary action button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (hasNextTask && nextTask != null) {
                                  // Navigate to next task timer
                                  final notifier = ref.read(taskNotifierProvider.notifier);
                                  notifier.startTimer(nextTask.id);
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => TimerPage(taskId: nextTask.id),
                                    ),
                                    (route) => false,
                                  );
                                } else {
                                  // No more tasks, go to main navigation
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => const MainNavigation(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: textColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                hasNextTask
                                    ? 'Continue to Next Task'
                                    : 'All Tasks Completed! 🎉',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (_) => const MainNavigation(),
                                  ),
                                  (route) => false,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: textColor,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                side: BorderSide(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                ),
                              ),
                              child: const Text(
                                'Back to Tasks',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final month = months[dateTime.month - 1];
    final day = dateTime.day;
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '$month $day, ${displayHour}:${minute.toString().padLeft(2, '0')} $period';
  }
}

