import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:yellow_flowers/core/design_system.dart';

class AlbumCard extends StatefulWidget {
  const AlbumCard({
    super.key,
    required this.title,
    required this.icon,
    required this.colors,
    this.onTap,
    this.count = 0,
    this.previewPaths = const [],
    this.quotes = const [],
  });

  final String title;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback? onTap;
  final int count;
  final List<String> previewPaths;
  final List<String> quotes;

  @override
  State<AlbumCard> createState() => _AlbumCardState();
}

class _AlbumCardState extends State<AlbumCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool isFeatured = widget.count > 0;

    return Hero(
      tag: 'album-${widget.title}',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isHovered = true),
        onTapUp: (_) => setState(() => _isHovered = false),
        onTapCancel: () => setState(() => _isHovered = false),
        child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 200),
            tween: Tween<double>(begin: 1.0, end: _isHovered ? 1.03 : 1.0),
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: _isHovered
                        ? PremiumDesign.deepShadow
                        : (isFeatured ? PremiumDesign.softShadow : []),
                    border: !isFeatured
                        ? Border.all(
                            color:
                                PremiumDesign.softText.withValues(alpha: 0.05))
                        : null,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Material(
                      color: isFeatured
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                      child: InkWell(
                        onTap: widget.onTap,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Preview Area
                            Expanded(
                              flex: 3,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  _buildPreviewBackground(isFeatured),
                                  if (isFeatured) _buildGlossyOverlay(),
                                  _buildCounterBadge(),
                                  if (isFeatured && widget.quotes.isNotEmpty)
                                    _buildQuotesOverlay(),
                                ],
                              ),
                            ),

                            // Album Info
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.playfairDisplay(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: isFeatured
                                            ? PremiumDesign.softText
                                            : PremiumDesign.secondaryText,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(widget.icon,
                                            size: 14,
                                            color: isFeatured
                                                ? PremiumDesign.radiantGold
                                                : PremiumDesign.secondaryText
                                                    .withValues(alpha: 0.5)),
                                        const SizedBox(width: 6),
                                        Text(
                                          isFeatured ? 'Colección' : 'Vacío',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: PremiumDesign.secondaryText
                                                .withValues(alpha: 0.7),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }

  Widget _buildPreviewBackground(bool isFeatured) {
    if (widget.previewPaths.isNotEmpty) {
      return Container(
        margin: const EdgeInsets.all(12),
        child: Stack(
          children: [
            // Bottom fake card for stack effect
            if (widget.previewPaths.length > 1)
              Positioned.fill(
                child: Transform.rotate(
                  angle: -0.05,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                        )
                      ],
                    ),
                  ),
                ),
              ),

            // Middle fake card for stack effect
            if (widget.previewPaths.length > 2)
              Positioned.fill(
                child: Transform.rotate(
                  angle: 0.05,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                        )
                      ],
                    ),
                  ),
                ),
              ),

            // Top actual card
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.file(
                    File(widget.previewPaths.first),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildGradientBackground(),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return _buildGradientBackground();
  }

  Widget _buildGradientBackground() {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            widget.colors.first.withValues(alpha: 0.4),
            widget.colors.last.withValues(alpha: 0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(widget.icon,
            color: widget.colors.last.withValues(alpha: 0.5), size: 44),
      ),
    );
  }

  Widget _buildGlossyOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withValues(alpha: 0.3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCounterBadge() {
    if (widget.count == 0) return const SizedBox.shrink();

    return Positioned(
      top: 16,
      right: 16,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded,
                    color: PremiumDesign.radiantGold.withValues(alpha: 0.9),
                    size: 10),
                const SizedBox(width: 6),
                Text(
                  '${widget.count} ${widget.count == 1 ? 'recuerdo' : 'recuerdos'}',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuotesOverlay() {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '“${widget.quotes.first}”',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 10,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w500,
              shadows: [
                const Shadow(
                    color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))
              ]),
        ),
      ),
    );
  }
}
