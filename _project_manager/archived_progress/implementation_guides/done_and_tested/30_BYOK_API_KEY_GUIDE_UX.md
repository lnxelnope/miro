# Step 30: BYOK — คู่มือ API Key + ปรับ UX ให้ชัดเจน

> **สำหรับ:** Junior Developer
> **เวลาโดยประมาณ:** 3-4 ชั่วโมง
> **ความยาก:** ปานกลาง
> **ต้องทำก่อน:** Step 29 (ซ่อนฟีเจอร์ที่ไม่ใช้)

---

## 🎯 เป้าหมาย

1. **เขียนคู่มือ Step-by-Step** ในหน้า API Key ให้ผู้ใช้ทั่วไปทำตามได้
2. **Implement ปุ่มทดสอบการเชื่อมต่อ** — ทดสอบว่า Key ใช้งานได้
3. **Graceful Degradation** — ไม่มี Key ก็ใช้แอปได้ (บันทึกด้วยมือ)
4. **Banner แนะนำตั้งค่า** ในหน้า Timeline เมื่อยังไม่มี Key

---

## 📂 ไฟล์ที่เกี่ยวข้อง

| ไฟล์ | Action | คำอธิบาย |
|------|--------|----------|
| `lib/features/profile/presentation/api_key_screen.dart` | EDIT | เขียน UI คู่มือ step-by-step + implement test |
| `lib/core/ai/gemini_service.dart` | EDIT | ปรับ error message + เพิ่ม hasApiKey() |
| `lib/features/health/widgets/food_detail_bottom_sheet.dart` | EDIT | Graceful no-key handling |
| `lib/features/health/widgets/gemini_analysis_sheet.dart` | EDIT | Graceful no-key handling |
| `lib/features/health/presentation/food_preview_screen.dart` | EDIT | Graceful no-key handling |
| `lib/features/chat/services/intent_handler.dart` | EDIT | Graceful no-key handling |
| `lib/features/health/presentation/health_timeline_tab.dart` | EDIT | เพิ่ม No-Key Banner |

---

## 🔧 ขั้นตอนการทำงาน

### Step 1: เพิ่ม `hasApiKey()` ใน GeminiService

**ไฟล์:** `lib/core/ai/gemini_service.dart`
**Action:** EDIT

เพิ่ม static method สำหรับตรวจว่ามี Key หรือยัง:

```dart
import '../services/secure_storage_service.dart';

class GeminiService {
  // ... code เดิม ...

  /// ตรวจว่ามี API Key อยู่แล้วหรือยัง
  static Future<bool> hasApiKey() async {
    final key = await SecureStorageService.getApiKey();
    return key != null && key.isNotEmpty;
  }

  /// ทดสอบ API Key ว่าใช้งานได้จริง
  /// return true ถ้าสำเร็จ, throw error ถ้าไม่สำเร็จ
  static Future<bool> testConnection() async {
    final key = await SecureStorageService.getApiKey();
    if (key == null || key.isEmpty) {
      throw Exception('ยังไม่ได้ตั้งค่า API Key');
    }

    try {
      // ส่ง request ง่ายๆ เพื่อทดสอบ
      // ใช้ generateContent กับข้อความสั้นๆ
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',  // หรือ model ที่ใช้อยู่
        apiKey: key,
      );
      final response = await model.generateContent([
        Content.text('Hi'),
      ]).timeout(const Duration(seconds: 10));

      return response.text != null;
    } on TimeoutException {
      throw Exception('หมดเวลาเชื่อมต่อ — ตรวจสอบอินเทอร์เน็ต');
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('api key') || msg.contains('401') || msg.contains('invalid')) {
        throw Exception('API Key ไม่ถูกต้อง — ตรวจสอบและลองใหม่');
      }
      if (msg.contains('quota') || msg.contains('429')) {
        throw Exception('ใช้ API เกินโควต้า — รอสักครู่แล้วลองใหม่');
      }
      throw Exception('เชื่อมต่อไม่สำเร็จ: ${e.toString()}');
    }
  }
}
```

---

### Step 2: เขียนหน้า API Key ใหม่เป็นคู่มือ Step-by-Step

