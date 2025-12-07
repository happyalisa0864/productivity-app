import 'package:flutter/material.dart';

class AddTaskResult {
  final String title;
  final int minutes;
  final String? description;
  const AddTaskResult(this.title, this.minutes, this.description);
}

class AddTaskDialog extends StatefulWidget {
  const AddTaskDialog({super.key});

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descriptionCtrl = TextEditingController();
  int _selectedHours = 0;
  int _selectedMinutes = 20;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final title = _titleCtrl.text.trim();
    final totalMinutes = (_selectedHours * 60) + _selectedMinutes;
    Navigator.of(context).pop(
      AddTaskResult(title, totalMinutes, _descriptionCtrl.text.trim().isEmpty ? null : _descriptionCtrl.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = const Color(0xFFFAF7F5);
    final inputColor = Colors.white; // Match card color
    final textColor = const Color(0xFF4E4A47);
    final saveButtonColor = const Color(0xFFF5B8B1); // Match app accent color

    return Material(
      color: Colors.transparent,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  'New To-Do',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              // Form content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 0,
                      bottom: 20, // Extra bottom padding
                    ),
                    children: [
                      // Task input
                      _InputField(
                        label: 'Task',
                        controller: _titleCtrl,
                        hintText: 'e.g., Read for 30 minutes',
                        backgroundColor: inputColor,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Enter a task name' : null,
                      ),
                      const SizedBox(height: 20),
                      // Description input
                      _InputField(
                        label: 'Description (optional)',
                        controller: _descriptionCtrl,
                        hintText: 'Add more details...',
                        backgroundColor: inputColor,
                        maxLines: 4,
                      ),
                      const SizedBox(height: 24),
                      // Time limit section
                      Text(
                        'Set Time Limit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Time picker
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                        decoration: BoxDecoration(
                          color: inputColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Hours picker
                            Expanded(
                              child: _TimePicker(
                                value: _selectedHours,
                                maxValue: 23,
                                suffix: 'h',
                                onChanged: (value) {
                                  setState(() => _selectedHours = value);
                                },
                              ),
                            ),
                            // Colon separator - aligned with center of scrollable numbers
                            Padding(
                              padding: const EdgeInsets.only(top: 30, bottom: 0),
                              child: Text(
                                ':',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                  height: 1.0,
                                ),
                              ),
                            ),
                            // Minutes picker
                            Expanded(
                              child: _TimePicker(
                                value: _selectedMinutes,
                                maxValue: 59,
                                suffix: 'm',
                                onChanged: (value) {
                                  setState(() => _selectedMinutes = value);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40), // Extra padding to prevent cutoff
                    ],
                  ),
                ),
              ),
              // Action buttons
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Cancel button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: textColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(
                            color: textColor.withValues(alpha: 0.1),
                            width: 1,
                          ),
                        ),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Save button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: saveButtonColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final Color backgroundColor;
  final int maxLines;
  final String? Function(String?)? validator;

  const _InputField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.backgroundColor,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = const Color(0xFF4E4A47);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: textColor.withValues(alpha: 0.5),
            ),
            filled: true,
            fillColor: backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _TimePicker extends StatefulWidget {
  final int value;
  final int maxValue;
  final String suffix;
  final ValueChanged<int> onChanged;

  const _TimePicker({
    required this.value,
    required this.maxValue,
    required this.suffix,
    required this.onChanged,
  });

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
    final textColor = const Color(0xFF4E4A47);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Suffix label at top
        Container(
          height: 30,
          alignment: Alignment.center,
          child: Text(
            widget.suffix,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: textColor.withValues(alpha: 0.7),
            ),
          ),
        ),
        // Scrollable picker - numbers align with colon
        SizedBox(
          height: 100,
          child: ListWheelScrollView.useDelegate(
            itemExtent: 35,
            physics: const FixedExtentScrollPhysics(),
            controller: _controller,
            onSelectedItemChanged: (index) {
              if (index != _currentValue) {
                _currentValue = index;
                widget.onChanged(index);
              }
            },
            childDelegate: ListWheelChildBuilderDelegate(
              builder: (context, index) {
                if (index > widget.maxValue) return null;
                final isSelected = index == _currentValue;
                return Center(
                  child: Text(
                    index.toString().padLeft(2, '0'),
                    style: TextStyle(
                      fontSize: isSelected ? 24 : 18,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? textColor : textColor.withValues(alpha: 0.5),
                      height: 1.0,
                    ),
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
