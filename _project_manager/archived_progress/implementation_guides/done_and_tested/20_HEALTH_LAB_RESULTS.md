# Step 20: Health Lab Results

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 3-4 ชั่วโมง
> **ความยาก:** ยาก
> **ต้องทำก่อน:** Step 19 (Other Health Tab)
> **อ้างอิง:** `_project_manager/HEALTH_FEATURE_DESIGN.md`

---

## 🎯 เป้าหมาย

- บันทึกผลตรวจสุขภาพแบบ open-ended (ไม่จำกัดรายการ)
- ถ่ายรูปผลตรวจ → AI อ่านค่า
- เปรียบเทียบค่าข้ามครั้ง
- แสดงกราฟแนวโน้ม

---

## 🔑 Key Concept

```
ปัญหา: คนตรวจสุขภาพไม่เหมือนกัน
- บางคนตรวจทั่วไป (CBC, Lipid Profile)
- บางคนตรวจละเอียด (Tumor Markers, Hormones)
- แต่ละโรงพยาบาลใช้ชื่อต่างกัน!

วิธีแก้: Open-ended key-value pairs
- AI อ่านรูป → กรอกค่าเท่าที่อ่านได้
- ผู้ใช้ตรวจทาน → แก้ไข/ยืนยัน
- ชื่อไม่ตรงกัน = บันทึกแยก → merge ทีหลังได้
```

---

## สิ่งที่ต้องทำ

1. สร้าง LabSession Model
2. สร้าง LabItem Model
3. สร้าง Lab Provider
4. สร้าง Lab Tab UI
5. สร้าง Lab Session Detail Screen
6. สร้าง Add Lab Result Screen
7. ทดสอบ

---

## ขั้นตอนที่ 1: สร้าง LabSession Model

**สร้างไฟล์:** `lib/features/health/models/lab_session.dart`

```dart
import 'package:isar/isar.dart';

part 'lab_session.g.dart';

/// ครั้งที่ตรวจสุขภาพ
@collection
class LabSession {
  Id id = Isar.autoIncrement;

  /// วันที่ตรวจ
  late DateTime date;

  /// โรงพยาบาล/คลินิก
  String? location;

  /// หัวข้อ เช่น "ตรวจประจำปี", "ตรวจ Lipid"
  String? title;

  /// หมายเหตุ
  String? notes;

  /// รูปผลตรวจ (path)
  String? imagePath;

  /// จำนวนรายการที่ตรวจ
  int itemCount = 0;

  late DateTime createdAt;
  DateTime? updatedAt;
}
```

---

## ขั้นตอนที่ 2: สร้าง LabItem Model

**สร้างไฟล์:** `lib/features/health/models/lab_item.dart`

```dart
import 'package:isar/isar.dart';

part 'lab_item.g.dart';

/// รายการผลตรวจแต่ละค่า
@collection
class LabItem {
  Id id = Isar.autoIncrement;

  /// อ้างอิง LabSession
  late int sessionId;

  /// ชื่อรายการ (ตามที่อ่านได้/ผู้ใช้ใส่)
  late String name;

  /// ค่าที่วัดได้ (เก็บเป็น String เพราะบางทีมี range)
  late String value;

  /// หน่วย
  String? unit;

  /// ค่าปกติ เช่น "70-100", "<200"
  String? normalRange;

  /// สถานะ
  @enumerated
  LabItemStatus status = LabItemStatus.normal;

  /// หมายเหตุ
  String? notes;

  late DateTime createdAt;
}

enum LabItemStatus {
  normal,
  high,
  low,
  critical,
  unknown,
}

extension LabItemStatusExtension on LabItemStatus {
  String get emoji {
    switch (this) {
      case LabItemStatus.normal: return '✅';
      case LabItemStatus.high: return '⬆️';
      case LabItemStatus.low: return '⬇️';
      case LabItemStatus.critical: return '⚠️';
      case LabItemStatus.unknown: return '❓';
    }
  }

  String get displayName {
    switch (this) {
      case LabItemStatus.normal: return 'ปกติ';
      case LabItemStatus.high: return 'สูง';
      case LabItemStatus.low: return 'ต่ำ';
      case LabItemStatus.critical: return 'วิกฤต';
      case LabItemStatus.unknown: return 'ไม่ทราบ';
    }
  }
}
```

---

