import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/moments_gallery/bloc/moments_gallery_bloc.dart';
import 'package:yellow_flowers/features/moments_gallery/widgets/album_card.dart';

class MomentsGalleryLayout extends StatefulWidget {
  const MomentsGalleryLayout({super.key});

  @override
  State<MomentsGalleryLayout> createState() => _MomentsGalleryLayoutState();
}

class _MomentsGalleryLayoutState extends State<MomentsGalleryLayout>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgController;
  late final Animation<Color?> _topColorAnim;
  late final Animation<Color?> _bottomColorAnim;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
    _topColorAnim = ColorTween(
      begin: const Color(0xFFFFF7C2),
      end: const Color(0xFFFFE8A3),
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
    _bottomColorAnim = ColorTween(
      begin: const Color(0xFFFFD3B6),
      end: const Color(0xFFFFB347),
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MomentsGalleryBloc>(
      builder: (context, model, _) => AnimatedBuilder(
        animation: _bgController,
        builder: (context, child) {
          return Scaffold(
            appBar: AppBar(
              title: const Text(
                'Galería de Momentos',
                style: TextStyle(color: Colors.black87),
              ),
              backgroundColor: Colors.transparent,
              centerTitle: true,
            ),
            extendBodyBehindAppBar: true,
            body: Stack(
              children: [
                // Animated gradient like HomeLayout
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        _topColorAnim.value ?? const Color(0xFFFFF7C2),
                        _bottomColorAnim.value ?? const Color(0xFFFFB3C6),
                      ],
                    ),
                  ),
                ),
                // Decorative floating petals/hearts similar style
                ...List.generate(10, (i) {
                  final rnd = math.Random(i + 91);
                  final dx = rnd.nextDouble();
                  final dy = rnd.nextDouble();
                  final drift =
                      math.sin((_bgController.value * 2 * math.pi) + i) * 14;
                  final isHeart = i.isEven;
                  return Positioned(
                    left: dx * MediaQuery.of(context).size.width,
                    top: dy * MediaQuery.of(context).size.height / 1.4 + drift,
                    child: Opacity(
                      opacity: 0.08 +
                          0.12 *
                              math
                                  .sin(_bgController.value * 2 * math.pi + i)
                                  .abs(),
                      child: Transform.rotate(
                        angle: math.sin(_bgController.value * 2 * math.pi + i) *
                            0.25,
                        child: Icon(
                          isHeart ? Icons.favorite : Icons.local_florist,
                          color: isHeart
                              ? Colors.pinkAccent
                              : const Color(0xFFFFE07D),
                          size: 16 + rnd.nextDouble() * 14,
                        ),
                      ),
                    ),
                  );
                }),
                // Grid content
                SafeArea(
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
              ],
            ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => model.pickAndSaveMemory(context),
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Nuevo recuerdo'),
            ),
          );
        },
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
