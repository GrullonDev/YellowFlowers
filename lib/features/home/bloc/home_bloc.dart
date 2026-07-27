import 'package:flutter/material.dart';

import 'package:yellow_flowers/features/flowers/pages/flower_onboarding.dart';
import 'package:yellow_flowers/features/home/model/menu_item.dart';
import 'package:yellow_flowers/features/messages/pages/special_messages_page.dart';
import 'package:yellow_flowers/features/moments_gallery/pages/moments_gallery_page.dart';
import 'package:yellow_flowers/features/music/pages/music_page.dart';
import 'package:yellow_flowers/features/cycle/pages/cycle_music_page.dart';
import 'package:yellow_flowers/utils/base_model.dart';

class HomeBloc extends BaseModel {
  HomeBloc({required this.context});

  BuildContext context;

  List<MenuItem> get menuItems => [
        MenuItem(
          id: 'flowers',
          title: 'Flores Amarillas',
          icon: Icons.local_florist,
          destination: const FlowerOnboardingPage(),
          description: 'Un detalle con flores y un mensaje especial 💛',
        ),
        MenuItem(
          id: 'moments',
          title: 'Galería de Momentos',
          icon: Icons.photo_library,
          destination: const MomentsGalleryPage(),
          description: 'Tus recuerdos favoritos, en un solo lugar 🖼️',
        ),
        MenuItem(
          id: 'messages',
          title: 'Mensajes Especiales',
          icon: Icons.message,
          destination: const SpecialMessagesPage(),
          description: 'Palabras que llegan al corazón ✍️',
        ),
        MenuItem(
          id: 'music',
          title: 'Tu Música',
          icon: Icons.headphones_rounded,
          destination: const MusicPage(),
          description: 'Canciones según tu estado de ánimo 🎵',
        ),
        MenuItem(
          id: 'cycle',
          title: 'Mi Ciclo',
          icon: Icons.spa_rounded,
          destination: const CycleMusicPage(),
          description: 'Lleva el control de tu ciclo con amor 🌸',
        ),
        /* MenuItem(
          id: 'cards',
          title: 'Tarjetas Virtuales',
          icon: Icons.card_giftcard,
          destination: AlertDialog(
            title: const Text('Mensaje'),
            content: const Text('¡Hola! Este es un mensaje de prueba.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
          description: 'Diseña y comparte una tarjeta en segundos 🎁',
        ), */
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
