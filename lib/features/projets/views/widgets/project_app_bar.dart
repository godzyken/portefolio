import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/affichage/screen_size_detector.dart';
import '../../../../core/provider/providers.dart';
import '../../data/project_data.dart';

enum _MenuAction { selectAll, exportPdf }

class ProjectAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ProjectAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(responsiveInfoProvider);
    final selected = ref.watch(selectedProjectsProvider);

    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text(
        'Mes Projets',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic,
        ),
      ),
      actions: info.isWatch
          ? [_buildCompactMenu(context, ref, selected)]
          : _buildDesktopButtons(context, ref, selected),
    );
  }

  List<Widget> _buildDesktopButtons(
    BuildContext ctx,
    WidgetRef ref,
    List<ProjectInfo> selected,
  ) {
    return [
      IconButton(
        icon: const Icon(Icons.select_all),
        tooltip: 'Tout sélectionner',
        onPressed: () => _toggleAll(ref),
      ),
      IconButton(
        icon: const Icon(Icons.picture_as_pdf),
        tooltip: 'Exporter PDF',
        onPressed: () => _exportPdf(ctx, ref, selected),
      ),
    ];
  }

  Widget _buildCompactMenu(
    BuildContext c,
    WidgetRef ref,
    List<ProjectInfo> selected,
  ) {
    return PopupMenuButton<_MenuAction>(
      icon: const Icon(Icons.more_vert),
      onSelected: (action) {
        switch (action) {
          case _MenuAction.selectAll:
            _toggleAll(ref);
            break;
          case _MenuAction.exportPdf:
            _exportPdf(c, ref, selected);
            break;
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
          value: _MenuAction.selectAll,
          child: ListTile(
            leading: Icon(Icons.select_all),
            title: Text('Tout sélectionner'),
          ),
        ),
        PopupMenuItem(
          value: _MenuAction.exportPdf,
          child: ListTile(
            leading: Icon(Icons.picture_as_pdf),
            title: Text('Exporter PDF'),
          ),
        ),
      ],
    );
  }

  void _toggleAll(WidgetRef ref) {
    final List<ProjectInfo> all = ref
        .read(projectsFutureProvider)
        .maybeWhen(data: (list) => list, orElse: () => []);
    ref.read(selectedProjectsProvider.notifier).state = all;
  }

  void _exportPdf(BuildContext ctx, WidgetRef ref, List<ProjectInfo> selected) {
    if (selected.isEmpty) return;
    debugPrint('📄 Export PDF de ${selected.length} projets...');
    // Appel au service Riverpod
    ref.read(pdfExportProvider).export(selected);
    ctx.pushNamed('pdf');
  }
}
