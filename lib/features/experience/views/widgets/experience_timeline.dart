import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/ui/ui_widgets_extentions.dart';
import 'package:portefolio/features/experience/views/widgets/experience_widgets_extentions.dart';
import 'package:timelines_plus/timelines_plus.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../generator/views/generator_widgets_extentions.dart';
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

    final scrollController = ref.watch(timelineScrollControllerProvider);

    // Détermine si le timeline doit être horizontal
    final isWide = info.size.width >= 800;

    return ResponsiveBox(
      height: isWide ? 200 : null,
      width: isWide ? null : double.infinity,
      decoration: const BoxDecoration(
        image: DecorationImage(
          opacity: 0.5,
          image: AssetImage('assets/images/frise-mur.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: FadeTransition(
        opacity: fadeCtrl,
        child: Listener(
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              final delta = event.scrollDelta.dy;

              if (scrollController.hasClients) {
                scrollController.animateTo(
                  scrollController.offset + delta, // Nouvelle position
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut,
                );
              }
            }
          },
          child: Timeline.tileBuilder(
            controller: scrollController,
            scrollDirection: isWide ? Axis.horizontal : Axis.vertical,
            shrinkWrap: false,
            physics: const BouncingScrollPhysics(),
            builder: TimelineTileBuilder.fromStyle(
              itemCount: experiences.length,
              contentsAlign: ContentsAlign.alternating,
              oppositeContentsBuilder: (context, index) => ResponsiveBox(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ResponsiveText(
                  experiences[index].periode,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              contentsBuilder: (context, index) => GestureDetector(
                onTap: () =>
                    _showExperienceModal(context, experiences[index], info),
                child: ClipOval(
                  clipBehavior: Clip.hardEdge,
                  child: SmartImage(
                    path: experiences[index].logo,
                    responsiveSize: ResponsiveImageSize.medium,
                    fit: BoxFit.fill,
                    enableShimmer: true,
                    useCache: true,
                    colorBlendMode: BlendMode.luminosity,
                    color: Colors.white,
                    fallbackColor: Colors.black54,
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: Colors.black54,
                      width: 2,
                      style: BorderStyle.solid,
                      strokeAlign: BorderSide.strokeAlignInside,
                    ),
                  ),
                ),
              ),
              indicatorPositionBuilder: (_, __) => 0.5,
              indicatorStyle: IndicatorStyle.outlined,
              connectorStyle: ConnectorStyle.solidLine,
            ),
          ),
        ),
      ),
    );
  }

  void _showExperienceModal(
      BuildContext context, Experience experience, ResponsiveInfo info) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (_) => OrientationBuilder(
        builder: (context, orientation) {
          final initialSize = orientation == Orientation.portrait ? 0.5 : 0.7;
          return DraggableScrollableSheet(
              expand: false,
              initialChildSize: initialSize,
              minChildSize: 0.5,
              maxChildSize: 0.95,
              builder: (context, scrollController) {
                final screenHeight = info.size.height;
                return SingleChildScrollView(
                    controller: scrollController,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: screenHeight * initialSize,
                        maxHeight: screenHeight * 0.95,
                      ),
                      child: ResponsiveBox(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 16),
                        child: PokerExperienceCard(
                            experience: experience,
                            onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => ImmersiveExperienceDetail(
                                          experience: experience)),
                                )),
                      ),
                    ));
              });
        },
      ),
    );
  }
}

/// Wrapper pour injecter le fade AnimationController via Riverpod
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
