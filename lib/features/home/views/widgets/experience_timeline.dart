import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:timelines_plus/timelines_plus.dart';

import '../../data/extentions_models.dart';
import 'experience_card.dart';

class ExperienceTimeline extends StatefulWidget {
  final List<Experience> experiences;
  const ExperienceTimeline({super.key, required this.experiences});

  @override
  State<ExperienceTimeline> createState() => _ExperienceTimelineState();
}

class _ExperienceTimelineState extends State<ExperienceTimeline>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _fadeCtrl;
  Orientation? _lastOrientation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    // Start animation after first frame
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _fadeCtrl.forward();
    });
  }

  /// ➜ ICI : on lit MediaQuery/View **après** initState
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _lastOrientation ??= MediaQuery.of(context).orientation;
  }

  @override
  void didChangeMetrics() {
    if (!mounted) return;

    final current = MediaQuery.of(context).orientation;
    if (_lastOrientation != null && _lastOrientation != current) {
      _lastOrientation = current;

      setState(() {});
    }
    super.didChangeMetrics();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: FadeTransition(
            opacity: _fadeCtrl,
            child: Timeline.tileBuilder(
              key: ValueKey(isWide),
              scrollDirection: isWide ? Axis.horizontal : Axis.vertical,
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              builder: TimelineTileBuilder.fromStyle(
                itemCount: widget.experiences.length,
                contentsAlign: ContentsAlign.alternating,
                oppositeContentsBuilder:
                    (context, index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        widget.experiences[index].periode,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                contentsBuilder:
                    (context, index) => GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          context: context,
                          useSafeArea: true,
                          isScrollControlled: true,
                          builder:
                              (_) => OrientationBuilder(
                                builder: (context, orientation) {
                                  final initialSize =
                                      orientation == Orientation.portrait
                                          ? 0.5
                                          : 0.7;

                                  return DraggableScrollableSheet(
                                    expand: false,
                                    initialChildSize: initialSize,
                                    minChildSize: 0.5,
                                    maxChildSize: 0.95,
                                    builder:
                                        (context, scrollController) =>
                                            SingleChildScrollView(
                                              controller: scrollController,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 16,
                                                  ),
                                              child: ModernExperienceCard(
                                                experience:
                                                    widget.experiences[index],
                                              ),
                                            ),
                                  );
                                },
                              ),
                        );
                      },
                      child: ClipOval(
                        child: Image.asset(
                          widget.experiences[index].image,
                          width: 48,
                          height: 48,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                indicatorPositionBuilder: (context, index) => 0.5,
                indicatorStyle: IndicatorStyle.outlined,
                connectorStyle: ConnectorStyle.solidLine,
              ),
            ),
          ),
        );
      },
    );
  }
}
