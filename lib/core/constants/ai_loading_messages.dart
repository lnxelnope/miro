/// Technical loading messages for AI analysis
/// Makes the process feel sophisticated and justifies the 1 Energy cost
class AILoadingMessages {
  // ===== CONST MESSAGES (for const contexts) =====

  /// Image analysis
  static const String imageProcessing = 'PROCESSING IMAGE DATA...';
  static const String imageDetecting = 'DETECTING FOOD ITEMS...';
  static const String imageAnalyzing = 'ANALYZING COMPOSITION...';
  static const String imageCalculating = 'CALCULATING CALORIES...';
  static const String imageComputing = 'COMPUTING NUTRITION VALUES...';
  static const String imageFinalizing = 'FINALIZING RESULTS...';

  /// Barcode analysis
  static const String barcodeReading = 'READING BARCODE DATA...';
  static const String barcodeFetching = 'FETCHING PRODUCT INFO...';
  static const String barcodeAnalyzing = 'ANALYZING NUTRITION LABEL...';
  static const String barcodeProcessing = 'PROCESSING INGREDIENTS...';
  static const String barcodeCalculating = 'CALCULATING VALUES...';
  static const String barcodePreparing = 'PREPARING RESULTS...';

  /// Text analysis
  static const String textParsing = 'PARSING FOOD NAME...';
  static const String textIdentifying = 'IDENTIFYING INGREDIENTS...';
  static const String textAnalyzing = 'ANALYZING COMPOSITION...';
  static const String textEstimating = 'ESTIMATING NUTRIENTS...';
  static const String textComputing = 'COMPUTING MACROS...';
  static const String textFinalizing = 'FINALIZING DATA...';

  /// Generic
  static const String analyzing = 'ANALYZING...';
  static const String processing = 'PROCESSING...';
  static const String calculating = 'CALCULATING NUTRITION...';
  static const String subtitle = 'Processing advanced nutrition analysis';

  // ===== LISTS (for dynamic/animated contexts) =====

  static const List<String> imageAnalysisSteps = [
    imageProcessing,
    imageDetecting,
    imageAnalyzing,
    imageCalculating,
    imageComputing,
    imageFinalizing,
  ];

  static const List<String> barcodeSteps = [
    barcodeReading,
    barcodeFetching,
    barcodeAnalyzing,
    barcodeProcessing,
    barcodeCalculating,
    barcodePreparing,
  ];

  static const List<String> textAnalysisSteps = [
    textParsing,
    textIdentifying,
    textAnalyzing,
    textEstimating,
    textComputing,
    textFinalizing,
  ];

  // ===== HELPER METHODS (for animated loading) =====

  /// Get message for image analysis (by step index)
  static String getImageMessage(int step) {
    return imageAnalysisSteps[step % imageAnalysisSteps.length];
  }

  /// Get message for barcode analysis (by step index)
  static String getBarcodeMessage(int step) {
    return barcodeSteps[step % barcodeSteps.length];
  }

  /// Get message for text analysis (by step index)
  static String getTextMessage(int step) {
    return textAnalysisSteps[step % textAnalysisSteps.length];
  }

  /// Get a random analysis message
  static String getRandomMessage() {
    final allMessages = [
      ...imageAnalysisSteps,
      ...barcodeSteps,
      ...textAnalysisSteps,
    ];
    return allMessages[DateTime.now().millisecond % allMessages.length];
  }
}
