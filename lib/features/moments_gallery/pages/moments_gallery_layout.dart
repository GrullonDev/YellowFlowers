import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/features/moments_gallery/bloc/moments_gallery_bloc.dart';
import 'package:yellow_flowers/features/moments_gallery/widgets/album_card.dart';
import 'package:yellow_flowers/theme/theme_controller.dart';
import 'package:yellow_flowers/widgets/animated_background.dart';

class MomentsGalleryLayout extends StatefulWidget {
  const MomentsGalleryLayout({super.key});

  @override
  State<MomentsGalleryLayout> createState() => _MomentsGalleryLayoutState();
}

class _MomentsGalleryLayoutState extends State<MomentsGalleryLayout>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MomentsGalleryBloc>(
      builder: (context, model, _) => Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            'Galería de Momentos',
            style: GoogleFonts.playfairDisplay(
              fontWeight: FontWeight.w800,
              color: PremiumDesign.softText,
            ),
          ),
          centerTitle: true,
          actions: [
            _buildThemeButton(context),
            const SizedBox(width: 8),
          ],
        ),
        body: AnimatedBackground(
          decorationCount: 6,
          child: SafeArea(
            child: GridView.builder(
              padding: const EdgeInsets.all(PremiumDesign.s24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: PremiumDesign.s20,
                crossAxisSpacing: PremiumDesign.s20,
                childAspectRatio: 0.85,
              ),
              itemCount: model.albums.length,
              itemBuilder: (context, i) {
                final album = model.albums[i];
                final recent =
                    model.recentMemoriesForAlbum(album.id, limit: 1).toList();
                final count = model.countForAlbum(album.id);

                final animation = CurvedAnimation(
                  parent: _controller,
                  curve: Interval((i * 0.1).clamp(0.0, 1.0), 1.0,
                      curve: Curves.easeOut),
                );

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 0.1), end: Offset.zero)
                        .animate(animation),
                    child: FutureBuilder<Iterable<String>>(
                      future: _resolveThumbPaths(recent.map((m) => m.fileName)),
                      builder: (context, snap) {
                        final paths = snap.data?.toList() ?? const [];
                        return AlbumCard(
                          title: album.label,
                          icon: album.icon,
                          colors: album.colors,
                          onTap: () => model.onTapAlbum(context, album),
                          count: count,
                          previewPaths: paths,
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        floatingActionButton: _PremiumFAB(
          onPressed: () => model.pickAndSaveMemory(context),
        ),
      ),
    );
  }

  Widget _buildThemeButton(BuildContext context) {
    final controller = context.watch<ThemeController>();
    return IconButton(
      icon: Icon(
        controller.mode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
        color: PremiumDesign.softText,
      ),
      onPressed: () => controller.toggle(),
    );
  }
}

class _PremiumFAB extends StatelessWidget {
  const _PremiumFAB({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: PremiumDesign.premiumShadow,
        gradient: const LinearGradient(
          colors: [PremiumDesign.softText, Color(0xFF1A1A1A)],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add_a_photo_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Añadir',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
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
