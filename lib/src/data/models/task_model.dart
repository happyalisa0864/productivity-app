import 'dart:convert';

import 'package:productivity_app/src/domain/entities/task.dart';

class TaskModel {
  final String id;
  final String title;
  final int totalSeconds;
  final int remainingSeconds;
  final bool isCompleted;
  final bool isRunning;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskModel({
    required this.id,
    required this.title,
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.isCompleted,
    required this.isRunning,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TaskModel.fromEntity(Task e) => TaskModel(
        id: e.id,
        title: e.title,
        totalSeconds: e.totalSeconds,
        remainingSeconds: e.remainingSeconds,
        isCompleted: e.isCompleted,
        isRunning: e.isRunning,
        createdAt: e.createdAt,
        updatedAt: e.updatedAt,
      );

  Task toEntity() => Task(
        id: id,
        title: title,
        totalSeconds: totalSeconds,
        remainingSeconds: remainingSeconds,
        isCompleted: isCompleted,
        isRunning: isRunning,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'totalSeconds': totalSeconds,
        'remainingSeconds': remainingSeconds,
        'isCompleted': isCompleted,
        'isRunning': isRunning,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory TaskModel.fromMap(Map<String, dynamic> map) => TaskModel(
        id: map['id'] as String,
        title: map['title'] as String,
        totalSeconds: (map['totalSeconds'] as num).toInt(),
        remainingSeconds: (map['remainingSeconds'] as num).toInt(),
        isCompleted: map['isCompleted'] as bool,
        isRunning: map['isRunning'] as bool,
        createdAt: DateTime.parse(map['createdAt'] as String),
        updatedAt: DateTime.parse(map['updatedAt'] as String),
      );

  String toJson() => jsonEncode(toMap());
  factory TaskModel.fromJson(String source) => TaskModel.fromMap(jsonDecode(source) as Map<String, dynamic>);
}
