import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../home/data/services_data.dart';
import '../../controller/pricing_admin_controller.dart';

/// Ouvre un dialog pour créer un nouveau pack (si [existing] est null)
/// ou éditer un pack existant.
Future<void> showPackFormDialog(
  BuildContext context,
  WidgetRef ref, {
  required String serviceId,
  PricingPack? existing,
}) {
  return showDialog(
    context: context,
    builder: (_) => _PackFormDialog(serviceId: serviceId, existing: existing),
  );
}

class _PackFormDialog extends ConsumerStatefulWidget {
  const _PackFormDialog({required this.serviceId, this.existing});
  final String serviceId;
  final PricingPack? existing;

  @override
  ConsumerState<_PackFormDialog> createState() => _PackFormDialogState();
}

class _PackFormDialogState extends ConsumerState<_PackFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _unitCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _featuresCtrl;
  late final TextEditingController _priorityCtrl;
  late bool _featured;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _nameCtrl = TextEditingController(text: e?.name ?? '');
    _priceCtrl = TextEditingController(text: e?.price.toStringAsFixed(0) ?? '');
    _unitCtrl = TextEditingController(text: e?.priceUnit ?? '€');
    _descCtrl = TextEditingController(text: e?.description ?? '');
    _featuresCtrl = TextEditingController(text: e?.features.join('\n') ?? '');
    _priorityCtrl = TextEditingController(text: (e?.priority ?? 0).toString());
    _featured = e?.isFeatured ?? false;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _unitCtrl.dispose();
    _descCtrl.dispose();
    _featuresCtrl.dispose();
    _priorityCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final pack = PricingPack(
      id: widget.existing?.id,
      serviceId: widget.serviceId,
      name: _nameCtrl.text.trim(),
      price: double.parse(_priceCtrl.text.trim()),
      priceUnit: _unitCtrl.text.trim().isEmpty ? '€' : _unitCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      features: _featuresCtrl.text
          .split('\n')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      priority: int.tryParse(_priorityCtrl.text.trim()) ?? 0,
      isFeatured: _featured,
    );

    try {
      final controller = ref.read(pricingAdminControllerProvider);
      if (_isEditing) {
        await controller.updatePack(pack);
      } else {
        await controller.createPack(pack);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Modifier le pack' : 'Nouveau pack'),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nom (ex: Découverte)'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Prix'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Requis';
                          if (double.tryParse(v.trim()) == null) return 'Nombre invalide';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextFormField(
                        controller: _unitCtrl,
                        decoration: const InputDecoration(labelText: 'Unité (€, €/mois...)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Description courte'),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _featuresCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Ce qui est inclus (une ligne par élément)',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _priorityCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Ordre d\'affichage'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Mis en avant'),
                        value: _featured,
                        onChanged: (v) => setState(() => _featured = v),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _saving ? null : _submit,
          child: _saving
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Enregistrer'),
        ),
      ],
    );
  }
}
