import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:yellow_flowers/core/design_system.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({
    super.key,
    required this.onShare,
    required this.onSave,
  });

  final VoidCallback onShare;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PremiumInteractionButton(
            icon: Icons.share_rounded,
            label: 'Compartir',
            onPressed: onShare,
          ),
        ),
        const SizedBox(width: PremiumDesign.s16),
        Expanded(
          child: _PremiumInteractionButton(
            icon: Icons.download_rounded,
            label: 'Guardar',
            onPressed: onSave,
          ),
        ),
      ],
    );
  }
}

class _PremiumInteractionButton extends StatefulWidget {
  const _PremiumInteractionButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  State<_PremiumInteractionButton> createState() =>
      _PremiumInteractionButtonState();
}

class _PremiumInteractionButtonState extends State<_PremiumInteractionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: PremiumDesign.softText,
            borderRadius: BorderRadius.circular(18),
            boxShadow: PremiumDesign.softShadow,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
