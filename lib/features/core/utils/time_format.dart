String formatSeconds(int seconds) {
  final isNegative = seconds < 0;
  final absSeconds = seconds.abs();
  final s = absSeconds % 60;
  final m = (absSeconds ~/ 60) % 60;
  final h = absSeconds ~/ 3600;
  final prefix = isNegative ? '-' : '';
  if (h > 0) {
    return '$prefix${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '$prefix${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}
