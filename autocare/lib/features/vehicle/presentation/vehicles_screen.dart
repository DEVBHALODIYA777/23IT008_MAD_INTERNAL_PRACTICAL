import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/vehicle_provider.dart';
import 'add_vehicle_screen.dart';

class VehiclesScreen extends ConsumerWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vehicles = ref.watch(vehiclesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Garage', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: vehicles.isEmpty 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.directions_car_filled, size: 100, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('Your garage is empty.', style: TextStyle(fontSize: 18, color: Colors.grey.shade600)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: vehicles.length,
              itemBuilder: (context, index) {
                final v = vehicles[index];
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1, offset: Offset(0, 4))],
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 80,
                            width: 80,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFFEEEEEE), Color(0xFFE0E0E0)]),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              (v.name.toLowerCase().contains('bike') || v.model.toLowerCase().contains('enfield')) ? Icons.motorcycle : Icons.directions_car_filled,
                              size: 40,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(v.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(v.model, style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _buildBadge(v.fuelType, Colors.blue),
                                    const SizedBox(width: 8),
                                    _buildBadge(v.registrationNumber, Colors.grey),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.redAccent),
                        onPressed: () => ref.read(vehiclesProvider.notifier).deleteVehicle(v.id),
                      ),
                    ),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const AddVehicleScreen()));
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Vehicle', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBadge(String label, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.shade200),
      ),
      child: Text(label, style: TextStyle(fontSize: 12, color: color.shade700, fontWeight: FontWeight.bold)),
    );
  }
}