## ขั้นตอนที่ 3: อัปเดต Database Service

**แก้ไขไฟล์:** `lib/core/database/database_service.dart`

**เพิ่ม imports:**

```dart
import '../../features/health/models/lab_session.dart';
import '../../features/health/models/lab_item.dart';
```

**เพิ่มใน schemas:**

```dart
LabSessionSchema,
LabItemSchema,
```

**เพิ่ม getters:**

```dart
static IsarCollection<LabSession> get labSessions => _isar!.labSessions;
static IsarCollection<LabItem> get labItems => _isar!.labItems;
```

---

## ขั้นตอนที่ 4: รัน Build Runner

```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## ขั้นตอนที่ 5: สร้าง Lab Provider

**สร้างไฟล์:** `lib/features/health/providers/lab_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import '../../../core/database/database_service.dart';
import '../models/lab_session.dart';
import '../models/lab_item.dart';

// ============================================
// LAB SESSIONS
// ============================================

final labSessionsProvider = FutureProvider<List<LabSession>>((ref) async {
  return await DatabaseService.labSessions
      .where()
      .sortByDateDesc()
      .findAll();
});

final labSessionProvider = FutureProvider.family<LabSession?, int>((ref, id) async {
  return await DatabaseService.labSessions.get(id);
});

// ============================================
// LAB ITEMS
// ============================================

final labItemsProvider = FutureProvider.family<List<LabItem>, int>((ref, sessionId) async {
  return await DatabaseService.labItems
      .filter()
      .sessionIdEqualTo(sessionId)
      .sortByName()
      .findAll();
});

/// ดึง history ของ item ชื่อเดียวกัน (ข้ามครั้ง)
final labItemHistoryProvider = FutureProvider.family<List<LabItemWithSession>, String>((ref, name) async {
  final items = await DatabaseService.labItems
      .filter()
      .nameEqualTo(name)
      .findAll();

  final result = <LabItemWithSession>[];
  for (final item in items) {
    final session = await DatabaseService.labSessions.get(item.sessionId);
    if (session != null) {
      result.add(LabItemWithSession(item: item, session: session));
    }
  }

  result.sort((a, b) => b.session.date.compareTo(a.session.date));
  return result;
});

class LabItemWithSession {
  final LabItem item;
  final LabSession session;

  LabItemWithSession({required this.item, required this.session});
}

// ============================================
// UNIQUE ITEM NAMES (for comparison)
// ============================================

final uniqueLabItemNamesProvider = FutureProvider<List<String>>((ref) async {
  final items = await DatabaseService.labItems.where().findAll();
  final names = items.map((i) => i.name).toSet().toList();
  names.sort();
  return names;
});

// ============================================
// LAB NOTIFIER
// ============================================

class LabNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref ref;

  LabNotifier(this.ref) : super(const AsyncValue.data(null));

  /// สร้าง Lab Session ใหม่
  Future<LabSession> createSession({
    required DateTime date,
    String? title,
    String? location,
    String? notes,
    String? imagePath,
  }) async {
    final session = LabSession()
      ..date = date
      ..title = title ?? 'ผลตรวจ ${date.day}/${date.month}/${date.year}'
      ..location = location
      ..notes = notes
      ..imagePath = imagePath
      ..createdAt = DateTime.now();

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.labSessions.put(session);
    });

    ref.invalidate(labSessionsProvider);
    return session;
  }

  /// เพิ่ม Lab Item
  Future<LabItem> addItem({
    required int sessionId,
    required String name,
    required String value,
    String? unit,
    String? normalRange,
    LabItemStatus status = LabItemStatus.unknown,
  }) async {
    final item = LabItem()
      ..sessionId = sessionId
      ..name = name
      ..value = value
      ..unit = unit
      ..normalRange = normalRange
      ..status = status
      ..createdAt = DateTime.now();

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.labItems.put(item);

      // Update item count
      final session = await DatabaseService.labSessions.get(sessionId);
      if (session != null) {
        final count = await DatabaseService.labItems
            .filter()
            .sessionIdEqualTo(sessionId)
            .count();
        session.itemCount = count;
        await DatabaseService.labSessions.put(session);
      }
    });

    ref.invalidate(labItemsProvider(sessionId));
    ref.invalidate(uniqueLabItemNamesProvider);
    return item;
  }

  /// อัปเดต Lab Item
  Future<void> updateItem({
    required int itemId,
    String? name,
    String? value,
    String? unit,
    String? normalRange,
    LabItemStatus? status,
  }) async {
    await DatabaseService.isar.writeTxn(() async {
      final item = await DatabaseService.labItems.get(itemId);
      if (item != null) {
        if (name != null) item.name = name;
        if (value != null) item.value = value;
        if (unit != null) item.unit = unit;
        if (normalRange != null) item.normalRange = normalRange;
        if (status != null) item.status = status;
        await DatabaseService.labItems.put(item);
      }
    });

    ref.invalidate(labItemsProvider);
  }

  /// ลบ Lab Item
  Future<void> deleteItem(int itemId) async {
    final item = await DatabaseService.labItems.get(itemId);
    if (item == null) return;

    final sessionId = item.sessionId;

    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.labItems.delete(itemId);

      // Update item count
      final session = await DatabaseService.labSessions.get(sessionId);
      if (session != null) {
        final count = await DatabaseService.labItems
            .filter()
            .sessionIdEqualTo(sessionId)
            .count();
        session.itemCount = count;
        await DatabaseService.labSessions.put(session);
      }
    });

    ref.invalidate(labItemsProvider(sessionId));
  }

  /// ลบ Lab Session (และ items ทั้งหมด)
  Future<void> deleteSession(int sessionId) async {
    await DatabaseService.isar.writeTxn(() async {
      await DatabaseService.labItems
          .filter()
          .sessionIdEqualTo(sessionId)
          .deleteAll();
      await DatabaseService.labSessions.delete(sessionId);
    });

    ref.invalidate(labSessionsProvider);
  }
}

final labNotifierProvider =
    StateNotifierProvider<LabNotifier, AsyncValue<void>>((ref) {
  return LabNotifier(ref);
});
```

---

## ขั้นตอนที่ 6: สร้าง Lab Tab UI

**สร้างไฟล์:** `lib/features/health/presentation/health_lab_tab.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/lab_provider.dart';
import '../models/lab_session.dart';
import 'lab_session_detail_screen.dart';
import 'add_lab_session_screen.dart';

class HealthLabTab extends ConsumerWidget {
  const HealthLabTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionsAsync = ref.watch(labSessionsProvider);

