import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:portefolio/core/provider/unified_image_provider.dart';
import 'package:portefolio/features/generator/data/extention_models.dart';

import '../../../../core/affichage/colors_spec.dart';
import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/provider/expertise_provider.dart';
import '../../../../core/provider/json_data_provider.dart';
import '../../../../core/ui/ui_widgets_extentions.dart';

class ServicesSlider extends ConsumerStatefulWidget {
  const ServicesSlider({super.key});

  @override
  ConsumerState<ServicesSlider> createState() => _ServicesSliderState();
}

class _ServicesSliderState extends ConsumerState<ServicesSlider> {
  late final PageController controller;

  final Map<String, GlobalKey> _serviceKeys = {};

  GlobalKey _getBtnKey(String serviceId) {
    return _serviceKeys.putIfAbsent(
        serviceId, () => GlobalKey(debugLabel: 'btn_$serviceId'));
  }

  // Gestion de l'overlay
  OverlayEntry? _overlayEntry;
  bool _isTogglingOverlay = false;

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
      ResponsiveInfo info, GlobalKey btnKey) {
    if (_isTogglingOverlay) return;
    _isTogglingOverlay = true;

    if (_overlayEntry != null) {
      _removeOverlay();
      _isTogglingOverlay = false;
      setState(() {});
      return;
    }

    // 1. Calcul de la position du bouton cible
    final RenderBox? renderBox =
        btnKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      _isTogglingOverlay = false;
      return;
    }

    final offset = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    // 2. Création de l'entrée d'overlay avec le widget animé
    _overlayEntry = OverlayEntry(
      builder: (context) => _ExpertiseBubblesOverlay(
        expertise: expertise,
        targetOffset: offset,
        targetSize: size,
        onClose: () {
          // Callback pour synchroniser l'état du slider
          _removeOverlay();
          setState(() {});
        },
      ),
    );

    // 3. Insertion dans l'overlay global
    Overlay.of(context).insert(_overlayEntry!);

    _isTogglingOverlay = false;
    setState(() {});
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
            allowImplicitScrolling: false,
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              final btnKey = _getBtnKey(service.id); // Clé unique par instance
              final slideKey = ValueKey('slide_${service.id}_$index');

              return AnimatedBuilder(
                key: slideKey,
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
                                service, expertise, info, btnKey);
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
                                  child: CachedImage(
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

class _ExpertiseBubblesOverlay extends StatefulWidget {
  final ServiceExpertise expertise;
  final Offset targetOffset; // Position du bouton
  final Size targetSize; // Taille du bouton
  final VoidCallback onClose; // Pour fermer proprement

  const _ExpertiseBubblesOverlay({
    required this.expertise,
    required this.targetOffset,
    required this.targetSize,
    required this.onClose,
  });

  @override
  State<_ExpertiseBubblesOverlay> createState() =>
      _ExpertiseBubblesOverlayState();
}

class _ExpertiseBubblesOverlayState extends State<_ExpertiseBubblesOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Animation de 400ms pour un effet dynamique
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Courbe elasticOut pour l'effet de "rebond" premium
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    // Lancer l'animation dès l'apparition
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _closeAnimated() {
    // Jouer l'animation à l'envers avant de fermer
    _controller.reverse().then((_) => widget.onClose());
  }

  @override
  Widget build(BuildContext context) {
    // Calcul pour centrer l'overlay au-dessus du bouton
    const overlayWidth = 220.0;
    final left = widget.targetOffset.dx +
        (widget.targetSize.width / 2) -
        (overlayWidth / 2);
    final top = widget.targetOffset.dy - 10; // Un peu de marge au-dessus

    return Stack(
      children: [
        // 1. Fond transparent pour fermer au clic n'importe où
        GestureDetector(
          onTap: _closeAnimated,
          child: Container(color: Colors.transparent),
        ),

        // 2. Les bulles animées
        Positioned(
          left: left,
          top: top,
          child: Material(
            color: Colors.transparent,
            // Applique l'animation de Scale
            child: ScaleTransition(
              scale: _scaleAnimation,
              alignment:
                  Alignment.bottomCenter, // Point d'origine de l'animation
              child: Container(
                width: overlayWidth,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ColorHelpers.darkBg
                      .withValues(alpha: 0.95), // Fond sombre translucide
                  borderRadius: BorderRadius.circular(16),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Compétences clés',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    // Génération dynamique des bulles
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 300),
                      child: SingleChildScrollView(
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.expertise.skills.map((skill) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.5)),
                              ),
                              child: Text(
                                skill.name,
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
