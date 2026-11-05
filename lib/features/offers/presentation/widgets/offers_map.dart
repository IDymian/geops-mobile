import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/location/location_service.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/entities/offer.dart';

/// Map centered on the user, with the search radius and one marker per offer.
class OffersMap extends StatelessWidget {
  const OffersMap({
    super.key,
    required this.center,
    required this.radiusMeters,
    required this.offers,
    required this.onOfferTap,
  });

  final GeoPoint center;
  final int radiusMeters;
  final List<NearbyOffer> offers;
  final ValueChanged<NearbyOffer> onOfferTap;

  /// Rough zoom so the whole radius fits on a phone screen.
  static double zoomFor(int radiusMeters) => switch (radiusMeters) {
    <= 500 => 16,
    <= 1000 => 15,
    <= 2000 => 14,
    <= 5000 => 12.5,
    _ => 11.5,
  };

  @override
  Widget build(BuildContext context) {
    final here = LatLng(center.latitude, center.longitude);
    final primary = Theme.of(context).colorScheme.primary;
    return GoogleMap(
      initialCameraPosition: CameraPosition(target: here, zoom: zoomFor(radiusMeters)),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      mapToolbarEnabled: false,
      circles: {
        Circle(
          circleId: const CircleId('radius'),
          center: here,
          radius: radiusMeters.toDouble(),
          strokeWidth: 2,
          strokeColor: primary,
          fillColor: primary.withValues(alpha: 0.08),
        ),
      },
      markers: {
        for (final offer in offers)
          Marker(
            markerId: MarkerId(offer.id),
            position: LatLng(offer.business.latitude, offer.business.longitude),
            infoWindow: InfoWindow(
              title: offer.title,
              snippet: '${Formatters.price(offer.offerPrice)} · ${offer.business.name}',
              onTap: () => onOfferTap(offer),
            ),
          ),
      },
    );
  }
}
