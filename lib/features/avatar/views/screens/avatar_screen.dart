import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/affichage/colors_spec.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import '../widgets/avatar_display.dart';
import '../widgets/avatar_chat_panel.dart';
import '../../notifiers/avatar_chat_notifier.dart';

class AvatarScreen extends ConsumerWidget {
  const AvatarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(responsiveInfoProvider);
    final chatState = ref.watch(avatarChatProvider);
    
    // Déterminer l'état de l'avatar
    final avatarState = chatState.isLoading 
        ? AvatarState.thinking 
        : (chatState.asData?.value.isNotEmpty ?? false)
            ? (chatState.asData!.value.last.role == MessageRole.avatar ? AvatarState.talking : AvatarState.idle)
            : AvatarState.idle;

    return Scaffold(
      backgroundColor: ColorHelpers.surface,
      appBar: AppBar(
        title: const Text("AVATAR INTERACTIF", style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: info.isMobile 
          ? _buildMobileLayout(avatarState) 
          : _buildDesktopLayout(avatarState, info),
    );
  }

  Widget _buildMobileLayout(AvatarState state) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: AvatarDisplay(state: state),
        ),
        const Expanded(
          child: AvatarChatPanel(),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(AvatarState state, ResponsiveInfo info) {
    return Row(
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
    );
  }
}