**ไฟล์:** `lib/features/profile/presentation/api_key_screen.dart`
**Action:** EDIT (เขียนใหม่เกือบทั้งหมด)

#### 2.1 Layout หลัก

```
┌──────────────────────────────────────────┐
│  ← ตั้งค่า Gemini API Key               │
│                                          │
│  ┌─ INFO BOX ──────────────────────────┐ │
│  │ 🤖 ใช้ AI วิเคราะห์อาหารจากรูป     │ │
│  │    Gemini API ใช้ฟรี!               │ │
│  └─────────────────────────────────────┘ │
│                                          │
│  📌 ขั้นตอนที่ 1: เปิด Google AI Studio │
│     [ปุ่ม: เปิดเว็บไซต์ →]              │
│                                          │
│  📌 ขั้นตอนที่ 2: ล็อกอิน Google        │
│     ใช้ Gmail ที่มีอยู่                 │
│                                          │
│  📌 ขั้นตอนที่ 3: คลิก Create API Key   │
│     เลือก project ใดก็ได้               │
│                                          │
│  📌 ขั้นตอนที่ 4: คัดลอก Key            │
│     กดปุ่ม Copy ข้างกล่อง Key           │
│                                          │
│  📌 ขั้นตอนที่ 5: วาง Key ด้านล่าง      │
│  ┌─────────────────────────┐ [📋 วาง]   │
│  │  API Key ของคุณ         │             │
│  └─────────────────────────┘             │
│                                          │
│  [    💾 บันทึก API Key    ]             │
│  [    🔍 ทดสอบการเชื่อมต่อ ]             │
│                                          │
│  ─── คำถามที่พบบ่อย ───                 │
│  ▶ ฟรีจริงไหม?                          │
│  ▶ ปลอดภัยไหม?                          │
│  ▶ ถ้าไม่สร้าง Key?                     │
└──────────────────────────────────────────┘
```

#### 2.2 โค้ดหลัก

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // สำหรับ Clipboard
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ai/gemini_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/theme/app_colors.dart';

class ApiKeyScreen extends ConsumerStatefulWidget {
  const ApiKeyScreen({super.key});

  @override
  ConsumerState<ApiKeyScreen> createState() => _ApiKeyScreenState();
}

class _ApiKeyScreenState extends ConsumerState<ApiKeyScreen> {
  final _keyController = TextEditingController();
  bool _isLoading = false;
  bool _isTesting = false;
  bool _hasKey = false;
  bool _obscureKey = true;

  @override
  void initState() {
    super.initState();
    _loadExistingKey();
  }

