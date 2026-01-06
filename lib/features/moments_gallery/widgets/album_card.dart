import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AlbumCard extends StatelessWidget {
  const AlbumCard({
    super.key,
    required this.title,
    required this.icon,
    required this.colors,
    this.onTap,
    this.rotation = 0.0,
  });

  final String title;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback? onTap;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(4), // Bordes más rectos estilo foto
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(4, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(
              12, 12, 12, 40), // Espacio abajo para texto
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
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.gaegu(
                    // Fuente estilo marcador
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
