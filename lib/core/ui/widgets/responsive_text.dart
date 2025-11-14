import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../responsive_constants.dart';

class ResponsiveText extends ConsumerWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool softWrap;

  // Niveaux de taille prédéfinis
  final ResponsiveTextSize size;

  const ResponsiveText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
    this.size = ResponsiveTextSize.bodyMedium,
  });

  // 🎯 Constructeurs nommés pour faciliter l'usage
  const ResponsiveText.displayLarge(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : size = ResponsiveTextSize.displayLarge;

  const ResponsiveText.displayMedium(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : size = ResponsiveTextSize.displayMedium;

  const ResponsiveText.displaySmall(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : size = ResponsiveTextSize.displaySmall;

  const ResponsiveText.titleLarge(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : size = ResponsiveTextSize.titleLarge;

  const ResponsiveText.titleMedium(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : size = ResponsiveTextSize.titleMedium;

  const ResponsiveText.titleSmall(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : size = ResponsiveTextSize.titleSmall;

  const ResponsiveText.bodyLarge(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : size = ResponsiveTextSize.bodyLarge;

  const ResponsiveText.bodyMedium(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.softWrap = true,
  }) : size = ResponsiveTextSize.bodyMedium;

  const ResponsiveText.bodySmall(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.softWrap = true,
  }) : size = ResponsiveTextSize.bodySmall;

  const ResponsiveText.headlineLarge(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : size = ResponsiveTextSize.headlineLarge;

  const ResponsiveText.headlineMedium(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap = true,
  }) : size = ResponsiveTextSize.headlineMedium;

  const ResponsiveText.headlineSmall(
    this.text, {
    super.key,
    this.style,
    this.maxLines,
    this.overflow,
    this.textAlign,
    this.softWrap = true,
  }) : size = ResponsiveTextSize.headlineSmall;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final constants = ref.watch(responsiveConstantsProvider);
    final theme = Theme.of(context);

    // Récupérer la taille de police responsive
    final fontSize = _getFontSize(constants);

    // Récupérer le style de base du thème
    final TextStyle? baseStyle = _getBaseStyle(theme);
    final finalStyle = baseStyle?.copyWith(fontSize: fontSize).merge(style);

    return Text(
      text,
      style: finalStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
      softWrap: softWrap,
    );
  }

  double _getFontSize(ResponsiveConstants constants) {
    return switch (size) {
      ResponsiveTextSize.displayLarge => constants.displayLarge,
      ResponsiveTextSize.displayMedium => constants.displayMedium,
      ResponsiveTextSize.displaySmall => constants.displaySmall,
      ResponsiveTextSize.headlineLarge => constants.headlineLarge,
      ResponsiveTextSize.headlineMedium => constants.headlineMedium,
      ResponsiveTextSize.headlineSmall => constants.headlineSmall,
      ResponsiveTextSize.titleLarge => constants.titleLarge,
      ResponsiveTextSize.titleMedium => constants.titleMedium,
      ResponsiveTextSize.titleSmall => constants.titleSmall,
      ResponsiveTextSize.bodyLarge => constants.bodyLarge,
      ResponsiveTextSize.bodyMedium => constants.bodyMedium,
      ResponsiveTextSize.bodySmall => constants.bodySmall,
      ResponsiveTextSize.labelLarge => constants.labelLarge,
      ResponsiveTextSize.labelMedium => constants.labelMedium,
      ResponsiveTextSize.labelSmall => constants.labelSmall,
    };
  }

  TextStyle? _getBaseStyle(ThemeData theme) {
    return switch (size) {
      ResponsiveTextSize.displayLarge => theme.textTheme.displayLarge,
      ResponsiveTextSize.displayMedium => theme.textTheme.displayMedium,
      ResponsiveTextSize.displaySmall => theme.textTheme.displaySmall,
      ResponsiveTextSize.headlineLarge => theme.textTheme.headlineLarge,
      ResponsiveTextSize.headlineMedium => theme.textTheme.headlineMedium,
      ResponsiveTextSize.headlineSmall => theme.textTheme.headlineSmall,
      ResponsiveTextSize.titleLarge => theme.textTheme.titleLarge,
      ResponsiveTextSize.titleMedium => theme.textTheme.titleMedium,
      ResponsiveTextSize.titleSmall => theme.textTheme.titleSmall,
      ResponsiveTextSize.bodyLarge => theme.textTheme.bodyLarge,
      ResponsiveTextSize.bodyMedium => theme.textTheme.bodyMedium,
      ResponsiveTextSize.bodySmall => theme.textTheme.bodySmall,
      ResponsiveTextSize.labelLarge => theme.textTheme.labelLarge,
      ResponsiveTextSize.labelMedium => theme.textTheme.labelMedium,
      ResponsiveTextSize.labelSmall => theme.textTheme.labelSmall,
    };
  }
}

enum ResponsiveTextSize {
  displayLarge,
  displayMedium,
  displaySmall,
  headlineLarge,
  headlineMedium,
  headlineSmall,
  titleLarge,
  titleMedium,
  titleSmall,
  bodyLarge,
  bodyMedium,
  bodySmall,
  labelLarge,
  labelMedium,
  labelSmall,
}

class ResponsiveBox extends ConsumerWidget {
  final Widget? child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final ResponsiveSpacing? paddingSize;
  final ResponsiveSpacing? marginSize;
  final Decoration? decoration;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;

  const ResponsiveBox({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.paddingSize,
    this.marginSize,
    this.decoration,
    this.width,
    this.height,
    this.alignment,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final constants = ref.watch(responsiveConstantsProvider);

    return Container(
      width: width,
      height: height,
      padding: padding ?? _getPadding(constants),
      margin: margin ?? _getMargin(constants),
      decoration: decoration,
      alignment: alignment,
      child: child,
    );
  }

  EdgeInsets? _getPadding(ResponsiveConstants constants) {
    if (paddingSize == null) return null;
    final value = _getSpacingValue(constants, paddingSize!);
    return EdgeInsets.all(value);
  }

  EdgeInsets? _getMargin(ResponsiveConstants constants) {
    if (marginSize == null) return null;
    final value = _getSpacingValue(constants, marginSize!);
    return EdgeInsets.all(value);
  }

  double _getSpacingValue(
      ResponsiveConstants constants, ResponsiveSpacing size) {
    return switch (size) {
      ResponsiveSpacing.xs => constants.spacingXS,
      ResponsiveSpacing.s => constants.spacingS,
      ResponsiveSpacing.m => constants.spacingM,
      ResponsiveSpacing.l => constants.spacingL,
      ResponsiveSpacing.xl => constants.spacingXL,
      ResponsiveSpacing.xxl => constants.spacingXXL,
    };
  }
}

enum ResponsiveSpacing { xs, s, m, l, xl, xxl }

class ResponsiveButton extends ConsumerWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;
  final bool isPrimary;

  const ResponsiveButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
    this.isPrimary = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final constants = ref.watch(responsiveConstantsProvider);

    final defaultStyle = ElevatedButton.styleFrom(
      padding: EdgeInsets.symmetric(
        horizontal: constants.buttonPaddingH,
        vertical: constants.buttonPaddingV,
      ),
      minimumSize: Size(0, constants.buttonHeight),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(constants.radiusM),
      ),
    );

    if (isPrimary) {
      return ElevatedButton(
        onPressed: onPressed,
        style: defaultStyle.merge(style),
        child: child,
      );
    }

    return OutlinedButton(
      onPressed: onPressed,
      style: defaultStyle.merge(style),
      child: child,
    );
  }
}
