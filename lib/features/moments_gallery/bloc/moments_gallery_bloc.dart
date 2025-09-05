import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

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
    // Placeholder while wiring the rest of the flow.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Abrir álbum: ${album.label} ${album.emoji}')),
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
}
