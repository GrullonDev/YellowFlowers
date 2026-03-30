import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yellow_flowers/features/messages/bloc/special_messages_bloc.dart';
import 'package:yellow_flowers/features/messages/model/message_models.dart';
import 'package:yellow_flowers/features/messages/widgets/message_card.dart';
import 'package:yellow_flowers/widgets/animated_background.dart';
import 'package:yellow_flowers/di/injector.dart' as di;
import 'package:yellow_flowers/features/music/bloc/music_bloc.dart';
import 'package:yellow_flowers/features/music/domain/entities/mood.dart';
import 'package:yellow_flowers/features/experience/pages/immersive_experience_page.dart';
import 'package:yellow_flowers/features/cycle/pages/cycle_music_page.dart';

class SpecialMessagesLayout extends StatefulWidget {
  const SpecialMessagesLayout({super.key});

  @override
  State<SpecialMessagesLayout> createState() => _SpecialMessagesLayoutState();
}

class _SpecialMessagesLayoutState extends State<SpecialMessagesLayout> {
  @override
  Widget build(BuildContext context) {
    return Consumer<SpecialMessagesBloc>(
      builder: (context, model, _) => DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Mensajes Especiales'),
            actions: [
              IconButton(
                tooltip: 'Ciclo y Música',
                icon: const Icon(Icons.auto_awesome_rounded),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CycleMusicPage()),
                  );
                },
              ),
              IconButton(
                tooltip: 'Modo inmersivo',
                icon: const Icon(Icons.play_circle_fill_rounded),
                onPressed: () {
                  final bloc = context.read<SpecialMessagesBloc>();
                  final mood = _moodForCategory(bloc.selected);
                  final firstText = bloc.messages.isNotEmpty
                      ? bloc.messages.first.text
                      : 'Un momento especial para ti';
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ImmersiveExperiencePage(
                        initialText: firstText,
                        mood: mood,
                      ),
                    ),
                  );
                },
              ),
            ],
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
                      padding:
                          const EdgeInsets.only(left: 16, right: 16, top: 8),
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
                    _ContextRecommendationBar(),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                MessageCard(
                                  text: '${msg.text} ${msg.category.emoji}',
                                  isFavorite: msg.isFavorite,
                                  onFavorite: () => model.toggleFavorite(i),
                                  onSpeak: () => model.speak(i),
                                ),
                                const SizedBox(height: 6),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    icon: const Text('🎶'),
                                    label: const Text('Acompañar con música'),
                                    onPressed: () => _showMusicSuggestion(
                                        context, msg.category, msg.text),
                                  ),
                                ),
                              ],
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

class _ContextRecommendationBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.watch<SpecialMessagesBloc>();
    final mood = _moodForCategory(bloc.selected);
    final text = _contextualText(mood);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          leading: const Text('💡', style: TextStyle(fontSize: 20)),
          title: Text(text),
          trailing: FilledButton(
            onPressed: () => _showMusicSuggestion(context, bloc.selected, null),
            child: const Text('Escuchar'),
          ),
        ),
      ),
    );
  }
}

Future<void> _showMusicSuggestion(
    BuildContext context, MessageCategory category, String? sourceText) async {
  final mood = _moodForCategory(category);
  final bloc = di.sl<MusicBloc>();
  bloc.selectMood(mood);
  // Espera breve para que el bloc obtenga recomendación (mejorable con listener a futuro)
  await Future.delayed(const Duration(milliseconds: 150));
  final song = bloc.dailyRecommendation;
  if (song == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay sugerencias disponibles ahora.')),
      );
    }
    return;
  }
  if (!context.mounted) return;
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (ctx) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_sheetTitleForMood(mood),
                style: Theme.of(ctx).textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                if (song.coverUrl.isNotEmpty)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(song.coverUrl,
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink()),
                  )
                else
                  const SizedBox(width: 64, height: 64),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '${song.title} — ${song.artist}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: () async {
                    await bloc.playSong(song);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: const Text('Reproducir'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    bloc.playSong(song);
                    Navigator.pop(ctx);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ImmersiveExperiencePage(
                          initialText: sourceText ?? 'Un recuerdo para ti',
                          mood: mood,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Ver recuerdo sugerido'),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Guardado como favorito con su canción')),
                    );
                  },
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('Guardar como favorito'),
                ),
              ],
            ),
            if (sourceText != null && sourceText.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Mensaje:',
                style: Theme.of(ctx)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: Colors.black54),
              ),
              Text(
                sourceText,
                style: Theme.of(ctx).textTheme.bodyMedium,
              ),
            ]
          ],
        ),
      );
    },
  );
}

Mood _moodForCategory(MessageCategory c) {
  switch (c) {
    case MessageCategory.love:
      return Mood.romantic;
    case MessageCategory.friendship:
      return Mood.happy;
    case MessageCategory.selfEsteem:
      return Mood.motivated;
    case MessageCategory.family:
      return Mood.nostalgic;
    case MessageCategory.occasions:
      return Mood.happy;
    case MessageCategory.community:
      return Mood.relaxed;
  }
}

String _contextualText(Mood mood) {
  switch (mood) {
    case Mood.motivated:
      return 'Hoy que te sientes motivada, esta canción te dará energía 🚀';
    case Mood.nostalgic:
      return 'Como te sientes nostálgica, revive un recuerdo acompañado de esta canción 🎶';
    case Mood.romantic:
      return 'Para este momento romántico, deja que la música hable por ti 💖';
    case Mood.happy:
      return 'Con ese ánimo alegre, sube el volumen y disfruta 💛';
    case Mood.relaxed:
      return 'Respira profundo y relájate con esta melodía 🌿';
  }
}

String _sheetTitleForMood(Mood mood) {
  switch (mood) {
    case Mood.motivated:
      return 'Energía para este momento ✨';
    case Mood.nostalgic:
      return 'Una canción para recordar 🌙';
    case Mood.romantic:
      return 'Acompaña tu mensaje con amor 💖';
    case Mood.happy:
      return 'Música para sonreír 💛';
    case Mood.relaxed:
      return 'Un respiro musical 🌿';
  }
}
