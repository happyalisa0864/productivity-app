// statistics page showing weekly productivity metrics; combines saved task history with live data to compute this week's stats
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productivity_app/features/core/providers.dart';
import 'package:productivity_app/features/core/utils/category_colors.dart';
import 'package:productivity_app/features/core/utils/time_format.dart';
import 'package:productivity_app/features/task_tracking/data/models/task_statistics_model.dart';

class StatisticsPage extends ConsumerStatefulWidget {
  const StatisticsPage({super.key});

  @override
  ConsumerState<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends ConsumerState<StatisticsPage> {
  // so stats aren't re-fetched on every rebuild
  Future<List<TaskStatisticsModel>>? _statsFuture;

  @override
  Widget build(BuildContext context) {
    // app bar for statistics page
    final textColor = const Color(0xFF4E4A47);
    final accent = const Color(0xFFF5B8B1);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F5),
      appBar: AppBar(
        title: const Text('Statistics', style: TextStyle(fontWeight: FontWeight.w700, letterSpacing: 0.3)),
      ),

      // AI assistance from cursor agent used to store + reset weekly stats
      body: FutureBuilder<List<TaskStatisticsModel>>(
        future: _statsFuture ??= ref.read(statisticsDataSourceProvider.future).then((ds) => ds.getAllStatistics()),
        builder: (context, statsSnapshot) {
          // builds a unified list from all stats
          final allCompletedData = <_TaskStatisticsData>[];

          // historical stats persist even after tasks are deleted
          if (statsSnapshot.hasData) {
            for (final stat in statsSnapshot.data!) {
              allCompletedData.add(_TaskStatisticsData(
                completedAt: stat.completedAt,
                totalSeconds: stat.totalSeconds,
                remainingSeconds: stat.remainingSeconds,
                category: stat.category,
              ));
            }
          }

          // week runs monday 00:00 to next monday 00:00 in local time
          final now = DateTime.now();
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
          final endOfWeekDate = startOfWeekDate.add(const Duration(days: 7));

          // checks if task was completed this week
          bool isCompletedThisWeek(_TaskStatisticsData data) {
            final local = data.completedAt.toLocal();
            final completedDate = DateTime(local.year, local.month, local.day);
            return !completedDate.isBefore(startOfWeekDate) && completedDate.isBefore(endOfWeekDate);
          }

          // how many tasks were completed
          final weeklyCompletedTasks = allCompletedData.where(isCompletedThisWeek).toList();
          final totalTimeBeforeOvertime = weeklyCompletedTasks.fold<int>(0, (sum, task) {
            return task.remainingSeconds >= 0 ? sum + (task.totalSeconds - task.remainingSeconds) : sum + task.totalSeconds;
          });

          // how much overtime
          final totalOvertime = weeklyCompletedTasks.fold<int>(0, (sum, task) {
            return task.remainingSeconds < 0 ? sum + task.remainingSeconds.abs() : sum;
          });

          // accuracy percentage
          final totalTimeSpent = totalTimeBeforeOvertime + totalOvertime;
          final accuracyPercentage = totalTimeSpent > 0 ? (totalTimeBeforeOvertime / totalTimeSpent * 100) : 100.0;
          final weeklyCompletedTasksCount = weeklyCompletedTasks.length;

          // sum of time spent per category
          const allCategories = ['Work', 'Study', 'Personal', 'Health', 'Other'];
          final categoryStats = {for (final c in allCategories) c: 0};
          for (final data in weeklyCompletedTasks) {
            final category = data.category ?? 'Other';
            final timeSpent = data.remainingSeconds >= 0
                ? data.totalSeconds - data.remainingSeconds
                : data.totalSeconds + data.remainingSeconds.abs();
            categoryStats[category] = (categoryStats[category] ?? 0) + timeSpent;
          }

          // building the rest of the statistics page!
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // top row: tasks completed + time within limit
                Row(children: [
                  Expanded(child: _StatCard(title: 'Tasks Completed This Week', value: weeklyCompletedTasksCount.toString(), icon: Icons.check_circle, color: accent)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(title: 'Total Time (Within Time Limit)', value: formatSeconds(totalTimeBeforeOvertime), icon: Icons.timer, color: const Color(0xFFB2C8BA))),
                ]),

                const SizedBox(height: 12),
                // bottom row: overtime + accuracy percentage
                Row(children: [
                  Expanded(child: _StatCard(title: 'Total Overtime', value: formatSeconds(totalOvertime), icon: Icons.trending_up, color: const Color(0xFFD7CDE9))),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(title: 'Time Limit Accuracy', value: '${accuracyPercentage.toStringAsFixed(1)}%', icon: Icons.track_changes, color: const Color(0xFFFADCD9))),
                ]),

                // time by category
                const SizedBox(height: 32),
                Text('Time by Category (weekly)', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, color: textColor)),
                const SizedBox(height: 12),
                ...allCategories.map((category) {
                  final timeSpent = categoryStats[category] ?? 0;
                  final categoryColor = CategoryColors.getColorForCategory(category);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: categoryColor, borderRadius: BorderRadius.circular(12)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(category, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600, color: textColor)),
                          Text(formatSeconds(timeSpent), style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: textColor.withValues(alpha: 0.7))),
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

// holds data for a single completed task used in stat calculations
class _TaskStatisticsData {
  final DateTime completedAt;
  final int totalSeconds;
  final int remainingSeconds;
  final String? category;

  _TaskStatisticsData({required this.completedAt, required this.totalSeconds, required this.remainingSeconds, this.category});
}

// private widget used above: white card showing one stat metric with icon, value, and label
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    const statColor = Color(0xFF4E4A47);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: statColor)),
          const SizedBox(height: 4),
          Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: statColor.withValues(alpha: 0.6))),
        ],
      ),
    );
  }
}