import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/location/location_service.dart';

/// Full-screen map to place the business pin. Returns the chosen [GeoPoint].
class LocationPickerPage extends StatefulWidget {
  const LocationPickerPage({super.key, this.initial});

  /// Where the pin starts; Lima's main square if the business has no location yet.
  final GeoPoint? initial;

  static const _lima = GeoPoint(-12.0464, -77.0428);

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  late GeoPoint _point = widget.initial ?? LocationPickerPage._lima;

  @override
  Widget build(BuildContext context) {
    final pin = LatLng(_point.latitude, _point.longitude);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicación del negocio'),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(_point), child: const Text('Listo'))],
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(target: pin, zoom: 16),
            myLocationButtonEnabled: false,
            mapToolbarEnabled: false,
            onTap: (latLng) => setState(() => _point = GeoPoint(latLng.latitude, latLng.longitude)),
            markers: {
              Marker(
                markerId: const MarkerId('business'),
                position: pin,
                draggable: true,
                onDragEnd: (latLng) => setState(() => _point = GeoPoint(latLng.latitude, latLng.longitude)),
              ),
            },
          ),
          const Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Text('Toca el mapa o arrastra el pin hasta la puerta de tu negocio.'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
