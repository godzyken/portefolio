import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AssetsDebugger extends StatefulWidget {
  const AssetsDebugger({super.key});

  @override
  State<AssetsDebugger> createState() => _AssetsDebuggerState();
}

class _AssetsDebuggerState extends State<AssetsDebugger> {
  List<String> allAssets = [];
  List<String> imageAssets = [];
  List<String> dataAssets = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  Future<void> _loadAssets() async {
    try {
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      setState(() {
        allAssets = manifestMap.keys.toList()..sort();
        imageAssets = allAssets
            .where((path) =>
                path.startsWith('assets/images/') &&
                (path.endsWith('.jpg') ||
                    path.endsWith('.jpeg') ||
                    path.endsWith('.png') ||
                    path.endsWith('.webp')))
            .toList();
        dataAssets =
            allAssets.where((path) => path.startsWith('assets/data/')).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Assets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => isLoading = true);
              _loadAssets();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text('Erreur: $error'),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCard(),
                      const SizedBox(height: 24),
                      _buildSection(
                        'Images (${imageAssets.length})',
                        imageAssets,
                        Icons.image,
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        'Données (${dataAssets.length})',
                        dataAssets,
                        Icons.description,
                      ),
                      const SizedBox(height: 24),
                      _buildSection(
                        'Tous les assets (${allAssets.length})',
                        allAssets,
                        Icons.folder,
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Résumé',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildStat('Total assets', allAssets.length, Icons.inventory),
            _buildStat('Images', imageAssets.length, Icons.image),
            _buildStat('Fichiers data', dataAssets.length, Icons.description),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, int value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<String> assets, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (assets.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Aucun asset trouvé'),
          )
        else
          ...assets.map((path) => _buildAssetTile(path)),
      ],
    );
  }

  Widget _buildAssetTile(String path) {
    final isImage = path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png') ||
        path.endsWith('.webp');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: isImage
            ? Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    path,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.broken_image,
                      color: Colors.red,
                    ),
                  ),
                ),
              )
            : const Icon(Icons.insert_drive_file),
        title: Text(
          path.split('/').last,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
        subtitle: Text(
          path,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy, size: 16),
              tooltip: 'Copier le chemin',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: path));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Copié: $path'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              },
            ),
            if (isImage)
              IconButton(
                icon: const Icon(Icons.preview, size: 16),
                tooltip: 'Prévisualiser',
                onPressed: () => _showImagePreview(path),
              ),
          ],
        ),
      ),
    );
  }

  void _showImagePreview(String path) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(path.split('/').last),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Image.asset(
                path,
                errorBuilder: (context, error, stackTrace) => Column(
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Erreur: $error'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
