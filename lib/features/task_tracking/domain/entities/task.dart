class Task {
  final String id;
  final String title;
  final int totalSeconds;
  final int remainingSeconds;
  final bool isCompleted;
  final bool isRunning;
  final String? category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? completedAt;

  const Task({
    required this.id,
    required this.title,
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.isCompleted,
    required this.isRunning,
    this.category,
    required this.createdAt,
    required this.updatedAt,
    this.completedAt,
  });

  Task copyWith({
    String? id,
    String? title,
    int? totalSeconds,
    int? remainingSeconds,
    bool? isCompleted,
    bool? isRunning,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? completedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isCompleted: isCompleted ?? this.isCompleted,
      isRunning: isRunning ?? this.isRunning,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  double get progress => totalSeconds == 0
      ? 0
      : (1 - (remainingSeconds.clamp(0, totalSeconds) / totalSeconds));
}
