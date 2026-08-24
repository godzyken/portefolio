import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:timelines_plus/timelines_plus.dart';
import 'package:portefolio/features/generator/views/widgets/immersive_experience_detail.dart';

import '../../../../core/affichage/colors_spec.dart';
import '../../../../core/affichage/screen_size_detector.dart';
import '../../controllers/providers/timeline_scroll_controller_provider.dart';
import '../../data/experiences_data.dart';

final fadeCtrlProvider = Provider<AnimationController>((_) {
  throw UnimplementedError();
});

class ExperienceTimeline extends ConsumerWidget {
  final List<Experience> experiences;
  const ExperienceTimeline({super.key, required this.experiences});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(responsiveInfoProvider);
    final fadeCtrl = ref.watch(fadeCtrlProvider);
    final scrollCtrl = ref.watch(timelineScrollControllerProvider);
    final isWide = info.size.width >= 800;

    return ResponsiveBox(
      height: isWide ? 220 : null,
      width: isWide ? null : double.infinity,
      decoration: BoxDecoration(
        // ── Background original conservé ──
        image: const DecorationImage(
          opacity: 0.35,
          image: AssetImage('assets/images/backgrounds/frise_mur.png'),
          fit: BoxFit.cover,
        ),
        // ── Overlay sombre pour faire ressortir les éléments ──
        color: ColorHelpers.surface.withValues(alpha: 0.55),
      ),
      child: Stack(
        children: [
          // ── Lignes de scan horizontales (ambiance HUD) ──
          Positioned.fill(child: CustomPaint(painter: _ScanlinePainter())),

          // ── Lueur cyan en haut ──
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  ColorHelpers.cyan.withValues(alpha: 0.8),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          // ── Lueur magenta en bas ──
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 1.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  ColorHelpers.magenta.withValues(alpha: 0.5),
                  Colors.transparent,
                ]),
              ),
            ),
          ),

          // ── Timeline ──
          FadeTransition(
            opacity: fadeCtrl,
            child: Listener(
              onPointerSignal: (event) {
                if (event is PointerScrollEvent && scrollCtrl.hasClients) {
                  scrollCtrl.animateTo(
                    scrollCtrl.offset + event.scrollDelta.dy,
                    duration: const Duration(milliseconds: 100),
                    curve: Curves.easeOut,
                  );
                }
              },
              child: Timeline.tileBuilder(
                controller: scrollCtrl,
                scrollDirection: isWide ? Axis.horizontal : Axis.vertical,
                shrinkWrap: false,
                physics: const BouncingScrollPhysics(),
                builder: TimelineTileBuilder.connected(
                  itemCount: experiences.length,
                  contentsAlign: ContentsAlign.alternating,

                  // ── Période (texte au-dessus/dessous) ──
                  oppositeContentsBuilder: (context, index) => _PeriodeLabel(
                    periode: experiences[index].periode,
                  ),

                  // ── Logo (contenu principal) ──
                  contentsBuilder: (context, index) => _LogoTile(
                    experience: experiences[index],
                    onTap: () =>
                        _showExperienceModal(context, experiences[index], info),
                  ),

                  // ── Indicateur (nœud) cyberpunk ──
                  indicatorBuilder: (context, index) => const _CyberNode(),

                  // ── Connecteur (ligne) ──
                  connectorBuilder: (context, index, type) {
                    return DecoratedLineConnector(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ColorHelpers.cyan.withValues(alpha: 0.3),
                            ColorHelpers.magenta.withValues(alpha: 0.2),
                            ColorHelpers.cyan.withValues(alpha: 0.3),
                          ],
                        ),
                      ),
                    );
                  },

                  indicatorPositionBuilder: (_, __) => 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showExperienceModal(
    BuildContext context,
    Experience experience,
    ResponsiveInfo info,
  ) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, a, __) => FadeTransition(
          opacity: a,
          child: ImmersiveExperienceDetail(experience: experience),
        ),
        transitionDuration: const Duration(milliseconds: 400),
        fullscreenDialog: true,
      ),
    );
  }
}

class _PeriodeLabel extends StatelessWidget {
  final String periode;
  const _PeriodeLabel({required this.periode});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ResponsiveText.titleMedium(
        periode,
        style: const TextStyle(
          color: ColorHelpers.textMuted,
          fontFamily: 'monospace',
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _LogoTile extends StatefulWidget {
  final Experience experience;
  final VoidCallback onTap;
  const _LogoTile({required this.experience, required this.onTap});

  @override
  State<_LogoTile> createState() => _LogoTileState();
}

class _LogoTileState extends State<_LogoTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: _hovered
                ? ColorHelpers.surface.withValues(alpha: 0.9)
                : ColorHelpers.surface.withValues(alpha: 0.75),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: _hovered
                  ? ColorHelpers.cyan.withValues(alpha: 0.7)
                  : ColorHelpers.border.withValues(alpha: 0.4),
              width: _hovered ? 2 : 1,
            ),
            boxShadow: [
              if (_hovered)
                BoxShadow(
                  color: ColorHelpers.cyan.withValues(alpha: 0.25),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipOval(
                    child: SmartImage(
                      path: widget.experience.logo,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      enableShimmer: true,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: ResponsiveText.titleMedium(
                          widget.experience.entreprise,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ResponsiveText.bodyMedium(
                        widget.experience.poste,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ColorHelpers.textMuted,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CyberNode extends StatelessWidget {
  const _CyberNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: ColorHelpers.surface,
        border: Border.all(
            color: ColorHelpers.cyan.withValues(alpha: 0.6), width: 2),
        boxShadow: [
          BoxShadow(
            color: ColorHelpers.cyan.withValues(alpha: 0.3),
            blurRadius: 6,
          ),
        ],
      ),
    );
  }
}

class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ColorHelpers.cyan.withValues(alpha: 0.025)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 5) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_ScanlinePainter _) => false;
}

class ExperienceTimelineWrapper extends StatefulWidget {
  final List<Experience> experiences;
  const ExperienceTimelineWrapper({super.key, required this.experiences});

  @override
  State<ExperienceTimelineWrapper> createState() =>
      _ExperienceTimelineWrapperState();
}

class _ExperienceTimelineWrapperState extends State<ExperienceTimelineWrapper>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scrollController = ScrollController();
    SchedulerBinding.instance.addPostFrameCallback((_) => _fadeCtrl.forward());
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        fadeCtrlProvider.overrideWithValue(_fadeCtrl),
        timelineScrollControllerProvider.overrideWithValue(_scrollController),
      ],
      child: ExperienceTimeline(experiences: widget.experiences),
    );
  }
}
