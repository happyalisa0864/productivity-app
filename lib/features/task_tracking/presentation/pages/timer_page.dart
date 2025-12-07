import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productivity_app/features/core/utils/time_format.dart';
import 'package:productivity_app/features/task_tracking/domain/entities/task.dart';
import 'package:productivity_app/features/task_tracking/presentation/providers/task_providers.dart';
import 'package:productivity_app/features/task_tracking/presentation/providers/completion_providers.dart';
import 'package:productivity_app/features/task_tracking/presentation/pages/task_completion_summary.dart';

class TimerPage extends ConsumerStatefulWidget {
  final String taskId;

  const TimerPage({super.key, required this.taskId});

  @override
  ConsumerState<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends ConsumerState<TimerPage> {
  bool _hasNavigated = false;
  bool _wasRunning = false;

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskByIdProvider(widget.taskId));
    final notifier = ref.read(taskNotifierProvider.notifier);
    final completion = ref.watch(taskCompletionProvider);
    
    // Check for completion via completion provider (primary method)
    if (completion != null && completion.taskId == widget.taskId && !_hasNavigated && mounted) {
      _hasNavigated = true;
      // Use a microtask to ensure navigation happens after build
      Future.microtask(() {
        if (!mounted) return;
        ref.read(taskCompletionProvider.notifier).clear();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => TaskCompletionSummary(
              taskId: completion.taskId,
              timeSpent: completion.timeSpent,
            ),
          ),
        );
      });
    }

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
          
          // Check if task just completed (was running, now completed with 0 remaining)
          if (_wasRunning && 
              !task.isRunning && 
              task.isCompleted && 
              task.remainingSeconds == 0 && 
              !_hasNavigated && 
              mounted) {
            // Task just completed - calculate time spent and navigate
            final timeSpent = task.totalSeconds; // Time spent = total time since it's complete
            _hasNavigated = true;
            Future.microtask(() {
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => TaskCompletionSummary(
                    taskId: task.id,
                    timeSpent: timeSpent,
                  ),
                ),
              );
            });
          }
          
          // Track if task was running
          _wasRunning = task.isRunning;
          
          return _TimerScaffold(
            task: task,
            onToggleRun: () {
              if (task.isRunning) {
                notifier.pauseTimer();
              } else if (!task.isCompleted) {
                notifier.startTimer(task.id);
              }
            },
            onReset: () {
              notifier.updateTask(
                id: task.id,
                minutes: (task.totalSeconds / 60).round(),
              );
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
  final VoidCallback onReset;
  final VoidCallback onClose;

  const _TimerScaffold({
    required this.task,
    required this.onToggleRun,
    required this.onReset,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFF5B8B1);
    final background = const Color(0xFFFAF7F5);
    final textColor = const Color(0xFF4E4A47);

    final timeText = formatSeconds(task.remainingSeconds);
    final progress = task.progress.clamp(0.0, 1.0);

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
                  Text(
                    'Focus Timer',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
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
                          // Progress ring with rounded ends
                          CustomPaint(
                            size: const Size(300, 300),
                            painter: _CircularProgressPainter(
                              progress: progress == 0 ? 0 : progress,
                              strokeWidth: 24,
                              color: accent,
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
                                  color: textColor,
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
                            backgroundColor: accent,
                            foregroundColor: Colors.white,
                            elevation: 4,
                          ),
                          child: Icon(
                            task.isRunning ? Icons.pause : Icons.play_arrow,
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 24),
                        ElevatedButton(
                          onPressed: onReset,
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(16),
                            backgroundColor: Colors.white,
                            foregroundColor: textColor.withOpacity(0.75),
                            elevation: 0,
                          ),
                          child: const Icon(Icons.replay, size: 26),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Current task card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Current Task',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: textColor,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              task.title,
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: textColor.withOpacity(0.8),
                                  ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: onClose,
                                icon: const Icon(Icons.skip_next),
                                label: const Text('Back to Tasks'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: textColor,
                                  side: BorderSide(
                                    color: textColor.withOpacity(0.1),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
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
