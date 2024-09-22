import 'package:flutter/material.dart';
import 'package:yellow_flowers/features/Flowers/pages/flower_screen.dart';
import 'package:yellow_flowers/utils/buttons/elevated_button.dart';

class HomeLayout extends StatelessWidget {
  const HomeLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text('Menu'),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppElevatedButton(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const Placeholder(),
              ),
            ),
            title: 'lalalalalala',
          ),
          const SizedBox(height: 20),
          const Text('Hola Mundo!!'),
          const SizedBox(height: 20),
          const Text('Hola Mundo!!'),
          const SizedBox(height: 20),
          const Text('Hola Mundo!!'),
          const SizedBox(height: 20),
          const Text('Hola Mundo!!'),
          const SizedBox(height: 20),
          AppElevatedButton(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FlowerScreen(),
              ),
            ),
            title: 'Flores Amarillas',
          ),
        ],
      ),
    );
  }
}
