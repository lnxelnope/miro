# Step 14: Task Lists & Notes

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 2-3 ชั่วโมง
> **ความยาก:** ปานกลาง
> **ต้องทำก่อน:** Step 13 (Calendar View)

---

## 🎯 เป้าหมาย

- สร้าง Lists สำหรับจัดกลุ่ม Tasks
- สร้าง Quick Notes (จดโน้ตสั้นๆ)
- Drag & Drop reorder items
- Share list ได้

---

## สิ่งที่ต้องทำ

1. สร้าง TaskList และ Note Models
2. รัน Build Runner
3. สร้าง Lists Provider
4. สร้าง Lists Tab UI
5. สร้าง List Detail Screen
6. สร้าง Quick Notes Section
7. ทดสอบ

---

## ขั้นตอนที่ 1: สร้าง TaskList Model

**สร้างไฟล์:** `lib/features/tasks/models/task_list.dart`

```dart
import 'package:isar/isar.dart';

part 'task_list.g.dart';

@collection
class TaskList {
  Id id = Isar.autoIncrement;

  late String name;
  String? description;
  String? emoji;  // เช่น 🛒, 📚, 🏠
  
  @enumerated
  ListColor color = ListColor.blue;

  bool isPinned = false;
  bool isArchived = false;

  late DateTime createdAt;
  DateTime? updatedAt;

  // จำนวน items (computed, ไม่เก็บใน DB)
  @ignore
  int itemCount = 0;

  @ignore
  int completedCount = 0;
}

enum ListColor {
  blue,
  green,
  orange,
  red,
  purple,
  pink,
  teal,
  grey,
}

extension ListColorExtension on ListColor {
  int get colorValue {
    switch (this) {
      case ListColor.blue: return 0xFF2196F3;
      case ListColor.green: return 0xFF4CAF50;
      case ListColor.orange: return 0xFFFF9800;
      case ListColor.red: return 0xFFF44336;
      case ListColor.purple: return 0xFF9C27B0;
      case ListColor.pink: return 0xFFE91E63;
      case ListColor.teal: return 0xFF009688;
      case ListColor.grey: return 0xFF607D8B;
    }
  }
}
```

---

## ขั้นตอนที่ 2: สร้าง ListItem Model

**สร้างไฟล์:** `lib/features/tasks/models/list_item.dart`

```dart
import 'package:isar/isar.dart';

part 'list_item.g.dart';

@collection
class ListItem {
  Id id = Isar.autoIncrement;

  late int listId;  // อ้างอิง TaskList
  late String content;
  
  bool isCompleted = false;
  int sortOrder = 0;  // สำหรับ reorder

  DateTime? completedAt;
  late DateTime createdAt;
}
```

---

## ขั้นตอนที่ 3: สร้าง QuickNote Model

**สร้างไฟล์:** `lib/features/tasks/models/quick_note.dart`

```dart
import 'package:isar/isar.dart';

part 'quick_note.g.dart';

@collection
class QuickNote {
  Id id = Isar.autoIncrement;

  late String content;
  bool isPinned = false;
  
  @enumerated
  NoteColor color = NoteColor.yellow;

  late DateTime createdAt;
  DateTime? updatedAt;
}

enum NoteColor {
  yellow,
  green,
  blue,
  pink,
  purple,
  orange,
}

extension NoteColorExtension on NoteColor {
  int get colorValue {
    switch (this) {
      case NoteColor.yellow: return 0xFFFFF9C4;
      case NoteColor.green: return 0xFFC8E6C9;
      case NoteColor.blue: return 0xFFBBDEFB;
      case NoteColor.pink: return 0xFFF8BBD0;
      case NoteColor.purple: return 0xFFE1BEE7;
      case NoteColor.orange: return 0xFFFFE0B2;
    }
  }
}
```

---

## ขั้นตอนที่ 4: อัปเดต Database Service

**แก้ไขไฟล์:** `lib/core/database/database_service.dart`

**เพิ่ม imports:**

```dart
import '../../features/tasks/models/task_list.dart';
import '../../features/tasks/models/list_item.dart';
import '../../features/tasks/models/quick_note.dart';
```

**เพิ่มใน schemas list:**

