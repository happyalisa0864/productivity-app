import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:productivity_app/features/task_tracking/presentation/pages/tasks_page.dart';
import 'package:productivity_app/features/settings/presentation/pages/settings_page.dart';
import 'package:productivity_app/features/task_tracking/presentation/pages/timer_page.dart';
import 'package:productivity_app/features/task_tracking/presentation/providers/task_providers.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 1; // Start on To-Do List (index 1)

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(taskNotifierProvider);
    
    // Find the currently running task for timer tab
    String? runningTaskId;
    tasksAsync.whenData((tasks) {
      final running = tasks.where((t) => t.isRunning).firstOrNull;
      runningTaskId = running?.id;
    });

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // Timer tab (index 0)
          runningTaskId != null
              ? TimerPage(taskId: runningTaskId!)
              : _NoActiveTimerView(),
          // To-Do List tab (index 1)
          const TasksPage(),
          // Settings tab (index 2)
          const SettingsPage(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: const Color(0xFF4E4A47).withOpacity(0.1),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() => _currentIndex = index);
          },
          backgroundColor: const Color(0xFFFAF7F5),
          selectedItemColor: const Color(0xFFF5B8B1),
          unselectedItemColor: const Color(0xFF4E4A47).withOpacity(0.5),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.timer),
              label: 'Timer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist),
              label: 'To-Do List',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}

class _NoActiveTimerView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timer_outlined,
              size: 80,
              color: const Color(0xFF4E4A47).withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No active timer',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: const Color(0xFF4E4A47),
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a task from the To-Do List',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF4E4A47).withOpacity(0.6),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

