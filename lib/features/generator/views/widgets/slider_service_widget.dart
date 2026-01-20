import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/provider/expertise_provider.dart';
import '../../../../core/provider/json_data_provider.dart';
import '../../../../core/ui/cards/base_card.dart';
import '../../../../core/ui/ui_widgets_extentions.dart';
import '../../../home/views/widgets/service_expertise_overlay.dart';

class ServicesSlider extends ConsumerStatefulWidget {
  const ServicesSlider({super.key});

  @override
  ConsumerState<ServicesSlider> createState() => _ServicesSliderState();
}

class _ServicesSliderState extends ConsumerState<ServicesSlider> {
  late final PageController controller;

  // Gestion de l'overlay
  OverlayEntry? _overlayEntry;
  bool _isTogglingOverlay = false;
  int _currentSkillIndex = 0;
  final Map<String, GlobalKey> _buttonKeys = {};
  final Map<String, GlobalKey> _cardKeys = {};

  @override
  void initState() {
    super.initState();
    controller = PageController(viewportFraction: 0.85);

    controller.addListener(() {
      // Si l'utilisateur commence à scroller et qu'un overlay est ouvert
      if (_overlayEntry != null) {
        // On ferme l'overlay proprement pour éviter qu'il ne "flotte"
        // pendant que les cartes défilent derrière lui.
        _removeOverlay();

        // On déclenche un setState pour que l'interface sache
        // que _overlayEntry est redevenu nul
        if (mounted) setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _removeOverlay();
    controller.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _handleServiceTap(BuildContext context, dynamic service) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Service sélectionné : ${service.title}'),
        action: SnackBarAction(label: 'Détails', onPressed: () {}),
      ),
    );
  }

  void _toggleSkillBubbles(Service service, ServiceExpertise expertise,
      ResponsiveInfo info, GlobalKey btnKey, GlobalKey cardKey) {
    if (_isTogglingOverlay) {
      debugPrint('[CARD] ⚠️ Toggle déjà en cours...');
      return;
    }

    _isTogglingOverlay = true;

    if (_overlayEntry != null) {
      _removeOverlay();
      setState(() {});
      _isTogglingOverlay = false;
      return;
    }

    // Utilisation de votre logique existante
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) {
        _isTogglingOverlay = false;
        return;
      }

      SchedulerBinding.instance.addPostFrameCallback((_) {
        try {
          final newOverlay = ServiceExpertiseOverlay.createOverlay(
            context: context,
            buttonKey: btnKey,
            cardKey: cardKey,
            expertise: expertise,
            info: info,
            service: service,
            currentSkillIndex: _currentSkillIndex,
            onSkillTap: (index) {
              setState(() {
                _currentSkillIndex = index;
                _overlayEntry?.markNeedsBuild();
              });
            },
            onClose: () {
              _removeOverlay();
              setState(() {});
            },
          );

          if (newOverlay != null && mounted) {
            Overlay.of(context).insert(newOverlay);
            setState(() => _overlayEntry = newOverlay);
          } else {
            debugPrint('[CARD] ❌ Échec de création de l\'overlay');
          }
        } catch (e, stack) {
          debugPrint('[CARD] ❌ Erreur lors de la création de l\'overlay: $e');
          debugPrint('Stack: $stack');
        } finally {
          _isTogglingOverlay = false;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final asyncServices = ref.watch(servicesJsonProvider);
    final info = ref.watch(responsiveInfoProvider);

    return asyncServices.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) =>
          Center(child: Text('Erreur lors du chargement des services: $e')),
      data: (services) {
        if (services.isEmpty) {
          return const SizedBox.shrink();
        }

        return AspectRatio(
          aspectRatio: info.isMobile ? 1.0 : 1.5,
          child: PageView.builder(
            controller: controller,
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              final btnKey = _buttonKeys.putIfAbsent(
                  service.id, () => GlobalObjectKey('btn_${service.id}'));

              final cardKey = _cardKeys.putIfAbsent(
                  service.id, () => GlobalObjectKey('card_${service.id}'));

              return AnimatedBuilder(
                animation: controller,
                builder: (context, child) {
                  double value = 1.0;

                  if (controller.position.haveDimensions) {
                    value = (controller.page! - index).abs();
                    // Plus de zoom si la valeur est plus proche de 1.0
                    value = (1 - (value * 0.3)).clamp(0.8, 1.0);
                  }

                  return Transform.scale(
                    scale: Curves.easeOut.transform(value),
                    child: child,
                  );
                },
                child: RepaintBoundary(
                  child: GestureDetector(
                    child: UnifiedContentCard(
                      key: cardKey,
                      title: service.title,
                      subtitle: service.description,
                      leading: Icon(service.icon),
                      trailing: IconButton(
                        key: btnKey,
                        tooltip: service.category.displayName,
                        icon: Icon(Icons.psychology_outlined),
                        onPressed: () {
                          // 1. Lire la data via le provider spécialisé
                          final expertise =
                              ref.read(serviceExpertiseProvider(service.id));

                          if (expertise != null) {
                            _toggleSkillBubbles(
                                service, expertise, info, btnKey, cardKey);
                          } else {
                            debugPrint(
                                "⚠️ Aucune expertise trouvée pour l'ID: ${service.id}");
                          }
                        },
                      ),
                      content: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Opacity(
                                  opacity: 0.4,
                                  child: SmartImage(
                                    path: service.imageUrl!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 1. Liste des Features
                                    ...service.features.map((feature) =>
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 6.0),
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.check_circle_outline,
                                                size: 16,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .secondary,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: ResponsiveText.bodySmall(
                                                  feature,
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )),

                                    const SizedBox(height: 16),
                                  ],
                                ),
                              )
                            ],
                          )),
                      config: CardConfig.expanded().copyWith(
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        onTap: () => _handleServiceTap(context, service),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: ResponsiveText.bodyMedium(
                                'Service : ${service.title}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
