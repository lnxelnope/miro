import 'package:flutter/foundation.dart';
import '../../../core/utils/logger.dart';

/// Service สำหรับ parse QR Code และ OCR text จากสลิป
class QRParser {
  // ========== PromptPay QR Decoder ==========

  /// Parse PromptPay QR Code (EMVCo format)
  /// Format: 00020101021129370016A000000677010111...
  Map<String, dynamic>? parsePromptPayQR(String rawValue) {
    // ตรวจสอบว่าเป็น EMVCo QR หรือไม่
    if (!rawValue.startsWith('00020101')) {
      debugPrint('Not EMVCo QR: ${rawValue.substring(0, 20)}...');
      return null;
    }

    try {
      final result = <String, dynamic>{'type': 'promptpay'};
      int pos = 0;

      while (pos < rawValue.length - 4) {
        // ป้องกัน out of range
        if (pos + 4 > rawValue.length) break;

        final tag = rawValue.substring(pos, pos + 2);
        final lengthStr = rawValue.substring(pos + 2, pos + 4);
        final length = int.tryParse(lengthStr);

        if (length == null || pos + 4 + length > rawValue.length) break;

        final value = rawValue.substring(pos + 4, pos + 4 + length);

        switch (tag) {
          case '00': // Payload Format Indicator
            result['format'] = value;
            break;
          case '01': // Point of Initiation
            result['poi'] = value;
            break;
          case '29': // PromptPay Merchant (National)
          case '30': // PromptPay Merchant (Cross-border)
            final subData = _parsePromptPaySubTags(value);
            result['merchant_data'] = subData;
            if (subData['phone'] != null) {
              result['phone'] = subData['phone'];
            }
            if (subData['national_id'] != null) {
              result['national_id'] = subData['national_id'];
            }
            break;
          case '53': // Currency (764 = THB)
            result['currency'] = value;
            break;
          case '54': // Amount
            result['amount'] = double.tryParse(value);
            break;
          case '58': // Country Code (TH)
            result['country'] = value;
            break;
          case '59': // Merchant Name
            result['merchant_name'] = value;
            break;
          case '60': // City
            result['city'] = value;
            break;
          case '62': // Additional Data
            result['additional_data'] = value;
            break;
          case '63': // CRC (Checksum)
            result['crc'] = value;
            break;
        }

        pos += 4 + length;
      }

      AppLogger.info('Parsed PromptPay QR: $result');
      return result;
    } catch (e) {
      debugPrint('❌ PromptPay parse error: $e');
      return null;
    }
  }

  /// Parse sub-tags ใน PromptPay data (tag 29/30)
  Map<String, String?> _parsePromptPaySubTags(String data) {
    final result = <String, String?>{
      'phone': null,
      'national_id': null,
      'ewallet_id': null,
    };

    try {
      int pos = 0;

      while (pos < data.length - 4) {
        if (pos + 4 > data.length) break;

        final tag = data.substring(pos, pos + 2);
        final lengthStr = data.substring(pos + 2, pos + 4);
        final length = int.tryParse(lengthStr);

        if (length == null || pos + 4 + length > data.length) break;

        final value = data.substring(pos + 4, pos + 4 + length);

        switch (tag) {
          case '00': // AID (A000000677010111 = PromptPay)
            // Skip
            break;
          case '01': // Mobile number
            // Format: 0066812345678 → 0812345678
            if (value.startsWith('0066')) {
              result['phone'] = '0${value.substring(4)}';
            } else if (value.startsWith('66')) {
              result['phone'] = '0${value.substring(2)}';
            } else {
              result['phone'] = value;
            }
            break;
          case '02': // National ID
            result['national_id'] = value;
            break;
          case '03': // E-Wallet ID
            result['ewallet_id'] = value;
            break;
        }

        pos += 4 + length;
      }
    } catch (e) {
      AppLogger.error('Sub-tag parse error', e);
    }

    return result;
  }

  // ========== OCR Slip Text Extraction ==========

