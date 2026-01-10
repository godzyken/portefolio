import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/widgets/responsive_text.dart';
import '../../data/models/location_data.dart';
import '../../services/location_service.dart';

/// Dialog pour expliquer et demander la permission de géolocalisation
class LocationPermissionDialog extends ConsumerStatefulWidget {
  const LocationPermissionDialog({super.key});

  @override
  ConsumerState<LocationPermissionDialog> createState() =>
      _LocationPermissionDialogState();
}

class _LocationPermissionDialogState
    extends ConsumerState<LocationPermissionDialog> {
  bool _isRequesting = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.location_on, color: Colors.blue),
          SizedBox(width: 8),
          Text('Géolocalisation'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cette fonctionnalité nécessite l\'accès à votre position pour afficher la carte SIG interactive.',
          ),
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.security, size: 20, color: Colors.green),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Vos données restent privées',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.public, size: 20, color: Colors.green),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Géolocalisation gratuite via navigateur',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(fontSize: 12, color: Colors.red),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isRequesting ? null : () => Navigator.pop(context, false),
          child: const Text('Refuser'),
        ),
        ResponsiveButton(
          onPressed: _isRequesting ? null : _requestPermission,
          child: _isRequesting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Autoriser'),
        ),
      ],
    );
  }

  Future<void> _requestPermission() async {
    setState(() {
      _isRequesting = true;
      _errorMessage = null;
    });

    try {
      final service = LocationService.instance;
      final status = await service.requestPermission();

      if (mounted) {
        if (status == LocationPermissionStatus.whileInUse ||
            status == LocationPermissionStatus.always) {
          Navigator.pop(context, true);
        } else {
          setState(() {
            _errorMessage = 'Permission refusée. Veuillez l\'autoriser dans '
                'les paramètres de votre navigateur.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Erreur: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRequesting = false;
        });
      }
    }
  }
}

/// Fonction helper pour afficher le dialog
Future<bool> showLocationPermissionDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => const LocationPermissionDialog(),
  );
  return result ?? false;
}
