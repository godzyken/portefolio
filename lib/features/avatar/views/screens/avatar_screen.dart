import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/affichage/tech_maturity_framework.dart';
import 'package:portefolio/core/ui/widgets/narrative_bubble.dart';
import '../../services/voice_service.dart';
import '../widgets/avatar_display.dart';
import '../widgets/avatar_chat_panel.dart';
import '../../notifiers/avatar_chat_notifier.dart';
import '../../data/avatar_message.dart';

/// Écran principal de l'Avatar Interactif.
/// Utilise Riverpod 3 via [ConsumerStatefulWidget].
class AvatarScreen extends ConsumerStatefulWidget {
  const AvatarScreen({super.key});

  @override
  ConsumerState<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends ConsumerState<AvatarScreen> {
  bool _isTheatreMode = true;

  @override
  Widget build(BuildContext context) {
    // 🪄 Riverpod 3 : Observation des états
    final info = ref.watch(responsiveInfoProvider);
    final chatState = ref.watch(avatarChatProvider);
    final isSpeaking = ref.watch(voiceServiceProvider);
    
    // Détermination de l'état de l'avatar
    final avatarState = _determineAvatarState(chatState, isSpeaking);

    return Scaffold(
      backgroundColor: ColorHelpers.surface,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: _isTheatreMode 
          ? _buildTheatreLayout(avatarState, info, chatState)
          : _buildChatLayout(avatarState, info),
    );
  }

  AvatarState _determineAvatarState(AsyncValue<List<AvatarMessage>> chatState, bool isSpeaking) {
    if (chatState.isLoading) return AvatarState.thinking;
    if (isSpeaking) return AvatarState.talking;
    return AvatarState.idle;
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_isTheatreMode ? "" : "AVATAR INTERACTIF", 
        style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(_isTheatreMode ? Icons.terminal : Icons.theater_comedy),
          onPressed: () => setState(() => _isTheatreMode = !_isTheatreMode),
        ),
      ],
    );
  }

  Widget _buildTheatreLayout(AvatarState state, ResponsiveInfo info, AsyncValue<List<AvatarMessage>> chatState) {
    final messages = chatState.asData?.value ?? [];
    final lastMsg = messages.isEmpty ? null : messages.last;
    final bool isAvatarTalking = (lastMsg?.role == MessageRole.avatar) || (state == AvatarState.thinking);
    final TechPillar? activePillar = lastMsg?.relatedPillar;

    return Stack(
      children: [
        // Fond : Avatar
        Positioned.fill(child: AvatarDisplay(state: state)),
        
        // Filtre visuel
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black45, Colors.transparent, Colors.black45],
              ),
            ),
          ),
        ),

        // Bulle de texte flottante
        if (lastMsg != null && isAvatarTalking)
          Positioned(
            left: info.isMobile ? 20 : 50,
            top: info.isMobile ? 100 : 150,
            child: SizedBox(
              width: info.isMobile ? (info.size.width - 40) : 400,
              child: NarrativeBubble(text: lastMsg.content).animate().fadeIn().slideX(begin: -0.1, end: 0),
            ),
          ),

        // Slide d'expertise technique
        if (activePillar != null)
          Positioned(
            right: info.isMobile ? 20 : 40,
            bottom: info.isMobile ? 120 : 150,
            child: _PillarSlide(pillar: activePillar, info: info),
          ),

        // Zone de saisie flottante
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.only(bottom: info.isMobile ? 20 : 40, left: 20, right: 20),
            child: const _CompactInputArea(),
          ),
        ),
      ],
    );
  }

  Widget _buildChatLayout(AvatarState state, ResponsiveInfo info) {
    return Material(
      color: ColorHelpers.surface,
      child: Row(
        children: [
          Expanded(flex: 4, child: AvatarDisplay(state: state)),
          const VerticalDivider(width: 1, color: Colors.white10),
          const Expanded(flex: 6, child: AvatarChatPanel()),
        ],
      ),
    );
  }
}

class _PillarSlide extends StatelessWidget {
  final TechPillar pillar;
  final ResponsiveInfo info;

  const _PillarSlide({required this.pillar, required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: info.isMobile ? 180 : 350,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: pillar.color.withValues(alpha: 0.5), width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(pillar.skillImage, height: info.isMobile ? 120 : 250, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          Text(pillar.label.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ).animate().fadeIn().scale(),
    );
  }
}

class _CompactInputArea extends ConsumerStatefulWidget {
  const _CompactInputArea();
  @override
  ConsumerState<_CompactInputArea> createState() => _CompactInputAreaState();
}

class _CompactInputAreaState extends ConsumerState<_CompactInputArea> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Une question technique ?",
              filled: true,
              fillColor: Colors.black45,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            onSubmitted: (v) => _send(ref),
          ),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          backgroundColor: ColorHelpers.cyan,
          child: IconButton(
            icon: const Icon(Icons.send, color: Colors.black, size: 20),
            onPressed: () => _send(ref),
          ),
        ),
      ],
    );
  }

  void _send(WidgetRef ref) {
    if (_ctrl.text.trim().isEmpty) return;
    ref.read(avatarChatProvider.notifier).sendMessage(_ctrl.text);
    _ctrl.clear();
  }
}