```dart
static Future<void> initialize() async {
  final dir = await getApplicationDocumentsDirectory();
  
  _isar = await Isar.open(
    [
      // ... schemas ที่มีอยู่ ...
      TaskListSchema,    // เพิ่ม
      ListItemSchema,    // เพิ่ม
      QuickNoteSchema,   // เพิ่ม
    ],
    directory: dir.path,
  );
}
```

**เพิ่ม getters:**

```dart
static IsarCollection<TaskList> get taskLists => _isar!.taskLists;
static IsarCollection<ListItem> get listItems => _isar!.listItems;
static IsarCollection<QuickNote> get quickNotes => _isar!.quickNotes;
```

---

## ขั้นตอนที่ 5: รัน Build Runner

```bash
dart run build_runner build --delete-conflicting-outputs
```

**ตรวจสอบว่าไม่มี error**

---

## ขั้นตอนที่ 6: สร้าง Lists Provider

**สร้างไฟล์:** `lib/features/tasks/providers/lists_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../models/task_list.dart';
import '../models/list_item.dart';
import '../models/quick_note.dart';

// ============================================
// TASK LISTS PROVIDERS
// ============================================

/// Provider สำหรับ TaskLists ทั้งหมด
final taskListsProvider = FutureProvider<List<TaskList>>((ref) async {
  final lists = await DatabaseService.taskLists
      .filter()
      .isArchivedEqualTo(false)
      .sortByIsPinnedDesc()
      .thenByCreatedAtDesc()
      .findAll();

  // Load item counts
  for (final list in lists) {
    final items = await DatabaseService.listItems
        .filter()
        .listIdEqualTo(list.id)
        .findAll();
    list.itemCount = items.length;
    list.completedCount = items.where((i) => i.isCompleted).length;
  }

  return lists;
});

/// Provider สำหรับ items ใน list
final listItemsProvider = FutureProvider.family<List<ListItem>, int>((ref, listId) async {
  return await DatabaseService.listItems
      .filter()
      .listIdEqualTo(listId)
      .sortBySortOrder()
      .findAll();
});

// ============================================
// QUICK NOTES PROVIDERS
// ============================================

/// Provider สำหรับ Quick Notes ทั้งหมด
final quickNotesProvider = FutureProvider<List<QuickNote>>((ref) async {
  return await DatabaseService.quickNotes
      .filter()
      .sortByIsPinnedDesc()
      .thenByCreatedAtDesc()
      .findAll();
});

// ============================================
// TASK LISTS NOTIFIER
// ============================================

class TaskListsNotifier extends StateNotifier<AsyncValue<List<TaskList>>> {
  final Ref ref;

  TaskListsNotifier(this.ref) : super(const AsyncValue.loading()) {
    loadLists();
  }

  Future<void> loadLists() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await ref.read(taskListsProvider.future);
    });
  }

  Future<TaskList> createList({
    required String name,
    String? emoji,
    ListColor color = ListColor.blue,
  }) async {
    final list = TaskList()
      ..name = name
      ..emoji = emoji
      ..color = color
      ..createdAt = DateTime.now();

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.taskLists.put(list);
    });

    await loadLists();
    return list;
  }

  Future<void> updateList(TaskList list) async {
    list.updatedAt = DateTime.now();
    
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.taskLists.put(list);
    });

    await loadLists();
  }

  Future<void> deleteList(int listId) async {
    await DatabaseService.isar.writeTxn(() async {
      // Delete all items in list
      await DatabaseService.listItems.filter().listIdEqualTo(listId).deleteAll();
      // Delete list
      await DatabaseService.taskLists.delete(listId);
    });

    await loadLists();
  }

  Future<void> togglePin(TaskList list) async {
    list.isPinned = !list.isPinned;
    await updateList(list);
  }

  Future<void> archiveList(int listId) async {
    final list = await DatabaseService.taskLists.get(listId);
    if (list != null) {
      list.isArchived = true;
      await updateList(list);
    }
  }
}

final taskListsNotifierProvider =
    StateNotifierProvider<TaskListsNotifier, AsyncValue<List<TaskList>>>((ref) {
  return TaskListsNotifier(ref);
});

// ============================================
// LIST ITEMS NOTIFIER
// ============================================

class ListItemsNotifier extends StateNotifier<List<ListItem>> {
  final Ref ref;
  final int listId;

  ListItemsNotifier(this.ref, this.listId) : super([]) {
    loadItems();
  }

  Future<void> loadItems() async {
    final items = await DatabaseService.listItems
        .filter()
        .listIdEqualTo(listId)
        .sortBySortOrder()
        .findAll();
    state = items;
  }

  Future<void> addItem(String content) async {
    final maxOrder = state.isEmpty ? 0 : state.map((e) => e.sortOrder).reduce((a, b) => a > b ? a : b);

    final item = ListItem()
      ..listId = listId
      ..content = content
      ..sortOrder = maxOrder + 1
      ..createdAt = DateTime.now();

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.listItems.put(item);
    });

    await loadItems();
    ref.invalidate(taskListsProvider); // Update counts
  }

  Future<void> updateItem(ListItem item) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.listItems.put(item);
    });

    await loadItems();
    ref.invalidate(taskListsProvider);
  }

  Future<void> toggleComplete(ListItem item) async {
    item.isCompleted = !item.isCompleted;
    item.completedAt = item.isCompleted ? DateTime.now() : null;
    await updateItem(item);
  }

  Future<void> deleteItem(int itemId) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.listItems.delete(itemId);
    });

    await loadItems();
    ref.invalidate(taskListsProvider);
  }

  Future<void> reorderItems(int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }

    final items = [...state];
    final item = items.removeAt(oldIndex);
    items.insert(newIndex, item);

    // Update sort orders
    await DatabaseService.isar.writeTxn(() async {
      for (int i = 0; i < items.length; i++) {
        items[i].sortOrder = i;
        await DatabaseService.listItems.put(items[i]);
      }
    });

    state = items;
  }
}

final listItemsNotifierProvider =
    StateNotifierProvider.family<ListItemsNotifier, List<ListItem>, int>((ref, listId) {
  return ListItemsNotifier(ref, listId);
});

// ============================================
// QUICK NOTES NOTIFIER
// ============================================

class QuickNotesNotifier extends StateNotifier<List<QuickNote>> {
  final Ref ref;

  QuickNotesNotifier(this.ref) : super([]) {
    loadNotes();
  }

  Future<void> loadNotes() async {
    final notes = await DatabaseService.quickNotes
        .filter()
        .sortByIsPinnedDesc()
        .thenByCreatedAtDesc()
        .findAll();
    state = notes;
  }

  Future<void> createNote(String content, {NoteColor color = NoteColor.yellow}) async {
    final note = QuickNote()
      ..content = content
      ..color = color
      ..createdAt = DateTime.now();

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.quickNotes.put(note);
    });

    await loadNotes();
  }

  Future<void> updateNote(QuickNote note) async {
    note.updatedAt = DateTime.now();

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.quickNotes.put(note);
    });

    await loadNotes();
  }

  Future<void> deleteNote(int noteId) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.quickNotes.delete(noteId);
    });

    await loadNotes();
  }

  Future<void> togglePin(QuickNote note) async {
    note.isPinned = !note.isPinned;
    await updateNote(note);
  }
}

final quickNotesNotifierProvider =
    StateNotifierProvider<QuickNotesNotifier, List<QuickNote>>((ref) {
  return QuickNotesNotifier(ref);
});
```