    return Scaffold(
      body: sessionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (sessions) {
          if (sessions.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length + 1, // +1 for header
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildHeader(context);
              }
              return _buildSessionCard(context, ref, sessions[index - 1]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddSession(context),
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มผลตรวจ'),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🩺 ผลตรวจสุขภาพ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'บันทึกและติดตามผลตรวจสุขภาพของคุณ',
            style: TextStyle(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('🩺', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text(
            'ยังไม่มีผลตรวจสุขภาพ',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'ถ่ายรูปหรือเพิ่มผลตรวจด้วยตัวเอง',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('เพิ่มผลตรวจแรก'),
            onPressed: () => _navigateToAddSession(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, WidgetRef ref, LabSession session) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _navigateToDetail(context, session.id),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.health.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('🩺', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.title ?? 'ผลตรวจสุขภาพ',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          DateFormat('d MMMM yyyy', 'th').format(session.date),
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${session.itemCount}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        'รายการ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (session.location != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      session.location!,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, int sessionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LabSessionDetailScreen(sessionId: sessionId),
      ),
    );
  }

  void _navigateToAddSession(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddLabSessionScreen(),
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 7: สร้าง Lab Session Detail Screen

**สร้างไฟล์:** `lib/features/health/presentation/lab_session_detail_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/lab_provider.dart';
import '../models/lab_item.dart';

class LabSessionDetailScreen extends ConsumerWidget {
  final int sessionId;

  const LabSessionDetailScreen({super.key, required this.sessionId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(labSessionProvider(sessionId));
    final itemsAsync = ref.watch(labItemsProvider(sessionId));

    return Scaffold(
      appBar: AppBar(
        title: sessionAsync.when(
          data: (session) => Text(session?.title ?? 'ผลตรวจ'),
          loading: () => const Text('...'),
          error: (_, __) => const Text('Error'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddItemDialog(context, ref),
          ),
        ],
      ),
      body: sessionAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (session) {
          if (session == null) {
            return const Center(child: Text('ไม่พบข้อมูล'));
          }

          return Column(
            children: [
              // Session Info
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: AppColors.surfaceVariant,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📅 ${DateFormat('d MMMM yyyy', 'th').format(session.date)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    if (session.location != null)
                      Text('📍 ${session.location}'),
                    if (session.notes != null)
                      Text('📝 ${session.notes}'),
                  ],
                ),
              ),

              // Items List
              Expanded(
                child: itemsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                  data: (items) {
                    if (items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('📋', style: TextStyle(fontSize: 48)),
                            const SizedBox(height: 8),
                            Text(
                              'ยังไม่มีรายการ',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('เพิ่มรายการ'),
                              onPressed: () => _showAddItemDialog(context, ref),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return _buildItemCard(context, ref, items[index]);
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItemCard(BuildContext context, WidgetRef ref, LabItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(
          item.status.emoji,
          style: const TextStyle(fontSize: 24),
        ),
        title: Text(item.name),
        subtitle: Text(
          '${item.value} ${item.unit ?? ''}'.trim(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        trailing: item.normalRange != null
            ? Text(
                'ปกติ: ${item.normalRange}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              )
            : null,
        onTap: () => _showItemHistory(context, ref, item.name),
        onLongPress: () => _showItemOptions(context, ref, item),
      ),
    );
  }

  void _showAddItemDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    final unitController = TextEditingController();
    final rangeController = TextEditingController();
    LabItemStatus status = LabItemStatus.unknown;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('➕ เพิ่มรายการ'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'ชื่อรายการ',
                    hintText: 'เช่น Cholesterol',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: valueController,
                        decoration: const InputDecoration(
                          labelText: 'ค่า',
                          hintText: '195',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: unitController,
                        decoration: const InputDecoration(
                          labelText: 'หน่วย',
                          hintText: 'mg/dL',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: rangeController,
                  decoration: const InputDecoration(
                    labelText: 'ค่าปกติ (optional)',
                    hintText: '<200',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<LabItemStatus>(
                  value: status,
                  decoration: const InputDecoration(
                    labelText: 'สถานะ',
                    border: OutlineInputBorder(),
                  ),
                  items: LabItemStatus.values.map((s) {
                    return DropdownMenuItem(
                      value: s,
                      child: Text('${s.emoji} ${s.displayName}'),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => status = v);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ยกเลิก'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isEmpty || valueController.text.isEmpty) {
                  return;
                }

                await ref.read(labNotifierProvider.notifier).addItem(
                      sessionId: sessionId,
                      name: nameController.text,
                      value: valueController.text,
                      unit: unitController.text.isEmpty ? null : unitController.text,
                      normalRange: rangeController.text.isEmpty ? null : rangeController.text,
                      status: status,
                    );

                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('เพิ่ม'),
            ),
          ],
        ),
      ),
    );
  }

  void _showItemHistory(BuildContext context, WidgetRef ref, String name) {
    // TODO: Navigate to history screen or show bottom sheet
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('ดูประวัติ "$name"')),
    );
  }

  void _showItemOptions(BuildContext context, WidgetRef ref, LabItem item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('ดูประวัติ'),
              onTap: () {
                Navigator.pop(context);
                _showItemHistory(context, ref, item.name);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('แก้ไข'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show edit dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('ลบ', style: TextStyle(color: Colors.red)),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(labNotifierProvider.notifier).deleteItem(item.id);
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

## ขั้นตอนที่ 8: สร้าง Add Lab Session Screen

**สร้างไฟล์:** `lib/features/health/presentation/add_lab_session_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/lab_provider.dart';
import 'lab_session_detail_screen.dart';

class AddLabSessionScreen extends ConsumerStatefulWidget {
  const AddLabSessionScreen({super.key});

  @override
  ConsumerState<AddLabSessionScreen> createState() => _AddLabSessionScreenState();
}

class _AddLabSessionScreenState extends ConsumerState<AddLabSessionScreen> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('เพิ่มผลตรวจสุขภาพ'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date Picker
            const Text(
              '📅 วันที่ตรวจ',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('d MMMM yyyy', 'th').format(_selectedDate),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Title
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'หัวข้อ',
                hintText: 'เช่น ตรวจประจำปี, ตรวจ Lipid',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Location
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'สถานที่ (optional)',
                hintText: 'เช่น โรงพยาบาล XYZ',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
            ),
            const SizedBox(height: 16),

            // Notes
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'หมายเหตุ (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            // Photo option (TODO)
            Card(
              child: ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('ถ่ายรูปผลตรวจ'),
                subtitle: const Text('AI จะช่วยอ่านค่าให้อัตโนมัติ'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Implement photo capture + AI analysis
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('ฟีเจอร์นี้กำลังพัฒนา')),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _createSession,
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('สร้างและเพิ่มรายการ'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _createSession() async {
    final session = await ref.read(labNotifierProvider.notifier).createSession(
          date: _selectedDate,
          title: _titleController.text.isEmpty ? null : _titleController.text,
          location: _locationController.text.isEmpty ? null : _locationController.text,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );

    if (mounted) {
      // Navigate to detail screen to add items
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LabSessionDetailScreen(sessionId: session.id),
        ),
      );
    }
  }
}
```

---

## ขั้นตอนที่ 9: อัปเดต Health Page

**แก้ไขไฟล์:** `lib/features/health/presentation/health_page.dart`

**เพิ่ม import และ tab:**

```dart
import 'health_lab_tab.dart';

// แก้ไข TabBar ให้มี Lab tab
TabBar(
  controller: _tabController,
  isScrollable: true,  // เพิ่มเพราะมี 5 tabs
  tabs: const [
    Tab(text: 'Timeline'),
    Tab(text: 'Diet'),
    Tab(text: 'Workout'),
    Tab(text: 'Other'),
    Tab(text: 'Lab'),    // เพิ่ม
  ],
),

// TabBarView
TabBarView(
  controller: _tabController,
  children: const [
    HealthTimelineTab(),
    HealthDietTab(),
    HealthWorkoutTab(),
    HealthOtherTab(),
    HealthLabTab(),      // เพิ่ม
  ],
),
```

**อย่าลืมแก้ `TabController` length เป็น 5:**

```dart
_tabController = TabController(length: 5, vsync: this);
```

---

## ขั้นตอนที่ 10: ทดสอบ

```bash
flutter run
```

### ทดสอบ:

1. **Health → Lab tab**
2. **เพิ่มผลตรวจใหม่** - กดปุ่ม + 
3. **เพิ่มรายการ** - เพิ่ม Cholesterol, FBS, etc.
4. **ดูรายละเอียด** - กดที่ session
5. **ลบรายการ** - กดค้างที่ item

---

## ✅ Checklist

- [ ] สร้าง `lab_session.dart` model แล้ว
- [ ] สร้าง `lab_item.dart` model แล้ว
- [ ] อัปเดต DatabaseService แล้ว
- [ ] รัน build_runner แล้ว
- [ ] สร้าง `lab_provider.dart` แล้ว
- [ ] สร้าง `health_lab_tab.dart` แล้ว
- [ ] สร้าง `lab_session_detail_screen.dart` แล้ว
- [ ] สร้าง `add_lab_session_screen.dart` แล้ว
- [ ] อัปเดต `health_page.dart` แล้ว (5 tabs)
- [ ] ทดสอบสร้าง session ได้
- [ ] ทดสอบเพิ่ม/ลบ item ได้

---

## ไฟล์ที่สร้าง/แก้ไขในขั้นตอนนี้

```
lib/features/health/
├── models/
│   ├── lab_session.dart            ← NEW
│   ├── lab_session.g.dart          ← GENERATED
│   ├── lab_item.dart               ← NEW
│   └── lab_item.g.dart             ← GENERATED
├── providers/
│   └── lab_provider.dart           ← NEW
└── presentation/
    ├── health_page.dart            ← UPDATED (5 tabs)
    ├── health_lab_tab.dart         ← NEW
    ├── lab_session_detail_screen.dart ← NEW
    └── add_lab_session_screen.dart ← NEW
```

---

## 🔮 Future Enhancement

- **AI อ่านรูปผลตรวจ:** ใช้ Gemini Vision อ่านค่าจากรูป
- **กราฟแนวโน้ม:** แสดง chart ของค่าข้ามครั้ง
- **Name Matching:** รวมชื่อที่ต่างกันแต่หมายถึงสิ่งเดียวกัน

---

## ขั้นตอนถัดไป

ไป **Step 21: Voice Input** เพื่อเพิ่มการสั่งงานด้วยเสียง
