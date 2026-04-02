import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../domain/models/vehicle.dart';
import '../data/vehicle_provider.dart';

class AddVehicleScreen extends ConsumerStatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  ConsumerState<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends ConsumerState<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String model = '';
  String registrationNumber = '';
  String fuelType = 'Petrol';
  DateTime purchaseDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Vehicle')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildModernTextField(
                label: 'Nickname (e.g. Daily Driver)',
                icon: Icons.directions_car,
                onSaved: (val) => name = val ?? '',
              ),
              const SizedBox(height: 16),
              _buildModernTextField(
                label: 'Make & Model (e.g. Honda Civic)',
                icon: Icons.branding_watermark,
                onSaved: (val) => model = val ?? '',
              ),
              const SizedBox(height: 16),
              _buildModernTextField(
                label: 'Registration Number',
                icon: Icons.pin,
                onSaved: (val) => registrationNumber = val ?? '',
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: fuelType,
                decoration: InputDecoration(
                  labelText: 'Fuel Type',
                  prefixIcon: const Icon(Icons.local_gas_station),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: Theme.of(context).cardTheme.color,
                ),
                items: ['Petrol', 'Diesel', 'Electric', 'Hybrid']
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (val) => setState(() => fuelType = val!),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    
                    final v = Vehicle(
                      id: const Uuid().v4(),
                      name: name,
                      model: model,
                      registrationNumber: registrationNumber,
                      fuelType: fuelType,
                      purchaseDate: purchaseDate,
                    );
                    
                    ref.read(vehiclesProvider.notifier).addVehicle(v);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Vehicle added successfully!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                ),
                child: const Text('Save Vehicle', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required String label, 
    required IconData icon, 
    required void Function(String?) onSaved
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: Theme.of(context).cardTheme.color,
      ),
      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
      onSaved: onSaved,
    );
  }
}
