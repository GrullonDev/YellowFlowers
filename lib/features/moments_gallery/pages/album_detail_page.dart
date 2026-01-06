import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:yellow_flowers/features/moments_gallery/bloc/moments_gallery_bloc.dart';
import 'package:yellow_flowers/di/injector.dart' as di;
import 'package:yellow_flowers/data/music_service/jamendo_service.dart';
import 'package:yellow_flowers/features/music/bloc/music_bloc.dart';
import 'package:yellow_flowers/features/moments_gallery/model/album_category.dart';
import 'package:yellow_flowers/features/moments_gallery/data/memory_model.dart';
import 'package:yellow_flowers/widgets/animated_background.dart';

class AlbumDetailPage extends StatelessWidget {
  const AlbumDetailPage({super.key, required this.album});
  final AlbumCategory album;

  @override
  Widget build(BuildContext context) {
    return Consumer<MomentsGalleryBloc>(
      builder: (context, bloc, _) {
        final list = bloc.memories.where((m) => m.albumId == album.id).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return Scaffold(
          appBar: AppBar(
            title: Text('${album.emoji} ${album.label}',
                style: const TextStyle(fontWeight: FontWeight.w700)),
            actions: [
              if (list.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.ios_share),
                  onPressed: () async {
                    final dir = await getApplicationDocumentsDirectory();
                    final base = p.join(dir.path, 'memories');
                    final paths = list
                        .take(6)
                        .map((m) => p.join(base, m.fileName))
                        .toList();
                    // ignore: deprecated_member_use
                    await Share.shareXFiles(
                      paths.map((e) => XFile(e)).toList(),
                      text: 'Algunos recuerdos de ${album.label} 💛',
                    );
                  },
                ),
            ],
          ),
          body: AnimatedBackground(
            child: list.isEmpty
                ? const Center(child: Text('Aún no hay recuerdos aquí'))
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 6,
                      mainAxisSpacing: 6,
                    ),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final mem = list[i];
                      return Semantics(
                          label:
                              'Recuerdo ${i + 1} de ${list.length}${(mem.description ?? '').isNotEmpty ? ', descripción: ${mem.description}' : ''}',
                          image: true,
                          onLongPressHint: 'Editar descripción',
                          child: GestureDetector(
                            onLongPress: () => _editDescription(context, mem),
                            onTap: () => _openViewer(context, list, i),
                            child: FutureBuilder<File>(
                              future: _resolveMemoryFile(mem.fileName),
                              builder: (context, snap) {
                                final file = snap.data;
                                return Hero(
                                  tag: mem.fileName,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Stack(
                                      children: [
                                        Positioned.fill(
                                          child: file == null
                                              ? Container(
                                                  color: Colors.grey.shade200)
                                              : Image.file(
                                                  file,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (_, __, ___) =>
                                                      Container(
                                                    color: Colors.grey.shade300,
                                                    alignment: Alignment.center,
                                                    child: const Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        size: 22),
                                                  ),
                                                ),
                                        ),
                                        if ((mem.description ?? '').isNotEmpty)
                                          Positioned(
                                            left: 4,
                                            right: 4,
                                            bottom: 4,
                                            child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 3),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.55),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                child: Text(mem.description!,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        height: 1.15))),
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ));
                    },
                  ),
          ),
        );
      },
    );
  }
}

Future<File> _resolveMemoryFile(String name) async {
  final dir = await getApplicationDocumentsDirectory();
  final base = Directory(p.join(dir.path, 'memories'));
  return File(p.join(base.path, name));
}

void _editDescription(BuildContext context, Memory mem) async {
  final bloc = context.read<MomentsGalleryBloc>();
  final controller = TextEditingController(text: mem.description ?? '');
  final result = await showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Editar descripción'),
      content: TextField(
        controller: controller,
        maxLines: 3,
        decoration: const InputDecoration(hintText: 'Descripción'),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Guardar')),
      ],
    ),
  );
  if (result == null) return;
  // mutate memory description (Memory is immutable => create new instance)
  if (!context.mounted) return;
  final idx = bloc.memories.indexOf(mem);
  if (idx == -1) return;
  await bloc.updateMemoryDescription(mem, result);
}

void _openViewer(BuildContext context, List<Memory> list, int index) {
  final barrier = Colors.black.withValues(alpha: 0.9);
  final bloc = context.read<MomentsGalleryBloc>();
  final parentContext = context; // keep context with provider to use after pop
  // If memory has an associated track, try to resolve and play it softly.
  final mem = list[index];
  if (mem.trackId != null && mem.trackId!.isNotEmpty) {
    try {
      final jam = di.sl<JamendoApiService>();
      final bloc = di.sl<MusicBloc>();
      jam.getTrackById(mem.trackId!).then((song) async {
        if (song == null) return;
        await bloc.playSong(song);
      });
    } catch (_) {}
  }
  Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: barrier,
      pageBuilder: (_, __, ___) => ChangeNotifierProvider.value(
        value: bloc,
        child: _FullScreenViewer(
            list: list, index: index, parentContext: parentContext),
      ),
    ),
  );
}