  Future<void> _loadExistingKey() async {
    final key = await SecureStorageService.getApiKey();
    if (key != null && key.isNotEmpty && mounted) {
      setState(() {
        _keyController.text = key;
        _hasKey = true;
      });
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ตั้งค่า Gemini API Key')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoBox(),
            const SizedBox(height: 24),
            _buildStep1(),
            _buildStep2(),
            _buildStep3(),
            _buildStep4(),
            _buildStep5KeyInput(),
            const SizedBox(height: 16),
            _buildSaveButton(),
            const SizedBox(height: 8),
            _buildTestButton(),
            const SizedBox(height: 8),
            if (_hasKey) _buildDeleteButton(),
            const SizedBox(height: 32),
            _buildFAQ(),
          ],
        ),
      ),
    );
  }

  // ============ UI Components ============

  Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: const Row(
        children: [
          Icon(Icons.smart_toy, size: 32, color: Colors.blue),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('วิเคราะห์อาหารด้วย AI',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                SizedBox(height: 4),
                Text('ถ่ายรูปอาหาร → AI คำนวณแคลอรี่ให้อัตโนมัติ\nGemini API ใช้ฟรี ไม่ต้องจ่ายเงิน!',
                    style: TextStyle(fontSize: 13, color: Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    return _buildStepCard(
      stepNumber: 1,
      title: 'เปิด Google AI Studio',
      description: 'กดปุ่มด้านล่างเพื่อไปสร้าง API Key',
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => _openUrl('https://aistudio.google.com/apikey'),
          icon: const Icon(Icons.open_in_new),
          label: const Text('เปิด Google AI Studio'),
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return _buildStepCard(
      stepNumber: 2,
      title: 'ล็อกอิน Google Account',
      description: 'ใช้ Gmail หรือ Google Account ที่มีอยู่ (ถ้ายังไม่มี สร้างฟรี)',
    );
  }

  Widget _buildStep3() {
    return _buildStepCard(
      stepNumber: 3,
      title: 'คลิก "Create API Key"',
      description: 'กดปุ่มสีน้ำเงิน "Create API Key"\nถ้าถามให้เลือก Project → กด "Create API key in new project"',
    );
  }

  Widget _buildStep4() {
    return _buildStepCard(
      stepNumber: 4,
      title: 'คัดลอก Key แล้วกลับมาวางด้านล่าง',
      description: 'กดปุ่ม Copy ข้างกล่อง Key ที่สร้างเสร็จ\nKey จะหน้าตาประมาณ: AIzaSyxxxx...',
    );
  }

  Widget _buildStep5KeyInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStepBadge(5),
            const SizedBox(width: 8),
            const Text('วาง API Key ที่นี่',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _keyController,
                obscureText: _obscureKey,
                decoration: InputDecoration(
                  hintText: 'วาง API Key ที่คัดลอกมา',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureKey ? Icons.visibility_off : Icons.visibility),
                    onPressed: () => setState(() => _obscureKey = !_obscureKey),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // ปุ่มวาง (Paste)
            IconButton.filled(
              onPressed: _pasteFromClipboard,
              icon: const Icon(Icons.content_paste),
              tooltip: 'วาง',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStepCard({
    required int stepNumber,
    required String title,
    required String description,
    Widget? child,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepBadge(stepNumber),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Text(description, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                if (child != null) ...[
                  const SizedBox(height: 8),
                  child,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepBadge(int number) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text('$number',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _saveKey,
        icon: _isLoading
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.save),
        label: const Text('บันทึก API Key'),
      ),
    );
  }

  Widget _buildTestButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: (_isTesting || !_hasKey) ? null : _testConnection,
        icon: _isTesting
            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.wifi_tethering),
        label: Text(_isTesting ? 'กำลังทดสอบ...' : 'ทดสอบการเชื่อมต่อ'),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton.icon(
        onPressed: _deleteKey,
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        label: const Text('ลบ API Key', style: TextStyle(color: Colors.red)),
      ),
    );
  }

  // ============ FAQ Section ============

  Widget _buildFAQ() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('คำถามที่พบบ่อย',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        _buildFaqItem(
          question: 'ฟรีจริงไหม?',
          answer: 'ฟรีจริง! Gemini 2.0 Flash ใช้ฟรี 1,500 ครั้ง/วัน\n'
              'สำหรับบันทึกอาหาร (5-15 ครั้ง/วัน) → ฟรีตลอด ไม่ต้องจ่ายเงิน',
        ),
        _buildFaqItem(
          question: 'ปลอดภัยไหม?',
          answer: 'API Key เก็บใน Secure Storage ในเครื่องเท่านั้น\n'
              'แอปไม่ส่ง Key ไปที่ server ของเรา\n'
              'ถ้า Key หลุด → ลบทิ้งสร้างใหม่ได้เลย (ไม่ใช่รหัสผ่าน Google)',
        ),
        _buildFaqItem(
          question: 'ถ้าไม่สร้าง Key ล่ะ?',
          answer: 'ยังใช้แอปได้! แต่:\n'
              '❌ ไม่สามารถถ่ายรูป → AI วิเคราะห์\n'
              '✅ บันทึกอาหารด้วยมือได้\n'
              '✅ Quick Add ได้\n'
              '✅ ดูสรุป kcal/macro ได้',
        ),
        _buildFaqItem(
          question: 'ต้องมีบัตรเครดิตไหม?',
          answer: 'ไม่ต้อง — สร้าง API Key ได้ฟรีโดยไม่ต้องใส่บัตรเครดิต',
        ),
      ],
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return ExpansionTile(
      title: Text(question, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 8, bottom: 12),
      children: [
        Text(answer, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
      ],
    );
  }

  // ============ Actions ============

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      setState(() => _keyController.text = data.text!);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _saveKey() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      _showSnackBar('กรุณาวาง API Key ก่อน', isError: true);
      return;
    }
    if (!key.startsWith('AIza')) {
      _showSnackBar('API Key ไม่ถูกต้อง — ต้องขึ้นต้นด้วย "AIza"', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      await SecureStorageService.saveApiKey(key);
      if (mounted) {
        setState(() {
          _hasKey = true;
          _isLoading = false;
        });
        _showSnackBar('บันทึก API Key เรียบร้อย');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar('เกิดข้อผิดพลาด: $e', isError: true);
      }
    }
  }

  Future<void> _testConnection() async {
    setState(() => _isTesting = true);
    try {
      final success = await GeminiService.testConnection();
      if (mounted) {
        _showSnackBar(success ? '✅ เชื่อมต่อสำเร็จ! พร้อมใช้งาน' : '❌ เชื่อมต่อไม่สำเร็จ',
            isError: !success);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('❌ $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _isTesting = false);
    }
  }

  Future<void> _deleteKey() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('ลบ API Key?'),
        content: const Text('จะไม่สามารถใช้ AI วิเคราะห์อาหารได้จนกว่าจะตั้งค่าใหม่'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('ยกเลิก')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('ลบ', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SecureStorageService.deleteApiKey();
      if (mounted) {
        setState(() {
          _keyController.clear();
          _hasKey = false;
        });
        _showSnackBar('ลบ API Key เรียบร้อย');
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }
}
```

> **หมายเหตุ:** โค้ดนี้เป็น template ให้ปรับตาม code style ของโปรเจค
> ถ้า SecureStorageService method ชื่อต่างจากนี้ ให้เปลี่ยนตามที่มีอยู่

---

### Step 3: Graceful Degradation — ไม่มี Key ก็ไม่ crash

#### 3.1 สร้าง helper function กลาง

เพิ่มใน `lib/core/ai/gemini_service.dart`:

```dart
/// แสดง Dialog แนะนำตั้งค่า API Key
static void showNoApiKeyDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.key_off, color: Colors.orange),
          SizedBox(width: 8),
          Text('ต้องการ API Key'),
        ],
      ),
      content: const Text(
        'การวิเคราะห์อาหารด้วย AI ต้องใช้ Gemini API Key\n\n'
        'สร้างฟรี! ใช้เวลาแค่ 5 นาที',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('ไว้ก่อน'),
        ),
        ElevatedButton.icon(
          onPressed: () {
            Navigator.pop(ctx);
            // Navigate ไปหน้า API Key
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ApiKeyScreen()),
            );
          },
          icon: const Icon(Icons.settings),
          label: const Text('ตั้งค่า API Key'),
        ),
      ],
    ),
  );
}
```

#### 3.2 เพิ่ม guard ในแต่ละจุดที่ใช้ Gemini

**ไฟล์ที่ต้องแก้ (ทำซ้ำ pattern เดียวกันทุกจุด):**

1. `food_preview_screen.dart` — ก่อนส่งรูปไปวิเคราะห์
2. `food_detail_bottom_sheet.dart` — ก่อนกดปุ่ม Gemini
3. `gemini_analysis_sheet.dart` — ก่อนเรียก Gemini
4. `intent_handler.dart` — ก่อน Gemini lookup

**Pattern (เหมือนกันทุกจุด):**

```dart
// ก่อนเรียก Gemini → เช็คว่ามี Key ไหม
final hasKey = await GeminiService.hasApiKey();
if (!hasKey) {
  if (mounted) {  // หรือ context.mounted
    GeminiService.showNoApiKeyDialog(context);
  }
  return; // หยุดไม่ทำต่อ
}

