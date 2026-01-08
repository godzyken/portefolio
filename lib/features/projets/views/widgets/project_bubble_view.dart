import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/projet_providers.dart';

class GithubAIInsightView extends ConsumerWidget {
  final String repoUrl;

  const GithubAIInsightView({
    super.key,
    required this.repoUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncInfo = ref.watch(githubProjectAIProvider(repoUrl));

    return asyncInfo.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text("Erreur d’analyse : $err")),
      data: (info) {
        final allBubbles = [
          ...info.frameworks.map((e) => _BubbleData(e, Colors.tealAccent)),
          ...info.languages.map((e) => _BubbleData(e, Colors.amberAccent)),
          ...info.platforms.map((e) => _BubbleData(e, Colors.purpleAccent)),
        ];

        return Stack(
          alignment: Alignment.center,
          children: [
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: allBubbles.map((b) => _AnimatedBubble(b)).toList(),
            ),
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Column(
                children: [
                  Text(
                    info.aiSummary,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "Tech détectées : ${info.summary}",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BubbleData {
  final String label;
  final Color color;
  _BubbleData(this.label, this.color);
}

class _AnimatedBubble extends StatelessWidget {
  final _BubbleData data;
  const _AnimatedBubble(this.data);

  @override
  Widget build(BuildContext context) {
    final size = 50.0 + Random().nextDouble() * 40;
    final dx = Random().nextDouble() * 10;
    final dy = Random().nextDouble() * 10;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeInOut,
      transform: Matrix4.translationValues(dx, dy, 0),
      decoration: BoxDecoration(
        color: data.color.withValues(alpha: 0.25),
        shape: BoxShape.circle,
        border:
            Border.all(color: data.color.withValues(alpha: 0.7), width: 1.5),
        boxShadow: [
          BoxShadow(color: data.color.withValues(alpha: 0.3), blurRadius: 8),
        ],
      ),
      width: size,
      height: size,
      child: Center(
        child: Text(
          data.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
