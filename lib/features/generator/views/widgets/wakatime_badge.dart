import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/provider/providers.dart';

class WakaTimeBadge extends ConsumerWidget {
  final String projectName;

  const WakaTimeBadge({super.key, required this.projectName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgeUrl = ref.watch(wakatimeBadgeProvider(projectName));

    if (badgeUrl == null) return const SizedBox();

    return SvgPicture.network(
      badgeUrl,
      height: 24,
      placeholderBuilder:
          (_) => const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(strokeWidth: 1.5),
          ),
    );
  }
}
