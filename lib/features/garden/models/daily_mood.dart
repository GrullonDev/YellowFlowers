import 'package:flutter/material.dart';

import 'package:yellow_flowers/core/user_gender.dart';
import 'package:yellow_flowers/features/flowers/models/personalization.dart';

/// Estado de ánimo que la usuaria registra cada día.
///
/// Se guarda por su `index` en SharedPreferences (`mood_checkin_yyyy-MM-dd`),
/// así que los valores nuevos siempre se agregan al final: cambiar el orden
/// cambiaría los ánimos ya guardados.
enum DailyMood {
  happy,
  calm,
  strong,
  reflective,
  loving,
  sad,
  angry,
  anxious,
  tired,
  lonely,
  overwhelmed,
  sensitive,
  grateful,
  empowered,
  hopeful,
  confident,
}

/// Pequeños gestos que la app ofrece cuando el día pesa.
enum ComfortAction { breathe, mandala, music }

class MoodInfo {
  const MoodInfo({
    required this.emoji,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.responseEmoji,
    required this.messages,
    this.comfort = const [],
  });

  final String emoji;
  final String label;
  final String subtitle;
  final Color color;
  final String responseEmoji;

  /// Respuestas posibles; `{name}` se reemplaza por el nombre de la usuaria.
  final List<String> messages;

  /// Gestos sugeridos, en orden de prioridad. Vacío para los días buenos.
  final List<ComfortAction> comfort;

  bool get needsComfort => comfort.isNotEmpty;
}

extension DailyMoodX on DailyMood {
  MoodInfo get info => _info[this]!;

  /// Ánimos de días ligeros; el resto se agrupa como "hoy me cuesta".
  bool get isBright => const {
        DailyMood.happy,
        DailyMood.calm,
        DailyMood.strong,
        DailyMood.reflective,
        DailyMood.loving,
        DailyMood.grateful,
        DailyMood.empowered,
        DailyMood.hopeful,
        DailyMood.confident,
      }.contains(this);

  /// Respuesta del día: cambia según la fecha para no repetir siempre la misma.
  String messageFor(String name, {DateTime? now}) {
    final d = now ?? DateTime.now();
    final list = info.messages;
    final text = list[(d.year * 400 + d.month * 31 + d.day) % list.length];
    return text.replaceAll('{name}', name);
  }

  /// Ánimo de [DailyInspiration] que mejor acompaña a este estado.
  Mood get inspirationMood => switch (this) {
        DailyMood.happy ||
        DailyMood.strong ||
        DailyMood.empowered ||
        DailyMood.confident =>
          Mood.joy,
        DailyMood.loving ||
        DailyMood.lonely ||
        DailyMood.sensitive =>
          Mood.passion,
        _ => Mood.calm,
      };

  /// Lee el ánimo guardado como índice, ignorando valores desconocidos.
  static DailyMood? fromIndex(int? index) =>
      index != null && index >= 0 && index < DailyMood.values.length
          ? DailyMood.values[index]
          : null;
}

