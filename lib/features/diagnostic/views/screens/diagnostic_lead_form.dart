import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/ui/widgets/common_form_fields.dart';
import '../../../../core/ui/widgets/responsive_text.dart';

import '../../data/models/diagnostic_models.dart';
import '../../data/state/diagnostic_state.dart';
import '../../providers/diagnostic_provider.dart';

class DiagnosticLeadForm extends ConsumerStatefulWidget {
  const DiagnosticLeadForm({super.key, required this.result});

  final DiagnosticResult result;

  @override
  ConsumerState<DiagnosticLeadForm> createState() => _DiagnosticLeadFormState();
}

class _DiagnosticLeadFormState extends ConsumerState<DiagnosticLeadForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _companyController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(diagnosticNotifierProvider);
    final notifier = ref.read(diagnosticNotifierProvider.notifier);
    final isLoading = state.submitStatus == LeadSubmitStatus.loading;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ResponsiveText.titleMedium(
              'Recevez votre rapport détaillé',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const ResponsiveText.bodySmall(
              'Laissez vos coordonnées pour recevoir une synthèse personnalisée et être recontacté.',
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            NameFormField(
              controller: _nameController,
              labelText: 'Votre nom',
              hintText: 'Jean Dupont',
              onChanged: notifier.updateLeadName,
              validator: (_) => null,
            ),
            const SizedBox(height: 12),
            EmailFormField(
              controller: _emailController,
              onChanged: notifier.updateLeadEmail,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _companyController,
              onChanged: notifier.updateCompanyName,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Entreprise (optionnel)',
                labelStyle: const TextStyle(color: Colors.white70),
                prefixIcon:
                    Icon(Icons.business_outlined, color: theme.colorScheme.primary),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (state.submitStatus == LeadSubmitStatus.error) ...[
              const SizedBox(height: 12),
              Text(
                'Une erreur est survenue${state.submitError != null ? ' : ${state.submitError}' : '.'} '
                'Vous pouvez réessayer.',
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: isLoading
                    ? null
                    : () async {
                        if (!(_formKey.currentState?.validate() ?? false)) return;
                        await notifier.submitLead(widget.result);
                      },
                icon: isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.send),
                label: Text(isLoading ? 'Envoi en cours...' : 'Recevoir mon rapport'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: theme.colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
