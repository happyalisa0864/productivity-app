import 'dart:convert';

import 'package:productivity_app/features/task_tracking/domain/entities/task.dart';

class TaskModel {
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

  const TaskModel({
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

  factory TaskModel.fromEntity(Task e) => TaskModel(
        id: e.id,
        title: e.title,
        totalSeconds: e.totalSeconds,
        remainingSeconds: e.remainingSeconds,
        isCompleted: e.isCompleted,
        isRunning: e.isRunning,
        category: e.category,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
        completedAt: e.completedAt,
      );

  Task toEntity() => Task(
        id: id,
        title: title,
        totalSeconds: totalSeconds,
        remainingSeconds: remainingSeconds,
        isCompleted: isCompleted,
        isRunning: isRunning,
        category: category,
        createdAt: createdAt,
        updatedAt: updatedAt,
        completedAt: completedAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'totalSeconds': totalSeconds,
        'remainingSeconds': remainingSeconds,
        'isCompleted': isCompleted,
        'isRunning': isRunning,
        'category': category,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
      };

  factory TaskModel.fromMap(Map<String, dynamic> map) => TaskModel(
        id: map['id'] as String,
        title: map['title'] as String,
        totalSeconds: (map['totalSeconds'] as num).toInt(),
        remainingSeconds: (map['remainingSeconds'] as num).toInt(),
        isCompleted: map['isCompleted'] as bool,
        isRunning: map['isRunning'] as bool,
        category: map['category'] == null ? null : map['category'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
        completedAt: map['completedAt'] == null
            ? null
            : DateTime.parse(map['completedAt'] as String),
      );

  String toJson() => jsonEncode(toMap());
  factory TaskModel.fromJson(String source) => TaskModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
