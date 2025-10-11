import 'dart:async';

import 'package:flutter/material.dart';
import 'package:portefolio/features/generator/services/web_geolocation_service.dart';

import '../../data/location_data.dart';

class GeolocationTesterWidget extends StatefulWidget {
  const GeolocationTesterWidget({super.key});

  @override
  State<GeolocationTesterWidget> createState() =>
      _GeolocationTesterWidgetState();
}

class _GeolocationTesterWidgetState extends State<GeolocationTesterWidget> {
  final GeolocationService _geolocationService = GeolocationService();
  LocationData? _currentPosition;
  String? _error;
  bool _isWatching = false;
  StreamSubscription<LocationData>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    // Vérifier si la géolocalisation est supportée au démarrage
    if (!GeolocationService.isSupported()) {
      setState(() {
        _error =
            'La géolocalisation n\'est pas supportée sur cette plateforme/navigateur.';
      });
    }
  }

  Future<void> _getCurrentPosition() async {
    setState(() {
      _error = null;
      _currentPosition = null;
    });
    try {
      final position = await _geolocationService.getCurrentPosition();
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur (Single): $e';
      });
    }
  }

  Future<void> _requestPermission() async {
    final hasPermission = await _geolocationService.requestPermission();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          hasPermission
              ? 'Permission accordée (ou déjà obtenue).'
              : 'Permission refusée ou erreur.',
        ),
      ),
    );
  }

  void _toggleWatchPosition() {
    if (_isWatching) {
      // Arrêter le suivi
      _positionStreamSubscription?.cancel();
      setState(() {
        _isWatching = false;
      });
    } else {
      // Démarrer le suivi
      setState(() {
        _error = null;
        _isWatching = true;
      });
      _positionStreamSubscription = _geolocationService.watchPosition().listen(
        (position) {
          setState(() {
            _currentPosition = position;
          });
        },
        onError: (error) {
          setState(() {
            _error = 'Erreur (Stream): $error';
            _isWatching = false; // Arrêter en cas d'erreur
          });
        },
        onDone: () {
          // Le stream s'est fermé
          setState(() {
            _isWatching = false;
          });
        },
      );
    }
  }

  // N'oubliez pas de nettoyer les ressources !
  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _geolocationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Geolocation Service Tester',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _requestPermission,
            child: const Text('1. Demander la permission'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _getCurrentPosition,
            child: const Text('2. Obtenir la position actuelle'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: _toggleWatchPosition,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isWatching ? Colors.red : Colors.green,
            ),
            child: Text(_isWatching
                ? 'Arrêter le suivi de position'
                : '3. Démarrer le suivi de position'),
          ),
          const SizedBox(height: 24),
          _buildResultView(),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    if (_error != null) {
      return Text(
        _error!,
        style: const TextStyle(color: Colors.red, fontSize: 16),
        textAlign: TextAlign.center,
      );
    }
    if (_currentPosition != null) {
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Dernière position reçue:',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text('Latitude: ${_currentPosition!.latitude}'),
              Text('Longitude: ${_currentPosition!.longitude}'),
              Text(
                  'Précision: ${_currentPosition!.accuracy.toStringAsFixed(2)} mètres'),
              Text('Timestamp: ${_currentPosition!.timestamp.toLocal()}'),
            ],
          ),
        ),
      );
    }
    return const Text(
      'En attente d\'une action...',
      textAlign: TextAlign.center,
      style: TextStyle(fontStyle: FontStyle.italic),
    );
  }
}
