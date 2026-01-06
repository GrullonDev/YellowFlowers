import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:yellow_flowers/features/moments_gallery/model/album_category.dart';
import 'package:yellow_flowers/utils/app_theme.dart';

class AlbumDetailPage extends StatefulWidget {
  final AlbumCategory album;

  const AlbumDetailPage({super.key, required this.album});

  @override
  State<AlbumDetailPage> createState() => _AlbumDetailPageState();
}

class _AlbumDetailPageState extends State<AlbumDetailPage> {
  List<File> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final albumDir =
          Directory(p.join(appDir.path, 'memories', widget.album.id));

      if (await albumDir.exists()) {
        final List<FileSystemEntity> entities = await albumDir.list().toList();
        final files = entities.whereType<File>().where((f) {
          final ext = p.extension(f.path).toLowerCase();
          return ['.jpg', '.jpeg', '.png'].contains(ext);
        }).toList();

        // Sort by modification time (newest first)
        files.sort(
            (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));

        if (mounted) {
          setState(() {
            _photos = files;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint("Error loading photos: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F5EC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9F5EC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "${widget.album.emoji} ${widget.album.label}",
          style: GoogleFonts.playball(
            color: Colors.black87,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.sunnyGold))
          : _photos.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_album_outlined,
                          size: 64, color: Colors.grey.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        "Aún no hay recuerdos aquí.\n¡Agrega uno!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _photos.length,
                  itemBuilder: (context, index) {
                    final file = _photos[index];
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(2, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.file(
                                file,
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Washi tape effect on bottom
                          Container(
                            height: 4,
                            width: 40,
                            decoration: BoxDecoration(
                              color: widget.album.colors.last.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
