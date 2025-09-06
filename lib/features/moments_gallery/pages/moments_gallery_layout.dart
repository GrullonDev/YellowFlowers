import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/moments_gallery/bloc/moments_gallery_bloc.dart';
import 'package:yellow_flowers/features/moments_gallery/widgets/album_card.dart';
import 'package:yellow_flowers/theme/theme_controller.dart';
import 'package:yellow_flowers/widgets/animated_background.dart';

class MomentsGalleryLayout extends StatefulWidget {
  const MomentsGalleryLayout({super.key});

  @override
  State<MomentsGalleryLayout> createState() => _MomentsGalleryLayoutState();
}

class _MomentsGalleryLayoutState extends State<MomentsGalleryLayout> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MomentsGalleryBloc>(
      builder: (context, model, _) => Scaffold(
        appBar: AppBar(
            title: const Text('Galería de Momentos',
                style: TextStyle(fontWeight: FontWeight.w700)),
            backgroundColor: Colors.transparent,
            centerTitle: true,
            actions: [
              Builder(builder: (ctx) {
                final controller = ctx.watch<ThemeController>();
                final mode = controller.mode;
                IconData icon;
                String tip;
                switch (mode) {
                  case ThemeMode.light:
                    icon = Icons.light_mode;
                    tip = 'Tema claro (tap para oscuro)';
                    break;
                  case ThemeMode.dark:
                    icon = Icons.dark_mode;
                    tip = 'Tema oscuro (tap para sistema)';
                    break;
                  case ThemeMode.system:
                    icon = Icons.brightness_auto;
                    tip = 'Tema del sistema (tap para claro)';
                    break;
                }
                return Semantics(
                  label: 'Botón cambio de tema. Modo actual: ${mode.name}',
                  button: true,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: IconButton(
                      constraints:
                          const BoxConstraints(minWidth: 56, minHeight: 56),
                      tooltip: tip,
                      onPressed: () => ctx.read<ThemeController>().toggle(),
                      icon: Icon(icon,
                          size: 26,
                          color: Theme.of(ctx).colorScheme.onSurface),
                    ),
                  ),
                );
              }),
            ]),
        extendBodyBehindAppBar: true,
        body: AnimatedBackground(
          decorationCount: 10,
          child: SafeArea(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.92,
              ),
              itemCount: model.albums.length,
              itemBuilder: (context, i) {
                final album = model.albums[i];
                final recent = model
                    .recentMemoriesForAlbum(album.id, limit: 3)
                    .toList();
                final count = model.countForAlbum(album.id);
                // Build absolute paths
                return FutureBuilder<Iterable<String>>(
                  future:
                      _resolveThumbPaths(recent.map((m) => m.fileName)),
                  builder: (context, snap) {
                    final paths = snap.data?.toList() ?? const [];
                    return AlbumCard(
                      title: '${album.emoji} ${album.label}',
                      icon: album.icon,
                      colors: album.colors,
                      onTap: () => model.onTapAlbum(context, album),
                      count: count,
                      previewPaths: paths,
                    );
                  },
                );
              },
            ),
          ),
        ),
        floatingActionButton: Semantics(
          label: 'Añadir nuevo recuerdo',
          button: true,
          child: FloatingActionButton.extended(
            onPressed: () => model.pickAndSaveMemory(context),
            icon: const Icon(Icons.add_a_photo, size: 28),
            label: const Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text('Nuevo recuerdo',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ),
      ),
    );
  }
}

Future<Iterable<String>> _resolveThumbPaths(Iterable<String> fileNames) async {
  final dir = await getApplicationDocumentsDirectory();
  final base = Directory(p.join(dir.path, 'memories'));
  final thumbs = Directory(p.join(base.path, 'thumbs'));
  return fileNames.map((f) {
    final thumbPath = p.join(thumbs.path, f);
    if (File(thumbPath).existsSync()) return thumbPath;
    // fallback to original until thumb generated
    return p.join(base.path, f);
  });
}
