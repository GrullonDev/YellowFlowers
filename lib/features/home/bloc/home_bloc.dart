import 'package:flutter/material.dart';

import 'package:yellow_flowers/features/Flowers/pages/flower_onboarding.dart';
import 'package:yellow_flowers/features/home/data/model/menu_item.dart';
import 'package:yellow_flowers/features/music/pages/music_page.dart';
import 'package:yellow_flowers/utils/base_model.dart';

class HomeBloc extends BaseModel {
  HomeBloc({required this.context});

  BuildContext context;

  List<MenuItem> get menuItems => [
        MenuItem(
          title: 'Flores Amarillas',
          icon: Icons.local_florist,
          destination: const FlowerOnboardingPage(),
        ),
        MenuItem(
          title: 'Galería de Momentos',
          icon: Icons.photo_library,
          destination: const Scaffold(),
        ),
        MenuItem(
          title: 'Mensajes Especiales',
          icon: Icons.message,
          destination: const Scaffold(),
        ),
        MenuItem(
          title: 'Música Romántica',
          icon: Icons.music_note,
          destination: const MusicPage(),
        ),
        MenuItem(
          title: 'Tarjetas Virtuales',
          icon: Icons.card_giftcard,
          destination: const Scaffold(),
        ),
      ];

  void showMessage() {
    // Show a message to the user
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Mensaje'),
          content: const Text('¡Hola! Este es un mensaje de prueba.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }
}
