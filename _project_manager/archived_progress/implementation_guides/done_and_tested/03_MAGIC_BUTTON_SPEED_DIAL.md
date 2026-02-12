# Step 03: Magic Button with Speed Dial

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 30 นาที
> **ความยาก:** ง่าย
> **ต้องทำก่อน:** Step 02 (Home Screen)

---

## สิ่งที่ต้องทำ

1. ติดตั้ง flutter_speed_dial package
2. แก้ไข Magic Button ให้เป็น Speed Dial
3. เพิ่ม Animation สวยงาม
4. เชื่อมต่อ actions ไปยังหน้าต่างๆ

---

## ขั้นตอนที่ 1: ตรวจสอบ Package

ตรวจสอบว่า `pubspec.yaml` มี package นี้แล้ว:

```yaml
dependencies:
  flutter_speed_dial: ^7.0.0
```

ถ้ายังไม่มี ให้รัน:

```bash
flutter pub add flutter_speed_dial
```

---

## ขั้นตอนที่ 2: แก้ไข Magic Button

**แก้ไขไฟล์:** `lib/features/home/widgets/magic_button.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../../core/theme/app_colors.dart';

class MagicButton extends StatelessWidget {
  const MagicButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      // Main button
      icon: Icons.auto_awesome,
      activeIcon: Icons.close,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      activeBackgroundColor: AppColors.error,
      activeForegroundColor: Colors.white,
      
      // Button size
      buttonSize: const Size(56, 56),
      childrenButtonSize: const Size(56, 56),
      
      // Animation
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 200),
      
      // Overlay
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      
      // Spacing
      spacing: 12,
      spaceBetweenChildren: 12,
      
      // Direction
      direction: SpeedDialDirection.up,
      
      // Visibility
      visible: true,
      closeManually: false,
      renderOverlay: true,
      
      // Tooltip
      tooltip: 'เพิ่มข้อมูล',
      heroTag: 'magic-button',
      
      // Children
      children: [
        // Camera
        SpeedDialChild(
          child: const Icon(Icons.camera_alt),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          label: 'ถ่ายรูป',
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          labelBackgroundColor: Colors.white,
          onTap: () => _openCamera(context),
        ),
        
        // Gallery
        SpeedDialChild(
          child: const Icon(Icons.photo_library),
          backgroundColor: AppColors.health,
          foregroundColor: Colors.white,
          label: 'เลือกรูป',
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          labelBackgroundColor: Colors.white,
          onTap: () => _openGallery(context),
        ),
        
        // Manual Input
        SpeedDialChild(
          child: const Icon(Icons.edit_note),
          backgroundColor: AppColors.finance,
          foregroundColor: Colors.white,
          label: 'พิมพ์เอง',
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          labelBackgroundColor: Colors.white,
          onTap: () => _openQuickAdd(context),
        ),
        
        // Chat AI
        SpeedDialChild(
          child: const Icon(Icons.smart_toy),
          backgroundColor: AppColors.tasks,
          foregroundColor: Colors.white,
          label: 'Chat AI',
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          labelBackgroundColor: Colors.white,
          onTap: () => _openChat(context),
        ),
      ],
    );
  }

  void _openCamera(BuildContext context) {
    // TODO: Implement camera screen
    _showComingSoon(context, 'ถ่ายรูป');
  }

  void _openGallery(BuildContext context) {
    // TODO: Implement gallery picker
    _showComingSoon(context, 'เลือกรูป');
  }

  void _openQuickAdd(BuildContext context) {
    // TODO: Implement quick add screen
    _showQuickAddDialog(context);
  }

  void _openChat(BuildContext context) {
    // TODO: Navigate to chat screen
    _showComingSoon(context, 'Chat AI');
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _showQuickAddDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuickAddBottomSheet(),
    );
  }
}

// Quick Add Bottom Sheet
class QuickAddBottomSheet extends StatefulWidget {
  const QuickAddBottomSheet({super.key});

  @override
  State<QuickAddBottomSheet> createState() => _QuickAddBottomSheetState();
}

class _QuickAddBottomSheetState extends State<QuickAddBottomSheet> {
  String _selectedType = 'expense'; // expense, food, task

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Title
          const Text(
            'เพิ่มข้อมูลด่วน',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          // Type selector
          Row(
            children: [
              _buildTypeChip(
                label: '💰 รายจ่าย',
                value: 'expense',
              ),
              const SizedBox(width: 8),
              _buildTypeChip(
                label: '🍔 อาหาร',
                value: 'food',
              ),
              const SizedBox(width: 8),
              _buildTypeChip(
                label: '📅 Task',
                value: 'task',
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Input field based on type
          if (_selectedType == 'expense') _buildExpenseInput(),
          if (_selectedType == 'food') _buildFoodInput(),
          if (_selectedType == 'task') _buildTaskInput(),
          
          const SizedBox(height: 16),
          
          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _submit(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'บันทึก',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          // Safe area padding
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }

  Widget _buildTypeChip({
    required String label,
    required String value,
  }) {
    final isSelected = _selectedType == value;
    
    return GestureDetector(
      onTap: () => setState(() => _selectedType = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseInput() {
    return Column(
      children: [
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'จำนวนเงิน (บาท)',
            prefixText: '฿ ',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            labelText: 'รายละเอียด (optional)',
            hintText: 'เช่น กาแฟ Starbucks',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFoodInput() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'ชื่ออาหาร',
            hintText: 'เช่น ข้าวผัดกุ้ง',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'แคลอรี่ (kcal)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskInput() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'ชื่องาน',
            hintText: 'เช่น ประชุม Team Weekly',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          decoration: InputDecoration(
            labelText: 'วันที่/เวลา (optional)',
            hintText: 'เช่น พรุ่งนี้ 14:00',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  void _submit() {
    // TODO: Save data based on type
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('บันทึกสำเร็จ!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
```

---

## ขั้นตอนที่ 3: ทดสอบ

```bash
flutter run
```

**ผลที่ควรได้:**
- กดปุ่ม ✨ แล้ว 4 ปุ่มย่อยค่อยๆ โผล่ขึ้นมา
- มี overlay สีดำจางๆ ด้านหลัง
- แต่ละปุ่มมี label บอกว่าคืออะไร
- กด "พิมพ์เอง" จะแสดง Quick Add Bottom Sheet
- สามารถเลือกประเภท (รายจ่าย/อาหาร/Task) และกรอกข้อมูลได้

---

## ✅ Checklist

- [ ] ตรวจสอบ flutter_speed_dial ใน pubspec.yaml แล้ว
- [ ] แก้ไข magic_button.dart ให้ใช้ SpeedDial
- [ ] มี 4 ปุ่มย่อย (ถ่ายรูป, เลือกรูป, พิมพ์เอง, Chat AI)
- [ ] Quick Add Bottom Sheet ทำงานได้
- [ ] Animation สวยงาม
- [ ] ทดสอบ run app สำเร็จ

---

## ไฟล์ที่แก้ไขในขั้นตอนนี้

```
lib/features/home/widgets/
└── magic_button.dart    ← UPDATED
```

---

## ขั้นตอนถัดไป

ไปที่ **Step 04: Profile & Settings Screen** เพื่อสร้างหน้า Profile และตั้งค่า API Key