const _info = <DailyMood, MoodInfo>{
  DailyMood.happy: MoodInfo(
    emoji: '😊',
    label: 'Feliz',
    subtitle: 'Me siento alegre y con energía',
    color: Color(0xFFFFB300),
    responseEmoji: '🌻',
    messages: [
      '¡Qué bonito, {name}! Tu alegría ilumina todo a tu alrededor. Hoy tu jardín florecerá con colores brillantes.',
      'Esa sonrisa tuya contagia, {name}. Guarda este momento: también es parte de tu jardín.',
      'Hoy brillas, {name}. Disfrútalo sin culpa, te lo mereces.',
    ],
  ),
  DailyMood.calm: MoodInfo(
    emoji: '🌿',
    label: 'Tranquila',
    subtitle: 'Estoy en paz y relajada',
    color: Color(0xFF43A047),
    responseEmoji: '🍃',
    messages: [
      'Qué paz, {name}. Hoy es un día perfecto para respirar profundo y disfrutar cada momento con calma.',
      'La calma también es fuerza, {name}. Tu jardín crece despacito y bonito, como tú.',
    ],
  ),
  DailyMood.strong: MoodInfo(
    emoji: '💪',
    label: 'Fuerte',
    subtitle: 'Me siento valiente y decidida',
    color: Color(0xFFF57C00),
    responseEmoji: '🔥',
    messages: [
      '¡Así se siente, {name}! Esa fuerza interior es lo que te hace imparable. Hoy nada te detiene.',
      'Mírate, {name}: todo lo que superaste te trajo hasta aquí. Hoy ve por lo que quieres.',
    ],
  ),
  DailyMood.reflective: MoodInfo(
    emoji: '🌙',
    label: 'Reflexiva',
    subtitle: 'Necesito un momento conmigo',
    color: Color(0xFF7E57C2),
    responseEmoji: '✨',
    messages: [
      'Está bien sentirse así, {name}. Los momentos de reflexión nos ayudan a crecer. Tu jardín te abraza.',
      'Escucharte también es cuidarte, {name}. Date el tiempo que necesites.',
    ],
  ),
  DailyMood.loving: MoodInfo(
    emoji: '💖',
    label: 'Enamorada',
    subtitle: 'El amor llena mi día',
    color: Color(0xFFE91E8C),
    responseEmoji: '🌹',
    messages: [
      'El amor te rodea, {name}. Hoy tu jardín floreció con un brillo especial, justo como tú.',
      'Qué lindo sentir así, {name}. Y recuerda: el primer amor que mereces es el tuyo.',
    ],
  ),
  DailyMood.sad: MoodInfo(
    emoji: '😢',
    label: 'Triste',
    subtitle: 'Hoy me pesa el corazón',
    color: Color(0xFF64B5F6),
    responseEmoji: '🫂',
    messages: [
      'Está bien no estar bien, {name}. No tienes que sonreír hoy: aquí puedes ser tú, tal como estás.',
      'Las flores también necesitan lluvia para crecer, {name}. Esto que sientes va a pasar, y no estás sola.',
      'Te mando un abrazo enorme, {name}. Sé suave contigo hoy, como lo serías con alguien que quieres.',
    ],
    comfort: [
      ComfortAction.breathe,
      ComfortAction.music,
      ComfortAction.mandala
    ],
  ),
  DailyMood.angry: MoodInfo(
    emoji: '😤',
    label: 'Enojada',
    subtitle: 'Algo me molestó o me frustró',
    color: Color(0xFFEF5350),
    responseEmoji: '🌋',
    messages: [
      'Tu enojo es válido, {name}. Algo te importó, y eso dice mucho de ti. Vamos a soltarlo poco a poco.',
      'Respira, {name}. No tienes que resolverlo todo ahora: primero vuelve a ti.',
    ],
    comfort: [
      ComfortAction.breathe,
      ComfortAction.mandala,
      ComfortAction.music
    ],
  ),
  DailyMood.anxious: MoodInfo(
    emoji: '😰',
    label: 'Ansiosa',
    subtitle: 'Mi mente no para de pensar',
    color: Color(0xFF4DB6AC),
    responseEmoji: '🌊',
    messages: [
      'Aquí estás a salvo, {name}. Vamos a bajar el ritmo juntas: un respiro a la vez.',
      'No tienes que tener todas las respuestas hoy, {name}. Solo este momento, y ya lo estás haciendo bien.',
    ],
    comfort: [
      ComfortAction.breathe,
      ComfortAction.mandala,
      ComfortAction.music
    ],
  ),
  DailyMood.tired: MoodInfo(
    emoji: '😴',
    label: 'Cansada',
    subtitle: 'Necesito descansar',
    color: Color(0xFF90A4AE),
    responseEmoji: '☁️',
    messages: [
      'Descansar no es rendirse, {name}. Hoy tu única tarea es tratarte con cariño.',
      'Has dado mucho, {name}. Tu jardín sigue creciendo aunque hoy vayas más despacio.',
    ],
    comfort: [
      ComfortAction.music,
      ComfortAction.breathe,
      ComfortAction.mandala
    ],
  ),
  DailyMood.lonely: MoodInfo(
    emoji: '🥺',
    label: 'Sola',
    subtitle: 'Extraño sentirme acompañada',
    color: Color(0xFF9575CD),
    responseEmoji: '💌',
    messages: [
      'Aquí estoy contigo, {name}. Eres importante, aunque hoy no lo sientas así.',
      'Sentirse sola duele, {name}. ¿Y si le escribes a alguien que quieres? Seguro le alegras el día.',
    ],
    comfort: [
      ComfortAction.music,
      ComfortAction.mandala,
      ComfortAction.breathe
    ],
  ),
  DailyMood.overwhelmed: MoodInfo(
    emoji: '😵‍💫',
    label: 'Abrumada',
    subtitle: 'Tengo demasiado encima',
    color: Color(0xFFFF8A65),
    responseEmoji: '🪷',
    messages: [
      'Una cosa a la vez, {name}. No tienes que poder con todo hoy, y está bien pedir ayuda.',
      'Suelta por un momento lo que no depende de ti, {name}. Lo demás puede esperar unos minutos.',
    ],
    comfort: [
      ComfortAction.breathe,
      ComfortAction.mandala,
      ComfortAction.music
    ],
  ),
  DailyMood.sensitive: MoodInfo(
    emoji: '🥹',
    label: 'Sensible',
    subtitle: 'Estoy a flor de piel',
    color: Color(0xFFF06292),
    responseEmoji: '🌸',
    messages: [
      'Sentir tanto es parte de tu magia, {name}. Hoy date permiso de ir más lento y consentirte.',
      'Tu sensibilidad es un don, {name}, no una debilidad. Abrázate fuerte hoy.',
    ],
    comfort: [
      ComfortAction.music,
      ComfortAction.breathe,
      ComfortAction.mandala
    ],
  ),
  DailyMood.grateful: MoodInfo(
    emoji: '🙏',
    label: 'Agradecida',
    subtitle: 'Valoro lo que tengo hoy',
    color: Color(0xFF26A69A),
    responseEmoji: '🌼',
    messages: [
      'La gratitud transforma, {name}. Reconocer lo bueno multiplica la luz en tu vida.',
      'Qué bonito detenerse a agradecer, {name}. Tu jardín celebra contigo.',
    ],
  ),
  DailyMood.empowered: MoodInfo(
    emoji: '👑',
    label: 'Empoderada',
    subtitle: 'Soy capaz de todo lo que me proponga',
    color: Color(0xFFAB47BC),
    responseEmoji: '👑',
    messages: [
      '¡Imparable, {name}! Esa energía que sientes hoy puede mover montañas.',
      'Mírate brillar, {name}. Esa seguridad es tuya y nadie te la quita.',
    ],
  ),
  DailyMood.hopeful: MoodInfo(
    emoji: '🌅',
    label: 'Esperanzada',
    subtitle: 'Confío en que viene algo bueno',
    color: Color(0xFFFF8A65),
    responseEmoji: '🌅',
    messages: [
      'La esperanza es tu superpoder, {name}. Cada amanecer trae nuevas posibilidades.',
      'Algo hermoso viene en camino, {name}. Tu jardín crece contigo.',
    ],
  ),
  DailyMood.confident: MoodInfo(
    emoji: '✨',
    label: 'Segura',
    subtitle: 'Confío en mí y en mi camino',
    color: Color(0xFFFFCA28),
    responseEmoji: '💫',
    messages: [
      'Brillas con luz propia, {name}. Esa seguridad es solo el reflejo de quien realmente eres.',
      'Confía en ti, {name}. Ya has superado tanto para llegar hasta aquí.',
    ],
  ),
};

List<DailyMood> moodsForGender(UserGender gender) {
  switch (gender) {
    case UserGender.female:
    case UserGender.unspecified:
      return DailyMood.values;
    case UserGender.male:
      return [
        DailyMood.happy,
        DailyMood.calm,
        DailyMood.strong,
        DailyMood.reflective,
        DailyMood.loving,
        DailyMood.sad,
        DailyMood.angry,
        DailyMood.anxious,
        DailyMood.tired,
        DailyMood.overwhelmed,
        DailyMood.grateful,
        DailyMood.hopeful,
        DailyMood.confident,
      ];
  }
}
