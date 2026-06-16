// Edit screen for an existing task's name, time limit, and category.
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
  int _selectedHours = 0;
  int _selectedMinutes = 0;
  String? _selectedCategory;
  bool _isInitialized = false;
  String? _lastTaskId;

  static const _categoryOptions = ['Work', 'Study', 'Personal', 'Health', 'Other'];
  static const _backgroundColor = Color(0xFFFAF7F5);
  static const _textColor = Color(0xFF4E4A47);
  static const _mainPink = Color(0xFFF4C2C2);
  static const _lighterPink = Color(0xFFF9E0E0);

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
    if (!mounted) return;
    if (_lastTaskId != t.id || !_isInitialized) {
      _titleCtrl.text = t.title;
      final totalMinutes = (t.totalSeconds / 60).round();
      _selectedHours = totalMinutes ~/ 60;
      _selectedMinutes = totalMinutes % 60;
      _selectedCategory = t.category ?? _categoryOptions.first;
      _lastTaskId = t.id;
      _isInitialized = true;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'work': return Icons.work;
      case 'study': return Icons.school;
      case 'personal': return Icons.person;
      case 'health': return Icons.favorite;
      default: return Icons.category;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final notifier = ref.read(taskNotifierProvider.notifier);
    final totalMinutes = (_selectedHours * 60) + _selectedMinutes;
    final currentTask = ref.read(taskByIdProvider(widget.taskId)).value;
    final currentTotalMinutes = currentTask != null ? (currentTask.totalSeconds / 60).round() : null;
    final minutesToUpdate = (currentTotalMinutes != null && totalMinutes != currentTotalMinutes) ? totalMinutes : null;
    await notifier.updateTask(id: widget.taskId, title: _titleCtrl.text.trim(), minutes: minutesToUpdate, category: _selectedCategory);
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
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton.tonal(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed == true) {
      await notifier.deleteTask(widget.taskId);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  PreferredSizeWidget _appBar({VoidCallback? onBack}) {
    return AppBar(
      backgroundColor: _backgroundColor,
      elevation: 0,
      leading: IconButton(icon: Icon(Icons.arrow_back, color: _textColor), onPressed: onBack ?? () => Navigator.of(context).pop()),
      title: Text('Edit Task', style: TextStyle(color: _textColor, fontWeight: FontWeight.w600)),
      centerTitle: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final taskAsync = ref.watch(taskByIdProvider(widget.taskId));

    return taskAsync.when(
      loading: () => Scaffold(backgroundColor: _backgroundColor, appBar: _appBar(), body: const SizedBox.shrink()),
      error: (e, _) => Scaffold(backgroundColor: _backgroundColor, appBar: _appBar(), body: Center(child: Text('Error: $e'))),
      data: (task) {
        if (task == null) {
          return Scaffold(backgroundColor: _backgroundColor, appBar: _appBar(), body: const Center(child: Text('Task not found')));
        }
        _initFromTask(task);
        return Scaffold(
          backgroundColor: _backgroundColor,
          appBar: _appBar(),
          body: SafeArea(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  const _SectionLabel('TASK NAME'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(color: _lighterPink, borderRadius: BorderRadius.circular(12)),
                    child: TextFormField(
                      controller: _titleCtrl,
                      style: const TextStyle(color: _textColor, fontSize: 16),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        filled: true, fillColor: _lighterPink,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a task name' : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _SectionLabel('TIME LIMIT'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(color: _lighterPink, borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: _TimePicker(value: _selectedHours, maxValue: 23, suffix: 'HOURS', onChanged: (v) => setState(() => _selectedHours = v))),
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Text(':', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: _textColor, height: 1.0)),
                        ),
                        Expanded(child: _TimePicker(value: _selectedMinutes, maxValue: 59, suffix: 'MINS', onChanged: (v) => setState(() => _selectedMinutes = v))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _SectionLabel('CATEGORY'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Select Category'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: _categoryOptions.map((category) => ListTile(
                              leading: Icon(_getCategoryIcon(category)),
                              title: Text(category),
                              selected: _selectedCategory == category,
                              onTap: () { setState(() => _selectedCategory = category); Navigator.of(context).pop(); },
                            )).toList(),
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(color: _lighterPink, borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                        Icon(_getCategoryIcon(_selectedCategory ?? 'Work'), color: _textColor, size: 24),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_selectedCategory ?? 'Work', style: const TextStyle(color: _textColor, fontSize: 16))),
                        const Icon(Icons.arrow_forward_ios, size: 16, color: _textColor),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(backgroundColor: _mainPink, foregroundColor: _textColor, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                      child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _confirmDelete,
                      style: ElevatedButton.styleFrom(backgroundColor: _lighterPink, foregroundColor: const Color(0xFFFF5C8A), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                      child: const Text('Delete Task', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(label, style: const TextStyle(color: _TaskEditPageState._mainPink, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5));
  }
}

class _TimePicker extends StatefulWidget {
  final int value;
  final int maxValue;
  final String suffix;
  final ValueChanged<int> onChanged;
  const _TimePicker({required this.value, required this.maxValue, required this.suffix, required this.onChanged});

  @override
  State<_TimePicker> createState() => _TimePickerState();
}

class _TimePickerState extends State<_TimePicker> {
  late FixedExtentScrollController _controller;
  int _currentValue = 0;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
    _controller = FixedExtentScrollController(initialItem: widget.value);
  }

  @override
  void didUpdateWidget(_TimePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _currentValue != widget.value) {
      _currentValue = widget.value;
      _controller.jumpToItem(widget.value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const textColor = Color(0xFF4E4A47);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          height: 30,
          child: Center(child: Text(widget.suffix, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor.withValues(alpha: 0.7), letterSpacing: 0.5))),
        ),
        SizedBox(
          height: 100,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 35,
            physics: const FixedExtentScrollPhysics(),
            controller: _controller,
            onSelectedItemChanged: (index) {
              if (index != _currentValue) { _currentValue = index; widget.onChanged(index); }
            },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                if (index > widget.maxValue) return null;
                final isSelected = index == _currentValue;
                return Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: TextStyle(fontSize: isSelected ? 24 : 18, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: isSelected ? textColor : textColor.withValues(alpha: 0.5), height: 1.0),
                  ),
                );
              },
              childCount: widget.maxValue + 1,
            ),
          ),
        ),
      ],
    );
  }
}
