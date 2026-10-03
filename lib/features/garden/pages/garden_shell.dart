import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:yellow_flowers/core/notification_service.dart';
import 'package:yellow_flowers/core/personalization_service.dart';
import 'package:yellow_flowers/core/responsive.dart';
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
import 'package:url_launcher/url_launcher.dart';
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
    final barH = context.hp(64).clamp(56.0, 72.0);
    final itemW = context.wp(64).clamp(52.0, 80.0);
    final iconSize = context.dp(22).clamp(18.0, 26.0);
    final labelSize = context.sp(9).clamp(8.0, 11.0);
    final hPad = context.wp(16).clamp(10.0, 24.0);
    final bottomPad = MediaQuery.of(context).padding.bottom + context.hp(8);
    final radius = context.dp(24).clamp(18.0, 28.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, bottomPad),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: barH,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
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
                    width: itemW,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                          padding: EdgeInsets.all(context.dp(6)),
                          decoration: active
                              ? BoxDecoration(
                                  color: _gold.withAlpha(35),
                                  borderRadius:
                                      BorderRadius.circular(context.dp(12)),
                                )
                              : null,
                          child: Icon(icon,
                              size: iconSize,
                              color:
                                  active ? _gold : _warmWhite.withAlpha(120)),
                        ),
                        SizedBox(height: context.hp(2)),
                        Text(label,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: labelSize,
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
              padding: EdgeInsets.fromLTRB(
                  context.wp(20).clamp(14.0, 28.0),
                  context.hp(24),
                  context.wp(20).clamp(14.0, 28.0),
                  context.hp(8)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Hola, $name',
                      style: GoogleFonts.playfairDisplay(
                          fontSize: context.sp(26).clamp(20, 32),
                          fontWeight: FontWeight.w700,
                          color: _warmWhite)),
                  SizedBox(height: context.hp(4)),
                  Text('Tu espacio de calma y flores',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: context.sp(13).clamp(11, 15),
                          color: _warmWhite.withAlpha(150))),
                ],
              ),
            ),
            const Divider(color: Color(0x33FFD54F), indent: 20, endIndent: 20),
            SizedBox(height: context.hp(8)),
            _DrawerTile(
              icon: Icons.local_florist,
              label: 'Amarillas',
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
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: GestureDetector(
                onTap: () => _openBetaSignup(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(colors: [
                      const Color(0xFFFFE082).withAlpha(25),
                      const Color(0xFFFFB300).withAlpha(15),
                    ]),
                    border: Border.all(color: _gold.withAlpha(60)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _gold.withAlpha(30),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.science_rounded,
                            color: _gold, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Únete a la Beta',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _gold)),
                            Text('Prueba Amarillas antes que nadie',
                                style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    color: _warmWhite.withAlpha(130))),
                          ],
                        ),
                      ),
                      Icon(Icons.open_in_new_rounded,
                          color: _gold.withAlpha(140), size: 18),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
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

  Future<void> _openBetaSignup(BuildContext context) async {
    const betaUrl = 'https://forms.gle/REPLACE_WITH_YOUR_FORM_ID';
    final uri = Uri.parse(betaUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
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
              fontSize: 15, fontWeight: FontWeight.w600, color: _warmWhite)),
      trailing: Icon(Icons.chevron_right_rounded,
          color: _warmWhite.withAlpha(60), size: 20),
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
    );
  }
}
