import 'package:flutter/material.dart';

class CodeHighlightList extends StatelessWidget {
  final List<String> items;
  final String tag;

  const CodeHighlightList({super.key, required this.items, required this.tag});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.greenAccent.withAlpha((255 * 0.6).toInt()),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header type éditeur
          const Row(
            children: [
              _EditorDot(color: Colors.red),
              SizedBox(width: 6),
              _EditorDot(color: Colors.amber),
              SizedBox(width: 6),
              _EditorDot(color: Colors.green),
            ],
          ),
          const SizedBox(height: 12),
          // Lignes de "code"
          ...items.asMap().entries.map((entry) {
            final index = entry.key + 1;
            final line = entry.value;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Numéro de ligne
                  Text(
                    index.toString().padLeft(2, '0'),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Texte avec coloration
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 14,
                          color: Colors.white,
                        ),
                        children: _highlightSyntax("$tag $line", theme),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Simule une coloration syntaxique type Dart
  List<TextSpan> _highlightSyntax(String text, ThemeData theme) {
    final spans = <TextSpan>[];

    final keywords = ['class', 'final', 'const', 'return', 'async', 'await'];
    final types = ['String', 'int', 'double', 'bool', 'Widget'];

    final words = text.split(' ');
    for (var word in words) {
      if (keywords.contains(word)) {
        spans.add(
          TextSpan(
            text: '$word ',
            style: const TextStyle(color: Colors.blueAccent),
          ),
        );
      } else if (types.contains(word)) {
        spans.add(
          TextSpan(
            text: '$word ',
            style: const TextStyle(color: Colors.orangeAccent),
          ),
        );
      } else if (word.startsWith('"') && word.endsWith('"')) {
        spans.add(
          TextSpan(
            text: '$word ',
            style: const TextStyle(color: Colors.greenAccent),
          ),
        );
      } else if (word.startsWith('🛠') ||
          word.startsWith('🎯') ||
          word.startsWith('📈')) {
        spans.add(
          TextSpan(
            text: '$word ',
            style: const TextStyle(color: Colors.purpleAccent),
          ),
        );
      } else {
        spans.add(
          TextSpan(
            text: '$word ',
            style: const TextStyle(color: Colors.white),
          ),
        );
      }
    }

    return spans;
  }
}

class _EditorDot extends StatelessWidget {
  final Color color;
  const _EditorDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
