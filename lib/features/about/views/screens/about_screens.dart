import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:portefolio/core/affichage/screen_size_detector.dart';
import 'package:portefolio/core/ui/widgets/responsive_text.dart';
import 'package:portefolio/core/ui/widgets/smart_image.dart';

class AboutSection extends ConsumerStatefulWidget {
  const AboutSection({super.key});

  @override
  ConsumerState<AboutSection> createState() => _AboutSectionState();
}

class _AboutSectionState extends ConsumerState<AboutSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final info = ref.watch(responsiveInfoProvider);
    final theme = Theme.of(context);
    final isWide = info.size.width > 800;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ResponsiveBox(
        width: double.infinity,
        paddingSize: info.isMobile ? ResponsiveSpacing.m : ResponsiveSpacing.l,
        padding: EdgeInsets.symmetric(
          horizontal: info.isMobile ? 24 : 48,
          vertical: info.isMobile ? 48 : 72,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: isWide
                ? _buildWideLayout(context, theme, info)
                : _buildNarrowLayout(context, theme, info),
          ),
        ),
      ),
    );
  }

  Widget _buildWideLayout(
    BuildContext context,
    ThemeData theme,
    ResponsiveInfo info,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image à gauche
        Flexible(
          flex: 4,
          child: _buildProfileImage(context, theme, info),
        ),
        const ResponsiveBox(
            paddingSize: ResponsiveSpacing.xl), // Contenu à droite
        Flexible(
          flex: 6,
          child: _buildContent(context, theme, false),
        ),
      ],
    );
  }

  Widget _buildNarrowLayout(
    BuildContext context,
    ThemeData theme,
    ResponsiveInfo info,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildProfileImage(context, theme, info),
        const ResponsiveBox(height: 40),
        _buildContent(context, theme, true),
      ],
    );
  }

  Widget _buildProfileImage(
    BuildContext context,
    ThemeData theme,
    ResponsiveInfo info,
  ) {
    final imageSize = info.isMobile
        ? info.size.width * 0.65
        : info.isTablet
            ? info.size.width * 0.35
            : 320.0;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.elasticOut,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Hero(
            tag: 'profile_image',
            child: ResponsiveBox(
              width: imageSize,
              height: imageSize,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withValues(alpha: 0.3),
                    theme.colorScheme.secondary.withValues(alpha: 0.3),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(8),
              paddingSize: ResponsiveSpacing.s,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: SmartImage(
                  path: 'assets/images/me_portrait_2.webp',
                  fit: BoxFit.cover,
                  fallbackIcon: Icons.person,
                  fallbackColor: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent(
    BuildContext context,
    ThemeData theme,
    bool isCentered,
  ) {
    return Column(
      crossAxisAlignment:
          isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        // Titre
        _buildAnimatedText(
          delay: 200,
          child: ResponsiveText.titleLarge(
            "Emryck Doré",
            style: GoogleFonts.montserrat(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              foreground: Paint()
                ..shader = LinearGradient(
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary,
                  ],
                ).createShader(const Rect.fromLTWH(0, 0, 400, 70)),
            ),
            textAlign: isCentered ? TextAlign.center : TextAlign.left,
          ),
        ),
        const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
        // Badge rôle
        _buildAnimatedText(
          delay: 400,
          child: ResponsiveBox(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary.withValues(alpha: 0.15),
                  theme.colorScheme.secondary.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.code,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "Développeur Flutter Freelance",
                  style: GoogleFonts.openSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const ResponsiveBox(paddingSize: ResponsiveSpacing.xl),
        // Description
        _buildAnimatedText(
          delay: 600,
          child: _buildDescription(context, theme, isCentered),
        ),
        const ResponsiveBox(paddingSize: ResponsiveSpacing.xl),
        // Statistiques
        _buildAnimatedText(
          delay: 800,
          child: _buildStats(context, theme, isCentered),
        ),
      ],
    );
  }

  Widget _buildAnimatedText({
    required int delay,
    required Widget child,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildDescription(
    BuildContext context,
    ThemeData theme,
    bool isCentered,
  ) {
    return Column(
      crossAxisAlignment:
          isCentered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        _buildParagraph(
          context,
          theme,
          isCentered,
          "Je conçois des applications Flutter sur mesure pour aider les entreprises à digitaliser leurs processus métiers.",
          isFirst: true,
        ),
        const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
        _buildParagraph(
          context,
          theme,
          isCentered,
          "Chaque année, je développe un projet complet — de l'idée à la mise en production — pour transformer des besoins réels en solutions performantes et durables.",
          isFirst: false,
        ),
        const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
        _buildParagraph(
          context,
          theme,
          isCentered,
          "Travaillant seul, je maîtrise chaque aspect du développement (UX, architecture, intégration, déploiement) afin d'offrir des outils clairs, efficaces et alignés sur les objectifs de mes clients.",
          isFirst: false,
        ),
      ],
    );
  }

  Widget _buildParagraph(
    BuildContext context,
    ThemeData theme,
    bool isCentered,
    String text, {
    required bool isFirst,
  }) {
    return ResponsiveBox(
      padding: const EdgeInsets.all(16),
      paddingSize: ResponsiveSpacing.m,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isFirst ? Icons.stars : Icons.arrow_right_rounded,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          const ResponsiveBox(width: 12),
          Expanded(
            child: ResponsiveText(
              text,
              textAlign: isCentered ? TextAlign.center : TextAlign.start,
              style: GoogleFonts.openSans(
                fontSize: 15,
                height: 1.6,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(
    BuildContext context,
    ThemeData theme,
    bool isCentered,
  ) {
    final stats = [
      {
        'icon': Icons.work_history,
        'number': '10+',
        'label': 'Années\nd\'expérience'
      },
      {'icon': Icons.apps, 'number': '10+', 'label': 'Projets\nréalisés'},
      {'icon': Icons.star, 'number': '97%', 'label': 'Satisfaction\nclient'},
    ];

    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: isCentered ? WrapAlignment.center : WrapAlignment.start,
      children: stats.map((stat) {
        return ResponsiveBox(
          width: 140,
          padding: const EdgeInsets.all(20),
          paddingSize: ResponsiveSpacing.l,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withValues(alpha: 0.1),
                theme.colorScheme.secondary.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                stat['icon'] as IconData,
                color: theme.colorScheme.primary,
                size: 32,
              ),
              const ResponsiveBox(paddingSize: ResponsiveSpacing.m),
              ResponsiveText(
                stat['number'] as String,
                style: GoogleFonts.montserrat(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const ResponsiveBox(paddingSize: ResponsiveSpacing.xs),
              ResponsiveText(
                stat['label'] as String,
                style: GoogleFonts.openSans(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
