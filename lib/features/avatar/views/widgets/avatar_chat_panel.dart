import 'package:cloudflare_turnstile/cloudflare_turnstile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/service/turnstile_service.dart';
import 'package:portefolio/core/ui/widgets/narrative_bubble.dart';
import '../data/avatar_message.dart';
import '../notifiers/avatar_chat_notifier.dart';

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
          if (TurnstileService.isConfigured)
            CloudflareTurnstile(
              siteKey: TurnstileService.siteKey!,
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
              onSubmitted: (val) {
                ref.read(avatarChatProvider.notifier).sendMessage(val);
                _controller.clear();
              },
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            backgroundColor: ColorHelpers.cyan,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.black),
              onPressed: () {
                ref.read(avatarChatProvider.notifier).sendMessage(_controller.text);
                _controller.clear();
              },
            ),
          ),
        ],
      ),
    );
  }
}
