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

class AvatarScreen extends ConsumerStatefulWidget {
  const AvatarScreen({super.key});

  @override
  ConsumerState<AvatarScreen> createState() => _AvatarScreenState();
}

class _AvatarScreenState extends ConsumerState<AvatarScreen> {
  bool _isTheatreMode = true;

  @override
  Widget build(BuildContext context) {
    debugPrint('🚀 Build AvatarScreen');
    final info = ref.watch(responsiveInfoProvider);
    final chatState = ref.watch(avatarChatProvider);
    final isSpeaking = ref.watch(voiceServiceProvider);
    
    AvatarState avatarState = AvatarState.idle;
    if (chatState.isLoading) {
      avatarState = AvatarState.thinking;
    } else if (isSpeaking) {
      avatarState = AvatarState.talking;
    }

    return Scaffold(
      backgroundColor: ColorHelpers.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
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
      ),
      body: _isTheatreMode 
          ? _buildTheatreLayout(avatarState, info, chatState)
          : (info.isMobile ? _buildMobileLayout(avatarState) : _buildDesktopLayout(avatarState, info)),
    );
  }

  Widget _buildTheatreLayout(AvatarState state, ResponsiveInfo info, AsyncValue<List<AvatarMessage>> chatState) {
    final List<AvatarMessage> messages = chatState.asData?.value ?? [];
    final AvatarMessage? lastMessage = messages.isNotEmpty ? messages.last : null;
    final bool isAvatarTalking = (lastMessage?.role == MessageRole.avatar) || state == AvatarState.thinking;

    // ✅ SÉCURISATION DU PILIER TECHNIQUE
    final TechPillar? activePillar = lastMessage?.relatedPillar;

    return Stack(
      children: [
        Positioned.fill(child: AvatarDisplay(state: state)),
        
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black45, Colors.transparent, Colors.black45],
              ),
            ),
          ),
        ),

        if (lastMessage != null && isAvatarTalking)
          Positioned(
            left: info.isMobile ? 20 : 50,
            top: info.isMobile ? 100 : 150,
            child: SizedBox(
              width: info.isMobile ? info.size.width - 40 : 400,
              child: NarrativeBubble(text: lastMessage.content).animate().fadeIn().slideX(begin: -0.1, end: 0),
            ),
          ),

        if (activePillar != null)
          Positioned(
            right: info.isMobile ? 20 : 40,
            bottom: info.isMobile ? 120 : 150,
            child: _buildPillarSlide(activePillar, info),
          ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            padding: EdgeInsets.only(bottom: info.isMobile ? 20 : 40, left: 20, right: 20),
            child: _CompactInputArea(),
          ),
        ),
      ],
    );
  }

  Widget _buildPillarSlide(TechPillar pillar, ResponsiveInfo info) {
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
          Text(pillar.label.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        ],
      ).animate().fadeIn().scale(),
    );
  }

  Widget _buildMobileLayout(AvatarState state) {
     return Material(color: ColorHelpers.surface, child: Center(child: AvatarDisplay(state: state)));
  }

  Widget _buildDesktopLayout(AvatarState state, ResponsiveInfo info) {
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

class _CompactInputArea extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CompactInputArea> createState() => _CompactInputAreaState();
}

class _CompactInputAreaState extends ConsumerState<_CompactInputArea> {
  final _ctrl = TextEditingController();
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
            onSubmitted: (v) {
              ref.read(avatarChatProvider.notifier).sendMessage(v);
              _ctrl.clear();
            },
          ),
        ),
        const SizedBox(width: 8),
        CircleAvatar(
          backgroundColor: ColorHelpers.cyan,
          child: IconButton(
            icon: const Icon(Icons.send, color: Colors.black, size: 20),
            onPressed: () {
              ref.read(avatarChatProvider.notifier).sendMessage(_ctrl.text);
              _ctrl.clear();
            },
          ),
        ),
      ],
    );
  }
}
