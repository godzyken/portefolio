import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:portefolio/features/generator/services/web_geolocation_service.dart';

import '../data/location_data.dart';
import '../data/location_data_stub.dart';

abstract class LocationService {
  static LocationService get instance => _PlatformLocationService();

  Future<LocationPermissionStatus> checkPermission();
  Future<LocationPermissionStatus> requestPermission();
  Future<LocationData?> getCurrentLocation();
  Stream<LocationData> getLocationStream();
  Future<bool> isLocationEnabled();
}

/// 🌐 / 📱 / Stub unifié
class _PlatformLocationService extends LocationService {
  final LocationService _impl;

  _PlatformLocationService() : _impl = _createService();

  static LocationService _createService() {
    if (kIsWeb) {
      return _WebLocationServiceWrapper();
    }
    // Pour mobile/desktop, utilisez un service simulé ou geolocator
    // (à réactiver selon vos besoins)
    return _SimulatedLocationService();
  }

  @override
  Future<LocationPermissionStatus> checkPermission() => _impl.checkPermission();

  @override
  Future<LocationPermissionStatus> requestPermission() =>
      _impl.requestPermission();

  @override
  Future<LocationData?> getCurrentLocation() => _impl.getCurrentLocation();

  @override
  Stream<LocationData> getLocationStream() => _impl.getLocationStream();

  @override
  Future<bool> isLocationEnabled() => _impl.isLocationEnabled();
}

/// Wrapper pour le service Web natif
class _WebLocationServiceWrapper extends LocationService {
  final _service = WebGeolocationService();

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    if (WebGeolocationService.isSupported()) {
      return LocationPermissionStatus.whileInUse;
    }
    return LocationPermissionStatus.denied;
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    final granted = await _service.requestPermission();
    return granted
        ? LocationPermissionStatus.whileInUse
        : LocationPermissionStatus.denied;
  }

  @override
  Future<LocationData?> getCurrentLocation() async {
    try {
      return await _service.getCurrentPosition();
    } catch (e) {
      debugPrint('❌ Erreur getCurrentLocation: $e');
      return null;
    }
  }

  @override
  Stream<LocationData> getLocationStream() {
    return _service.watchPosition();
  }

  @override
  Future<bool> isLocationEnabled() async {
    return WebGeolocationService.isSupported();
  }
}

/// === Mobile ===
class _MobileLocationService extends LocationService {
  @override
  Future<LocationPermissionStatus> checkPermission() async {
    try {
      final perm = await Geolocator.checkPermission();
      return _mapPermission(perm);
    } catch (e) {
      developer.log('❌ Erreur checkPermission: $e');
      return LocationPermissionStatus.denied;
    }
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    try {
      final perm = await Geolocator.requestPermission();
      return _mapPermission(perm);
    } catch (e) {
      developer.log('❌ Erreur requestPermission: $e');
      return LocationPermissionStatus.denied;
    }
  }

  @override
  Future<LocationData?> getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        developer.log('GPS désactivé, position simulée renvoyée');
        return LocationData(
            latitude: 0,
            longitude: 0,
            accuracy: 9999,
            timestamp: DateTime.now());
      }
      final pos = await Geolocator.getCurrentPosition();
      return _toLocationData(pos);
    } catch (e) {
      developer.log('❌ Erreur getCurrentLocation: $e');
      return null;
    }
  }

  @override
  Stream<LocationData> getLocationStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).map((pos) => LocationData(
          latitude: pos.latitude,
          longitude: pos.longitude,
          accuracy: pos.accuracy,
          timestamp: pos.timestamp ?? DateTime.now(),
        ));
  }

  @override
  Future<bool> isLocationEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      developer.log('❌ Erreur isLocationEnabled: $e');
      return false;
    }
  }

  LocationPermissionStatus _mapPermission(LocationPermission perm) {
    return switch (perm) {
      LocationPermission.denied ||
      LocationPermission.deniedForever =>
        LocationPermissionStatus.denied,
      LocationPermission.whileInUse => LocationPermissionStatus.whileInUse,
      LocationPermission.always => LocationPermissionStatus.always,
      LocationPermission.unableToDetermine =>
        LocationPermissionStatus.unableToDetermine,
    };
  }

  LocationData _toLocationData(Position pos) => LocationData(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        timestamp: pos.timestamp ?? DateTime.now(),
      );
}

/// === Stub fallback (Desktop, autres) ===
class _StubLocationService extends LocationService {
  @override
  Future<LocationPermissionStatus> checkPermission() async {
    debugPrint('🖥️ Stub: Pas de géolocalisation disponible');
    return LocationPermissionStatus.denied;
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    debugPrint('🖥️ Stub: Pas de géolocalisation disponible');
    return LocationPermissionStatus.denied;
  }

  @override
  Future<LocationData?> getCurrentLocation() async {
    debugPrint('🖥️ Stub: Pas de géolocalisation disponible');
    return null;
  }

  @override
  Stream<LocationData> getLocationStream() async* {
    debugPrint('🖥️ Stub: Stream vide');
  }

  @override
  Future<bool> isLocationEnabled() async {
    debugPrint('🖥️ Stub: GPS non disponible');
    return false;
  }
}

/// Service simulé pour mobile/desktop (position fixe)
class _SimulatedLocationService extends LocationService {
  StreamController<LocationData>? _controller;
  Timer? _timer;

  static const _defaultLat = 48.8566;
  static const _defaultLng = 2.3522;

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    debugPrint('📱 LocationService: Mode simulé - Permission accordée');
    return LocationPermissionStatus.whileInUse;
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    debugPrint('📱 LocationService: Mode simulé - Permission accordée');
    return LocationPermissionStatus.whileInUse;
  }

  @override
  Future<LocationData?> getCurrentLocation() async {
    debugPrint('📱 LocationService: Position simulée (Paris)');
    return LocationData(
      latitude: _defaultLat,
      longitude: _defaultLng,
      accuracy: 100,
      timestamp: DateTime.now(),
    );
  }

  @override
  Stream<LocationData> getLocationStream() {
    _controller ??= StreamController<LocationData>.broadcast(
      onListen: _startEmitting,
      onCancel: _stopEmitting,
    );
    return _controller!.stream;
  }

  void _startEmitting() {
    debugPrint('📱 LocationService: Démarrage du stream de position');
    _emitPosition();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _emitPosition();
    });
  }

  void _emitPosition() {
    if (_controller != null && !_controller!.isClosed) {
      final loc = LocationData(
        latitude: _defaultLat,
        longitude: _defaultLng,
        accuracy: 100,
        timestamp: DateTime.now(),
      );
      _controller!.add(loc);
      debugPrint('📱 LocationService: Position émise');
    }
  }

  void _stopEmitting() {
    debugPrint('📱 LocationService: Arrêt du stream');
    _timer?.cancel();
    _timer = null;
    _controller?.close();
    _controller = null;
  }

  @override
  Future<bool> isLocationEnabled() async {
    debugPrint('📱 LocationService: GPS simulé actif');
    return true;
  }
}
