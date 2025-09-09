import 'package:flutter/material.dart';

import '../../data/project_data.dart';

class ProjectBubble extends StatelessWidget {
  final ProjectInfo project;
  final bool isSelected;

  const ProjectBubble({
    super.key,
    required this.project,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      elevation: 6,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 120, // 📏 Taille réduite
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(3, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image du projet
            ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: PageView(
                children: (project.image ?? [])
                    .map((url) => Image.network(url, fit: BoxFit.cover))
                    .toList(),
              ),
            ),
            const SizedBox(height: 6),
            // Titre
            Text(
              project.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.green, size: 16),
          ],
        ),
      ),
    );
  }
}
