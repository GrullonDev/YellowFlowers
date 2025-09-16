import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yellow_flowers/features/moments_gallery/data/memory_model.dart';
import 'package:yellow_flowers/features/moments_gallery/model/album_category.dart';
import 'package:yellow_flowers/features/moments_gallery/model/pending_meta.dart';
import 'package:yellow_flowers/features/moments_gallery/pages/album_detail_page.dart';
import 'package:yellow_flowers/features/moments_gallery/widgets/meta_data_sheet.dart';
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

  final List<Memory> _memories = [];
  List<Memory> get memories => List.unmodifiable(_memories);
  String? _lastAlbumId; // persisted last used album

  Future<void> init() async {
    await _loadMemories();
    await _loadLastAlbum();
  }

  List<Memory> recentMemoriesForAlbum(String albumId, {int limit = 3}) {
    final list = _memories.where((m) => m.albumId == albumId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    if (list.length > limit) return list.sublist(0, limit);
    return list;
  }

  int countForAlbum(String albumId) =>
      _memories.where((m) => m.albumId == albumId).length;

  Future<void> updateMemoryDescription(Memory mem, String? desc) async {
    final idx = _memories.indexWhere((m) => m.fileName == mem.fileName);
    if (idx == -1) return;
    _memories[idx] = Memory(
      fileName: mem.fileName,
      albumId: mem.albumId,
      createdAt: mem.createdAt,
      description: (desc == null || desc.trim().isEmpty) ? null : desc.trim(),
      trackId: mem.trackId,
    );
    await _saveMemories();
    notifyListeners();
  }

  Future<void> updateMemoryTrack(Memory mem, String? trackId) async {
    final idx = _memories.indexWhere((m) => m.fileName == mem.fileName);
    if (idx == -1) return;
    _memories[idx] = Memory(
      fileName: mem.fileName,
      albumId: mem.albumId,
      createdAt: mem.createdAt,
      description: mem.description,
      trackId: (trackId == null || trackId.trim().isEmpty)
          ? null
          : trackId.trim(),
    );
    await _saveMemories();
    notifyListeners();
  }

  Future<void> deleteMemory(Memory mem) async {
    final idx = _memories.indexWhere((m) => m.fileName == mem.fileName);
    if (idx == -1) return;
    _memories.removeAt(idx);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final base = Directory(p.join(dir.path, 'memories'));
      final file = File(p.join(base.path, mem.fileName));
      if (await file.exists()) {
        await file.delete();
      }
      final thumbsDir = Directory(p.join(base.path, 'thumbs'));
      final thumb = File(p.join(thumbsDir.path, mem.fileName));
      if (await thumb.exists()) {
        await thumb.delete();
      }
    } catch (_) {}
    await _saveMemories();
    notifyListeners();
  }

  void onTapAlbum(BuildContext context, AlbumCategory album) {
    final bloc = this;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: bloc,
          child: AlbumDetailPage(album: album),
        ),
      ),
    );
  }

  Future<void> pickAndSaveMemory(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

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

      if (!context.mounted) return; // Ensure context is still valid
      final meta = await _askMetadata(context, dest);
      if (meta == null) {
        // Usuario canceló: limpiar archivo copiado para no dejar huérfanos
        if (await dest.exists()) {
          try {
            await dest.delete();
          } catch (_) {}
        }
        return; // cancelado en modal
      }
      _memories.add(Memory(
        fileName: fileName,
        albumId: meta.album.id,
        createdAt: DateTime.now(),
        description: meta.description?.trim().isEmpty == true
            ? null
            : meta.description?.trim(),
        trackId: meta.trackId,
      ));
      await _saveMemories();
      await _saveLastAlbum(meta.album.id);
      // Generate thumbnail in background (no await to keep UI responsive)
      Future.microtask(() => _ensureThumbnail(fileName));
      notifyListeners();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recuerdo guardado.')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar el recuerdo: $e')),
        );
      }
    }
  }
}

extension _MemoryStorage on MomentsGalleryBloc {
  Future<File> _metadataFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, 'memories', 'memories.json'));
  }

  Future<void> _saveMemories() async {
    try {
      final file = await _metadataFile();
      await file.writeAsString(Memory.encodeList(_memories));
    } catch (_) {}
  }

  Future<void> _loadMemories() async {
    try {
      final file = await _metadataFile();
      if (!await file.exists()) return;
      final raw = await file.readAsString();
      _memories
        ..clear()
        ..addAll(Memory.decodeList(raw));
      // Kick off missing thumbnail generation (fire & forget)
      for (final m in _memories) {
        // ignore unawaited
        Future.microtask(() => _ensureThumbnail(m.fileName));
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _loadLastAlbum() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lastAlbumId = prefs.getString('moments_last_album');
    } catch (_) {}
  }

  Future<void> _saveLastAlbum(String id) async {
    _lastAlbumId = id;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('moments_last_album', id);
    } catch (_) {}
  }

  Future<PendingMeta?> _askMetadata(
      BuildContext context, File imageFile) async {
    final initial = albums.firstWhere(
      (a) => a.id == _lastAlbumId,
      orElse: () => albums.first,
    );
    return showModalBottomSheet<PendingMeta>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => MetadataSheet(
        imageFile: imageFile,
        albums: albums,
        initial: initial,
      ),
    );
  }
}

extension _Thumbnails on MomentsGalleryBloc {
  Future<File> _thumbFile(String fileName) async {
    final dir = await getApplicationDocumentsDirectory();
    final base = Directory(p.join(dir.path, 'memories'));
    final thumbs = Directory(p.join(base.path, 'thumbs'));
    if (!await thumbs.exists()) await thumbs.create(recursive: true);
    return File(p.join(thumbs.path, fileName));
  }

  Future<void> _ensureThumbnail(String fileName) async {
    try {
      final thumb = await _thumbFile(fileName);
      if (await thumb.exists()) return;
      final dir = await getApplicationDocumentsDirectory();
      final base = Directory(p.join(dir.path, 'memories'));
      final original = File(p.join(base.path, fileName));
      if (!await original.exists()) return;
      final bytes = await original.readAsBytes();
      // Usamos codec para redimensionar a ancho máximo 240 manteniendo aspecto.
      ui.Codec codec;
      try {
        codec = await ui.instantiateImageCodec(bytes, targetWidth: 240);
      } catch (_) {
        return; // No soportado / corrupto
      }
      final frame = await codec.getNextFrame();
      final ui.Image imgFrame = frame.image;
      final byteData =
          await imgFrame.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;
      final Uint8List outBytes = byteData.buffer.asUint8List();
      await thumb.writeAsBytes(outBytes, flush: false);
    } catch (_) {
      // Silencioso; no queremos romper flujo principal si la miniatura falla
    }
  }

  // ignore: unused_element
  Future<String?> getThumbnailPath(String fileName) async {
    final f = await _thumbFile(fileName);
    if (await f.exists()) return f.path;
    // attempt generate synchronously if missing
    await _ensureThumbnail(fileName);
    if (await f.exists()) return f.path;
    return null;
  }
}
