import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/home/bloc/home_bloc.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bgController;
  late final Animation<Color?> _topColorAnim;
  late final Animation<Color?> _bottomColorAnim;

  @override
  void initState() {
    super.initState();
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat(reverse: true);
    _topColorAnim = ColorTween(
      begin: const Color(0xFFFFF7C2),
      end: const Color(0xFFFFE8A3),
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
    _bottomColorAnim = ColorTween(
      begin: const Color(0xFFFFD3B6),
      end: const Color(0xFFFFB347),
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<HomeBloc>(
      builder: (context, model, child) => AnimatedBuilder(
        animation: _bgController,
        builder: (context, _) => Scaffold(
          appBar: AppBar(
            title: const Text(
              'Elige tu experiencia ✨',
              style: TextStyle(
                color: Colors.black87,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
          ),
          extendBodyBehindAppBar: true,
          body: Stack(
            children: [
              // Animated gradient background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      _topColorAnim.value ?? const Color(0xFFFFF7C2),
                      _bottomColorAnim.value ?? const Color(0xFFFFB3C6),
                    ],
                  ),
                ),
              ),
              // Soft decorative hearts/petals
              ...List.generate(8, (i) {
                final rnd = math.Random(i + 42);
                final dx = rnd.nextDouble();
                final dy = rnd.nextDouble();
                final drift =
                    math.sin((_bgController.value * 2 * math.pi) + i) * 10;
                final isHeart = i.isEven;
                return Positioned(
                  left: dx * MediaQuery.of(context).size.width,
                  top: dy * MediaQuery.of(context).size.height / 2 + drift,
                  child: Opacity(
                    opacity: 0.10 +
                        0.10 *
                            math
                                .sin(_bgController.value * 2 * math.pi + i)
                                .abs(),
                    child: Transform.rotate(
                      angle:
                          math.sin(_bgController.value * 2 * math.pi + i) * 0.2,
                      child: Icon(
                        isHeart ? Icons.favorite : Icons.local_florist,
                        color: isHeart
                            ? Colors.pinkAccent
                            : const Color(0xFFFFE07D),
                        size: 18 + rnd.nextDouble() * 10,
                      ),
                    ),
                  ),
                );
              }),
              // Content list
              SafeArea(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                  itemCount: model.menuItems.length,
                  itemBuilder: (context, index) {
                    final item = model.menuItems[index];
                    final color = Colors.pink[300]!;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Card(
                        elevation: 6,
                        shadowColor: Colors.black.withValues(alpha: 0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: ListTile(
                          leading: _AnimatedLeadingIcon(
                              icon: item.icon,
                              progress: _bgController.value,
                              color: color),
                          title: Text(
                            item.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          subtitle: Text(item.description),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => item.destination,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedLeadingIcon extends StatelessWidget {
  const _AnimatedLeadingIcon({
    required this.icon,
    required this.progress,
    required this.color,
  });
  final IconData icon;
  final double progress;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final t = Curves.easeInOut.transform(progress);
    final isMusic =
        icon == Icons.music_note || icon == Icons.music_note_outlined;
    final sway = math.sin(t * 2 * math.pi) * 0.08;
    final lift = math.sin(t * 2 * math.pi) * (isMusic ? 2.0 : 1.0);
    return Transform.translate(
      offset: Offset(0, -lift),
      child: Transform.rotate(
        angle: sway,
        child: Icon(
          icon,
          color: color,
          size: 28,
        ),
      ),
    );
  }
}
