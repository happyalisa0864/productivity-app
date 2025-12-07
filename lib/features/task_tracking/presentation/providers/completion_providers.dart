import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskCompletionEvent {
  final String taskId;
  final int timeSpent;
  
  TaskCompletionEvent({
    required this.taskId,
    required this.timeSpent,
  });
}

final taskCompletionProvider = StateNotifierProvider<TaskCompletionNotifier, TaskCompletionEvent?>((ref) {
  return TaskCompletionNotifier();
});

class TaskCompletionNotifier extends StateNotifier<TaskCompletionEvent?> {
  TaskCompletionNotifier() : super(null);
  
  void notifyCompletion(String taskId, int timeSpent) {
    state = TaskCompletionEvent(taskId: taskId, timeSpent: timeSpent);
  }
  
  void clear() {
    state = null;
  }
}

