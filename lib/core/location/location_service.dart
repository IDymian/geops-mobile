import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// A point on the map.
class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  @override
  bool operator ==(Object other) => other is GeoPoint && other.latitude == latitude && other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

enum LocationAccess { granted, denied, deniedForever, serviceDisabled }

/// Thin wrapper over geolocator so the rest of the app (and tests) never touch it directly.
///
/// Privacy: only "while in use" access is ever requested; the manifest declares no
/// background location permission.
class LocationService {
  const LocationService();

  Future<LocationAccess> currentAccess() => _access(request: false);

  /// Shows the system dialog if the user has not answered yet.
  Future<LocationAccess> requestAccess() => _access(request: true);

  Future<GeoPoint> currentPosition() async {
    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 15)),
    );
    return GeoPoint(position.latitude, position.longitude);
  }

  Future<void> openAppSettings() => Geolocator.openAppSettings();

  Future<void> openLocationSettings() => Geolocator.openLocationSettings();

  Future<LocationAccess> _access({required bool request}) async {
    if (!await Geolocator.isLocationServiceEnabled()) return LocationAccess.serviceDisabled;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied && request) {
      permission = await Geolocator.requestPermission();
    }
    return switch (permission) {
      LocationPermission.always || LocationPermission.whileInUse => LocationAccess.granted,
      LocationPermission.deniedForever => LocationAccess.deniedForever,
      LocationPermission.denied || LocationPermission.unableToDetermine => LocationAccess.denied,
    };
  }
}

final locationServiceProvider = Provider<LocationService>((ref) => const LocationService());
