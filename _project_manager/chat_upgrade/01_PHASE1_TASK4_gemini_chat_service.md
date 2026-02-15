# Phase 1 Task 4: สร้าง Gemini Chat Service

## เป้าหมาย
สร้าง service สำหรับส่ง chat text ไป Gemini Backend (Firebase Function)

## ขั้นตอน

### 1. สร้างไฟล์ใหม่
ตำแหน่ง: `lib/core/ai/gemini_chat_service.dart`

### 2. Copy โค้ดนี้ลงไฟล์

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:miro/core/config/firebase_config.dart';
import 'package:miro/core/services/device_id_service.dart';

/// Service for Chat with Miro AI (Gemini Backend)
class GeminiChatService {
  static const String _functionUrl = FirebaseConfig.analyzeFoodUrl;

  /// Send message to Gemini Backend for Chat analysis
  /// 
  /// Returns:
  /// ```json
  /// {
  ///   "type": "food_log",
  ///   "items": [
  ///     {
  ///       "food_name": "Stir-fried basil pork",
  ///       "food_name_local": "ผัดกะเพราหมู",
  ///       "meal_type": "breakfast",
  ///       "serving_size": 1.0,
  ///       "serving_unit": "plate",
  ///       "calories": 450,
  ///       "protein": 25,
  ///       "carbs": 45,
  ///       "fat": 18
  ///     }
  ///   ],
  ///   "reply": "Logged 1 item! Today's total: 450 kcal 💪"
  /// }
  /// ```
  static Future<Map<String, dynamic>> analyzeChatMessage({
    required String message,
  }) async {
    try {
      final deviceId = await DeviceIdService.getDeviceId();

      final response = await http.post(
        Uri.parse(_functionUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'type': 'chat',
          'text': message,
          'deviceId': deviceId,
        }),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data as Map<String, dynamic>;
      } else if (response.statusCode == 429) {
        throw Exception('Energy depleted. Please purchase more Energy from the store.');
      } else {
        throw Exception('Failed to analyze chat: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
```

## อธิบายโค้ด

### Input
- `message`: ข้อความที่ user พิมพ์ใน chat
- `type: 'chat'`: บอก Backend ว่าเป็น chat (ไม่ใช่ photo analysis)

### Output
Backend จะส่งกลับมา:
```json
{
  "type": "food_log",
  "items": [
    {
      "food_name": "...",
      "food_name_local": "...",
      "meal_type": "breakfast",
      "serving_size": 1.0,
      "serving_unit": "plate",
      "calories": 450,
      "protein": 25,
      "carbs": 45,
      "fat": 18
    }
  ],
  "reply": "Logged 1 item!"
}
```

### Error Handling
- `429` = Energy หมด → แจ้ง user ให้ไปซื้อ
- Timeout 60 วินาที
- อื่นๆ → throw Exception

## เสร็จแล้ว
✅ Task 4 เสร็จ — Service สำเร็จ
➡️ ไปต่อ Task 5: `01_PHASE1_TASK5_backend_function.md`
