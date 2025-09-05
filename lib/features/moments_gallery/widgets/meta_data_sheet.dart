import 'dart:io';

import 'package:flutter/material.dart';

import 'package:yellow_flowers/features/moments_gallery/model/album_category.dart';
import 'package:yellow_flowers/features/moments_gallery/model/pending_meta.dart';

class MetadataSheet extends StatefulWidget {
  const MetadataSheet({
    super.key,
    required this.imageFile,
    required this.albums,
    required this.initial,
  });
  final File imageFile;
  final List<AlbumCategory> albums;
  final AlbumCategory initial;

  @override
  State<MetadataSheet> createState() => _MetadataSheetState();
}

class _MetadataSheetState extends State<MetadataSheet> {
  late AlbumCategory selected;
  late TextEditingController controller;

  @override
  void initState() {
    super.initState();
    selected = widget.initial;
    controller = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: bottom + 16,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 48,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Nuevo recuerdo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.file(
                      widget.imageFile,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade200,
                        alignment: Alignment.center,
                        child: const Icon(Icons.image_outlined, size: 42),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final a in widget.albums)
                      ChoiceChip(
                        label: Text(a.label),
                        selected: a.id == selected.id,
                        onSelected: (_) => setState(() => selected = a),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(
                          context,
                          PendingMeta(
                            album: selected,
                            description: controller.text,
                          ),
                        ),
                        child: const Text('Guardar'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
