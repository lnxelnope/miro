/// AI mode สำหรับ Chat System
/// - local: ใช้ Local AI (ฟรี, อังกฤษอย่างเดียว, ความแม่นยำต่ำ)
/// - miroAi: ใช้ Miro AI (2⚡ base + 1⚡ per item, ทุกภาษา, ความแม่นยำสูง)
enum ChatAiMode {
  /// Local AI — Free, English only, Regex-based
  local,
  
  /// Miro AI — 2⚡ base + 1⚡/item, Multi-language, Gemini-powered
  miroAi;

  /// Display name สำหรับแสดงใน UI
  String get displayName {
    switch (this) {
      case ChatAiMode.local:
        return 'Local AI';
      case ChatAiMode.miroAi:
        return 'Miro AI';
    }
  }

  /// Description สำหรับแสดงใน UI
  String get description {
    switch (this) {
      case ChatAiMode.local:
        return 'Free • EN only';
      case ChatAiMode.miroAi:
        return '2⚡ + 1⚡/item';
    }
  }

  /// Icon สำหรับแสดงใน UI
  String get icon {
    switch (this) {
      case ChatAiMode.local:
        return '🧠';
      case ChatAiMode.miroAi:
        return '⚡';
    }
  }

  /// ว่าใช้ Energy หรือไม่
  bool get requiresEnergy {
    return this == ChatAiMode.miroAi;
  }
}
