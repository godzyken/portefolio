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
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(_isTheatreMode ? Icons.terminal : Icons.theater_comedy, color: ColorHelpers.cyan),
            onPressed: () => setState(() => _isTheatreMode = !_isTheatreMode),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isTheatreMode 
          ? _buildTheatreHUD(avatarState, info, chatState)
          : _buildClassicChat(avatarState, info),
    );
  }

  Widget _buildTheatreHUD(AvatarState state, ResponsiveInfo info, AsyncValue<List<AvatarMessage>> chatState) {
    final List<AvatarMessage> messages = chatState.asData?.value ?? [];
    final AvatarMessage? lastMsg = messages.isEmpty ? null : messages.last;
    final bool isAvatarTalking = (lastMsg?.role == MessageRole.avatar) || (state == AvatarState.thinking);
    final TechPillar? activePillar = lastMsg?.relatedPillar;

    return Stack(
      children: [
        // 🌌 FOND CYBERNÉTIQUE
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [ColorHelpers.cyan.withValues(alpha: 0.05), Colors.black],
              ),
            ),
          ),
        ),

        // 🤖 L'AVATAR (À droite comme sur l'image)
        if (!info.isMobile)
          Positioned(
            right: -50,
            top: 0,
            bottom: 0,
            width: info.size.width * 0.5,
            child: Stack(
              children: [
                Positioned.fill(child: CustomPaint(painter: _HUDSignalsPainter())),
                AvatarDisplay(state: state),
              ],
            ),
          )
        else
          Positioned.fill(child: Opacity(opacity: 0.3, child: AvatarDisplay(state: state))),

        // 💬 BULLE IA (Positionnée pour pointer vers l'avatar)
        if (lastMsg != null && isAvatarTalking)
          Positioned(
            left: info.isMobile ? 20 : 100,
            top: info.isMobile ? 120 : 200,
            child: SizedBox(
              width: info.isMobile ? info.size.width - 40 : 450,
              child: NarrativeBubble(text: lastMsg.content).animate().fadeIn().slideX(begin: -0.1, end: 0),
            ),
          ),

        // 📊 SLIDE TECHNIQUE (Centrale / Appui)
        if (activePillar != null)
          Align(
            alignment: info.isMobile ? Alignment.center : const Alignment(-0.2, 0.5),
            child: _HUDSlide(pillar: activePillar, info: info),
          ),

        // ⌨️ INPUT HUD
        Positioned(
          left: 0,
          right: 0,
          bottom: 40,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _HUDInputArea(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassicChat(AvatarState state, ResponsiveInfo info) {
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

class _HUDSlide extends StatelessWidget {
  final TechPillar pillar;
  final ResponsiveInfo info;
  const _HUDSlide({required this.pillar, required this.info});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: info.isMobile ? 200 : 380,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: pillar.color.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [BoxShadow(color: pillar.color.withValues(alpha: 0.2), blurRadius: 30)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(pillar.skillImage, height: info.isMobile ? 120 : 220, fit: BoxFit.cover),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(pillar.icon, color: pillar.color, size: 18),
              const SizedBox(width: 10),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(pillar.label.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ).animate().fadeIn().scale(delay: 300.ms),
    );
  }
}

class _HUDInputArea extends ConsumerStatefulWidget {
  @override
  ConsumerState<_HUDInputArea> createState() => _HUDInputAreaState();
}

class _HUDInputAreaState extends ConsumerState<_HUDInputArea> {
  final _ctrl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: ColorHelpers.cyan.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 20),
          const Icon(Icons.bolt, color: ColorHelpers.cyan, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _ctrl,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                hintText: "COMMAND_INPUT: Posez une question technique...",
                hintStyle: TextStyle(color: Colors.white24, fontSize: 13),
                border: InputBorder.none,
              ),
              onSubmitted: (v) => _send(),
            ),
          ),
          CircleAvatar(
            backgroundColor: ColorHelpers.cyan,
            child: IconButton(
              icon: const Icon(Icons.arrow_upward, color: Colors.black, size: 20),
              onPressed: _send,
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    if (_ctrl.text.trim().isEmpty) return;
    ref.read(avatarChatProvider.notifier).sendMessage(_ctrl.text);
    _ctrl.clear();
  }
}

class _HUDSignalsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ColorHelpers.cyan.withValues(alpha: 0.15)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    // Dessin de lignes de circuit qui "partent" de la gauche vers l'avatar
    for (var i = 0; i < 5; i++) {
      double y = size.height * (0.2 + (i * 0.15));
      path.moveTo(0, y);
      path.lineTo(size.width * 0.2, y);
      path.lineTo(size.width * 0.3, y + 20);
      path.lineTo(size.width * 0.5, y + 20);
    }
    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
