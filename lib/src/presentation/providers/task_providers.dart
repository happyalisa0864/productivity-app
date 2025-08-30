import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productivity_app/src/core/providers.dart';
import 'package:productivity_app/src/domain/entities/task.dart';
import 'package:productivity_app/src/presentation/notifiers/task_notifier.dart';

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
