import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productivity_app/features/core/utils/time_format.dart';
import 'package:productivity_app/features/task_tracking/domain/entities/task.dart';
import 'package:productivity_app/features/task_tracking/presentation/providers/task_providers.dart';

class TimerPage extends ConsumerStatefulWidget {
  final String taskId;

  const TimerPage({super.key, required this.taskId});

  @override
  ConsumerState<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends ConsumerState<TimerPage> {

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskByIdProvider(widget.taskId));
    final notifier = ref.read(taskNotifierProvider.notifier);

    // Also check task state directly as a fallback
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        // Auto-pause when leaving the timer screen
        if (!didPop) {
          await notifier.pauseTimer();
          if (mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: taskAsync.when(
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
          
          return _TimerScaffold(
            task: task,
            onToggleRun: () {
              if (task.isRunning) {
                notifier.pauseTimer();
              } else if (!task.isCompleted) {
                notifier.startTimer(task.id);
              }
            },
            onDone: () async {
              // Show confirmation dialog
              final confirmed = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Complete Task'),
                  content: const Text('Have you finished this task?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Yes'),
                    ),
                  ],
                ),
              );

              if (confirmed == true && mounted) {
                // Mark task as complete
                await notifier.toggleComplete(task.id);
                
                // Find the next incomplete task
                final allTasks = ref.read(taskNotifierProvider).value ?? <Task>[];
                final incompleteTasks = allTasks.where((t) => !t.isCompleted).toList();
                
                // Find the next task after the current one
                Task? nextTask;
                final currentIndex = allTasks.indexWhere((t) => t.id == task.id);
                if (currentIndex != -1) {
                  // Look for next incomplete task after current
                  for (int i = currentIndex + 1; i < allTasks.length; i++) {
                    if (!allTasks[i].isCompleted) {
                      nextTask = allTasks[i];
                      break;
                    }
                  }
                  // If no task found after current, look from the beginning
                  if (nextTask == null) {
                    for (int i = 0; i < currentIndex; i++) {
                      if (!allTasks[i].isCompleted) {
                        nextTask = allTasks[i];
                        break;
                      }
                    }
                  }
                } else if (incompleteTasks.isNotEmpty) {
                  // Fallback: just get the first incomplete task
                  nextTask = incompleteTasks.first;
                }
                
                if (mounted) {
                  if (nextTask != null) {
                    // Navigate to next task's timer and start it
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => TimerPage(taskId: nextTask!.id),
                      ),
                    );
                    // Start the timer for the next task
                    notifier.startTimer(nextTask.id);
                  } else {
                    // No more incomplete tasks, go back to tasks page
                    Navigator.of(context).pop();
                  }
                }
              }
            },
            onClose: () async {
              // Pause before closing
              await notifier.pauseTimer();
              if (mounted) {
                Navigator.of(context).pop();
              }
            },
          );
        },
      ),
    );
  }
}

class _TimerScaffold extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleRun;
  final VoidCallback onDone;
  final VoidCallback onClose;

  const _TimerScaffold({
    required this.task,
    required this.onToggleRun,
    required this.onDone,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFF5B8B1);
    final background = const Color(0xFFFAF7F5);
    final textColor = const Color(0xFF4E4A47);

    final timeText = formatSeconds(task.remainingSeconds);
    final isOvertime = task.remainingSeconds < 0;
    // For overtime, show progress as complete (full circle)
    final progress = isOvertime ? 1.0 : task.progress.clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Lightweight top bar with close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(
                      task.title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: onClose,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    // Circular timer - slightly smaller with rounded ends
                    SizedBox(
                      height: 320,
                      width: 320,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background ring
                          CustomPaint(
                            size: const Size(300, 300),
                            painter: _CircularProgressPainter(
                              progress: 1.0,
                              strokeWidth: 24,
                              color: accent.withOpacity(0.18),
                            ),
                          ),
                          // Progress ring with rounded ends - red when in overtime
                          CustomPaint(
                            size: const Size(300, 300),
                            painter: _CircularProgressPainter(
                              progress: progress == 0 ? 0 : progress,
                              strokeWidth: 24,
                              color: isOvertime ? Colors.red : accent,
                            ),
                          ),
                          Text(
                            timeText,
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 64,
                                  color: isOvertime ? Colors.red : textColor,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Focus Time',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: textColor.withOpacity(0.7),
                          ),
                    ),
                    const SizedBox(height: 24),
                    // Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: onToggleRun,
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(20),
                            backgroundColor: Colors.white,
                            foregroundColor: textColor.withOpacity(0.75),
                            elevation: 0,
                          ),
                          child: Icon(
                            task.isRunning ? Icons.pause : Icons.play_arrow,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 24),
                        ElevatedButton(
                          onPressed: onDone,
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(16),
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            elevation: 4,
                          ),
                          child: const Icon(Icons.check, size: 26),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom painter for circular progress with rounded ends
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  _CircularProgressPainter({
    required this.progress,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round; // Rounded ends!

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final startAngle = -math.pi / 2; // Start from top
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color;
  }
}