  /// ดึงข้อมูลจาก OCR text ของสลิป
  Map<String, dynamic> extractFromSlipText(String text) {
    final result = <String, dynamic>{
      'type': 'finance',
      'category': 'uncategorized',
    };

    // Clean text
    final cleanText = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    // 1. ดึงจำนวนเงิน
    final amount = _extractAmount(cleanText);
    if (amount != null) {
      result['amount'] = amount;
    }

    // 2. ดึงวันที่
    final date = _extractDate(cleanText);
    if (date != null) {
      result['date'] = date;
    }

    // 3. ดึงชื่อผู้รับ
    final receiver = _extractReceiver(cleanText);
    if (receiver != null) {
      result['receiver'] = receiver;
    }

    // 4. ตรวจสอบ merchant และกำหนด category
    final merchantInfo = _detectMerchant(cleanText);
    if (merchantInfo != null) {
      result['receiver'] = merchantInfo['name'];
      result['category'] = merchantInfo['category'];
    }

    // 5. ตรวจสอบประเภทธุรกรรม
    final transactionType = _detectTransactionType(cleanText);
    if (transactionType != null) {
      result['transaction_type'] = transactionType;
    }

    AppLogger.info('Extracted from slip: $result');
    return result;
  }

  /// ดึงจำนวนเงิน
  double? _extractAmount(String text) {
    // Patterns ต่างๆ สำหรับจำนวนเงินในสลิปไทย
    final patterns = [
      // "Amount: 1,234.56" or "จำนวน 1,234.56"
      RegExp(r'(?:Amount|จำนวน|ยอด)[:\s]*([\d,]+\.?\d*)', caseSensitive: false),
      // "THB 1,234.56" or "฿1,234.56"
      RegExp(r'(?:THB|฿)\s*([\d,]+\.?\d*)', caseSensitive: false),
      // "1,234.56 บาท"
      RegExp(r'([\d,]+\.\d{2})\s*(?:บาท|THB|฿)', caseSensitive: false),
      // Standalone amount with 2 decimal places
      RegExp(r'\b([\d,]+\.\d{2})\b'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        String raw = match.group(1)!.replaceAll(',', '');
        final amount = double.tryParse(raw);
        // Filter unreasonable amounts
        if (amount != null && amount > 0 && amount < 10000000) {
          return amount;
        }
      }
    }

    return null;
  }

  /// ดึงวันที่
  String? _extractDate(String text) {
    // Pattern: DD/MM/YYYY, DD-MM-YYYY, DD.MM.YYYY
    final patterns = [
      RegExp(r'(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{2,4})'),
      // Thai Buddhist year: 03/02/2567
      RegExp(r'(\d{1,2})[/\-.](\d{1,2})[/\-.](\d{4})'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final day = match.group(1)!.padLeft(2, '0');
        final month = match.group(2)!.padLeft(2, '0');
        var year = match.group(3)!;

        // Convert Buddhist year to CE
        if (year.length == 4) {
          final yearNum = int.parse(year);
          if (yearNum > 2500) {
            year = (yearNum - 543).toString();
          }
        } else if (year.length == 2) {
          year = '20$year';
        }

        return '$day/$month/$year';
      }
    }

    return null;
  }

  /// ดึงชื่อผู้รับ
  String? _extractReceiver(String text) {
    final patterns = [
      // "To: Name" or "ไปยัง: Name"
      RegExp(r'(?:To|ไปยัง|ผู้รับ|Receiver)[:\s]+([ก-๙a-zA-Z\s\.]+)',
          caseSensitive: false),
      // "Name: ..." หลัง To/Receiver
      RegExp(r'(?:Name|ชื่อ)[:\s]+([ก-๙a-zA-Z\s\.]+)', caseSensitive: false),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        final name = match.group(1)!.trim();
        // Filter noise
        if (name.length > 2 && name.length < 50) {
          return name;
        }
      }
    }

