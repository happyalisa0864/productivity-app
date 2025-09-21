import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productivity_app/features/task_tracking/domain/entities/task.dart';
import 'package:productivity_app/features/task_tracking/presentation/providers/task_providers.dart';

class TaskEditPage extends ConsumerStatefulWidget {
  final String taskId;
  const TaskEditPage({super.key, required this.taskId});

  @override
  ConsumerState<TaskEditPage> createState() => _TaskEditPageState();
}

class _TaskEditPageState extends ConsumerState<TaskEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  int? _selectedMinutes;
  String? _selectedCategory;

  static const List<int> _minuteOptions = [5, 10, 15, 20, 25, 30, 45, 60, 90];
  static const List<String> _categoryOptions = [
    'Work',
    'Study',
    'Personal',
    'Health',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _initFromTask(Task t) {
    _titleCtrl.text = t.title;
    _selectedMinutes ??= (t.totalSeconds / 60).round();
    _selectedCategory ??= t.category;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(taskNotifierProvider.notifier);
    await notifier.updateTask(
      id: widget.taskId,
      title: _titleCtrl.text.trim(),
      minutes: _selectedMinutes,
      category: _selectedCategory,
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete() async {
    final notifier = ref.read(taskNotifierProvider.notifier);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await notifier.deleteTask(widget.taskId);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskByIdProvider(widget.taskId));

    return taskAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('TaskEdit')),
        body: Center(child: Text('Error: $e')),
      ),
      data: (task) {
        if (task == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('TaskEdit')),
            body: const Center(child: Text('Task not found')),
          );
        }
        _initFromTask(task);
        return Scaffold(
          backgroundColor: const Color(0xFFFFE6EA), // light pink similar to mockup
          appBar: AppBar(
            title: const Text('TaskEdit'),
            actions: [
              IconButton(
                tooltip: 'Save',
                icon: const Icon(Icons.save_outlined),
                onPressed: _save,
              ),
            ],
          ),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(12),
                children: [
                  _LabeledSection(
                    label: 'Name of Task:',
                    child: TextFormField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Enter a task name' : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LabeledSection(
                    label: 'Time Limit:',
                    child: DropdownButtonFormField<int>(
                      value: _selectedMinutes,
                      items: _minuteOptions
                          .map((m) => DropdownMenuItem<int>(
                                value: m,
                                child: Text('$m minutes'),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedMinutes = v),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'add items...'
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _LabeledSection(
                    label: 'Category:',
                    child: DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      items: _categoryOptions
                          .map((c) => DropdownMenuItem<String>(
                                value: c,
                                child: Text(c),
                              ))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v),
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                        hintText: 'add items...'
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: _confirmDelete,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF5C8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Delete Task'),
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LabeledSection extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledSection({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: Colors.black.withOpacity(0.1),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
