class Task {
  final String id;
  final String title;
  final int totalSeconds;
  final int remainingSeconds;
  final bool isCompleted;
  final bool isRunning;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Task({
    required this.id,
    required this.title,
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.isCompleted,
    required this.isRunning,
    required this.createdAt,
    required this.updatedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    int? totalSeconds,
    int? remainingSeconds,
    bool? isCompleted,
    bool? isRunning,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      isRunning: isRunning ?? this.isRunning,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get progress => totalSeconds == 0
      ? 0
      : (1 - (remainingSeconds.clamp(0, totalSeconds) / totalSeconds));
}
