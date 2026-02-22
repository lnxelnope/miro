# 📝 String Template Examples

> ตัวอย่าง Strings รูปแบบต่างๆ พร้อมวิธีใช้

---

## 1. Simple Strings (ข้อความธรรมดา)

### ARB File
```json
{
  "save": "บันทึก",
  "cancel": "ยกเลิก",
  "delete": "ลบ",
  "edit": "แก้ไข",
  "close": "ปิด",
  "loading": "กำลังโหลด...",
  "error": "เกิดข้อผิดพลาด"
}
```

### Usage in Code
```dart
Text(L10n.of(context)!.save)
ElevatedButton(
  onPressed: () {},
  child: Text(L10n.of(context)!.cancel),
)
```

---

## 2. Strings with Placeholders (ข้อความที่มีตัวแปร)

### ARB File (app_th.arb)
```json
{
  "welcomeMessage": "สวัสดี {name}!",
  "@welcomeMessage": {
    "placeholders": {
      "name": {
        "type": "String"
      }
    }
  },
  
  "energyRemaining": "พลังงานเหลือ {energy} หน่วย",
  "@energyRemaining": {
    "placeholders": {
      "energy": {
        "type": "int"
      }
    }
  },
  
  "priceAmount": "ราคา {price} บาท",
  "@priceAmount": {
    "placeholders": {
      "price": {
        "type": "double",
        "format": "currency",
        "optionalParameters": {
          "decimalDigits": 2
        }
      }
    }
  }
}
```

### Usage in Code
```dart
// String placeholder
Text(L10n.of(context)!.welcomeMessage('John'))

// Int placeholder
Text(L10n.of(context)!.energyRemaining(10))

// Double placeholder
Text(L10n.of(context)!.priceAmount(99.99))
```

---

## 3. Multiple Placeholders (หลายตัวแปร)

### ARB File
```json
{
  "chatFoodSavedDetail": "{name} {serving} {unit}\n{cal} kcal",
  "@chatFoodSavedDetail": {
    "placeholders": {
      "name": {
        "type": "String"
      },
      "serving": {
        "type": "String"
      },
      "unit": {
        "type": "String"
      },
      "cal": {
        "type": "String"
      }
    }
  },
  
  "macroSummary": "โปรตีน {protein}g • คาร์บ {carbs}g • ไขมัน {fat}g",
  "@macroSummary": {
    "placeholders": {
      "protein": {
        "type": "int"
      },
      "carbs": {
        "type": "int"
      },
      "fat": {
        "type": "int"
      }
    }
  }
}
```

### Usage in Code
```dart
// Named parameters
Text(L10n.of(context)!.chatFoodSavedDetail(
  name: 'ข้าวผัด',
  serving: '1',
  unit: 'จาน',
  cal: '350',
))

// Named parameters (int)
Text(L10n.of(context)!.macroSummary(
  protein: 150,
  carbs: 200,
  fat: 50,
))
```

---

## 4. Multiline Strings (ข้อความหลายบรรทัด)

### ARB File
```json
{
  "clearAllDataConfirm": "ข้อมูลทั้งหมดจะถูกลบ:\n• บันทึกอาหาร\n• เมนูของฉัน\n• วัตถุดิบ\n• เป้าหมาย\n\nลบแล้วกู้คืนไม่ได้!",
  
  "backupDescription": "สำรองข้อมูลของคุณ:\n\n✅ พลังงาน (Energy)\n✅ บันทึกอาหารทั้งหมด\n✅ เมนูของฉัน\n✅ วัตถุดิบ\n\n⚠️ รูปภาพจะไม่ถูกบันทึก"
}
```

### Usage in Code
```dart
AlertDialog(
  title: Text(L10n.of(context)!.clearAllDataTitle),
  content: Text(L10n.of(context)!.clearAllDataConfirm),
)
```

---

## 5. Dialog Strings (ข้อความ Dialog)

### ARB File
```json
{
  "confirmDeleteTitle": "ยืนยันการลบ",
  "confirmDeleteMessage": "คุณแน่ใจหรือไม่ว่าต้องการลบ?",
  "confirmDeleteButton": "ลบ",
  "cancelButton": "ยกเลิก",
  
  "successTitle": "สำเร็จ!",
  "successMessage": "ดำเนินการสำเร็จ",
  "errorTitle": "เกิดข้อผิดพลาด",
  "errorMessage": "กรุณาลองใหม่อีกครั้ง"
}
```

### Usage in Code
```dart
showDialog(
  context: context,
  builder: (ctx) => AlertDialog(
    title: Text(L10n.of(context)!.confirmDeleteTitle),
    content: Text(L10n.of(context)!.confirmDeleteMessage),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(ctx),
        child: Text(L10n.of(context)!.cancelButton),
      ),
      ElevatedButton(
        onPressed: () => _handleDelete(),
        child: Text(L10n.of(context)!.confirmDeleteButton),
      ),
    ],
  ),
)
```

