# Productivity App - Development Plan

## Project Overview
A Flutter-based productivity app with task tracking and timer functionality, featuring a clean, pastel design inspired by modern productivity tools.

## Current Features

### ✅ Completed Features

#### 1. **Welcome/Onboarding Flow**
- Welcome screen with logo and "Get Started" button
- Onboarding completion tracking using SharedPreferences
- Automatic navigation to tasks page after onboarding

#### 2. **Task Management**
- **Tasks List Page** ("Today's Tasks")
  - Display all tasks in a clean card-based layout
  - Task tiles with:
    - Checkbox for completion status
    - Task title and time badge
    - Play/pause button for timer control
    - Edit functionality
  - Empty state message
  - Floating action button to add new tasks

- **Add Task Dialog**
  - Bottom sheet modal with:
    - Task name input field
    - Optional description field
    - Scrollable time picker (hours and minutes)
    - Cancel and Save buttons
  - Matches app color scheme

- **Task Edit Page**
  - Edit task name, time limit, and category
  - Delete task functionality
  - Form validation

#### 3. **Timer Functionality**
- **Main Timer Screen**
  - Large circular progress timer (300px radius)
  - Rounded progress bar ends
  - Real-time countdown display
  - Play/pause controls
  - Reset button
  - Current task card
  - Auto-pause when leaving the screen
  - Timer updates every second

- **Timer Integration**
  - Start timer from task list
  - Navigate to timer screen when starting
  - Timer persists across navigation
  - Automatic pause on screen exit

#### 4. **Settings Page**
- General settings (Sound Notifications, Vibration)
- Appearance settings (Theme, Font Style)
- Timer settings (Default durations)
- Support & Feedback section
- Matches app design system

#### 5. **Architecture & State Management**
- Clean architecture with feature-based structure:
  - `data/` - Data sources, models, repositories
  - `domain/` - Entities, repository interfaces, use cases
  - `presentation/` - Pages, widgets, providers, notifiers
- Riverpod for state management
- SharedPreferences for local persistence
- Optimized data persistence (throttled writes during timer)

#### 6. **Design System**
- Pastel color palette:
  - Primary: `#F5B8B1` (Soft Coral)
  - Background: `#FAF7F5` (Warm Off-White)
  - Text: `#4E4A47` (Dark Gray)
  - Cards: White
- Consistent typography and spacing
- Rounded corners and soft shadows

## Technical Stack

- **Framework**: Flutter 3.8.1+
- **State Management**: flutter_riverpod 2.5.1
- **Local Storage**: shared_preferences 2.2.3
- **UUID Generation**: uuid 4.3.3
- **Architecture**: Clean Architecture with feature modules

## Project Structure

```
lib/
├── features/
│   ├── core/
│   │   ├── providers.dart (SharedPreferences provider)
│   │   └── utils/
│   │       └── time_format.dart
│   ├── task_tracking/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── notifiers/
│   │       ├── pages/
│   │       ├── providers/
│   │       └── widgets/
│   ├── welcome/
│   │   └── (similar structure)
│   └── settings/
│       └── presentation/
│           └── pages/
└── main.dart
```

## Future Enhancements

### High Priority
- [ ] Task completion summary screen (shown when timer completes)
- [ ] Bottom navigation bar (Timer, To-Do List, Settings)
- [ ] Task categories with color coding
- [ ] Statistics/analytics view
- [ ] Sound notifications when timer completes
- [ ] Break timer functionality

### Medium Priority
- [ ] Task search and filtering
- [ ] Task sorting options
- [ ] Dark mode support
- [ ] Task templates
- [ ] Export tasks/data
- [ ] Task history/archive

### Low Priority
- [ ] Cloud sync
- [ ] Multi-device support
- [ ] Widget support
- [ ] Apple Watch integration
- [ ] Siri shortcuts
- [ ] Task sharing

## Known Issues / Technical Debt

- [ ] Consider adding unit tests for business logic
- [ ] Add integration tests for critical flows
- [ ] Optimize timer persistence further if needed
- [ ] Consider adding error boundaries
- [ ] Add analytics/error tracking

## Design References

The app design is based on the provided Stitch design files:
- Main timer screen
- To-do list management
- Settings screen
- Task completion summary

## Development Notes

- Timer persistence is throttled (saves every 10 seconds during active timer)
- SharedPreferences is centralized through a single provider
- Navigation uses standard MaterialPageRoute
- All screens support proper back navigation
- Timer auto-pauses when navigating away from timer screen

