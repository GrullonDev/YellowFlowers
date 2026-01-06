import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AlbumCard extends StatelessWidget {
  const AlbumCard({
    super.key,
    required this.title,
    required this.icon,
    required this.colors,
    this.onTap,
    this.onAddPhoto,
    this.rotation = 0.0,
  });

  final String title;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback? onTap;
  final VoidCallback? onAddPhoto;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // Main Photo Card
            Container(
              margin: const EdgeInsets.only(top: 12), // Espacio para la cinta
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 10,
                    offset: const Offset(4, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 36),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: colors,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.gaegu(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Add Photo Button (Mini FAB style)
            Positioned(
              bottom: 12,
              right: 8,
              child: GestureDetector(
                onTap: onAddPhoto,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add_a_photo_rounded,
                    size: 18,
                    color: colors.last.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
            // Washi Tape Decoration
            Positioned(
              top: 0,
              child: Transform.rotate(
                angle: -0.05,
                child: Container(
                  width: 50,
                  height: 24,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Container(
                      width: 40,
                      height: 14,
                      color: const Color(0xFFF7C2D4).withValues(alpha: 0.4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
