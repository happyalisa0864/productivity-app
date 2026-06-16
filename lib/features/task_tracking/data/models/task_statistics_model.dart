import 'dart:convert';

class TaskStatisticsModel {
  final String? taskId; // Nullable for backward compatibility
  final DateTime completedAt;
  final int totalSeconds;
  final int remainingSeconds;
  final String? category;

  const TaskStatisticsModel({
    this.taskId,
    required this.completedAt,
    required this.totalSeconds,
    required this.remainingSeconds,
    this.category,
  });

  Map<String, dynamic> toMap() => {
        'taskId': taskId,
        'completedAt': completedAt.toIso8601String(),
        'totalSeconds': totalSeconds,
        'remainingSeconds': remainingSeconds,
        'category': category,
      };

  factory TaskStatisticsModel.fromMap(Map<String, dynamic> map) =>
      TaskStatisticsModel(
        taskId: map['taskId'] as String?,
        completedAt: DateTime.parse(map['completedAt'] as String),
        totalSeconds: (map['totalSeconds'] as num).toInt(),
        remainingSeconds: (map['remainingSeconds'] as num).toInt(),
        category: map['category'] == null ? null : map['category'] as String,
      );

  String toJson() => jsonEncode(toMap());

  factory TaskStatisticsModel.fromJson(String json) {
    final map = jsonDecode(json) as Map<String, dynamic>;
    return TaskStatisticsModel.fromMap(map);
  }
}

