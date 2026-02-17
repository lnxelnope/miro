/// Configuration สำหรับ Firebase Cloud Functions URLs
class FirebaseConfig {
  /// Base URL สำหรับ Firebase Functions
  static const String functionsUrl =
      'https://us-central1-miro-d6856.cloudfunctions.net';

  /// URL สำหรับ analyzeFood function (รองรับทั้ง photo และ chat)
  static const String analyzeFoodUrl =
      'https://us-central1-miro-d6856.cloudfunctions.net/analyzeFood';
}
