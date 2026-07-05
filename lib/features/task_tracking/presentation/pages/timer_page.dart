// timer screen for one task: shows a circular countdown, play/pause, and a done button that marks task complete and moves to next task
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productivity_app/features/core/utils/time_format.dart';
import 'package:productivity_app/features/task_tracking/domain/entities/task.dart';
import 'package:productivity_app/features/task_tracking/presentation/providers/task_providers.dart';

// same left-slide-animation as the one in tasks_page
PageRoute<T> _createLeftSlideRoute<T extends Object?>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final tween = Tween(begin: const Offset(-1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.ease));
      return SlideTransition(position: animation.drive(tween), child: child);
    },
  );
}

class TimerPage extends ConsumerStatefulWidget {
  final String taskId;
  const TimerPage({super.key, required this.taskId});

  @override
  ConsumerState<TimerPage> createState() => _TimerPageState();
}

// renders timer UI or handles navigation based on task's current state
class _TimerPageState extends ConsumerState<TimerPage> {
  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskByIdProvider(widget.taskId));
    final notifier = ref.read(taskNotifierProvider.notifier);

    final task = taskAsync.value;
    return PopScope(
      // going back to tasks page pauses timer
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          await notifier.pauseTimer();
          if (!context.mounted) return;
          Navigator.of(context).pop();
        }
      },
      child: task == null ? const Scaffold(backgroundColor: Color(0xFFFAF7F5), body: SizedBox.shrink()) : _TimerScaffold(
        task: task,
        // toggle play/pause button
        onToggleRun: () {
          if (task.isRunning) {
            notifier.pauseTimer();
          } else if (!task.isCompleted) {
            notifier.startTimer(task.id);
          }
        },
        onDone: () async {
          // confirmation dialog before marking task as complete
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Complete Task'),
              content: const Text('Have you finished this task?'),
              actions: [
                TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Yes')),
              ],
            ),
          );
          if (confirmed != true || !context.mounted) return;
          await notifier.toggleComplete(task.id);

          // find the next incomplete task in list order
          final allTasks = ref.read(taskNotifierProvider).value ?? <Task>[];
          Task? nextTask;
          final currentIndex = allTasks.indexWhere((t) => t.id == task.id);
          if (currentIndex != -1) {
            // look for next incomplete task after current task
            for (int i = currentIndex + 1; i < allTasks.length; i++) {
              if (!allTasks[i].isCompleted) { nextTask = allTasks[i]; break; }
            }
            // if no task found after current task, look from the beginning of the list
            if (nextTask == null) {
              for (int i = 0; i < currentIndex; i++) {
                if (!allTasks[i].isCompleted) { nextTask = allTasks[i]; break; }
              }
            }
          // START HERE
          } else {
            // fallback: just get the first incomplete task
            final incomplete = allTasks.where((t) => !t.isCompleted);
            if (incomplete.isNotEmpty) nextTask = incomplete.first;
          }
          if (!context.mounted) return;
          if (nextTask != null) {
            // jump straight to the next task's timer and start it
            Navigator.of(context).pushReplacement(_createLeftSlideRoute(TimerPage(taskId: nextTask.id)));
            notifier.startTimer(nextTask.id);
          } else {
            // no more incomplete tasks, go back to tasks page
            Navigator.of(context).pop();
          }
        },
        onClose: () async {
          await notifier.pauseTimer();
          if (!context.mounted) return;
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

// the timer layout: title bar, circular progress ring, and control buttons.
class _TimerScaffold extends StatelessWidget {
  final Task task;
  final VoidCallback onToggleRun;
  final VoidCallback onDone;
  final VoidCallback onClose;

  const _TimerScaffold({required this.task, required this.onToggleRun, required this.onDone, required this.onClose});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFF5B8B1);
    const background = Color(0xFFFAF7F5);
    const textColor = Color(0xFF4E4A47);
    final timeText = formatSeconds(task.remainingSeconds);
    final isOvertime = task.remainingSeconds < 0;
    // ring fills completely when time runs out (overtime shown in red)
    final progress = isOvertime ? 1.0 : task.progress.clamp(0.0, 1.0);
    final timerStyle = Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.bold, fontSize: 64);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),
            // lightweight top bar with close button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const SizedBox(width: 40),
                  Expanded(
                    child: Text(task.title, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  IconButton(onPressed: onClose, icon: const Icon(Icons.close)),
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
                    // circular timer - slightly smaller with rounded ends
                    SizedBox(
                      height: 320, width: 320,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // faded background ring
                          CustomPaint(size: const Size(300, 300), painter: _CircularProgressPainter(progress: 1.0, strokeWidth: 24, color: accent.withValues(alpha: 0.18))),
                          // active progress ring (red when in overtime)
                          CustomPaint(size: const Size(300, 300), painter: _CircularProgressPainter(progress: progress == 0 ? 0 : progress, strokeWidth: 24, color: isOvertime ? Colors.red : accent)),
                          // timer digits with a subtle outline for readability
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // white outline - draw text in multiple positions to create stroke
                              ...List.generate(8, (index) {
                                final angle = (index * math.pi * 2) / 8;
                                return Transform.translate(
                                  offset: Offset(math.cos(angle) * 2.5, math.sin(angle) * 2.5),
                                  child: Text(timeText, style: timerStyle?.copyWith(color: background)), // white outline using background color
                                );
                              }),
                              // main text on top - color changes based on overtime
                              Text(timeText, style: timerStyle?.copyWith(color: isOvertime ? Colors.red : textColor)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text('Focus Time', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: textColor.withValues(alpha: 0.7))),
                    const SizedBox(height: 24),
                    // controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: onToggleRun,
                          style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(20), backgroundColor: Colors.white, foregroundColor: textColor.withValues(alpha: 0.75), elevation: 0),
                          child: Icon(task.isRunning ? Icons.pause : Icons.play_arrow, size: 32),
                        ),
                        const SizedBox(width: 24),
                        ElevatedButton(
                          onPressed: onDone,
                          style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(16), backgroundColor: accent, foregroundColor: Colors.white, elevation: 4),
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

// draws the circular progress arc with rounded stroke ends.
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final Color color;

  _CircularProgressPainter({required this.progress, required this.strokeWidth, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = strokeWidth..style = PaintingStyle.stroke..strokeCap = StrokeCap.round; // rounded ends!
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -math.pi / 2, 2 * math.pi * progress, false, paint); // start from top
  }

  @override
  bool shouldRepaint(_CircularProgressPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.strokeWidth != strokeWidth || oldDelegate.color != color;
}
