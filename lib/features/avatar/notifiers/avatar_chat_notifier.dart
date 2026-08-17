import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/avatar_message.dart';
import '../services/avatar_chat_service.dart';
import '../services/avatar_context_builder.dart';

class AvatarChatNotifier extends AsyncNotifier<List<AvatarMessage>> {
  final List<AvatarMessage> _messages = [];
  final AvatarChatService _chatService = AvatarChatService();

  @override
  FutureOr<List<AvatarMessage>> build() {
    return _messages;
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMsg = AvatarMessage(
      id: DateTime.now().toIso8601String(),
      role: MessageRole.user,
      content: text,
      timestamp: DateTime.now(),
    );

    _messages.add(userMsg);
    state = AsyncData(List.from(_messages));

    // Déclencher la réflexion
    state = const AsyncLoading<List<AvatarMessage>>().copyWithPrevious(AsyncData(List.from(_messages)));

    final contextBuilder = ref.read(avatarContextBuilderProvider);
    final systemContext = await contextBuilder.buildGlobalContext();

    final response = await _chatService.getResponse(
      systemContext: systemContext,
      history: _messages,
    );

    final avatarMsg = AvatarMessage(
      id: DateTime.now().toIso8601String(),
      role: MessageRole.avatar,
      content: response,
      timestamp: DateTime.now(),
    );

    _messages.add(avatarMsg);
    state = AsyncData(List.from(_messages));
  }
}

final avatarChatProvider = AsyncNotifierProvider<AvatarChatNotifier, List<AvatarMessage>>(
  AvatarChatNotifier.new,
);
