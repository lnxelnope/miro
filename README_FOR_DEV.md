# 👋 Welcome to Miro Project

## 🚀 For Junior Developers / AI Agents

This project is set up and ready for implementation.
Please follow the implementation plans in the `_project_manager` folder sequentially.

### 📂 Work Plans (Follow this order)

1.  **Phase 1: Foundation** -> `_project_manager/phase1_foundation.md`
    *   *Task:* Setup Database (Isar), Models, and Backup Service.
2.  **Phase 2: Scanner** -> `_project_manager/phase2_scanner.md`
    *   *Task:* Implement ML Kit to filter images and extract QR/Text.
3.  **Phase 3: The Brain** -> `_project_manager/phase3_brain_task.md`
    *   *Task:* Implement Gemma 3 (Local), Google Calendar Sync, and Finance API.
4.  **Phase 4: UI** -> `_project_manager/phase4_ui.md`
    *   *Task:* Build the Timeline and Chat Interface.

### 🛠️ Environment Setup
- Run `flutter pub get` to install dependencies.
- Run `flutter pub run build_runner build` to generate code (for Isar/Riverpod).
- Ensure you have an Android device/emulator connected.

### ⚠️ Important Notes
- **Do not change the architecture.** Use Riverpod for state and Isar for DB.
- **Offline First:** Always prioritize local processing before calling APIs.
