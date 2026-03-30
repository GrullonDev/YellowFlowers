import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:yellow_flowers/core/design_system.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({
    super.key,
    required this.text,
    this.onFavorite,
    this.isFavorite = false,
    this.onSpeak,
    this.color,
  });

  final String text;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final VoidCallback? onSpeak;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: PremiumDesign.premiumRadius,
        boxShadow: PremiumDesign.softShadow,
      ),
      child: ClipRRect(
        borderRadius: PremiumDesign.premiumRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.all(PremiumDesign.s24),
            decoration: BoxDecoration(
              color: (color ?? Colors.white).withValues(alpha: 0.85),
              borderRadius: PremiumDesign.premiumRadius,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icono decorativo sutil
                Opacity(
                  opacity: 0.4,
                  child: Icon(Icons.format_quote_rounded, 
                    color: PremiumDesign.premiumGold, 
                    size: 32
                  ),
                ),
                
                const SizedBox(height: PremiumDesign.s8),

                // Texto del mensaje
                Center(
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: PremiumDesign.softText,
                      height: 1.4,
                    ),
                  ),
                ),

                const SizedBox(height: PremiumDesign.s24),

                // Acciones refinadas
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _ActionButton(
                      icon: isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.redAccent : PremiumDesign.secondaryText,
                      onTap: onFavorite,
                    ),
                    const SizedBox(width: PremiumDesign.s16),
                    _ActionButton(
                      icon: Icons.volume_up_rounded,
                      color: PremiumDesign.secondaryText,
                      onTap: onSpeak,
                    ),
                    const SizedBox(width: PremiumDesign.s16),
                    _ActionButton(
                      icon: Icons.share_rounded,
                      color: PremiumDesign.secondaryText,
                      onTap: () async {
                        await Share.share(text);
                      },
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}
