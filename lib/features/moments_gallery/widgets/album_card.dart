import 'package:flutter/material.dart';
import 'dart:io';

class AlbumCard extends StatelessWidget {
  const AlbumCard({
    super.key,
    required this.title,
    required this.icon,
    required this.colors,
    this.onTap,
    this.count = 0,
    this.previewPaths = const [],
  });

  final String title;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback? onTap;
  final int count;
  final List<String> previewPaths; // absolute paths to preview images

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(16);
    return Semantics(
      label: 'Álbum $title con $count recuerdos',
      button: true,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.65),
                  Colors.white.withValues(alpha: 0.30),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 18,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.8),
                width: 1.4,
              )),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: borderRadius,
                gradient: LinearGradient(
                  colors: [
                    colors.first.withValues(alpha: 0.94),
                    colors.last.withValues(alpha: 0.94),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(icon,
                              color: Colors.black.withValues(alpha: 0.85))),
                      const Spacer(),
                      if (count > 0)
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Text('$count',
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                    color: Colors.white))),
                    ],
                  ),
                  const Spacer(),
                  if (previewPaths.isNotEmpty)
                    SizedBox(
                      height: 52,
                      child: Row(
                        children: previewPaths.take(3).map((path) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(path),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    alignment: Alignment.center,
                                    child: const Icon(Icons.image_not_supported,
                                        size: 20),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  if (previewPaths.isNotEmpty) const SizedBox(height: 8),
                  Text(title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.black.withValues(alpha: 0.92),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.4,
                        shadows: [
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.85),
                            offset: const Offset(0, 1.2),
                            blurRadius: 3,
                          ),
                        ],
                      )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
