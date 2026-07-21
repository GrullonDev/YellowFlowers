import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:yellow_flowers/core/design_system.dart';

/// Shared empty/error state (icon + title + message + optional retry).
///
/// Use this instead of ad-hoc "no results" widgets so every feature
/// (music, moments gallery, special messages...) degrades the same way
/// when a load fails or Firestore is unreachable, rather than showing a
/// silent blank screen.
class AppErrorView extends StatelessWidget {
  const AppErrorView({
    super.key,
    required this.message,
    this.title = 'No pudimos cargar esto',
    this.emoji = '🐚',
    this.onRetry,
    this.retryLabel = 'Reintentar',
  });

  final String title;
  final String message;
  final String emoji;
  final VoidCallback? onRetry;
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(PremiumDesign.s32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: PremiumDesign.softText,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: PremiumDesign.secondaryText,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              InkWell(
                onTap: onRetry,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: PremiumDesign.premiumGold.withValues(alpha: 0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    retryLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: PremiumDesign.premiumGold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
