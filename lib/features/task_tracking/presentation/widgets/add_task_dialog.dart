import 'package:flutter/material.dart';

class AddTaskResult {
  final String title;
  final int minutes;
  final String? category;
  const AddTaskResult(this.title, this.minutes, this.category);
}

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  int _selectedMinutes = 25;
  static const List<int> _minuteOptions = [5, 10, 15, 20, 25, 30, 45, 60, 90];
  String? _selectedCategory;
  static const List<String> _categoryOptions = [
    'Work',
    'Study',
    'Personal',
    'Health',
    'Other',
  ];

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final title = _titleCtrl.text.trim();
    final minutes = _selectedMinutes;
    Navigator.of(context).pop(AddTaskResult(title, minutes, _selectedCategory));
  }

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        backgroundColor: const Color(0xFFFFE6EA),
        appBar: AppBar(
          title: const Text('Add Task'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              tooltip: 'Save',
              icon: const Icon(Icons.check),
              onPressed: _submit,
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
                    onChanged: (v) => setState(() => _selectedMinutes = v ?? 25),
                    decoration: const InputDecoration(
                      isDense: true,
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'add items...',
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
                      hintText: 'add items...',
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8BC34A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Add Task'),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
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
