import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:yellow_flowers/features/cycle/cycle_controller.dart';
import 'package:yellow_flowers/features/music/domain/entities/mood.dart';
import 'package:yellow_flowers/features/music/bloc/music_bloc.dart';
import 'package:yellow_flowers/di/injector.dart' as di;

class CyclePhaseBar extends StatelessWidget {
  const CyclePhaseBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleController>();
    final phase = cycle.currentPhase;
    final copy = _friendlyCopy(phase);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(_emoji(phase), style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      copy,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_needsSetup(cycle))
                    OutlinedButton(
                      onPressed: () => _openConfig(context),
                      child: const Text('Configurar'),
                    ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () => _suggestMusic(context, phase),
                    child: const Text('Escuchar'),
                  ),
                ],
              ),
              if (phase == CyclePhase.fertile)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: ChoiceChip(
                      label: const Text('Hoy prefiero energía 💥'),
                      selected: cycle.fertilePreferEnergetic,
                      onSelected: (v) => context
                          .read<CycleController>()
                          .setFertilePreferEnergetic(v),
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}

bool _needsSetup(CycleController c) => c.lastPeriodStart == null;

String _emoji(CyclePhase p) {
  switch (p) {
    case CyclePhase.premenstrual:
      return '🌙';
    case CyclePhase.fertile:
      return '💗';
    case CyclePhase.period:
      return '🌿';
    case CyclePhase.other:
      return '🌸';
  }
}

String _friendlyCopy(CyclePhase p) {
  switch (p) {
    case CyclePhase.premenstrual:
      return 'Un momento para apapacharte: música relajante y suave.';
    case CyclePhase.fertile:
      return 'Días de brillo: romántica o con mucha energía para ti.';
    case CyclePhase.period:
      return 'Tómatelo con calma: mensajes motivadores + música tranquilita.';
    case CyclePhase.other:
      return 'Te acompañamos con música que va contigo hoy.';
  }
}

Mood _moodForPhase(CyclePhase p) {
  switch (p) {
    case CyclePhase.premenstrual:
      return Mood.relaxed;
    case CyclePhase.fertile:
      return Mood.romantic; // también podría ser motivated
    case CyclePhase.period:
      return Mood.motivated; // mensajes motivadores + música calmante
    case CyclePhase.other:
      return Mood.relaxed;
  }
}

Future<void> _suggestMusic(BuildContext context, CyclePhase phase) async {
  final bloc = di.sl<MusicBloc>();
  final mood = _moodForPhase(phase);
  // Trigger selection which internally will load songs / recommendation.
  bloc.selectMood(mood);
  // Allow async fetch inside bloc to complete (could be improved with a state listener).
  await Future.delayed(const Duration(milliseconds: 150));
  final recommendation = bloc.dailyRecommendation;
  if (!context.mounted) return;
  if (recommendation == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No hay sugerencias disponibles ahora.')),
    );
    return;
  }
  await bloc.playSong(recommendation);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Reproduciendo: ${recommendation.title}')),
  );
}

Future<void> _openConfig(BuildContext context) async {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    builder: (ctx) => const _CycleConfigSheet(),
  );
}

class _CycleConfigSheet extends StatefulWidget {
  const _CycleConfigSheet();

  @override
  State<_CycleConfigSheet> createState() => _CycleConfigSheetState();
}

class _CycleConfigSheetState extends State<_CycleConfigSheet> {
  DateTime? _selectedDate;
  int _length = 28;

  @override
  void initState() {
    super.initState();
    final c = context.read<CycleController>();
    _selectedDate = c.lastPeriodStart;
    _length = c.cycleLength;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Tu ciclo', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final now = DateTime.now();
                    final first = DateTime(now.year - 1);
                    final initial = _selectedDate ?? now;
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: first,
                      lastDate: DateTime(now.year + 1),
                      initialDate: initial,
                    );
                    if (picked != null) setState(() => _selectedDate = picked);
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(_selectedDate == null
                      ? 'Primer día del último periodo'
                      : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Duración del ciclo:'),
              const SizedBox(width: 12),
              DropdownButton<int>(
                value: _length,
                items: List.generate(15, (i) => 21 + i)
                    .map((d) =>
                        DropdownMenuItem(value: d, child: Text('$d días')))
                    .toList(),
                onChanged: (v) => setState(() => _length = v ?? 28),
              ),
            ],
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () async {
              final c = context.read<CycleController>();
              if (_selectedDate != null) await c.setLastPeriod(_selectedDate!);
              await c.setCycleLength(_length);
              if (context.mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Guardar'),
          )
        ],
      ),
    );
  }
}
