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
  late TextEditingController trackController;

  @override
  void initState() {
    super.initState();
    selected = widget.initial;
    controller = TextEditingController();
    trackController = TextEditingController();
  }

  @override
  void dispose() {
    controller.dispose();
    trackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final scheme = Theme.of(context).colorScheme;
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
                Text(
                  'Nuevo recuerdo',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: scheme.onSurface,
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
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final a in widget.albums)
                      ChoiceChip(
                        label: Text(
                          a.label,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: a.id == selected.id
                                ? scheme.onPrimary
                                : scheme.onSurface.withValues(alpha:0.85),
                          ),
                        ),
                        selected: a.id == selected.id,
                        elevation: a.id == selected.id ? 2 : 0,
                        pressElevation: 0,
                        selectedColor: scheme.primary,
                        backgroundColor: scheme.surfaceContainerHighest,
                        side: BorderSide(
                          color: a.id == selected.id
                              ? scheme.primary
                              : scheme.outlineVariant,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        onSelected: (_) => setState(() => selected = a),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    labelText: 'Descripción (opcional)',
                    filled: true,
                    fillColor: scheme.surfaceContainerHighest.withValues(alpha:0.35),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: trackController,
                  textInputAction: TextInputAction.done,
                  decoration: InputDecoration(
                    labelText: 'ID de canción Jamendo (opcional)',
                    hintText: 'Ej: 123456',
                    filled: true,
                    fillColor: scheme.surfaceContainerHighest.withValues(alpha:0.35),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                        label: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.pop(
                          context,
                          PendingMeta(
                            album: selected,
                            description: controller.text.trim(),
                            trackId: trackController.text.trim().isEmpty
                                ? null
                                : trackController.text.trim(),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Guardar'),
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
