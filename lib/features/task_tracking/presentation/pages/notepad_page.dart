// simple notepad for free-form notes with a title and body; content saved automatically as the user types
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productivity_app/features/core/providers.dart';

class NotepadPage extends ConsumerStatefulWidget {
  const NotepadPage({super.key});

  @override
  ConsumerState<NotepadPage> createState() => _NotepadPageState();
}

class _NotepadPageState extends ConsumerState<NotepadPage> {
  // to save changes in the note
  static const String _titleKey = 'notepad_title';
  static const String _contentKey = 'notepad_content';

  // setting notepad color palette
  static const Color _background = Color(0xFFFAF7F5);
  static const Color _textColor = Color(0xFF4E4A47);
  static const Color _mutedText = Color(0xFF8B8680);
  static const Color _rosePink = Color(0xFFF5B8B1);
  static const Color _lightRose = Color(0xFFFADCD9);

  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  Timer? _saveTimer;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadNotepadContent());
  }

  // AI assistance from cursor agent used for autosave function
  @override
  void dispose() {
    _saveTimer?.cancel();
    _saveNotepadContent();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  // loading previously saved title and body from device storage
  Future<void> _loadNotepadContent() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      if (mounted) {
        _titleController.text = prefs.getString(_titleKey) ?? '';
        _bodyController.text = prefs.getString(_contentKey) ?? '';
      }
    } catch (_) {}
  }

  // autosaves current title and body
  Future<void> _saveNotepadContent() async {
    try {
      final prefs = await ref.read(sharedPreferencesProvider.future);
      await prefs.setString(_titleKey, _titleController.text);
      await prefs.setString(_contentKey, _bodyController.text);
    } catch (_) {}
  }

  // so we don't save changes on every keystroke
  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(const Duration(milliseconds: 500), _saveNotepadContent);
  }

  // formats today's date for display under the note title
  String _formatDate(DateTime date) {
    const months = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // putting everything together to build the notepad page!
  @override
  Widget build(BuildContext context) {
    final today = _formatDate(DateTime.now());
    const titleStyle = TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: _textColor, height: 1.0);

    return Scaffold(
      backgroundColor: _background,
      
      // app bar for notepad page
      appBar: AppBar(
        backgroundColor: _background,
        foregroundColor: _textColor,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).pop()),
        title: const Text('Notepad', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18, color: _textColor)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _titleController,
                  onChanged: (_) => _scheduleSave(),
                  style: titleStyle,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Note Title',
                    hintStyle: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: _mutedText, height: 1.0),
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                    isCollapsed: true,
                  ),
                  maxLines: 1,
                ),
                const SizedBox(height: 6),
                Row(children: [
                  Icon(Icons.calendar_today_outlined, size: 16, color: _rosePink.withValues(alpha: 0.85)),
                  const SizedBox(width: 8),
                  Text(today, style: const TextStyle(fontSize: 14, color: _mutedText)),
                ]),
                const SizedBox(height: 24),
                Expanded(
                  child: TextField(
                    controller: _bodyController,
                    onChanged: (_) => _scheduleSave(),
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(fontSize: 16, color: _textColor, height: 1.6),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Start writing your thoughts here...',
                      hintStyle: TextStyle(fontSize: 16, color: _mutedText, height: 1.6),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // decorative sparkle in the top-right corner for aestheticness <3
          const Positioned(
            top: 8, right: 20,
            child: IgnorePointer(child: Icon(Icons.auto_awesome, size: 52, color: _lightRose)),
          ),
        ],
      ),
    );
  }
}