// ... เรียก Gemini ตามปกติ ...
```

**ตัวอย่างใน `food_preview_screen.dart`:**

หา method ที่เรียก Gemini วิเคราะห์รูป (อาจชื่อ `_analyzeImage()` หรือ `_sendToGemini()`)

```dart
Future<void> _analyzeImage() async {
  // === เพิ่มบรรทัดนี้ ===
  final hasKey = await GeminiService.hasApiKey();
  if (!hasKey) {
    if (mounted) GeminiService.showNoApiKeyDialog(context);
    return;
  }
  // === จบส่วนที่เพิ่ม ===

  setState(() => _isAnalyzing = true);
  try {
    // ... code เรียก Gemini เดิม ...
  } catch (e) {
    // ... error handling เดิม ...
  }
}
```

**ทำซ้ำ pattern นี้กับทุกไฟล์ที่เรียก Gemini**

---

### Step 4: เพิ่ม No-Key Banner ในหน้า Timeline

**ไฟล์:** `lib/features/health/presentation/health_timeline_tab.dart`
**Action:** EDIT

#### 4.1 เพิ่ม Banner widget

เพิ่ม method ใน class:

```dart
Widget _buildApiKeyBanner() {
  return FutureBuilder<bool>(
    future: GeminiService.hasApiKey(),
    builder: (context, snapshot) {
      // มี Key แล้ว → ไม่แสดง banner
      if (snapshot.data == true) return const SizedBox.shrink();

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            const Icon(Icons.smart_toy, color: Colors.blue, size: 28),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ตั้งค่า Gemini AI',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('เพื่อวิเคราะห์อาหารจากรูปถ่ายอัตโนมัติ',
                      style: TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ApiKeyScreen()),
                );
              },
              child: const Text('ตั้งค่า'),
            ),
          ],
        ),
      );
    },
  );
}
```

#### 4.2 เพิ่มใน build() ของ Timeline

หาตำแหน่งใน build method ที่เหมาะสม (เช่น ก่อน DailySummaryCard หรือหลัง):

```dart
// เพิ่มใน Column / ListView ของ Timeline
_buildApiKeyBanner(),  // ← เพิ่มบรรทัดนี้