---

## 6. Form Strings (ฟอร์มและ Input)

### ARB File
```json
{
  "foodNameLabel": "ชื่ออาหาร",
  "foodNameHint": "เช่น ข้าวผัด",
  "foodNameError": "กรุณากรอกชื่ออาหาร",
  
  "caloriesLabel": "แคลอรี่",
  "caloriesHint": "0",
  "caloriesError": "กรุณากรอกแคลอรี่",
  "caloriesInvalidError": "กรุณากรอกตัวเลขที่ถูกต้อง",
  
  "servingSizeLabel": "ปริมาณ",
  "servingSizeHint": "1",
  "servingUnitLabel": "หน่วย",
  "servingUnitHint": "จาน"
}
```

### Usage in Code
```dart
TextFormField(
  decoration: InputDecoration(
    labelText: L10n.of(context)!.foodNameLabel,
    hintText: L10n.of(context)!.foodNameHint,
  ),
  validator: (value) {
    if (value == null || value.isEmpty) {
      return L10n.of(context)!.foodNameError;
    }
    return null;
  },
)

TextFormField(
  decoration: InputDecoration(
    labelText: L10n.of(context)!.caloriesLabel,
    hintText: L10n.of(context)!.caloriesHint,
  ),
  keyboardType: TextInputType.number,
  validator: (value) {
    if (value == null || value.isEmpty) {
      return L10n.of(context)!.caloriesError;
    }
    if (int.tryParse(value) == null) {
      return L10n.of(context)!.caloriesInvalidError;
    }
    return null;
  },
)
```

---

## 7. List Items (รายการ)

### ARB File
```json
{
  "mealBreakfast": "เช้า",
  "mealLunch": "กลางวัน",
  "mealDinner": "เย็น",
  "mealSnack": "ของว่าง",
  
  "activityLevelSedentary": "นั่งทำงาน ไม่ค่อยเคลื่อนไหว",
  "activityLevelLight": "ออกกำลังกายเบาๆ 1-3 วัน/สัปดาห์",
  "activityLevelModerate": "ออกกำลังกายปานกลาง 3-5 วัน/สัปดาห์",
  "activityLevelActive": "ออกกำลังกายหนัก 6-7 วัน/สัปดาห์",
  "activityLevelVeryActive": "ออกกำลังกายหนักมาก หรือทำงานหนัก"
}
```

### Usage in Code
```dart
// Dropdown
DropdownButton<MealType>(
  items: [
    DropdownMenuItem(
      value: MealType.breakfast,
      child: Text(L10n.of(context)!.mealBreakfast),
    ),
    DropdownMenuItem(
      value: MealType.lunch,
      child: Text(L10n.of(context)!.mealLunch),
    ),
    DropdownMenuItem(
      value: MealType.dinner,
      child: Text(L10n.of(context)!.mealDinner),
    ),
  ],
)

// RadioButton
Column(
  children: [
    RadioListTile(
      title: Text(L10n.of(context)!.activityLevelSedentary),
      value: ActivityLevel.sedentary,
      groupValue: selectedActivity,
      onChanged: (value) => setState(() => selectedActivity = value),
    ),
    RadioListTile(
      title: Text(L10n.of(context)!.activityLevelLight),
      value: ActivityLevel.light,
      groupValue: selectedActivity,
      onChanged: (value) => setState(() => selectedActivity = value),
    ),
  ],
)
```

---

## 8. Status Messages (ข้อความสถานะ)

### ARB File
```json
{
  "savedSuccess": "บันทึกเรียบร้อย",
  "deletedSuccess": "ลบเรียบร้อย",
  "updatedSuccess": "อัพเดทเรียบร้อย",
  "copiedSuccess": "คัดลอกแล้ว",
  
  "savingInProgress": "กำลังบันทึก...",
  "loadingData": "กำลังโหลดข้อมูล...",
  "processingRequest": "กำลังประมวลผล...",
  
  "networkError": "ไม่สามารถเชื่อมต่อได้",
  "timeoutError": "หมดเวลาเชื่อมต่อ",
  "unknownError": "เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ"
}
```

### Usage in Code
```dart
// SnackBar
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(L10n.of(context)!.savedSuccess)),
)

// Loading Indicator
if (isLoading)
  Center(
    child: Column(
      children: [
        CircularProgressIndicator(),
        SizedBox(height: 16),
        Text(L10n.of(context)!.loadingData),
      ],
    ),
  )

// Error Message
Text(
  L10n.of(context)!.networkError,
  style: TextStyle(color: Colors.red),
)
```

---

