import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'package:yellow_flowers/core/connectivity/connectivity_controller.dart';

/// Wraps the whole app (via MaterialApp.builder) with a thin, dismissible
/// banner that appears whenever the device loses connectivity. Cached
/// content (music, gallery, messages) keeps working — this just sets
/// expectations instead of letting failures look like bugs.
class OfflineBannerWrapper extends StatelessWidget {
  const OfflineBannerWrapper({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityController>(
      builder: (context, connectivity, _) {
        return Column(
          children: [
            AnimatedSize(
              duration: const Duration(milliseconds: 250),
              child: connectivity.isOnline
                  ? const SizedBox.shrink()
                  : const _OfflineBar(),
            ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}

class _OfflineBar extends StatelessWidget {
  const _OfflineBar();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF3E2723),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cloud_off_rounded, size: 14, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                'Sin conexión — mostrando contenido guardado',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
