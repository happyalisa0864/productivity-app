// AI assistance from cursor agent used to create this file
// owns task list in memory, loads/saves it to disk, runs the countdown timer 
// ui pages call this via taskNotifierProvider

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productivity_app/features/core/providers.dart';
import 'package:productivity_app/features/task_tracking/data/models/task_statistics_model.dart';
import 'package:productivity_app/features/task_tracking/domain/entities/task.dart';
import 'package:productivity_app/features/task_tracking/domain/repositories/task_repository.dart';
import 'package:uuid/uuid.dart';


class TaskNotifier extends StateNotifier<AsyncValue<List<Task>>> {
  final TaskRepository? _repo;
  final Ref? _ref;
  Timer? _timer;
  String? _runningTaskId;
  int _tickCountSinceLastPersist = 0;

  // used while the repository is loading, failed, or ready
  TaskNotifier.loading() : _repo = null, _ref = null, super(const AsyncLoading());
  TaskNotifier.error(Object e, StackTrace st) : _repo = null, _ref = null, super(AsyncError(e, st));
  TaskNotifier(this._repo, [this._ref]) : super(const AsyncLoading());

  // load saved tasks into memory w/ error handling
  Future<void> init() async {
    final repo = _repo!;
    try {
      final tasks = await repo.loadTasks();
      state = AsyncData(tasks);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  // save list to disk
  Future<void> _persist(List<Task> tasks) async {
    final repo = _repo;
    if (repo == null) return;
    await repo.saveTasks(tasks);
  }

  // append a new task and save to disk
  Future<void> addTask({required String title, required int minutes, String? category}) async {
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
      category: category,
      createdAt: now,
      updatedAt: now,
    );
    final updated = [...current, task];
    state = AsyncData(updated);
    await _persist(updated);
  }

  // delete a task and save to disk
  Future<void> deleteTask(String id) async {
    final updated = (state.value ?? <Task>[]).where((t) => t.id != id).toList();
    state = AsyncData(updated);
    await _persist(updated);
  }

  // delete all tasks and save to disk
  Future<void> deleteAllTasks() async {
    state = const AsyncData(<Task>[]);
    await _persist(<Task>[]);
  }

  Future<void> reorderTasks(int oldIndex, int newIndex) async {
    final list = [...(state.value ?? <Task>[])];
    
    // adjust newIndex if moving down the list
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    
    // perform the reordering
    final task = list.removeAt(oldIndex);
    list.insert(newIndex, task);
  
    // update all tasks with timestamp to preserve order
    final updatedList = list.map((t) => t.copyWith(updatedAt: DateTime.now())).toList();
    
    state = AsyncData(updatedList);
    await _persist(updatedList);
  }

  Future<void> toggleComplete(String id) async {
    final list = [...(state.value ?? <Task>[])];
    final idx = list.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    final t = list[idx];
    final completed = !t.isCompleted;
    final completedAt = completed ? DateTime.now() : null;
    list[idx] = t.copyWith(
      isCompleted: completed,
      isRunning: false,
      updatedAt: DateTime.now(),
      completedAt: completedAt,
    );
    state = AsyncData(list);
    await _persist(list);
    
    // START HERE
    // Save or remove statistics based on completion status
    if (_ref != null) {
      try {
        final statsDataSource = await _ref!.read(statisticsDataSourceProvider.future);
        if (completed && completedAt != null) {
          // Save statistics when task is completed
          await statsDataSource.saveStatistics(
            TaskStatisticsModel(
              taskId: id,
              completedAt: completedAt,
              totalSeconds: t.totalSeconds,
              remainingSeconds: t.remainingSeconds,
              category: t.category,
            ),
          );
        } else {
          // Remove statistics when task is uncompleted
          await statsDataSource.removeStatisticsForTask(id);
        }
      } catch (_) {}
    }
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
    // If task was paused (not running and has remaining time), continue from where it left off
    // Otherwise, reset to totalSeconds (covers: never started, or time limit was just edited)
    final wasPaused = !task.isRunning && task.remainingSeconds < task.totalSeconds;
    task = task.copyWith(
      isRunning: true,
      remainingSeconds: wasPaused ? task.remainingSeconds : task.totalSeconds,
      updatedAt: DateTime.now(),
    );
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

      // Allow timer to go negative (overtime) - don't clamp to 0
      final remaining = cur.remainingSeconds - 1;
      cur = cur.copyWith(
        remainingSeconds: remaining,
        updatedAt: DateTime.now(),
      );
      currentList[i] = cur;
      state = AsyncData(currentList);
      
      // Persist less frequently to avoid excessive writes
      _tickCountSinceLastPersist++;
      if (_tickCountSinceLastPersist >= 10) {
        _tickCountSinceLastPersist = 0;
        await _persist(currentList);
      }
    });
  }

  Future<void> pauseTimer({bool save = true}) async {
    _timer?.cancel();
    final runningId = _runningTaskId;
    _runningTaskId = null;
    if (runningId == null) return;

    // Wait a tiny bit to ensure any in-flight timer updates complete
    await Future.microtask(() {});
    
    final list = [...(state.value ?? <Task>[])];
    final idx = list.indexWhere((t) => t.id == runningId);
    if (idx == -1) return;
    final t = list[idx].copyWith(isRunning: false, updatedAt: DateTime.now());
    list[idx] = t;
    state = AsyncData(list);
    if (save) await _persist(list);
  }

  Future<void> updateTask({
    required String id,
    String? title,
    int? minutes,
    String? category,
  }) async {
    final list = [...(state.value ?? <Task>[])];
    final idx = list.indexWhere((t) => t.id == id);
    if (idx == -1) return;
    var t = list[idx];

    int? newTotalSeconds;
    int? newRemainingSeconds;
    if (minutes != null) {
      newTotalSeconds = minutes * 60;
      // If task is not running, reset to new total when time limit is edited
      // If task is running, clamp remaining to new total if needed
      if (!t.isRunning) {
        newRemainingSeconds = newTotalSeconds;
      } else {
        newRemainingSeconds = t.remainingSeconds.clamp(0, newTotalSeconds);
      }
    }
    // If minutes is null (only title/category changed), preserve remainingSeconds
    // This is especially important when the task is running

    t = t.copyWith(
      title: title ?? t.title,
      totalSeconds: newTotalSeconds ?? t.totalSeconds,
      remainingSeconds: newRemainingSeconds ?? t.remainingSeconds, // Preserves current time if minutes is null
      category: category ?? t.category,
      updatedAt: DateTime.now(),
    );

    list[idx] = t;
    state = AsyncData(list);
    await _persist(list);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
