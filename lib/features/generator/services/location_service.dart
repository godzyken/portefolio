import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../data/location_data.dart';

abstract class LocationService {
  static LocationService get instance => _PlatformLocationService();

  Future<LocationPermissionStatus> checkPermission();
  Future<LocationPermissionStatus> requestPermission();
  Future<LocationData?> getCurrentLocation();
  Stream<LocationData> getLocationStream();
  Future<bool> isLocationEnabled();
  void dispose();
}

/// 🌐 / 📱 / Stub unifié
class _PlatformLocationService extends LocationService {
  final LocationService _impl;

  _PlatformLocationService() : _impl = _createService();

  static LocationService _createService() {
    // Check if we are running on a platform where geolocator is typically used (mobile/web)
    if (kIsWeb ||
        defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.android) {
      // Use Geolocator for Web, iOS, and Android
      // Note: Geolocator supports Web, but requires configuration.
      // If you want a fixed position fallback for all non-mobile, use the check below.

      // Option 1: Use Geolocator (or its wrapper) for Web/Mobile
      // return _MobileLocationService();

      // Option 2: Use the existing logic (Simulated for non-web/non-mobile)
      if (kIsWeb) {
        // Use Geolocator for Web
        return _GeolocatorLocationService();
      }
      return _SimulatedLocationService(); // Fallback for Mobile/Desktop as per original logic
    }

    // Fallback for Desktop/Other (Stub/Simulated)
    return _StubLocationService();
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

  @override
  void dispose() => _impl.dispose();
}

/// === Mobile/Web ===
class _GeolocatorLocationService extends LocationService {
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
          timestamp: DateTime.now(),
        );
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
    ).map(
      (pos) => LocationData(
        latitude: pos.latitude,
        longitude: pos.longitude,
        accuracy: pos.accuracy,
        timestamp: pos.timestamp ?? DateTime.now(),
      ),
    );
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

  @override
  void dispose() {}
}

/// === Stub fallback (Desktop, autres) ===
class _StubLocationService extends LocationService {
  @override
  Future<LocationPermissionStatus> checkPermission() async {
    developer.log('🖥️ Stub: Pas de géolocalisation disponible');
    return LocationPermissionStatus.denied;
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    developer.log('🖥️ Stub: Pas de géolocalisation disponible');
    return LocationPermissionStatus.denied;
  }

  @override
  Future<LocationData?> getCurrentLocation() async {
    developer.log('🖥️ Stub: Pas de géolocalisation disponible');
    return null;
  }

  @override
  Stream<LocationData> getLocationStream() async* {
    developer.log('🖥️ Stub: Stream vide');
  }

  @override
  Future<bool> isLocationEnabled() async {
    developer.log('🖥️ Stub: GPS non disponible');
    return false;
  }

  @override
  void dispose() {
    developer.log('🖥️ Stub: GPS no disponible');
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
    developer.log('📱 LocationService: Mode simulé - Permission accordée');
    return LocationPermissionStatus.whileInUse;
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    developer.log('📱 LocationService: Mode simulé - Permission accordée');
    return LocationPermissionStatus.whileInUse;
  }

  @override
  Future<LocationData?> getCurrentLocation() async {
    developer.log('📱 LocationService: Position simulée (Paris)');
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
    developer.log('📱 LocationService: Démarrage du stream de position');
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
      developer.log('📱 LocationService: Position émise');
    }
  }

  void _stopEmitting() {
    developer.log('📱 LocationService: Arrêt du stream');
    _timer?.cancel();
    _timer = null;
    _controller?.close();
    _controller = null;
  }

  @override
  Future<bool> isLocationEnabled() async {
    developer.log('📱 LocationService: GPS simulé actif');
    return true;
  }

  @override
  void dispose() {
    _stopEmitting();
  }
}
