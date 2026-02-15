import 'dart:io';

/// Request model for image analysis with optional user inputs
class ImageAnalysisRequest {
  final File imageFile;
  final String? foodName;
  final double? quantity;
  final String? unit;

  const ImageAnalysisRequest({
    required this.imageFile,
    this.foodName,
    this.quantity,
    this.unit,
  });

  /// Creates a copy with updated fields
  ImageAnalysisRequest copyWith({
    File? imageFile,
    String? foodName,
    double? quantity,
    String? unit,
  }) {
    return ImageAnalysisRequest(
      imageFile: imageFile ?? this.imageFile,
      foodName: foodName ?? this.foodName,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
    );
  }
}
