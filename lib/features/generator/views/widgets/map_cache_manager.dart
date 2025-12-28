import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MapCacheManager extends ConsumerWidget {
  const MapCacheManager({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (kIsWeb) return const SizedBox.shrink(); // Invisible sur le Web

    return ListTile(
      title: const Text("Cache de la carte"),
      subtitle: const Text("Optimise la vitesse et économise la data"),
      trailing: IconButton(
        icon: const Icon(Icons.delete_sweep, color: Colors.red),
        onPressed: () async {
          await FMTCStore('mapStore').manage.reset();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Cache vidé")),
          );
        },
      ),
    );
  }
}