## 9. Conditional Strings (ข้อความตามเงื่อนไข)

### ARB File
```json
{
  "energyPassActive": "Energy Pass ใช้งานได้",
  "energyPassExpired": "Energy Pass หมดอายุ",
  "energyPassNone": "ยังไม่มี Energy Pass",
  
  "subscriptionAutoRenewOn": "ต่ออายุอัตโนมัติ: เปิด",
  "subscriptionAutoRenewOff": "ต่ออายุอัตโนมัติ: ปิด",
  
  "aiLimitReachedTitle": "ใช้ AI ครบแล้ววันนี้",
  "aiLimitReachedMessage": "รอถึงพรุ่งนี้ หรืออัพเกรด Energy Pass"
}
```

### Usage in Code
```dart
// Conditional Text
Text(
  subscription.isActive
      ? L10n.of(context)!.energyPassActive
      : L10n.of(context)!.energyPassExpired,
)

// Switch Statement
String getStatusMessage() {
  switch (status) {
    case SubscriptionStatus.active:
      return L10n.of(context)!.energyPassActive;
    case SubscriptionStatus.expired:
      return L10n.of(context)!.energyPassExpired;
    default:
      return L10n.of(context)!.energyPassNone;
  }
}
```

---

## 10. Plural Strings (พหูพจน์)

### ARB File
```json
{
  "itemCount": "{count, plural, =0{ไม่มีรายการ} =1{1 รายการ} other{{count} รายการ}}",
  "@itemCount": {
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  },
  
  "daysRemaining": "{count, plural, =0{หมดอายุแล้ว} =1{เหลืออีก 1 วัน} other{เหลืออีก {count} วัน}}",
  "@daysRemaining": {
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}
```

### Usage in Code
```dart
Text(L10n.of(context)!.itemCount(items.length))
// 0 → "ไม่มีรายการ"
// 1 → "1 รายการ"
// 5 → "5 รายการ"

Text(L10n.of(context)!.daysRemaining(daysLeft))
// 0 → "หมดอายุแล้ว"
// 1 → "เหลืออีก 1 วัน"
// 7 → "เหลืออีก 7 วัน"
```

---

## 11. Date/Time Strings (วันที่/เวลา)

### ARB File
```json
{
  "today": "วันนี้",
  "yesterday": "เมื่อวาน",
  "tomorrow": "พรุ่งนี้",
  
  "dateFormat": "d MMMM yyyy",
  "timeFormat": "HH:mm",
  "dateTimeFormat": "d MMM yyyy, HH:mm",
  
  "lastUpdated": "อัพเดทล่าสุด: {date}",
  "@lastUpdated": {
    "placeholders": {
      "date": {
        "type": "DateTime",
        "format": "yMd"
      }
    }
  }
}
```

### Usage in Code
```dart
// Simple date strings
Text(L10n.of(context)!.today)

// Formatted date
import 'package:intl/intl.dart';

final formatter = DateFormat(L10n.of(context)!.dateFormat);
Text(formatter.format(DateTime.now()))

// With placeholder
Text(L10n.of(context)!.lastUpdated(lastUpdatedDate))
```

---

## 12. Navigation & Tabs

### ARB File
```json
{
  "navHome": "หน้าหลัก",
  "navTimeline": "Timeline",
  "navDiet": "Diet",
  "navChat": "แชท",
  "navProfile": "โปรไฟล์",
  
  "tabMyMeals": "เมนูของฉัน",
  "tabIngredients": "วัตถุดิบ",
  "tabRecipes": "สูตรอาหาร"
}
```

### Usage in Code
```dart
BottomNavigationBar(
  items: [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: L10n.of(context)!.navHome,
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.timeline),
      label: L10n.of(context)!.navTimeline,
    ),
  ],
)

TabBar(
  tabs: [
    Tab(text: L10n.of(context)!.tabMyMeals),
    Tab(text: L10n.of(context)!.tabIngredients),
    Tab(text: L10n.of(context)!.tabRecipes),
  ],
)
```

---

## 💡 Naming Conventions

### Pattern: `[feature][Component][Purpose]`

**Examples:**
- `profileSettings` - หน้า Profile, Settings
- `chatMessageHint` - Chat feature, Message input, Hint text
- `foodFormNameError` - Food form, Name field, Error message
- `mealBreakfast` - Meal type, Breakfast option
- `buttonSave` - Button, Save action
- `dialogConfirmDelete` - Dialog, Confirm delete

### Common Suffixes:
- `Label` - ป้ายชื่อ/หัวข้อ
- `Hint` - placeholder text
- `Error` - error message
- `Success` - success message
- `Title` - dialog/screen title
- `Message` - dialog/alert message
- `Button` - button text
- `Description` - คำอธิบาย

---

**Last Updated:** 19 ก.พ. 2026
