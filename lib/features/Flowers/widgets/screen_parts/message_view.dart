import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yellow_flowers/core/design_system.dart';
import 'package:yellow_flowers/features/flowers/models/personalization.dart';
import 'package:yellow_flowers/widgets/typewriter_text.dart';
import 'package:yellow_flowers/features/flowers/models/default_messages.dart';
import 'package:yellow_flowers/di/injector.dart';
import 'package:yellow_flowers/core/personalization_service.dart';

class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.recipientName,
    required this.message,
    required this.mood,
    required this.entranceController,
    required this.onShare,
    required this.onSave,
  });

  final String recipientName;
  final String message;
  final Mood mood;
  final AnimationController entranceController;
  final VoidCallback onShare;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final name = sl<PersonalizationService>().getUserName();
    final finalMessage = (message.trim().isEmpty) ? DefaultMessages.getRandom(name) : message;

    return Column(
      children: [
        const SizedBox(height: PremiumDesign.s16),

        _EmotionalHeader(controller: entranceController),

        const SizedBox(height: PremiumDesign.s24),

        _MoodStatusBubble(
          mood: mood,
          controller: entranceController,
        ),

        const SizedBox(height: PremiumDesign.s48),

        _GiftMessageCard(
          recipientName: recipientName,
          message: finalMessage,
          entrance: entranceController,
          onShare: onShare,
          onSave: onSave,
        ),
      ],
    );
  }
}

class _EmotionalHeader extends StatelessWidget {
  const _EmotionalHeader({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: controller, curve: const Interval(0.0, 0.4, curve: Curves.easeOut));
    final slide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(parent: controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOutQuart)),
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: Column(
          children: [
            Text(
              'Un regalo del corazón',
              style: PremiumDesign.serifDisplay,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Container(
              height: 2,
              width: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.transparent, PremiumDesign.radiantGold.withAlpha(100), Colors.transparent]),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Flores que susurran sentimientos 🌻',
              style: PremiumDesign.sansBody.copyWith(
                fontSize: 14,
                letterSpacing: 0.5,
                color: PremiumDesign.secondaryText.withAlpha(150),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodStatusBubble extends StatelessWidget {
  const _MoodStatusBubble({required this.mood, required this.controller});
  final Mood mood;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    final moodInfo = _getMoodInfo(mood);
    final scale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: controller, curve: const Interval(0.2, 0.6, curve: Curves.elasticOut)),
    );

    return ScaleTransition(
      scale: scale,
      child: FadeTransition(
        opacity: CurvedAnimation(parent: controller, curve: const Interval(0.2, 0.5)),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(140),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: moodInfo.color.withAlpha(30), width: 1),
            boxShadow: [
              BoxShadow(color: moodInfo.color.withAlpha(10), blurRadius: 15),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(shape: BoxShape.circle, color: moodInfo.color),
              ),
              const SizedBox(width: 8),
              Text(
                'Estado: ${moodInfo.label}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: PremiumDesign.softText.withAlpha(200),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ({Color color, String label}) _getMoodInfo(Mood mood) {
    switch (mood) {
      case Mood.joy: return (color: PremiumDesign.radiantGold, label: 'Alegre ☀️');
      case Mood.calm: return (color: Colors.purple.withAlpha(150), label: 'Relajada 🕊️');
      case Mood.passion: return (color: Colors.red.withAlpha(150), label: 'Pasión ❤️');
    }
  }
}

class _GiftMessageCard extends StatelessWidget {
  const _GiftMessageCard({
    required this.recipientName,
    required this.message,
    required this.entrance,
    required this.onShare,
    required this.onSave,
  });

  final String recipientName;
  final String message;
  final AnimationController entrance;
  final VoidCallback onShare;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: entrance, curve: const Interval(0.4, 0.9, curve: Curves.easeOut));
    final slide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
      CurvedAnimation(parent: entrance, curve: const Interval(0.4, 1.0, curve: Curves.easeOutBack)),
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            boxShadow: PremiumDesign.deepShadow,
            gradient: LinearGradient(
              colors: [Colors.white.withAlpha(210), Colors.white.withAlpha(180)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(color: Colors.white.withAlpha(180), width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
              child: Padding(
                padding: const EdgeInsets.all(PremiumDesign.s32),
                child: Column(
                  children: [
                    Text(
                      'UN MENSAJE ESPECIAL 🌻',
                      style: PremiumDesign.sansLabel,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '$recipientName,',
                      style: PremiumDesign.serifDisplay.copyWith(fontSize: 28),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    TypewriterText(
                      text: message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        fontStyle: FontStyle.italic,
                        height: 1.4,
                        color: PremiumDesign.softText,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _PremiumActionButton(
                            icon: Icons.share_rounded,
                            label: 'Compartir 💛',
                            isPrimary: true,
                            onPressed: onShare,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PremiumActionButton(
                            icon: Icons.download_rounded,
                            label: 'Guardar',
                            onPressed: onSave,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PremiumActionButton extends StatelessWidget {
  const _PremiumActionButton({required this.icon, required this.label, this.isPrimary = false, required this.onPressed});
  final IconData icon;
  final String label;
  final bool isPrimary;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? PremiumDesign.softText : Colors.white.withAlpha(100),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isPrimary ? PremiumDesign.isDarkMode(context) ? null : PremiumDesign.softShadow : null,
          border: isPrimary ? null : Border.all(color: PremiumDesign.softText.withAlpha(20)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: isPrimary ? Colors.white : PremiumDesign.softText),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isPrimary ? Colors.white : PremiumDesign.softText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
