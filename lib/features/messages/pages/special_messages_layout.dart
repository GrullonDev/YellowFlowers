import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/messages/bloc/special_messages_bloc.dart';
import 'package:yellow_flowers/features/messages/model/message_models.dart';
import 'package:yellow_flowers/features/messages/widgets/message_card.dart';
import 'package:yellow_flowers/widgets/animated_background.dart';

class SpecialMessagesLayout extends StatelessWidget {
  const SpecialMessagesLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SpecialMessagesBloc>(
      builder: (context, model, _) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Mensajes Especiales'),
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Mensajes'),
                Tab(text: 'Favoritos'),
              ],
            ),
          ),
          body: AnimatedBackground(
            child: TabBarView(
              children: [
                Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 8),
                      child: Row(
                        children: MessageCategory.values.map((c) {
                          final selected = c == model.selected;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(c.label),
                              selected: selected,
                              onSelected: (_) => model.setCategory(c),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 140,
                            child: TextField(
                              onChanged: model.setName,
                              decoration: const InputDecoration(
                                labelText: 'Nombre',
                                hintText: 'Ej: Ana',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: model.controller,
                              decoration: const InputDecoration(
                                hintText:
                                    'Escribe un mensaje… usa {nombre} si quieres',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            onPressed: () {
                              model.addMessage(model.controller.text);
                              model.controller.clear();
                            },
                            child: const Icon(Icons.send),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: model.messages.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, i) {
                          final msg = model.messages[i];
                          return Dismissible(
                            key: ValueKey(
                                'msg_${msg.category.name}_${msg.createdAt.millisecondsSinceEpoch}'),
                            background: Container(
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 16),
                              child:
                                  const Icon(Icons.delete, color: Colors.white),
                            ),
                            direction: DismissDirection.endToStart,
                            onDismissed: (_) => model.removeMessage(msg),
                            child: MessageCard(
                              text: '${msg.text} ${msg.category.emoji}',
                              isFavorite: msg.isFavorite,
                              onFavorite: () => model.toggleFavorite(i),
                              onSpeak: () => model.speak(i),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: model.favorites.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) {
                    final fav = model.favorites[i];
                    return MessageCard(
                      text: '${fav.text} ${fav.category.emoji}',
                      isFavorite: true,
                      onSpeak: () => model.speakMessage(fav),
                      onFavorite: () {
                        final idx = model.messages.indexWhere((m) =>
                            m.text == fav.text && m.category == fav.category);
                        if (idx != -1) model.toggleFavorite(idx);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
