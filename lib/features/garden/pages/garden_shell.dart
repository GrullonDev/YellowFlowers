import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yellow_flowers/core/notification_service.dart';
import 'package:yellow_flowers/core/personalization_service.dart';
import 'package:yellow_flowers/di/injector.dart';
import 'package:yellow_flowers/features/cycle/pages/cycle_music_page.dart';
import 'package:yellow_flowers/features/flowers/pages/flower_onboarding.dart';
import 'package:yellow_flowers/features/garden/pages/garden_page.dart';
import 'package:yellow_flowers/features/garden/pages/gift_chest_page.dart';
import 'package:yellow_flowers/features/garden/pages/greenhouse_page.dart';
import 'package:yellow_flowers/features/garden/pages/mood_checkin_page.dart';
import 'package:yellow_flowers/features/messages/pages/special_messages_page.dart';
import 'package:yellow_flowers/features/moments_gallery/pages/moments_gallery_page.dart';
import 'package:yellow_flowers/features/music/pages/music_page.dart';
import 'package:yellow_flowers/features/onboarding/pages/storytelling_onboarding.dart';

const _gold = Color(0xFFFFD54F);
const _warmWhite = Color(0xFFFFF8E1);

class GardenShell extends StatefulWidget {
  const GardenShell({super.key});

  @override
  State<GardenShell> createState() => _GardenShellState();
}

class _GardenShellState extends State<GardenShell> {
  int _currentIndex = 0;
  bool _showOnboarding = false;
  bool _onboardingChecked = false;

  final _pages = const <Widget>[
    GardenPage(),
    MoodCheckinPage(),
    GreenhousePage(),
    GiftChestPage(),
  ];

  @override
  void initState() {
    super.initState();
    _checkOnboarding();
  }

  Future<void> _checkOnboarding() async {
    final prefs = sl<SharedPreferences>();
    final seen = prefs.getBool('seen_premium_onboarding') ?? false;
    if (mounted) {
      setState(() {
        _showOnboarding = !seen;
        _onboardingChecked = true;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    final prefs = sl<SharedPreferences>();
    await prefs.setBool('seen_premium_onboarding', true);
    if (mounted) setState(() => _showOnboarding = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!_onboardingChecked) {
      return const Scaffold(
        backgroundColor: Color(0xFF0B0820),
        body: Center(child: CircularProgressIndicator(color: _gold)),
      );
    }
    if (_showOnboarding) {
      return StorytellingOnboarding(onComplete: _completeOnboarding);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0B0820),
      extendBody: true,
      drawer: _GardenDrawer(notificationService: sl<NotificationService>()),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _GlassBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = i);
        },
      ),
    );
  }
}

class _GlassBottomBar extends StatelessWidget {
  const _GlassBottomBar({
    required this.currentIndex,
    required this.onTap,
  });
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _items = [
    (Icons.yard_rounded, 'Jardín'),
    (Icons.emoji_emotions_rounded, 'Ánimo'),
    (Icons.local_florist_rounded, 'Recuerdos'),
    (Icons.card_giftcard_rounded, 'Regalos'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 0, 16, MediaQuery.of(context).padding.bottom + 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withAlpha(18),
              border: Border.all(
                color: const Color(0xFFFFE082).withAlpha(40),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(_items.length, (i) {
                final (icon, label) = _items[i];
                final active = currentIndex == i;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(i),
                  child: SizedBox(
                    width: 64,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          padding: const EdgeInsets.all(6),
                          decoration: active
                              ? BoxDecoration(
                                  color: _gold.withAlpha(35),
                                  borderRadius: BorderRadius.circular(12),
                                )
                              : null,
                          child: Icon(icon,
                              size: 22,
                              color: active
                                  ? _gold
                                  : _warmWhite.withAlpha(120)),
                        ),
                        const SizedBox(height: 2),
                        Text(label,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 9,
                                fontWeight:
                                    active ? FontWeight.w700 : FontWeight.w500,
                                color: active
                                    ? _gold
                                    : _warmWhite.withAlpha(100))),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _GardenDrawer extends StatefulWidget {
  const _GardenDrawer({required this.notificationService});
  final NotificationService notificationService;

  @override
  State<_GardenDrawer> createState() => _GardenDrawerState();
}

class _GardenDrawerState extends State<_GardenDrawer> {
  late bool _notificationsOn;

  @override
  void initState() {
    super.initState();
    _notificationsOn = widget.notificationService.enabled;
  }

  @override
  Widget build(BuildContext context) {
    final name = sl<PersonalizationService>().getUserName() ?? 'hermosa';
    return Drawer(
      backgroundColor: const Color(0xFF1A1030),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hola, $name',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: _warmWhite)),
                  const SizedBox(height: 4),
                  Text('Tu espacio de calma y flores',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 13, color: _warmWhite.withAlpha(150))),
                ],
              ),
            ),
            const Divider(color: Color(0x33FFD54F), indent: 20, endIndent: 20),
            const SizedBox(height: 8),
            _DrawerTile(
              icon: Icons.local_florist,
              label: 'Flores Amarillas',
              color: const Color(0xFFFFB300),
              onTap: () => _navigate(context, const FlowerOnboardingPage()),
            ),
            _DrawerTile(
              icon: Icons.photo_library_rounded,
              label: 'Galería de Momentos',
              color: const Color(0xFF43A047),
              onTap: () => _navigate(context, const MomentsGalleryPage()),
            ),
            _DrawerTile(
              icon: Icons.message_rounded,
              label: 'Mensajes Especiales',
              color: const Color(0xFFE91E8C),
              onTap: () => _navigate(context, const SpecialMessagesPage()),
            ),
            _DrawerTile(
              icon: Icons.headphones_rounded,
              label: 'Tu Música',
              color: const Color(0xFF7E57C2),
              onTap: () => _navigate(context, const MusicPage()),
            ),
            _DrawerTile(
              icon: Icons.spa_rounded,
              label: 'Mi Ciclo',
              color: const Color(0xFF0097A7),
              onTap: () => _navigate(context, const CycleMusicPage()),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Icon(Icons.notifications_active_rounded,
                      color: _gold.withAlpha(180), size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Recordatorio diario',
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14, color: _warmWhite.withAlpha(200))),
                  ),
                  Switch.adaptive(
                    value: _notificationsOn,
                    activeTrackColor: _gold,
                    onChanged: (v) {
                      setState(() => _notificationsOn = v);
                      widget.notificationService.setEnabled(v);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, Widget page) {
    Navigator.of(context).pop();
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withAlpha(30),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _warmWhite)),
      trailing: Icon(Icons.chevron_right_rounded,
          color: _warmWhite.withAlpha(60), size: 20),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
    );
  }
}
