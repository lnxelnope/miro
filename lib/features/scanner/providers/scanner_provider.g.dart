// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scanner_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scanControllerHash() => r'e8596600064d6cdcd6affc9e6d650d1dde8676bc';

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

typedef ScanControllerRef = AutoDisposeProviderRef<ScanController>;
String _$permissionServiceHash() => r'19b92322798ea7fd375e96ef01c7cc2626892ad5';

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

typedef PermissionServiceRef = AutoDisposeProviderRef<PermissionService>;
String _$galleryScanNotifierHash() =>
    r'96c072098d4499ba4c04adccd09dbd7cfefc1618';

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
String _$singleImagePickerHash() => r'ca1a85821224fd033e0cef3cb67e6c6f1ce3544b';

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
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