---

## ขั้นตอนที่ 7: สร้าง Lists Tab UI

**สร้างไฟล์:** `lib/features/tasks/presentation/tasks_lists_tab.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/lists_provider.dart';
import '../models/task_list.dart';
import '../models/quick_note.dart';
import 'list_detail_screen.dart';

class TasksListsTab extends ConsumerWidget {
  const TasksListsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listsAsync = ref.watch(taskListsNotifierProvider);
    final notes = ref.watch(quickNotesNotifierProvider);

    return CustomScrollView(
      slivers: [
        // Quick Notes Section
        SliverToBoxAdapter(
          child: _buildQuickNotesSection(context, ref, notes),
        ),

        // Lists Header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            child: Row(
              children: [
                const Text(
                  '📋 Lists',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('สร้าง List'),
                  onPressed: () => _showCreateListDialog(context, ref),
                ),
              ],
            ),
          ),
        ),

        // Lists Grid
        listsAsync.when(
          loading: () => const SliverToBoxAdapter(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => SliverToBoxAdapter(
            child: Center(child: Text('Error: $e')),
          ),
          data: (lists) {
            if (lists.isEmpty) {
              return SliverToBoxAdapter(
                child: _buildEmptyLists(context, ref),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildListCard(context, lists[index]),
                  childCount: lists.length,
                ),
              ),
            );
          },
        ),

        // Bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 100),
        ),
      ],
    );
  }

  Widget _buildQuickNotesSection(BuildContext context, WidgetRef ref, List<QuickNote> notes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              const Text(
                '📝 Quick Notes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.add, size: 18),
                label: const Text('เพิ่ม'),
                onPressed: () => _showCreateNoteDialog(context, ref),
              ),
            ],
          ),
        ),

        if (notes.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.note_add),
                title: const Text('ยังไม่มี Quick Notes'),
                subtitle: const Text('กด + เพื่อเพิ่มโน้ตสั้นๆ'),
                onTap: () => _showCreateNoteDialog(context, ref),
              ),
            ),
          )
        else
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: notes.length,
              itemBuilder: (context, index) {
                return _buildNoteCard(context, ref, notes[index]);
              },
            ),
          ),
      ],
    );
  }

  Widget _buildNoteCard(BuildContext context, WidgetRef ref, QuickNote note) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        color: Color(note.color.colorValue),
        child: InkWell(
          onTap: () => _showEditNoteDialog(context, ref, note),
          onLongPress: () => _showNoteOptions(context, ref, note),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (note.isPinned)
                  const Icon(Icons.push_pin, size: 14, color: Colors.black54),
                Expanded(
                  child: Text(
                    note.content,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListCard(BuildContext context, TaskList list) {
    final progress = list.itemCount > 0
        ? list.completedCount / list.itemCount
        : 0.0;

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ListDetailScreen(list: list),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    list.emoji ?? '📋',
                    style: const TextStyle(fontSize: 24),
                  ),
                  const Spacer(),
                  if (list.isPinned)
                    const Icon(Icons.push_pin, size: 16, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                list.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Text(
                    '${list.completedCount}/${list.itemCount}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 40,
                    height: 4,
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation(
                        Color(list.color.colorValue),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyLists(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Text('📋', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'ยังไม่มี List',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'สร้าง list สำหรับรายการซื้อของ\nหรือ todo list ต่างๆ',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('สร้าง List แรก'),
            onPressed: () => _showCreateListDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showCreateListDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String selectedEmoji = '📋';
    ListColor selectedColor = ListColor.blue;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('สร้าง List ใหม่'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Emoji picker
              SizedBox(
                height: 50,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: ['📋', '🛒', '📚', '🏠', '💼', '🎯', '🎁', '✈️', '🍔', '💪']
                      .map((emoji) => GestureDetector(
                            onTap: () => setState(() => selectedEmoji = emoji),
                            child: Container(
                              width: 40,
                              height: 40,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: selectedEmoji == emoji
                                    ? AppColors.primary.withOpacity(0.2)
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: Text(emoji, style: const TextStyle(fontSize: 24)),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'ชื่อ List',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              // Color picker
              Wrap(
                spacing: 8,
                children: ListColor.values.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(color.colorValue),
                        shape: BoxShape.circle,
                        border: selectedColor == color
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;

                await ref.read(taskListsNotifierProvider.notifier).createList(
                      name: nameController.text.trim(),
                      emoji: selectedEmoji,
                      color: selectedColor,
                    );

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('สร้าง'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateNoteDialog(BuildContext context, WidgetRef ref) {
    final contentController = TextEditingController();
    NoteColor selectedColor = NoteColor.yellow;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Quick Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  hintText: 'เขียนโน้ตสั้นๆ...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: NoteColor.values.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(color.colorValue),
                        shape: BoxShape.circle,
                        border: selectedColor == color
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contentController.text.trim().isEmpty) return;

                await ref.read(quickNotesNotifierProvider.notifier).createNote(
                      contentController.text.trim(),
                      color: selectedColor,
                    );

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditNoteDialog(BuildContext context, WidgetRef ref, QuickNote note) {
    final contentController = TextEditingController(text: note.content);
    NoteColor selectedColor = note.color;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('แก้ไข Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: NoteColor.values.map((color) {
                  return GestureDetector(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Color(color.colorValue),
                        shape: BoxShape.circle,
                        border: selectedColor == color
                            ? Border.all(color: Colors.black, width: 2)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (contentController.text.trim().isEmpty) return;

                note.content = contentController.text.trim();
                note.color = selectedColor;
                await ref.read(quickNotesNotifierProvider.notifier).updateNote(note);

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('บันทึก'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteOptions(BuildContext context, WidgetRef ref, QuickNote note) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(note.isPinned ? Icons.push_pin_outlined : Icons.push_pin),
              title: Text(note.isPinned ? 'เลิกปักหมุด' : 'ปักหมุด'),
              onTap: () async {
                await ref.read(quickNotesNotifierProvider.notifier).togglePin(note);
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('ลบ', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await ref.read(quickNotesNotifierProvider.notifier).deleteNote(note.id);
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 8: สร้าง List Detail Screen

**สร้างไฟล์:** `lib/features/tasks/presentation/list_detail_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/lists_provider.dart';
import '../models/task_list.dart';
import '../models/list_item.dart';

