import 'package:flutter/material.dart';

import 'package:yellow_flowers/features/flowers/widgets/name_entry_flower.dart';
import 'package:yellow_flowers/features/home/data/object/menu_item.dart';
import 'package:yellow_flowers/utils/base_model.dart';

class HomeBloc extends BaseModel {
  List<MenuItem> get menuItems => [
        MenuItem(
          title: 'Flores Amarillas',
          icon: Icons.local_florist,
          destination: const NameEntryFlower(),
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
          destination: const Scaffold(),
        ),
        MenuItem(
          title: 'Tarjetas Virtuales',
          icon: Icons.card_giftcard,
          destination: const Scaffold(),
        ),
      ];
}
