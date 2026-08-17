import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/avatar_message.dart';
import '../services/avatar_chat_service.dart';
import '../services/avatar_context_builder.dart';
import '../services/voice_service.dart';
import 'engagement_notifier.dart';

class AvatarChatNotifier extends AsyncNotifier<List<AvatarMessage>> {
  final List<AvatarMessage> _messages = [];
  final AvatarChatService _chatService = AvatarChatService();

  @override
  FutureOr<List<AvatarMessage>> build() {
    return _messages;
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Classification et incrémentation engagement
    final engagement = ref.read(engagementProvider.notifier);
    final pillar = engagement.classifyMessage(text);
    if (pillar != null) {
      engagement.incrementPillar(pillar);
    }

    final userMsg = AvatarMessage(
      id: DateTime.now().toIso8601String(),
      role: MessageRole.user,
      content: text,
      timestamp: DateTime.now(),
      relatedPillar: pillar,
    );

    _messages.add(userMsg);
    state = AsyncData(List.from(_messages));

    // 2. Déclencher la réflexion
    state = const AsyncLoading<List<AvatarMessage>>();
    // On restaure immédiatement les messages pour que le UI puisse les afficher 
    // tout en voyant l'état isLoading
    state = AsyncData(List.from(_messages));

    final contextBuilder = ref.read(avatarContextBuilderProvider);
    final systemContext = await contextBuilder.buildGlobalContext();
    final scores = ref.read(engagementProvider);

    final response = await _chatService.getResponse(
      systemContext: systemContext,
      history: _messages,
      engagementScores: scores,
    );

    final avatarMsg = AvatarMessage(
      id: DateTime.now().toIso8601String(),
      role: MessageRole.avatar,
      content: response,
      timestamp: DateTime.now(),
    );

    _messages.add(avatarMsg);
    state = AsyncData(List.from(_messages));

    // 3. Synthèse vocale
    ref.read(voiceServiceProvider.notifier).speak(response);

    // 4. Vérification qualification Lead
    if (engagement.isQualified && !_messages.any((m) => m.type == MessageType.leadForm)) {
      _offerLeadCapture();
    }
  }

  void _offerLeadCapture() {
    final offerMsg = AvatarMessage(
      id: "lead_offer_${DateTime.now().millisecondsSinceEpoch}",
      role: MessageRole.avatar,
      content: "Je vois que tu t'intéresses de près à mon expertise technique. Serais-tu intéressé pour qu'on poursuive cet échange par email ? Je peux t'envoyer un résumé de notre conversation.",
      timestamp: DateTime.now(),
    );

    final formMsg = AvatarMessage(
      id: "lead_form_${DateTime.now().millisecondsSinceEpoch}",
      role: MessageRole.system,
      content: "Formulaire de contact",
      timestamp: DateTime.now(),
      type: MessageType.leadForm,
    );

    _messages.add(offerMsg);
    _messages.add(formMsg);
    state = AsyncData(List.from(_messages));
  }
}

final avatarChatProvider = AsyncNotifierProvider<AvatarChatNotifier, List<AvatarMessage>>(
  AvatarChatNotifier.new,
);
