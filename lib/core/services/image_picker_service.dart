import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  // Pick from camera
  static Future<File?> pickFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  // Pick from gallery
  static Future<File?> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (image != null) {
      return File(image.path);
    }
    return null;
  }

  // Pick multiple from gallery
  static Future<List<File>> pickMultipleFromGallery() async {
    final List<XFile> images = await _picker.pickMultiImage(
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    return images.map((xFile) => File(xFile.path)).toList();
  }
}
