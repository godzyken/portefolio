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
  bool _isTheatreMode = true; // Mode immersif par défaut

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
            tooltip: _isTheatreMode ? "Mode Terminal" : "Mode Théâtre",
            onPressed: () => setState(() => _isTheatreMode = !_isTheatreMode),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isTheatreMode 
          ? _buildTheatreLayout(avatarState, info, chatState)
          : (info.isMobile ? _buildMobileLayout(avatarState) : _buildDesktopLayout(avatarState, info)),
    );
  }

  Widget _buildTheatreLayout(AvatarState state, ResponsiveInfo info, AsyncValue<List<AvatarMessage>> chatState) {
    final lastMessage = chatState.asData?.value.isNotEmpty == true ? chatState.asData?.value.last : null;
    final isAvatarTalking = lastMessage?.role == MessageRole.avatar || state == AvatarState.thinking;

    return Stack(
      children: [
        // 1. L'AVATAR EN FOND (Plein écran)
        Positioned.fill(
          child: AvatarDisplay(state: state),
        ),

        // Gradient subtil pour améliorer la lisibilité du texte
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.black.withValues(alpha: 0.4),
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
        ),

        // 2. LA BULLE DE NARRATION (Flottante)
        if (lastMessage != null && isAvatarTalking)
          Positioned(
            left: info.isMobile ? 20 : 50,
            top: info.isMobile ? 100 : 150,
            child: SizedBox(
              width: info.isMobile ? info.size.width - 40 : 400,
              child: NarrativeBubble(
                text: lastMessage.content,
              ).animate().fadeIn().slideX(begin: -0.1, end: 0),
            ),
          ),

        // 3. LES SLIDES D'APPUI (À droite)
        if (lastMessage != null && lastMessage.relatedPillar != null)
          Positioned(
            right: info.isMobile ? 20 : 40,
            bottom: info.isMobile ? 120 : 150,
            child: _buildPillarSlide(lastMessage.relatedPillar!, info),
          ),

        // 4. ZONE DE SAISIE (Discrète en bas)
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withValues(alpha: 0.8), Colors.transparent],
              ),
            ),
            padding: EdgeInsets.only(
              bottom: info.isMobile ? 20 : 40,
              left: info.isMobile ? 20 : 100,
              right: info.isMobile ? 20 : 100,
            ),
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
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: pillar.color.withValues(alpha: 0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: pillar.color.withValues(alpha: 0.3), 
            blurRadius: 30,
            spreadRadius: -5
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(pillar.skillImage, height: info.isMobile ? 120 : 250, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(pillar.icon, color: pillar.color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  pillar.label.toUpperCase(), 
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 14)
                ),
              ),
            ],
          ),
        ],
      ).animate().fadeIn().scale(delay: 200.ms),
    );
  }

  Widget _buildMobileLayout(AvatarState state) {
    return Material(
      color: ColorHelpers.surface,
      child: Column(
        children: [
          const SizedBox(height: 80),
          SizedBox(
            height: 250,
            child: AvatarDisplay(state: state),
          ),
          const Expanded(
            child: AvatarChatPanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(AvatarState state, ResponsiveInfo info) {
    return Material(
      color: ColorHelpers.surface,
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: AvatarDisplay(state: state),
          ),
          VerticalDivider(color: ColorHelpers.border, width: 1),
          const Expanded(
            flex: 6,
            child: AvatarChatPanel(),
          ),
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
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Posez votre question technique...",
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
            ),
            onSubmitted: (val) {
              ref.read(avatarChatProvider.notifier).sendMessage(val);
              _controller.clear();
            },
          ),
        ),
        const SizedBox(width: 12),
        CircleAvatar(
          radius: 25,
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
    );
  }
}
