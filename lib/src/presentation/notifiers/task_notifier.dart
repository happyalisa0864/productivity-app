import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productivity_app/src/domain/entities/task.dart';
import 'package:productivity_app/src/domain/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';

class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository? _repo;
  Timer? _timer;
  String? _runningTaskId;

  TaskNotifier.loading()
      : _repo = null,
        super(const AsyncLoading());

  TaskNotifier.error(Object e, StackTrace st)
      : _repo = null,
        super(AsyncError(e, st));

  TaskNotifier(this._repo) : super(const AsyncLoading());

  Future<void> init() async {
    final repo = _repo!;
    try {
      final tasks = await repo.loadTasks();
      state = AsyncData(tasks);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> _persist(List<Task> tasks) async {
    final repo = _repo;
    if (repo == null) return;
    await repo.saveTasks(tasks);
  }

  Future<void> addTask({required String title, required int minutes}) async {
    final current = state.value ?? <Task>[];
    final now = DateTime.now();
    final total = minutes * 60;
    final task = Task(
      id: const Uuid().v4(),
      title: title.trim(),
      totalSeconds: total,
      remainingSeconds: total,
      isCompleted: false,
      isRunning: false,
      createdAt: now,
      updatedAt: now,
    );
    final updated = [...current, task];
    state = AsyncData(updated);
    await _persist(updated);
  }

  Future<void> deleteTask(String id) async {
    // If deleting the running task, stop timer
    if (_runningTaskId == id) {
      await pauseTimer();
    }
    final updated = (state.value ?? <Task>[]).where((t) => t.id != id).toList();
    state = AsyncData(updated);
    await _persist(updated);
  }

  Future<void> toggleComplete(String id) async {
    final list = [...(state.value ?? <Task>[])];
    final idx = list.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final t = list[idx];
    final completed = !t.isCompleted;
    // If marking complete and it's running, pause
    if (completed && _runningTaskId == id) {
      await pauseTimer(save: false);
    }
    list[idx] = t.copyWith(
      isCompleted: completed,
      isRunning: false,
      updatedAt: DateTime.now(),
    );
    state = AsyncData(list);
    await _persist(list);
  }

  Future<void> startTimer(String id) async {
    // Stop any existing timer first
    if (_runningTaskId != null && _runningTaskId != id) {
      await pauseTimer(save: false);
    }

    final list = [...(state.value ?? <Task>[])];
    final idx = list.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    var task = list[idx];
    if (task.isCompleted) return; // do not start completed tasks

    _runningTaskId = id;
    task = task.copyWith(isRunning: true, updatedAt: DateTime.now());
    list[idx] = task;
    state = AsyncData(list);
    await _persist(list);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final currentList = [...(state.value ?? <Task>[])];
      final i = currentList.indexWhere((t) => t.id == id);
      if (i == -1) {
        timer.cancel();
        _runningTaskId = null;
        return;
      }
      var cur = currentList[i];
      if (!cur.isRunning) {
        timer.cancel();
        if (_runningTaskId == id) _runningTaskId = null;
        return;
      }

      final remaining = (cur.remainingSeconds - 1).clamp(0, cur.totalSeconds);
      final done = remaining == 0;
      cur = cur.copyWith(
        remainingSeconds: remaining,
        isRunning: !done,
        isCompleted: cur.isCompleted || done,
        updatedAt: DateTime.now(),
      );
      currentList[i] = cur;
      state = AsyncData(currentList);
      await _persist(currentList);

      if (done) {
        timer.cancel();
        if (_runningTaskId == id) _runningTaskId = null;
      }
    });
  }

  Future<void> pauseTimer({bool save = true}) async {
    _timer?.cancel();
    final runningId = _runningTaskId;
    _runningTaskId = null;
    if (runningId == null) return;

    final list = [...(state.value ?? <Task>[])];
    final idx = list.indexWhere((t) => t.id == runningId);
    if (idx == -1) return;
    final t = list[idx].copyWith(isRunning: false, updatedAt: DateTime.now());
    list[idx] = t;
    state = AsyncData(list);
    if (save) await _persist(list);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
