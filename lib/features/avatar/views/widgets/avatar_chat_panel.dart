import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/service/turnstile_service.dart';
import 'package:portefolio/core/ui/widgets/narrative_bubble.dart';
import '../../data/avatar_message.dart';
import '../../notifiers/avatar_chat_notifier.dart';
import '../../notifiers/engagement_notifier.dart';
import '../../services/avatar_lead_service.dart';

/// Panneau de chat classique (Mode Terminal).
/// Utilise Riverpod 3 via [ConsumerStatefulWidget].
class AvatarChatPanel extends ConsumerStatefulWidget {
  const AvatarChatPanel({super.key});

  @override
  ConsumerState<AvatarChatPanel> createState() => _AvatarChatPanelState();
}

class _AvatarChatPanelState extends ConsumerState<AvatarChatPanel> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isVerified = false;

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(avatarChatProvider);

    return Column(
      children: [
        Expanded(
          child: chatState.when(
            data: (messages) {
              if (messages.isEmpty && !_isVerified) {
                return _buildVerificationArea();
              }
              if (messages.isEmpty) {
                return const Center(
                  child: Text(
                    "Posez-moi une question sur le parcours de Soufiane.",
                    style: TextStyle(color: ColorHelpers.textSecondary, fontStyle: FontStyle.italic),
                  ),
                );
              }
              _scrollToBottom();
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildMessageBubble(msg),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: ColorHelpers.cyan)),
            error: (err, _) => Center(child: Text("Erreur: $err")),
          ),
        ),
        if (_isVerified) _buildInputArea(),
      ],
    );
  }

  Widget _buildVerificationArea() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.security, color: ColorHelpers.cyan, size: 48),
          const SizedBox(height: 16),
          const Text(
            "Vérification de sécurité requise",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Pour éviter les abus, veuillez valider que vous n'êtes pas un robot.",
            textAlign: TextAlign.center,
            style: TextStyle(color: ColorHelpers.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 24),
          if (TurnstileService.isConfigured && TurnstileService.siteKey != null)
            CloudflareTurnstile(
              siteKey: TurnstileService.siteKey ?? '',
              onTokenReceived: (token) {
                setState(() => _isVerified = true);
              },
            )
          else
            ElevatedButton(
              onPressed: () => setState(() => _isVerified = true),
              child: const Text("Passer (Debug Mode)"),
            ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(AvatarMessage msg) {
    if (msg.type == MessageType.leadForm) {
      return _AvatarLeadForm(onSubmitted: () => setState(() {}));
    }

    if (msg.role == MessageRole.avatar) {
      return NarrativeBubble(text: msg.content);
    } else {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ColorHelpers.cyan.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(4),
            ),
            border: Border.all(color: ColorHelpers.cyan.withValues(alpha: 0.3)),
          ),
          child: Text(
            msg.content,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ),
      );
    }
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorHelpers.surface,
        border: Border(top: BorderSide(color: ColorHelpers.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Demandez quelque chose...",
                hintStyle: const TextStyle(color: ColorHelpers.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: ColorHelpers.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: ColorHelpers.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide(color: ColorHelpers.cyan),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onSubmitted: (val) => _send(),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: ColorHelpers.cyan,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.black),
              onPressed: _send,
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    ref.read(avatarChatProvider.notifier).sendMessage(_controller.text);
    _controller.clear();
  }
}

class _AvatarLeadForm extends ConsumerStatefulWidget {
  final VoidCallback onSubmitted;
  const _AvatarLeadForm({required this.onSubmitted});

  @override
  ConsumerState<_AvatarLeadForm> createState() => _AvatarLeadFormState();
}

class _AvatarLeadFormState extends ConsumerState<_AvatarLeadForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  bool _isSubmitting = false;
  bool _isDone = false;

  Future<void> _submit() async {
    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final engagement = ref.read(engagementProvider.notifier);
      final chatMessages = ref.read(avatarChatProvider).asData?.value ?? [];
      
      final summary = chatMessages
          .where((m) => m.type == MessageType.text)
          .map((m) => "${m.role.name}: ${m.content}")
          .join("\n");

      await ref.read(avatarLeadServiceProvider).submit(
        name: _nameCtrl.text,
        email: _emailCtrl.text,
        conversationSummary: summary,
        pillarsExplored: engagement.exploredPillars,
        maxDepthScore: engagement.maxDepth,
      );

      setState(() {
        _isDone = true;
        _isSubmitting = false;
      });
      widget.onSubmitted();
    } catch (e) {
      setState(() => _isSubmitting = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Échec de l'envoi. Veuillez réessayer.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDone) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withValues(alpha: 0.5)),
        ),
        child: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "C'est noté ! Je t'envoie le résumé technique par email.",
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ColorHelpers.surfaceAlt,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColorHelpers.cyan.withValues(alpha: 0.4)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "DEMANDE DE RÉSUMÉ TECHNIQUE",
              style: TextStyle(color: ColorHelpers.cyan, fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _inputDecoration("Nom"),
              validator: (v) => v == null || v.isEmpty ? "Requis" : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: _inputDecoration("Email"),
              validator: (v) => v == null || !v.contains('@') ? "Email invalide" : null,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorHelpers.cyan,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSubmitting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text("RECEVOIR LE RÉSUMÉ", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: ColorHelpers.textSecondary, fontSize: 12),
      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: ColorHelpers.border)),
      focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: ColorHelpers.cyan)),
    );
  }
}
