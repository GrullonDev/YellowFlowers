import 'dart:io';
import 'dart:ui';
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
              padding: const EdgeInsets.symmetric(
                horizontal: PremiumDesign.s24, 
                vertical: PremiumDesign.s32
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: PremiumDesign.s32,
                crossAxisSpacing: PremiumDesign.s24,
                childAspectRatio: 0.78,
              ),
              itemCount: model.albums.length,
              itemBuilder: (context, i) {
                final album = model.albums[i];
                final recent =
                    model.recentMemoriesForAlbum(album.id, limit: 3).toList();
                final count = model.countForAlbum(album.id);
                final quotes = recent
                    .where((m) => m.description != null && m.description!.isNotEmpty)
                    .map((m) => m.description!)
                    .toList();

                final animation = CurvedAnimation(
                  parent: _controller,
                  curve: Interval((i * 0.05).clamp(0.0, 1.0), 0.6 + (i * 0.05).clamp(0.0, 0.4),
                      curve: Curves.easeOutBack),
                );

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: const Offset(0, 0.2), end: Offset.zero)
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
                          quotes: quotes,
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

class _PremiumFAB extends StatefulWidget {
  const _PremiumFAB({required this.onPressed});
  final VoidCallback onPressed;

  @override
  State<_PremiumFAB> createState() => _PremiumFABState();
}

class _PremiumFABState extends State<_PremiumFAB> with SingleTickerProviderStateMixin {
  late AnimationController _fabController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.elasticOut,
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _fabController.forward();
    });
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: PremiumDesign.softText.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    PremiumDesign.softText.withValues(alpha: 0.8),
                    const Color(0xFF1A1A1A).withValues(alpha: 0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.onPressed,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_a_photo_rounded, 
                          color: Colors.white, 
                          size: 22
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Añadir Recuerdo',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
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
