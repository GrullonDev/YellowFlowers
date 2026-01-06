import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:gal/gal.dart';
import 'package:yellow_flowers/features/moments_gallery/pages/album_detail_page.dart';
import 'package:yellow_flowers/features/moments_gallery/model/album_category.dart';
import 'package:yellow_flowers/utils/base_model.dart';

class MomentsGalleryBloc extends BaseModel {
  MomentsGalleryBloc();

  final List<AlbumCategory> albums = const [
    AlbumCategory(
      id: 'love',
      label: 'Amor',
      emoji: '💖',
      icon: Icons.favorite,
      colors: [Color(0xFFFFD1DC), Color(0xFFFF9EC4)],
    ),
    AlbumCategory(
      id: 'family',
      label: 'Familia',
      emoji: '🏡',
      icon: Icons.family_restroom,
      colors: [Color(0xFFD7E3FC), Color(0xFFB6CCFE)],
    ),
    AlbumCategory(
      id: 'friends',
      label: 'Amigas',
      emoji: '👯‍♀️',
      icon: Icons.groups_2,
      colors: [Color(0xFFE9D5FF), Color(0xFFD8B4FE)],
    ),
    AlbumCategory(
      id: 'trips',
      label: 'Viajes',
      emoji: '✈️',
      icon: Icons.flight_takeoff,
      colors: [Color(0xFFC7F9CC), Color(0xFF80ED99)],
    ),
    AlbumCategory(
      id: 'birthdays',
      label: 'Cumpleaños',
      emoji: '🎂',
      icon: Icons.cake,
      colors: [Color(0xFFFFF1B6), Color(0xFFFFE08A)],
    ),
    AlbumCategory(
      id: 'anniversaries',
      label: 'Aniversarios',
      emoji: '🌹',
      icon: Icons.calendar_month,
      colors: [Color(0xFFFFE5B4), Color(0xFFFFC78C)],
    ),
  ];

  void onTapAlbum(BuildContext context, AlbumCategory album) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AlbumDetailPage(album: album),
      ),
    );
  }

  Future<void> pickAndSaveMemory(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) {
        return;
      }

      final appDir = await getApplicationDocumentsDirectory();
      final memoriesDir = Directory(p.join(appDir.path, 'memories'));
      if (!await memoriesDir.exists()) {
        await memoriesDir.create(recursive: true);
      }

      final ts = DateTime.now().millisecondsSinceEpoch;
      final ext = p.extension(picked.name).toLowerCase();
      final fileName = 'memory_$ts$ext';
      final dest = File(p.join(memoriesDir.path, fileName));
      await picked.saveTo(dest.path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recuerdo guardado en tu dispositivo.')),
        );
      }

      // TODO: persistir metadatos (descripción, álbum, música, stickers) en storage local.
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar el recuerdo: $e')),
        );
      }
    }
  }

  Future<void> pickAndSaveToAlbum(
      BuildContext context, AlbumCategory album) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      // Internal storage for app persistence
      final albumDir = Directory(p.join(appDir.path, 'memories', album.id));
      if (!await albumDir.exists()) {
        await albumDir.create(recursive: true);
      }

      final ts = DateTime.now().millisecondsSinceEpoch;
      final ext = p.extension(picked.name).toLowerCase();
      final fileName = '${album.id}_$ts$ext';
      final dest = File(p.join(albumDir.path, fileName));
      await picked.saveTo(dest.path);

      // Save to NATIVE Gallery with intelligent album creation
      try {
        // "YellowFlowers - Amor"
        final nativeAlbumName = "YellowFlowers - ${album.label}";
        await Gal.putImage(dest.path, album: nativeAlbumName);
      } catch (e) {
        debugPrint("Error saving to native gallery album: $e");
        // Fallback or ignore if permission denied, mainly want to try.
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Foto guardada en álbum "${album.label}" 📸'),
            backgroundColor: album.colors.last,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    }
  }
}