class ListDetailScreen extends ConsumerStatefulWidget {
  final TaskList list;

  const ListDetailScreen({super.key, required this.list});

  @override
  ConsumerState<ListDetailScreen> createState() => _ListDetailScreenState();
}

class _ListDetailScreenState extends ConsumerState<ListDetailScreen> {
  final _addItemController = TextEditingController();
  final _addItemFocus = FocusNode();

  @override
  void dispose() {
    _addItemController.dispose();
    _addItemFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(listItemsNotifierProvider(widget.list.id));

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(widget.list.emoji ?? '📋', style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(widget.list.name),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              widget.list.isPinned ? Icons.push_pin : Icons.push_pin_outlined,
            ),
            onPressed: _togglePin,
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('แก้ไข List'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_completed',
                child: Row(
                  children: [
                    Icon(Icons.cleaning_services),
                    SizedBox(width: 8),
                    Text('ลบรายการที่เสร็จ'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('ลบ List', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _showEditListDialog();
                  break;
                case 'clear_completed':
                  _clearCompleted();
                  break;
                case 'delete':
                  _deleteList();
                  break;
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: items.isEmpty
                ? 0
                : items.where((i) => i.isCompleted).length / items.length,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation(Color(widget.list.color.colorValue)),
          ),

          // Items list
          Expanded(
            child: items.isEmpty
                ? _buildEmptyState()
                : ReorderableListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 100),
                    itemCount: items.length,
                    onReorder: (oldIndex, newIndex) {
                      ref
                          .read(listItemsNotifierProvider(widget.list.id).notifier)
                          .reorderItems(oldIndex, newIndex);
                    },
                    itemBuilder: (context, index) {
                      return _buildItemTile(items[index], Key('item-${items[index].id}'));
                    },
                  ),
          ),

          // Add item input
          _buildAddItemInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.list.emoji ?? '📋', style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          const Text(
            'List ว่างเปล่า',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'เพิ่มรายการด้านล่าง',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(ListItem item, Key key) {
    return Dismissible(
      key: key,
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) {
        ref.read(listItemsNotifierProvider(widget.list.id).notifier).deleteItem(item.id);
      },
      child: ListTile(
        key: key,
        leading: Checkbox(
          value: item.isCompleted,
          activeColor: Color(widget.list.color.colorValue),
          onChanged: (_) {
            ref.read(listItemsNotifierProvider(widget.list.id).notifier).toggleComplete(item);
          },
        ),
        title: Text(
          item.content,
          style: TextStyle(
            decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            color: item.isCompleted ? AppColors.textSecondary : null,
          ),
        ),
        trailing: ReorderableDragStartListener(
          index: ref.read(listItemsNotifierProvider(widget.list.id)).indexOf(item),
          child: const Icon(Icons.drag_handle, color: Colors.grey),
        ),
        onTap: () => _showEditItemDialog(item),
      ),
    );
  }

  Widget _buildAddItemInput() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _addItemController,
                focusNode: _addItemFocus,
                decoration: InputDecoration(
                  hintText: 'เพิ่มรายการ...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _addItem(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _addItem,
              icon: Icon(Icons.add_circle, color: Color(widget.list.color.colorValue), size: 32),
            ),
          ],
        ),
      ),
    );
  }

  void _addItem() {
    if (_addItemController.text.trim().isEmpty) return;

    ref
        .read(listItemsNotifierProvider(widget.list.id).notifier)
        .addItem(_addItemController.text.trim());

    _addItemController.clear();
    _addItemFocus.requestFocus();
  }

  void _togglePin() async {
    await ref.read(taskListsNotifierProvider.notifier).togglePin(widget.list);
    setState(() {});
  }

  void _showEditItemDialog(ListItem item) {
    final controller = TextEditingController(text: item.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แก้ไขรายการ'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              item.content = controller.text.trim();
              ref.read(listItemsNotifierProvider(widget.list.id).notifier).updateItem(item);
              Navigator.pop(context);
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void _showEditListDialog() {
    final controller = TextEditingController(text: widget.list.name);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('แก้ไข List'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'ชื่อ List',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isEmpty) return;
              widget.list.name = controller.text.trim();
              ref.read(taskListsNotifierProvider.notifier).updateList(widget.list);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('บันทึก'),
          ),
        ],
      ),
    );
  }

  void _clearCompleted() async {
    final items = ref.read(listItemsNotifierProvider(widget.list.id));
    final completed = items.where((i) => i.isCompleted).toList();

    for (final item in completed) {
      await ref.read(listItemsNotifierProvider(widget.list.id).notifier).deleteItem(item.id);
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ลบ ${completed.length} รายการที่เสร็จแล้ว')),
      );
    }
  }

  void _deleteList() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ลบ List?'),
        content: const Text('รายการทั้งหมดใน List จะถูกลบด้วย'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(taskListsNotifierProvider.notifier).deleteList(widget.list.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back
            },
            child: const Text('ลบ'),
          ),
        ],
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 9: อัปเดต Tasks Page

