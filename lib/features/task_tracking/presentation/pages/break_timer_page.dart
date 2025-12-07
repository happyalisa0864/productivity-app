import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productivity_app/features/core/utils/time_format.dart';

class BreakTimerPage extends ConsumerStatefulWidget {
  final int breakMinutes;
  
  const BreakTimerPage({
    super.key,
    this.breakMinutes = 5,
  });

  @override
  ConsumerState<BreakTimerPage> createState() => _BreakTimerPageState();
}

class _BreakTimerPageState extends ConsumerState<BreakTimerPage> {
  int _remainingSeconds = 0;
  bool _isRunning = false;
  Timer? _timer;
  late int _totalSeconds;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.breakMinutes * 60;
    _remainingSeconds = _totalSeconds;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;
    
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _remainingSeconds = (_remainingSeconds - 1).clamp(0, _totalSeconds);
        if (_remainingSeconds == 0) {
          _isRunning = false;
          timer.cancel();
          // Show completion dialog
          _showBreakCompleteDialog();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _remainingSeconds = _totalSeconds;
    });
  }

  void _showBreakCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Break Complete!'),
        content: const Text('Your break is over. Ready to get back to work?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = const Color(0xFFF5B8B1);
    final background = const Color(0xFFFAF7F5);
    final textColor = const Color(0xFF4E4A47);

    final timeText = formatSeconds(_remainingSeconds);
    final progress = _totalSeconds == 0
        ? 0.0
        : (1 - (_remainingSeconds.clamp(0, _totalSeconds) / _totalSeconds));

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text(
          'Break Timer',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Circular timer
              SizedBox(
                height: 300,
                width: 300,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Background ring
                    CustomPaint(
                      painter: _CircularProgressPainter(
                        progress: 1.0,
                        strokeWidth: 24,
                        color: accent.withOpacity(0.18),
                      ),
                      child: Container(),
                    ),
                    // Progress ring
                    CustomPaint(
                      painter: _CircularProgressPainter(
                        progress: progress,
                        strokeWidth: 24,
                        color: accent,
                      ),
                      child: Container(),
                    ),
                    Text(
                      timeText,
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
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
                'Break Time',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: textColor.withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 28),
              // Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _isRunning ? _pauseTimer : _startTimer,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      elevation: 4,
                    ),
                    child: Icon(
                      _isRunning ? Icons.pause : Icons.play_arrow,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 24),
                  ElevatedButton(
                    onPressed: _resetTimer,
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
              const SizedBox(height: 36),
            ],
          ),
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
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2) - strokeWidth / 2;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double startAngle = -math.pi / 2;
    final double sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.color != color;
  }
}