class _FullScreenViewer extends StatefulWidget {
  const _FullScreenViewer(
      {required this.list, required this.index, required this.parentContext});
  final List<Memory> list;
  final int index;
  final BuildContext parentContext; // context from AlbumDetailPage route

  @override
  State<_FullScreenViewer> createState() => _FullScreenViewerState();
}

class _FullScreenViewerState extends State<_FullScreenViewer> {
  late PageController _controller;
  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.index);
  }

  Future<void> _handleDelete(BuildContext buttonContext) async {
    final parentCtx = widget.parentContext;
    final bloc = parentCtx.read<MomentsGalleryBloc>();
    final page = _controller.page?.round() ?? widget.index;
    if (page < 0 || page >= widget.list.length) return;
    final mem = widget.list[page];
    final confirm = await showDialog<bool>(
      context: parentCtx,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar'),
        content: const Text('¿Eliminar este recuerdo permanentemente?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm != true) return;
    if (!mounted || !buttonContext.mounted) return;
    final albumId = mem.albumId;
    final willBeEmpty = bloc.countForAlbum(albumId) == 1;
    if (willBeEmpty) {
      final nav = Navigator.of(buttonContext);
      if (nav.canPop()) nav.pop();
      Future.microtask(() => bloc.deleteMemory(mem));
      return;
    }
    final idx = widget.list.indexOf(mem);
    if (idx != -1) {
      widget.list.removeAt(idx);
      if (mounted) setState(() {});
    }
    bloc.deleteMemory(mem); // fire & forget
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: widget.list.length,
            itemBuilder: (context, i) {
              final mem = widget.list[i];
              return FutureBuilder<File>(
                future: _resolveMemoryFile(mem.fileName),
                builder: (context, snap) {
                  final file = snap.data;
                  return Center(
                    child: Hero(
                      tag: mem.fileName,
                      child: file == null
                          ? Container(
                              color: Colors.grey.shade200,
                              width: double.infinity,
                              height: double.infinity)
                          : Image.file(file, fit: BoxFit.contain),
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
              top: 40,
              left: 16,
              child: Semantics(
                label: 'Cerrar visor',
                button: true,
                child: IconButton(
                  constraints:
                      const BoxConstraints(minWidth: 56, minHeight: 56),
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              )),
          Positioned(
            top: 40,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Semantics(
                  label: 'Editar descripción del recuerdo',
                  button: true,
                  child: Material(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(32),
                    child: IconButton(
                        constraints:
                            const BoxConstraints(minWidth: 56, minHeight: 56),
                        iconSize: 26,
                        icon: const Icon(Icons.edit, color: Colors.white),
                        tooltip: 'Editar',
                        onPressed: () => _handleEdit(context)),
                  ),
                ),
                const SizedBox(height: 12),
                Semantics(
                  label: 'Eliminar este recuerdo',
                  button: true,
                  child: Material(
                    color: Colors.redAccent.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(32),
                    child: IconButton(
                        constraints:
                            const BoxConstraints(minWidth: 56, minHeight: 56),
                        iconSize: 26,
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.white),
                        tooltip: 'Eliminar',
                        onPressed: () => _handleDelete(context)),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            left: 16,
            right: 16,
            child: Consumer<MomentsGalleryBloc>(
              builder: (_, b, __) {
                final page = _controller.hasClients
                    ? _controller.page?.round() ?? widget.index
                    : widget.index;
                final mem = widget.list[page];
                final desc = mem.description;
                if (desc == null || desc.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Semantics(
                    label: 'Descripción del recuerdo: $desc',
                    child: AnimatedOpacity(
                      opacity: 1,
                      duration: const Duration(milliseconds: 300),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.15))),
                        child: Text(desc,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 1.25),
                            textAlign: TextAlign.center),
                      ),
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleEdit(BuildContext buttonContext) {
    final parent = widget.parentContext;
    final page = _controller.page?.round() ?? widget.index;
    if (page < 0 || page >= widget.list.length) return;
    final mem = widget.list[page];
    final nav = Navigator.of(buttonContext);
    if (nav.canPop()) nav.pop();
    Future.microtask(() {
      if (parent.mounted) {
        _editDescription(parent, mem);
      }
    });
  }
}
