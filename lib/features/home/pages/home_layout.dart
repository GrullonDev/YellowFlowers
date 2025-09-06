import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/home/bloc/home_bloc.dart';
import 'package:yellow_flowers/widgets/animated_background.dart';

class HomeLayout extends StatefulWidget {
  const HomeLayout({super.key});

  @override
  State<HomeLayout> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  @override
  Widget build(BuildContext context) {
    return Consumer<HomeBloc>(
      builder: (context, model, child) => Scaffold(
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
        body: AnimatedBackground(
          child: SafeArea(
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
                          progress: 0.0, // Static for now, could be animated later
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
        ),
      ),
    );
  }
}

// End of _HomeLayoutState
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