// ... DailySummaryCard, QuickAddSection, etc. ...
```

---

## ✅ Checklist

### หลังทำเสร็จ ต้องตรวจสอบ:

- [ ] เปิดหน้า API Key → เห็นคู่มือ 5 ขั้นตอน
- [ ] กดปุ่ม "เปิด Google AI Studio" → เปิดเบราว์เซอร์ไปที่ aistudio.google.com/apikey
- [ ] กดปุ่ม "วาง" → วาง text จาก clipboard ลงในช่อง
- [ ] พิมพ์ Key ผิดรูปแบบ → แจ้ง "ต้องขึ้นต้นด้วย AIza"
- [ ] บันทึก Key → แสดง "บันทึกเรียบร้อย"
- [ ] กดทดสอบการเชื่อมต่อ (Key ถูก) → แสดง "เชื่อมต่อสำเร็จ"
- [ ] กดทดสอบ (Key ผิด) → แสดง "API Key ไม่ถูกต้อง"
- [ ] กดลบ Key → มี confirmation dialog → ลบสำเร็จ
- [ ] FAQ expand/collapse ทำงาน
- [ ] **ไม่มี Key** → ถ่ายรูปอาหาร → แสดง dialog "ต้องการ API Key" (ไม่ crash)
- [ ] **ไม่มี Key** → แชท "กินข้าวผัด" → ใช้ local DB (ไม่ crash)
- [ ] **ไม่มี Key** → เพิ่มอาหารด้วยมือ → ทำงานปกติ
- [ ] หน้า Timeline → เห็น Banner "ตั้งค่า Gemini AI" → กดแล้วไปหน้า API Key
- [ ] หน้า Timeline → ตั้ง Key แล้ว → Banner หายไป

---

## 🔍 Troubleshooting

### Q: ปุ่ม "เปิด Google AI Studio" ไม่ทำงาน
**สาเหตุ:** ยังไม่มี `url_launcher` dependency
**แก้:** ตรวจ `pubspec.yaml` ว่ามี `url_launcher` อยู่

### Q: testConnection() timeout ตลอด
**สาเหตุ:** อาจไม่มี internet หรือ Gemini ช้า
**แก้:** เพิ่ม timeout เป็น 15 วินาที

### Q: SecureStorageService ไม่มี method deleteApiKey()
**สาเหตุ:** อาจยังไม่ได้สร้าง
**แก้:** เพิ่มใน `secure_storage_service.dart`:
```dart
static Future<void> deleteApiKey() async {
  final storage = FlutterSecureStorage();
  await storage.delete(key: 'gemini_api_key');
}
```

---

## 🎉 เสร็จแล้ว! ไปต่อ Step 31 →

ไปทำ **Step 31: Freemium + In-App Purchase** ได้เลย
