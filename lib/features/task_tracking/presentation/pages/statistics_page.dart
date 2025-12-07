import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productivity_app/features/core/utils/time_format.dart';
import 'package:productivity_app/features/task_tracking/presentation/providers/task_providers.dart';

class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(taskNotifierProvider);
    final textColor = const Color(0xFF4E4A47);
    final accent = const Color(0xFFF5B8B1);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F5),
      appBar: AppBar(
        title: const Text(
          'Statistics',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (tasks) {
          final completedTasks = tasks.where((t) => t.isCompleted).toList();
          final totalTasks = tasks.length;
          final totalTimeSpent = completedTasks.fold<int>(
            0,
            (sum, task) => sum + (task.totalSeconds - task.remainingSeconds),
          );
          final averageTime = completedTasks.isEmpty
              ? 0
              : totalTimeSpent ~/ completedTasks.length;

          // Group by category
          final categoryStats = <String, int>{};
          for (final task in completedTasks) {
            final category = task.category ?? 'Other';
            categoryStats[category] =
                (categoryStats[category] ?? 0) + (task.totalSeconds - task.remainingSeconds);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Overview cards
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Tasks Completed',
                        value: completedTasks.length.toString(),
                        icon: Icons.check_circle,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Total Time',
                        value: formatSeconds(totalTimeSpent),
                        icon: Icons.timer,
                        color: const Color(0xFFB2C8BA),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        title: 'Average Time',
                        value: formatSeconds(averageTime),
                        icon: Icons.trending_up,
                        color: const Color(0xFFD7CDE9),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Total Tasks',
                        value: totalTasks.toString(),
                        icon: Icons.list,
                        color: const Color(0xFFFADCD9),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Category breakdown
                Text(
                  'Time by Category',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                ),
                const SizedBox(height: 12),
                if (categoryStats.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'No completed tasks yet',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: textColor.withOpacity(0.6),
                          ),
                    ),
                  )
                else
                  ...categoryStats.entries.map((entry) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                            ),
                            Text(
                              formatSeconds(entry.value),
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: textColor.withOpacity(0.7),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4E4A47),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF4E4A47).withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }
}

