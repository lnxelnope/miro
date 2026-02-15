# Phase 2 Task 3: Weekly/Monthly Summary (Local Query)

## เป้าหมาย
สร้างฟีเจอร์สรุป calories รายสัปดาห์/เดือน โดย query จาก local database (ไม่ใช้ Energy)

## ตัวอย่าง Output

### Weekly Summary
```
📊 Weekly Summary (Feb 10-14, 2026)

📅 Monday:    1,800 kcal ✅ (200 under target)
📅 Tuesday:   2,300 kcal ⚠️ (300 over target)
📅 Wednesday: 1,950 kcal ✅ (50 under target)
📅 Thursday:  2,100 kcal ⚠️ (100 over target)
📅 Friday:    1,750 kcal ✅ (250 under target)

🔥 Average: 1,980 kcal/day
🎯 Target: 2,000 kcal/day
📈 Result: 100 kcal under target — Great job! 💪
```

## ขั้นตอน

### 1. เปิดไฟล์
ตำแหน่ง: `lib/features/chat/presentation/chat_screen.dart`

### 2. แก้ไข method `_showWeeklySummary()` ที่เคยทำไว้ใน Task 2

```dart
/// Show weekly summary (local query)
Future<void> _showWeeklySummary() async {
  try {
    // Get date range for this week (last 7 days)
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    // Get all food entries for this week
    final healthNotifier = ref.read(healthNotifierProvider.notifier);
    final allEntries = ref.read(healthNotifierProvider);
    
    // Filter entries for this week
    final weekEntries = allEntries.where((entry) {
      return entry.timestamp.isAfter(startOfWeek.subtract(const Duration(days: 1))) &&
             entry.timestamp.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList();
    
    // Calculate daily calories
    final dailyCalories = <DateTime, double>{};
    for (final entry in weekEntries) {
      final date = DateTime(entry.timestamp.year, entry.timestamp.month, entry.timestamp.day);
      dailyCalories[date] = (dailyCalories[date] ?? 0) + entry.calories;
    }
    
    // Get target calories
    final healthGoal = ref.read(healthGoalProvider);
    final targetCalories = healthGoal?.targetCalories ?? 2000;
    
    // Build summary message
    final buffer = StringBuffer();
    buffer.writeln('📊 Weekly Summary (${_formatDate(startOfWeek)} - ${_formatDate(endOfWeek)})');
    buffer.writeln();
    
    // List each day
    double totalCalories = 0;
    int daysWithData = 0;
    
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final calories = dailyCalories[DateTime(date.year, date.month, date.day)] ?? 0;
      
      if (calories > 0) {
        totalCalories += calories;
        daysWithData++;
        
        final diff = calories - targetCalories;
        final diffText = diff > 0 
            ? '${diff.toStringAsFixed(0)} over target'
            : '${(-diff).toStringAsFixed(0)} under target';
        final emoji = diff > 0 ? '⚠️' : '✅';
        
        buffer.writeln('📅 ${_getDayName(date)}: ${calories.toStringAsFixed(0)} kcal $emoji ($diffText)');
      }
    }
    
    if (daysWithData == 0) {
      buffer.writeln('No food logged this week yet.');
    } else {
      buffer.writeln();
      final average = totalCalories / daysWithData;
      final weekDiff = totalCalories - (targetCalories * daysWithData);
      
      buffer.writeln('🔥 Average: ${average.toStringAsFixed(0)} kcal/day');
      buffer.writeln('🎯 Target: ${targetCalories.toStringAsFixed(0)} kcal/day');
      
      if (weekDiff > 0) {
        buffer.writeln('📈 Result: ${weekDiff.toStringAsFixed(0)} kcal over target');
      } else {
        buffer.writeln('📈 Result: ${(-weekDiff).toStringAsFixed(0)} kcal under target — Great job! 💪');
      }
    }
    
    // Add message to chat
    final message = ChatMessage(
      text: buffer.toString(),
      isUser: false,
      timestamp: DateTime.now(),
    );
    ref.read(chatNotifierProvider.notifier).addMessage(message);
    
  } catch (e) {
    final errorMsg = ChatMessage(
      text: '❌ Failed to load weekly summary: ${e.toString()}',
      isUser: false,
      timestamp: DateTime.now(),
    );
    ref.read(chatNotifierProvider.notifier).addMessage(errorMsg);
  }
}

/// Show monthly summary (local query)
Future<void> _showMonthlySummary() async {
  try {
    // Get date range for this month
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0);
    
    // Get all food entries for this month
    final allEntries = ref.read(healthNotifierProvider);
    
    // Filter entries for this month
    final monthEntries = allEntries.where((entry) {
      return entry.timestamp.isAfter(startOfMonth.subtract(const Duration(days: 1))) &&
             entry.timestamp.isBefore(endOfMonth.add(const Duration(days: 1)));
    }).toList();
    
    // Calculate total calories
    double totalCalories = 0;
    for (final entry in monthEntries) {
      totalCalories += entry.calories;
    }
    
    // Get target calories
    final healthGoal = ref.read(healthGoalProvider);
    final targetCalories = healthGoal?.targetCalories ?? 2000;
    
    // Calculate days in month
    final daysInMonth = endOfMonth.day;
    final targetTotal = targetCalories * daysInMonth;
    final average = monthEntries.isEmpty ? 0 : totalCalories / daysInMonth;
    
    // Build summary message
    final buffer = StringBuffer();
    buffer.writeln('📊 Monthly Summary (${_getMonthName(now)} ${now.year})');
    buffer.writeln();
    buffer.writeln('📅 Total Days: $daysInMonth');
    buffer.writeln('🔥 Total Consumed: ${totalCalories.toStringAsFixed(0)} kcal');
    buffer.writeln('🎯 Target Total: ${targetTotal.toStringAsFixed(0)} kcal');
    buffer.writeln('📈 Average: ${average.toStringAsFixed(0)} kcal/day');
    buffer.writeln();
    
    final diff = totalCalories - targetTotal;
    if (diff > 0) {
      buffer.writeln('⚠️ ${diff.toStringAsFixed(0)} kcal over target this month');
    } else {
      buffer.writeln('✅ ${(-diff).toStringAsFixed(0)} kcal under target — Excellent! 💪');
    }
    
    // Add message to chat
    final message = ChatMessage(
      text: buffer.toString(),
      isUser: false,
      timestamp: DateTime.now(),
    );
    ref.read(chatNotifierProvider.notifier).addMessage(message);
    
  } catch (e) {
    final errorMsg = ChatMessage(
      text: '❌ Failed to load monthly summary: ${e.toString()}',
      isUser: false,
      timestamp: DateTime.now(),
    );
    ref.read(chatNotifierProvider.notifier).addMessage(errorMsg);
  }
}

/// Helper: Format date as "Feb 10"
String _formatDate(DateTime date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${months[date.month - 1]} ${date.day}';
}

/// Helper: Get day name
String _getDayName(DateTime date) {
  const days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  return days[date.weekday - 1];
}

/// Helper: Get month name
String _getMonthName(DateTime date) {
  const months = ['January', 'February', 'March', 'April', 'May', 'June', 
                  'July', 'August', 'September', 'October', 'November', 'December'];
  return months[date.month - 1];
}
```

