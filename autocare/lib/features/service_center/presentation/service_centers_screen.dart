import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:math';

class ServiceCentersScreen extends StatefulWidget {
  const ServiceCentersScreen({super.key});

  @override
  State<ServiceCentersScreen> createState() => _ServiceCentersScreenState();
}

class _ServiceCentersScreenState extends State<ServiceCentersScreen> {
  LatLng _center = const LatLng(37.422, -122.084); // Default to Mountain View mock if failed
  GoogleMapController? mapController;
  bool _isLoadingLocation = true;

  String _selectedBrand = 'All';
  
  final List<String> _brands = [
    'All', 'Mahindra', 'Honda', 'Toyota', 'Tata', 'Suzuki', 'Royal Enfield', 'Hyundai'
  ];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _isLoadingLocation = false);
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _isLoadingLocation = false);
        return;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      setState(() => _isLoadingLocation = false);
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
        ),
      ).timeout(const Duration(seconds: 5));
      setState(() {
        _center = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });
      mapController?.animateCamera(CameraUpdate.newLatLngZoom(_center, 12.0));
    } catch (e) {
      // Fallback if blocked
      setState(() => _isLoadingLocation = false);
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (!_isLoadingLocation) {
      controller.animateCamera(CameraUpdate.newLatLngZoom(_center, 12.0));
    }
  }

  Set<Marker> _generateMockMarkers() {
    final random = Random(_selectedBrand.hashCode);
    final Set<Marker> markers = {};

    List<String> targetBrands = _selectedBrand == 'All' 
        ? _brands.where((b) => b != 'All').toList() 
        : [_selectedBrand];

    for (int i = 0; i < targetBrands.length; i++) {
      for (int j = 0; j < 2; j++) {
        final double latOffset = (random.nextDouble() - 0.5) * 0.05;
        final double lngOffset = (random.nextDouble() - 0.5) * 0.05;
        final brand = targetBrands[i];
        
        markers.add(
          Marker(
            markerId: MarkerId('${brand}_$j'),
            position: LatLng(_center.latitude + latOffset, _center.longitude + lngOffset),
            infoWindow: InfoWindow(
              title: '$brand Authorized Showroom & Service', 
              snippet: '${(4.0 + random.nextDouble()).toStringAsFixed(1)} Stars - Genuine Parts',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(_getBrandColor(brand)),
          ),
        );
      }
    }
    return markers;
  }

  double _getBrandColor(String brand) {
    switch (brand) {
      case 'Mahindra': return BitmapDescriptor.hueRed;
      case 'Honda': return BitmapDescriptor.hueAzure;
      case 'Tata': return BitmapDescriptor.hueBlue;
      case 'Suzuki': return BitmapDescriptor.hueCyan;
      case 'Royal Enfield': return BitmapDescriptor.hueGreen;
      case 'Toyota': return BitmapDescriptor.hueRose;
      case 'Hyundai': return BitmapDescriptor.hueOrange;
      default: return BitmapDescriptor.hueViolet;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Showrooms', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            color: Theme.of(context).scaffoldBackgroundColor,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _brands.map((brand) {
                  final isSelected = _selectedBrand == brand;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(brand, style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      )),
                      selected: isSelected,
                      selectedColor: Theme.of(context).colorScheme.primary,
                      backgroundColor: Colors.white,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedBrand = brand);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          Expanded(
            child: _isLoadingLocation
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                      GoogleMap(
                        onMapCreated: _onMapCreated,
                        initialCameraPosition: CameraPosition(target: _center, zoom: 12.0),
                        markers: _generateMockMarkers(),
                        myLocationEnabled: true,
                        zoomControlsEnabled: false,
                      ),
                      Positioned(
                        bottom: 24,
                        right: 16,
                        child: FloatingActionButton(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Colors.white,
                          child: const Icon(Icons.my_location),
                          onPressed: () => _determinePosition(),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
