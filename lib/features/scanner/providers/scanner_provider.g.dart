// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanner_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scanControllerHash() => r'550173420bbc5587381c8709766a9e51b3089527';

/// Provider สำหรับ ScanController
/// ใช้สำหรับสแกนรูปจาก Gallery
///
/// Copied from [scanController].
@ProviderFor(scanController)
final scanControllerProvider = AutoDisposeProvider<ScanController>.internal(
  scanController,
  name: r'scanControllerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scanControllerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ScanControllerRef = AutoDisposeProviderRef<ScanController>;
String _$permissionServiceHash() => r'8944118369fdc2dd355a221dd4f8a487b7f3372c';

/// Provider สำหรับ PermissionService
///
/// Copied from [permissionService].
@ProviderFor(permissionService)
final permissionServiceProvider =
    AutoDisposeProvider<PermissionService>.internal(
  permissionService,
  name: r'permissionServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$permissionServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PermissionServiceRef = AutoDisposeProviderRef<PermissionService>;
String _$galleryScanNotifierHash() =>
    r'c0c49239b555e6345127dbfb6e06c11160246b75';

/// Provider สำหรับสแกนรูปทั้งหมดใน Gallery
/// return จำนวนรูปที่สแกนได้
///
/// Copied from [GalleryScanNotifier].
@ProviderFor(GalleryScanNotifier)
final galleryScanNotifierProvider =
    AutoDisposeNotifierProvider<GalleryScanNotifier, AsyncValue<int>>.internal(
  GalleryScanNotifier.new,
  name: r'galleryScanNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$galleryScanNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$GalleryScanNotifier = AutoDisposeNotifier<AsyncValue<int>>;
String _$singleImagePickerHash() => r'a84a0c43e94c017e319e951ab0699be4064ef684';

/// Provider สำหรับเลือกรูปเดียวจาก Gallery
///
/// Copied from [SingleImagePicker].
@ProviderFor(SingleImagePicker)
final singleImagePickerProvider = AutoDisposeNotifierProvider<SingleImagePicker,
    AsyncValue<ScanResult?>>.internal(
  SingleImagePicker.new,
  name: r'singleImagePickerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$singleImagePickerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$SingleImagePicker = AutoDisposeNotifier<AsyncValue<ScanResult?>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