## อธิบาย

### Weekly Summary
- ดึงข้อมูล 7 วันล่าสุด (Monday - Sunday)
- แสดงแต่ละวันที่มีรายการอาหาร
- คำนวณ average และ total
- เปรียบเทียบกับเป้าหมาย

### Monthly Summary
- ดึงข้อมูลทั้งเดือนปัจจุบัน
- แสดง total, average, target
- เปรียบเทียบกับเป้าหมายทั้งเดือน

### สำคัญ
- **ไม่ใช้ Energy** — query จาก local database เท่านั้น
- รองรับภาษาอังกฤษเท่านั้น (วัน/เดือน)
- แสดงผลใน chat bubble

## ทดสอบ
1. กด "📊 Weekly" → ควรเห็นสรุปสัปดาห์นี้
2. กด "📊 Monthly" → ควรเห็นสรุปเดือนนี้
3. ถ้ายังไม่มีข้อมูล → แสดง "No food logged yet"
4. Energy balance ไม่เปลี่ยน (ฟรี)

## เสร็จแล้ว
✅ Task 3 เสร็จ — Phase 2 เสร็จสมบูรณ์!

### Phase 2 Summary
- ✅ Smart Greeting
- ✅ Quick FAQ Buttons
- ✅ Weekly/Monthly Summary (ฟรี)

➡️ ไปต่อ Phase 3: `03_PHASE3_TASK1_feature_tour_setup.md`
