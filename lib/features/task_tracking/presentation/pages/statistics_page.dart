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
          
          // Calculate total time within time limit
          // If completed within time limit (remainingSeconds >= 0), count actual time spent
          // If went into overtime (remainingSeconds < 0), count only up to the time limit
          final totalTimeBeforeOvertime = completedTasks.fold<int>(
            0,
            (sum, task) {
              if (task.remainingSeconds >= 0) {
                // Completed within time limit - count actual time spent
                return sum + (task.totalSeconds - task.remainingSeconds);
              } else {
                // Went into overtime - count only the time limit
                return sum + task.totalSeconds;
              }
            },
          );
          
          // Calculate total overtime time (sum of negative remainingSeconds)
          final totalOvertime = completedTasks.fold<int>(
            0,
            (sum, task) {
              // If remainingSeconds is negative, that's overtime
              if (task.remainingSeconds < 0) {
                final overtime = task.remainingSeconds.abs();
                return sum + overtime;
              }
              return sum;
            },
          );

          // Calculate time limit accuracy percentage
          final totalTimeSpent = totalTimeBeforeOvertime + totalOvertime;
          final accuracyPercentage = totalTimeSpent > 0
              ? (totalTimeBeforeOvertime / totalTimeSpent * 100)
              : 100.0;

          // Calculate weekly completions
          final now = DateTime.now();
          // Get start of current week (Monday)
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
          final endOfWeekDate = startOfWeekDate.add(const Duration(days: 7));
          
          final weeklyCompletedTasks = completedTasks.where((task) {
            if (task.completedAt == null) return false;
            final completedAt = task.completedAt!;
            // Include tasks completed from start of week (inclusive) to end of week (exclusive)
            return (completedAt.isAtSameMomentAs(startOfWeekDate) || completedAt.isAfter(startOfWeekDate)) && 
                   completedAt.isBefore(endOfWeekDate);
          }).length;

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
                        title: 'Tasks Completed This Week',
                        value: weeklyCompletedTasks.toString(),
                        icon: Icons.check_circle,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Total Time (Within Time Limit)',
                        value: formatSeconds(totalTimeBeforeOvertime),
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
                        title: 'Total Overtime',
                        value: formatSeconds(totalOvertime),
                        icon: Icons.trending_up,
                        color: const Color(0xFFD7CDE9),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        title: 'Time Limit Accuracy',
                        value: '${accuracyPercentage.toStringAsFixed(1)}%',
                        icon: Icons.track_changes,
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