**แก้ไขไฟล์:** `lib/features/tasks/presentation/tasks_page.dart`

**เพิ่ม import:**

```dart
import 'tasks_lists_tab.dart';
```

**เปลี่ยน placeholder เป็น TasksListsTab:**

```dart
TabBarView(
  controller: _tabController,
  children: [
    const TasksTodayTab(),
    const TasksCalendarTab(),
    const TasksListsTab(),  // ← แก้จาก placeholder
    _buildPlaceholder('Habits', '🔥'),
  ],
),
```

---

## ขั้นตอนที่ 10: ทดสอบ

```bash
flutter run
```

### ทดสอบ:

1. **Tasks → Lists tab**
   - ควรเห็น Quick Notes section
   - ควรเห็นปุ่ม "สร้าง List"

2. **สร้าง Quick Note**
   - กด + ที่ Quick Notes
   - พิมพ์ข้อความ เลือกสี กด บันทึก
   - ควรเห็น note ใหม่

3. **สร้าง List**
   - กด "สร้าง List"
   - เลือก emoji, พิมพ์ชื่อ, เลือกสี
   - กด สร้าง

4. **เข้าไปใน List**
   - กด List ที่สร้าง
   - เพิ่มรายการ
   - ติ๊กเสร็จ
   - ลาก reorder
   - ปัดลบ

