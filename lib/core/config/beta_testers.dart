/// Configuration สำหรับระบุ Beta Testers
///
/// ⚠️ CURRENT STRATEGY: ไม่ได้ใช้ตอนนี้!
/// - ช่วง beta: ทุกคนได้ 1,000 Energy (ตั้งค่าใน energy_service.dart)
/// - Production: เปลี่ยนเป็น 10 Energy สำหรับ launch
///
/// ⚠️ ไฟล์นี้เก็บไว้สำหรับอนาคต (ถ้าต้องการแยก beta testers)
class BetaTesters {
  /// รายชื่อ email ของ beta testers ทั้งหมด
  ///
  /// ⚠️ ตอนนี้ไม่ได้ใช้ เพราะใช้วิธี "เปลี่ยน welcome gift เป็น 1000 ชั่วคราว" แทน
  ///
  /// วิธีเพิ่มรายชื่อ (สำหรับอนาคต):
  /// 1. เข้า Google Play Console → Testing → Internal testing
  /// 2. เลือก track "miro-tester" (หรือ track ที่คุณสร้างไว้)
  /// 3. กด "Testers" tab → คัดลอก email addresses
  /// 4. Paste เข้ามาในนี้ (format: 'email@example.com',)
  ///
  /// **หรือใช้วิธีนี้:**
  /// 1. เข้า Firebase Console → Authentication → Users
  /// 2. Export users → คัดลอก email ของ beta testers
  /// 3. Paste เข้ามาในนี้
  static const List<String> emails = [
    // ตัวอย่าง:
    // 'john.doe@gmail.com',
    // 'beta.tester@example.com',
    // 'tester123@hotmail.com',

    // ⚠️ ตอนนี้ไม่จำเป็นต้องเพิ่ม (ใช้วิธี welcome gift 1000 แทน)
  ];

  /// ตรวจสอบว่า email นี้เป็น beta tester หรือไม่
  ///
  /// Returns: true ถ้าเป็น beta tester, false ถ้าไม่ใช่
  static bool isBetaTester(String? email) {
    if (email == null || email.isEmpty) return false;

    // Case-insensitive comparison (อีเมลไม่สนใจตัวพิมพ์ใหญ่/เล็ก)
    final normalizedEmail = email.trim().toLowerCase();
    return emails
        .any((testerEmail) => testerEmail.toLowerCase() == normalizedEmail);
  }

  /// สำหรับ debug: ดูว่าตัวเองเป็น beta tester หรือไม่
  static void printStatus(String? userEmail) {
    if (isBetaTester(userEmail)) {
      print('🌟 Beta Tester detected: $userEmail');
    } else {
      print('👤 Regular User: $userEmail');
    }
  }

  /// ดึงจำนวน beta testers ทั้งหมด
  static int get totalCount => emails.length;
}
