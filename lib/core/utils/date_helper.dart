import 'package:intl/intl.dart';

/// Helper สำหรับ format วันที่ตาม locale
class DateHelper {
  /// วันที่สั้น (เช่น "7 ก.พ." หรือ "Feb 7")
  static String shortDate(DateTime date, String locale) {
    return DateFormat.MMMd(locale).format(date);
  }

  /// วันที่เต็ม (เช่น "7 ก.พ. 2026" หรือ "Feb 7, 2026")
  static String fullDate(DateTime date, String locale) {
    return DateFormat.yMMMd(locale).format(date);
  }

  /// เวลา (เช่น "14:30")
  static String time(DateTime date, String locale) {
    return DateFormat.Hm(locale).format(date);
  }

  /// วันในสัปดาห์ (เช่น "จ" หรือ "Mon")
  static String dayOfWeek(DateTime date, String locale) {
    return DateFormat.E(locale).format(date);
  }

  /// วันและเดือน (เช่น "7 ก.พ." หรือ "Feb 7")
  static String dayMonth(DateTime date, String locale) {
    return DateFormat.MMMd(locale).format(date);
  }

  /// ปี เดือน วัน (เช่น "2026-02-11")
  static String isoDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
