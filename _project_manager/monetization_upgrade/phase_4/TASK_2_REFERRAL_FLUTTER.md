# Phase 4 - Task 2: Referral UI (Flutter)

**Status:** 📝 Ready for Implementation  
**Estimated Time:** 4-6 hours  
**Difficulty:** ⭐⭐⭐ Medium  
**Prerequisites:** Task 1 (Referral Backend) must be completed

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Requirements](#requirements)
3. [UI Design](#ui-design)
4. [Step-by-Step Implementation](#step-by-step-implementation)
5. [Testing](#testing)
6. [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

สร้าง UI สำหรับ Referral System ใน Flutter:

**Features:**
- แสดง MiRO ID ของ user (= referral code)
- ปุ่ม Copy และ Share code
- แสดง referral quota (X/2 this month)
- Form สำหรับใส่ referral code
- แสดง success/error messages

---

## 📊 Requirements

### Functional Requirements
- [ ] แสดง MiRO ID ของ user (referral code)
- [ ] Copy to clipboard
- [ ] Share via native share dialog
- [ ] Form สำหรับใส่ referral code
- [ ] Submit code และแสดงผล
- [ ] แสดง quota ที่ใช้ไปแล้ว
- [ ] แสดง list ของคนที่ refer สำเร็จ

### Non-Functional Requirements
- [ ] UI สวยงาม ใช้งานง่าย
- [ ] Loading states
- [ ] Error handling
- [ ] Responsive

---

## 🎨 UI Design

### Referral Screen

```
┌────────────────────────────────────┐
│  ← Invite Friends              ⚡50│
├────────────────────────────────────┤
│                                    │
│  🤝 Share Your Code                │
│                                    │
│  ┌──────────────────────────────┐  │
│  │  Your Referral Code:         │  │
│  │                              │  │
│  │  ╔════════════════════════╗  │  │
│  │  ║ MIRO-A3F9-K7X2-P8M1  ║  │  │
│  │  ╚════════════════════════╝  │  │
│  │                              │  │
│  │  ┌─────────────┐  ┌────────┐ │  │
│  │  │ 📋 Copy    │  │ 📤 Share│ │  │
│  │  └─────────────┘  └────────┘ │  │
│  └──────────────────────────────┘  │
│                                    │
│  ┌──────────────────────────────┐  │
│  │  💰 Earn 15 Energy           │  │
│  │  When your friend uses       │  │
│  │  AI 3 times!                 │  │
│  │                              │  │
│  │  This month: 1/2 invited     │  │
│  └──────────────────────────────┘  │
│                                    │
│  ─────────────────────────────────│
│                                    │
│  📝 Enter a Referral Code          │
│                                    │
│  ┌──────────────────────────────┐  │
│  │  Enter code...               │  │
│  └──────────────────────────────┘  │
│                                    │
│  [ Submit Code ]                   │
│                                    │
│  ⚠️ You can only submit a code     │
│     within 24 hours of signing up  │
│                                    │
└────────────────────────────────────┘
```

---

## 🚀 Step-by-Step Implementation

### Step 1: Create Referral Screen

#### 1.1 Create File

**File:** `lib/features/referral/presentation/referral_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/referral_provider.dart';
import '../../../core/services/referral_service.dart';

class ReferralScreen extends ConsumerStatefulWidget {
  const ReferralScreen({super.key});

  @override
  ConsumerState<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends ConsumerState<ReferralScreen> {
  final _codeController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📋 Referral code copied!'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _shareCode(String code) async {
    final message = '''
🔥 Join me on MiRO!

Use my referral code to get +5 Energy bonus:
$code

Download: [Your App Store Link]
''';

    await Share.share(message, subject: 'Join MiRO and get free Energy!');
  }

  Future<void> _submitCode() async {
    final code = _codeController.text.trim().toUpperCase();

    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Please enter a code')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await ref.read(referralServiceProvider).submitReferralCode(code);

      if (mounted) {
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('🎉 ${result.message}'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
            ),
          );
          _codeController.clear();
          
          // Refresh referral data
          ref.invalidate(referralDataProvider);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${result.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final referralData = ref.watch(referralDataProvider);
    final myCode = referralData.value?.myCode ?? '...';
    final quota = referralData.value?.quota ?? 0;
    final canSubmitCode = referralData.value?.canSubmitCode ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Invite Friends'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Share Your Code Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      '🤝 Share Your Code',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your Referral Code:',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        myCode,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: Colors.blue.shade900,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _copyCode(myCode),
                            icon: const Icon(Icons.copy),
                            label: const Text('Copy'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _shareCode(myCode),
                            icon: const Icon(Icons.share),
                            label: const Text('Share'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Reward Info Card
            Card(
              elevation: 2,
              color: Colors.green.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      '💰 Earn 15 Energy',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'When your friend uses AI 3 times!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'This month: $quota/2 invited',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Divider
            const Divider(),

            const SizedBox(height: 24),

            // Enter Code Section
            if (canSubmitCode) ...[
              const Text(
                '📝 Enter a Referral Code',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _codeController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'MIRO-XXXX-XXXX-XXXX',
                  prefixIcon: const Icon(Icons.qr_code),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitCode,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Submit Code',
                          style: TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You can only submit a code within 24 hours of signing up',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(Icons.check_circle, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 12),
                    Text(
                      'You\'ve already used a referral code',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

### Step 2: Create Referral Service

#### 2.1 Create Service

**File:** `lib/core/services/referral_service.dart`

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'device_id_service.dart';
import '../config/firebase_config.dart';

final referralServiceProvider = Provider((ref) {
  return ReferralService(
    deviceIdService: ref.read(deviceIdServiceProvider),
  );
});

class ReferralService {
  final DeviceIdService deviceIdService;

  ReferralService({required this.deviceIdService});

  Future<ReferralSubmitResult> submitReferralCode(String code) async {
    try {
      final deviceId = await deviceIdService.getDeviceId();
      
      final response = await http.post(
        Uri.parse('${FirebaseConfig.functionsUrl}/submitReferralCode'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'deviceId': deviceId,
          'referralCode': code,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return ReferralSubmitResult(
          success: true,
          message: data['message'] ?? 'Referral code accepted!',
          bonusEnergy: data['bonusEnergy'] ?? 0,
        );
      } else {
        return ReferralSubmitResult(
          success: false,
          error: data['error'] ?? 'Failed to submit code',
        );
      }
    } catch (e) {
      return ReferralSubmitResult(
        success: false,
        error: 'Network error: $e',
      );
    }
  }
}

class ReferralSubmitResult {
  final bool success;
  final String? message;
  final String? error;
  final int? bonusEnergy;

  ReferralSubmitResult({
    required this.success,
    this.message,
    this.error,
    this.bonusEnergy,
  });
}
```

---

### Step 3: Create Referral Provider

#### 3.1 Create Provider

**File:** `lib/features/referral/providers/referral_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/device_id_service.dart';

final referralDataProvider = FutureProvider<ReferralData>((ref) async {
  final deviceId = await ref.read(deviceIdServiceProvider).getDeviceId();
  
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(deviceId)
      .get();

  if (!doc.exists) {
    throw Exception('User not found');
  }

  final data = doc.data()!;
  final referrals = data['referrals'] as Map<String, dynamic>? ?? {};
  final createdAt = (data['createdAt'] as Timestamp?)?.toDate();

  // เช็คว่าสามารถใส่ code ได้หรือไม่ (ภายใน 24 ชม.)
  final canSubmitCode = referrals['referredBy'] == null &&
      createdAt != null &&
      DateTime.now().difference(createdAt).inHours < 24;

  return ReferralData(
    myCode: data['miroId'] ?? '',
    quota: referrals['referralCount'] ?? 0,
    referredUsers: List<String>.from(referrals['referredUsers'] ?? []),
    canSubmitCode: canSubmitCode,
    referredBy: referrals['referredBy'],
  );
});

class ReferralData {
  final String myCode;
  final int quota;
  final List<String> referredUsers;
  final bool canSubmitCode;
  final String? referredBy;

  ReferralData({
    required this.myCode,
    required this.quota,
    required this.referredUsers,
    required this.canSubmitCode,
    this.referredBy,
  });
}
```

---

### Step 4: Add Dependencies

#### 4.1 Update pubspec.yaml

```yaml
dependencies:
  share_plus: ^7.2.1
```

#### 4.2 Install

```bash
flutter pub get
```

---

### Step 5: Add Route

#### 5.1 Update Navigation

ใน Profile Screen หรือ Home Screen เพิ่มปุ่ม "Invite Friends":

```dart
ListTile(
  leading: const Icon(Icons.people),
  title: const Text('Invite Friends'),
  subtitle: const Text('Earn 15 Energy per friend'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReferralScreen()),
    );
  },
),
```

---

## 🧪 Testing

### Step 1: Manual Testing

1. เปิดหน้า Referral Screen
2. ตรวจสอบว่า MiRO ID แสดงถูกต้อง
3. กด Copy → clipboard ควรมี code
4. กด Share → native share dialog ควรเปิด
5. ใส่ referral code ที่ถูกต้อง → ควรได้ +5 Energy
6. ใส่ referral code ที่ผิด → ควรแสดง error
7. ใส่ referral code ตัวเอง → ควรแสดง error "Cannot refer yourself"

### Step 2: Edge Cases

- [ ] User ที่สมัครเกิน 24 ชม. → ไม่แสดง form
- [ ] User ที่ใส่ code แล้ว → แสดง "Already used code"
- [ ] Quota เต็ม (2/2) → แสดงสถานะ
- [ ] Network error → แสดง error message

---

## 🐛 Troubleshooting

### Issue: MiRO ID ไม่แสดง

**Solution:**
```dart
// ตรวจสอบว่า miroId มีใน Firestore
final data = await FirebaseFirestore.instance
    .collection('users')
    .doc(deviceId)
    .get();
print('User data: ${data.data()}');
```

### Issue: Share ไม่ทำงาน

**Solution:**
- ตรวจสอบว่าติดตั้ง `share_plus` แล้ว
- บน iOS: ต้อง config Info.plist
- ทดสอบบน real device (emulator อาจไม่ work)

### Issue: Submit code failed

**Solution:**
```dart
// Check response
print('Status code: ${response.statusCode}');
print('Response body: ${response.body}');
```

---

## ✅ Completion Checklist

- [ ] ReferralScreen แสดงผลถูกต้อง
- [ ] Copy code ทำงาน
- [ ] Share code ทำงาน
- [ ] Submit code ทำงาน
- [ ] Error handling ครบ
- [ ] Loading states ทำงาน
- [ ] UI responsive บนทุก screen size
- [ ] Test บน Android และ iOS

---

## 🚀 Next Steps

After completing this task:
1. Test with real users
2. Monitor referral metrics
3. Move to **Task 3: Comeback Bonus**

---

**Documentation Version:** 1.0  
**Last Updated:** 2026-02-17  
**Author:** Senior Developer  
**For:** Junior Developer