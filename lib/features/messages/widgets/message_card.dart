import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.text,
    this.onFavorite,
    this.isFavorite = false,
    this.onSpeak,
  });

  final String text;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final VoidCallback? onSpeak;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.local_florist, color: Colors.pinkAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: Colors.pinkAccent),
              onPressed: onFavorite,
              tooltip: 'Favorito',
            ),
            IconButton(
              icon: const Icon(Icons.volume_up_rounded),
              onPressed: onSpeak,
              tooltip: 'Escuchar',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () async {
                await SharePlus.instance.share(
                  ShareParams(text: text),
                );
              },
              tooltip: 'Compartir',
            ),
          ],
        ),
      ),
    );
  }
}
