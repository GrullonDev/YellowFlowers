import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/music/domain/entities/mood.dart';
import 'package:yellow_flowers/features/moments_gallery/bloc/moments_gallery_bloc.dart';
import 'package:yellow_flowers/features/moments_gallery/data/memory_model.dart';
import 'package:yellow_flowers/di/injector.dart' as di;
import 'package:yellow_flowers/features/music/bloc/music_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ImmersiveExperiencePage extends StatefulWidget {
  const ImmersiveExperiencePage({super.key, required this.initialText, required this.mood});
  final String initialText;
  final Mood mood;

  @override
  State<ImmersiveExperiencePage> createState() => _ImmersiveExperiencePageState();
}

class _ImmersiveExperiencePageState extends State<ImmersiveExperiencePage> {
  @override
  void initState() {
    super.initState();
    _autoplay();
  }

  Future<void> _autoplay() async {
    try {
      final bloc = di.sl<MusicBloc>();
      bloc.selectMood(widget.mood);
      await Future.delayed(const Duration(milliseconds: 150));
      final song = bloc.dailyRecommendation;
      if (song != null) {
        await bloc.playSong(song);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(child: _MemoriesCarousel()),
            Positioned(
              top: 12,
              left: 12,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Message overlay
            Positioned(
              left: 16,
              right: 16,
              bottom: 28,
              child: _MessageGlass(text: widget.initialText),
            )
          ],
        ),
      ),
    );
  }
}

class _MessageGlass extends StatelessWidget {
  const _MessageGlass({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _MemoriesCarousel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
  final bloc = context.read<MomentsGalleryBloc?>();
    final memories = (bloc?.memories ?? const <Memory>[]);
    if (memories.isEmpty) {
      return const Center(
        child: Icon(Icons.photo_library_outlined, color: Colors.white54, size: 64),
      );
    }
    return PageView.builder(
      itemCount: memories.length,
      controller: PageController(viewportFraction: 1),
      itemBuilder: (context, i) {
        final mem = memories[i];
        return FutureBuilder<File>(
          future: _resolveMemoryFile(mem.fileName),
          builder: (context, snap) {
            final file = snap.data;
            if (file == null) {
              return const SizedBox.shrink();
            }
            return Image.file(file, fit: BoxFit.cover);
          },
        );
      },
    );
  }

  Future<File> _resolveMemoryFile(String name) async {
    final dir = await getApplicationDocumentsDirectory();
    final base = Directory(p.join(dir.path, 'memories'));
    return File(p.join(base.path, name));
  }
}