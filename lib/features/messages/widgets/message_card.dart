import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.text,
    this.onFavorite,
    this.isFavorite = false,
    this.onSpeak,
    this.color = const Color(0xFFFFF9C4), // Default sticky note yellow
  });

  final String text;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final VoidCallback? onSpeak;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
        // Slight bottom-right curl effect
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(0),
            topRight: Radius.circular(0),
            bottomLeft: Radius.circular(0),
            bottomRight: Radius.circular(16)),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(
                    child: Text(
                      text,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.handlee(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.redAccent : Colors.black45,
                          size: 20),
                      onPressed: onFavorite,
                      tooltip: 'Favorito',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.volume_up_rounded,
                          color: Colors.black54, size: 20),
                      onPressed: onSpeak,
                      tooltip: 'Escuchar',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    const SizedBox(width: 16),
                    IconButton(
                      icon: const Icon(Icons.share,
                          color: Colors.black54, size: 20),
                      onPressed: () async {
                        await SharePlus.instance.share(
                          ShareParams(text: text),
                        );
                      },
                      tooltip: 'Compartir',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Pin graphic
          Positioned(
            top: -6,
            left: 0,
            right: 0,
            child: Icon(Icons.push_pin,
                size: 24, color: Colors.redAccent.withValues(alpha: 0.8)),
          ),
        ],
      ),
    );
  }
}
