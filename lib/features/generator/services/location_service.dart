import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

import '../data/location_data.dart';

abstract class LocationService {
  static LocationService get _instance => _PlatformLocationService();
  static LocationService get instance => _instance;

  Future<LocationPermissionStatus> checkPermission();
  Future<LocationPermissionStatus> requestPermission();
  Future<LocationData?> getCurrentLocation();
  Stream<LocationData> getLocationStream();
  Future<bool> isLocationEnabled();
}

/// 🌐 / 📱 / Stub unifié
class _PlatformLocationService extends LocationService {
  final LocationService _impl;

  _PlatformLocationService()
      : _impl = kIsWeb
            ? _WebLocationService()
            : (defaultTargetPlatform == TargetPlatform.android ||
                    defaultTargetPlatform == TargetPlatform.iOS)
                ? _MobileLocationService()
                : _StubLocationService();

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

/// === Web ===
class _WebLocationService extends LocationService {
  StreamController<LocationData>? _controller;

  @override
  Future<LocationPermissionStatus> checkPermission() async =>
      LocationPermissionStatus.whileInUse;

  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      LocationPermissionStatus.whileInUse;

  @override
  Future<LocationData?> getCurrentLocation() async => LocationData(
        latitude: 48.8566,
        longitude: 2.3522,
        accuracy: 100,
        timestamp: DateTime.now(),
      );

  @override
  Stream<LocationData> getLocationStream() {
    _controller ??= StreamController<LocationData>.broadcast(
      onListen: _startEmitting,
      onCancel: _stopEmitting,
    );
    return _controller!.stream;
  }

  void _startEmitting() async {
    while (_controller != null &&
        !_controller!.isClosed &&
        _controller!.hasListener) {
      await Future.delayed(const Duration(seconds: 5));
      final loc = await getCurrentLocation() ??
          LocationData(
              latitude: 0.0,
              longitude: 0.0,
              accuracy: 9999,
              timestamp: DateTime.now());
      _controller?.add(loc);
    }
  }

  void _stopEmitting() {
    // Rien de spécial, le while vérifie `hasListener`
  }

  @override
  Future<bool> isLocationEnabled() async => true;
}

/// === Mobile ===
class _MobileLocationService extends LocationService {
  @override
  Future<LocationPermissionStatus> checkPermission() async {
    final perm = await Geolocator.checkPermission();
    return _mapPermission(perm);
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    final perm = await Geolocator.requestPermission();
    return _mapPermission(perm);
  }

  @override
  Future<LocationData?> getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      debugPrint('GPS désactivé, position simulée renvoyée');
      return LocationData(
          latitude: 0, longitude: 0, accuracy: 9999, timestamp: DateTime.now());
    }
    final pos = await Geolocator.getCurrentPosition();
    return _toLocationData(pos);
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
  Future<bool> isLocationEnabled() => Geolocator.isLocationServiceEnabled();

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

/// === Stub fallback ===
class _StubLocationService extends LocationService {
  @override
  Future<LocationPermissionStatus> checkPermission() async =>
      LocationPermissionStatus.denied;

  @override
  Future<LocationPermissionStatus> requestPermission() async =>
      LocationPermissionStatus.denied;

  @override
  Future<LocationData?> getCurrentLocation() async => null;

  @override
  Stream<LocationData> getLocationStream() async* {}

  @override
  Future<bool> isLocationEnabled() async => false;
}
