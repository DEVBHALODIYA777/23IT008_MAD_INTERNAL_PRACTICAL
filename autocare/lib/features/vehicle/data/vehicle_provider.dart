import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/vehicle.dart';
import '../../../core/database/hive_manager.dart';

final vehiclesProvider = NotifierProvider<VehicleNotifier, List<Vehicle>>(() {
  return VehicleNotifier();
});

class VehicleNotifier extends Notifier<List<Vehicle>> {
  @override
  List<Vehicle> build() {
    return HiveManager.vehiclesBox.values.toList();
  }

  void addVehicle(Vehicle vehicle) {
    HiveManager.vehiclesBox.put(vehicle.id, vehicle);
    state = [...state, vehicle];
  }

  void deleteVehicle(String id) {
    HiveManager.vehiclesBox.delete(id);
    state = state.where((v) => v.id != id).toList();
  }
}