    return null;
  }

  /// ตรวจหา merchant ที่รู้จัก
  Map<String, String>? _detectMerchant(String text) {
    final lowerText = text.toLowerCase();

    // Known merchants with categories
    final merchants = {
      // Food & Drink
      'starbucks': {'name': 'Starbucks', 'category': 'Food'},
      'mcdonald': {'name': 'McDonald\'s', 'category': 'Food'},
      'kfc': {'name': 'KFC', 'category': 'Food'},
      'pizza': {'name': 'Pizza', 'category': 'Food'},
      'sizzler': {'name': 'Sizzler', 'category': 'Food'},
      'bar b q': {'name': 'Bar-B-Q Plaza', 'category': 'Food'},
      'ส้มตำ': {'name': 'ส้มตำ', 'category': 'Food'},
      'cafe': {'name': 'Cafe', 'category': 'Food'},
      
      // Convenience Stores
      '7-eleven': {'name': '7-Eleven', 'category': 'Convenience'},
      'eleven': {'name': '7-Eleven', 'category': 'Convenience'},
      'family mart': {'name': 'FamilyMart', 'category': 'Convenience'},
      'familymart': {'name': 'FamilyMart', 'category': 'Convenience'},
      'lawson': {'name': 'Lawson', 'category': 'Convenience'},
      'cj more': {'name': 'CJ More', 'category': 'Convenience'},
      
      // Grocery & Supermarket
      'lotus': {'name': 'Lotus\'s', 'category': 'Grocery'},
      'big c': {'name': 'Big C', 'category': 'Grocery'},
      'makro': {'name': 'Makro', 'category': 'Grocery'},
      'tops': {'name': 'Tops', 'category': 'Grocery'},
      'gourmet': {'name': 'Gourmet Market', 'category': 'Grocery'},
      'villa': {'name': 'Villa Market', 'category': 'Grocery'},
      
      // Transport
      'grab': {'name': 'Grab', 'category': 'Transport'},
      'bolt': {'name': 'Bolt', 'category': 'Transport'},
      'lineman': {'name': 'LINE MAN', 'category': 'Transport'},
      'bts': {'name': 'BTS', 'category': 'Transport'},
      'mrt': {'name': 'MRT', 'category': 'Transport'},
      'airport': {'name': 'Airport', 'category': 'Transport'},
      
      // Utilities & Bills
      'true': {'name': 'True', 'category': 'Bills'},
      'ais': {'name': 'AIS', 'category': 'Bills'},
      'dtac': {'name': 'DTAC', 'category': 'Bills'},
      'pea': {'name': 'การไฟฟ้า', 'category': 'Bills'},
      'mwa': {'name': 'การประปา', 'category': 'Bills'},
      'mea': {'name': 'การไฟฟ้านครหลวง', 'category': 'Bills'},
      
      // Transfer & Banks
      'kbank': {'name': 'KBank', 'category': 'Transfer'},
      'scb': {'name': 'SCB', 'category': 'Transfer'},
      'bbl': {'name': 'Bangkok Bank', 'category': 'Transfer'},
      'ktb': {'name': 'Krungthai', 'category': 'Transfer'},
      'ttb': {'name': 'TTB', 'category': 'Transfer'},
      'line pay': {'name': 'LINE Pay', 'category': 'Transfer'},
      'truemoney': {'name': 'TrueMoney', 'category': 'Transfer'},
      
      // Shopping
      'lazada': {'name': 'Lazada', 'category': 'Shopping'},
      'shopee': {'name': 'Shopee', 'category': 'Shopping'},
      'central': {'name': 'Central', 'category': 'Shopping'},
      'robinson': {'name': 'Robinson', 'category': 'Shopping'},
      'uniqlo': {'name': 'Uniqlo', 'category': 'Shopping'},
      'h&m': {'name': 'H&M', 'category': 'Shopping'},
    };

    for (final entry in merchants.entries) {
      if (lowerText.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  /// ตรวจสอบประเภทธุรกรรม
  String? _detectTransactionType(String text) {
    final lowerText = text.toLowerCase();

    if (lowerText.contains('transfer') || lowerText.contains('โอน')) {
      return 'transfer';
    }
    if (lowerText.contains('payment') || lowerText.contains('ชำระ')) {
      return 'payment';
    }
    if (lowerText.contains('top up') || lowerText.contains('เติมเงิน')) {
      return 'topup';
    }
    if (lowerText.contains('withdraw') || lowerText.contains('ถอน')) {
      return 'withdraw';
    }

    return null;
  }
}
