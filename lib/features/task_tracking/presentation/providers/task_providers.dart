import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productivity_app/features/core/providers.dart';
import 'package:productivity_app/features/task_tracking/domain/entities/task.dart';
import 'package:productivity_app/features/task_tracking/presentation/notifiers/task_notifier.dart';

final taskNotifierProvider =
    StateNotifierProvider<TaskNotifier, AsyncValue<List<Task>>>((ref) {
  final repoAsync = ref.watch(repositoryProvider);
  return repoAsync.when(
    data: (repo) {
      final notifier = TaskNotifier(repo);
      // Fire-and-forget initialization
      // ignore: discarded_futures
      notifier.init();
      return notifier;
    },
    loading: () => TaskNotifier.loading(),
    error: (e, st) => TaskNotifier.error(e, st),
  );
});

// Get a single task by id from the list state.
final taskByIdProvider = Provider.family<AsyncValue<Task?>, String>((ref, id) {
  final listAsync = ref.watch(taskNotifierProvider);
  return listAsync.whenData((list) {
    for (final t in list) {
      if (t.id == id) return t;
    }
    return null;
  });
});