---

## ✅ Checklist

- [ ] สร้าง `task_list.dart` model แล้ว
- [ ] สร้าง `list_item.dart` model แล้ว
- [ ] สร้าง `quick_note.dart` model แล้ว
- [ ] อัปเดต DatabaseService แล้ว
- [ ] รัน build_runner แล้ว
- [ ] สร้าง `lists_provider.dart` แล้ว
- [ ] สร้าง `tasks_lists_tab.dart` แล้ว
- [ ] สร้าง `list_detail_screen.dart` แล้ว
- [ ] อัปเดต `tasks_page.dart` แล้ว
- [ ] ทดสอบ Quick Notes ได้
- [ ] ทดสอบ Lists ได้
- [ ] ทดสอบ reorder และ delete ได้

---

## ไฟล์ที่สร้าง/แก้ไขในขั้นตอนนี้

```
lib/features/tasks/
├── models/
│   ├── task_list.dart       ← NEW
│   ├── task_list.g.dart     ← GENERATED
│   ├── list_item.dart       ← NEW
│   ├── list_item.g.dart     ← GENERATED
│   ├── quick_note.dart      ← NEW
│   └── quick_note.g.dart    ← GENERATED
├── providers/
│   └── lists_provider.dart  ← NEW
├── presentation/
│   ├── tasks_page.dart      ← UPDATED
│   ├── tasks_lists_tab.dart ← NEW
│   └── list_detail_screen.dart ← NEW
lib/core/database/
└── database_service.dart    ← UPDATED
```

---

## ขั้นตอนถัดไป

ไป **Step 15: Habits Tracking** เพื่อสร้างระบบติดตาม Habits และ Streaks
