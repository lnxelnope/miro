import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:miro_hybrid/core/database/database_service.dart';
import 'package:miro_hybrid/core/services/energy_service.dart';

/// Provider สำหรับ EnergyService (singleton)
final energyServiceProvider = Provider<EnergyService>((ref) {
  return EnergyService(DatabaseService.isar);
});

/// Provider สำหรับ Energy Balance (auto-refresh)
final energyBalanceProvider = StreamProvider<int>((ref) async* {
  final energyService = ref.watch(energyServiceProvider);
  
  // Yield initial value
  yield await energyService.getBalance();
  
  // Refresh every 5 seconds
  await for (final _ in Stream.periodic(const Duration(seconds: 5))) {
    yield await energyService.getBalance();
  }
});

/// Provider แบบ FutureProvider (ใช้ครั้งเดียว)
final currentEnergyProvider = FutureProvider<int>((ref) async {
  final energyService = ref.watch(energyServiceProvider);
  return await energyService.getBalance();
});
