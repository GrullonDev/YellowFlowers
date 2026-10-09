import 'dart:math' as math;

import 'package:yellow_flowers/features/flowers/models/personalization.dart';

/// Mensaje motivacional "del día", estable para una misma persona y fecha.
class DailyInspiration {
  const DailyInspiration({
    required this.greeting,
    required this.quote,
    this.author,
  });

  final String greeting;
  final String quote;
  final String? author;

  static const List<(String, String?)> _quotes = [
    ('Florece donde te planten, y hazlo con todo tu brillo.', null),
    (
      'La felicidad no es algo hecho. Proviene de tus propias acciones.',
      'Dalái Lama'
    ),
    ('Donde florece el amor, florece la vida.', null),
    ('Cada día es una nueva oportunidad para florecer.', null),
    (
      'Mantén tu rostro hacia el sol y las sombras caerán detrás de ti.',
      'Walt Whitman'
    ),
    (
      'Eres más valiente de lo que crees y más fuerte de lo que pareces.',
      'A. A. Milne'
    ),
    ('Las flores no compiten con las demás; simplemente florecen.', 'Zen Shin'),
    ('Lo que hoy siembras con cariño, mañana será tu jardín.', null),
    ('La vida es la flor de la cual el amor es la miel.', 'Victor Hugo'),
    ('Sonríe: tu luz hace que otros también se atrevan a brillar.', null),
    ('No cuentes los días, haz que los días cuenten.', 'Muhammad Ali'),
    ('Incluso la noche más oscura terminará y el sol saldrá.', 'Victor Hugo'),
    ('Tu esencia es tu mejor regalo para el mundo.', null),
    ('Que nada te quite las ganas de sonreír hoy.', null),
    ('La primavera llega para quien sabe esperar con esperanza.', null),
    ('Dondequiera que vayas, ve con todo tu corazón.', 'Confucio'),
    ('Eres suficiente, tal como eres, justo ahora.', null),
    ('Lo bonito de la vida está en los pequeños detalles.', null),
    ('El mundo es mejor contigo en él.', null),
    ('Hoy es un buen día para tener un buen día.', null),
    ('Si puedes soñarlo, puedes lograrlo.', 'Walt Disney'),
  ];

  static const Map<Mood, List<String>> _moodWishes = {
    Mood.joy: [
      'que tu alegría sea contagiosa',
      'que hoy rías hasta que te duela la panza',
      'que el sol te acompañe en cada paso',
    ],
    Mood.calm: [
      'que encuentres paz en cada respiro',
      'que hoy todo fluya con calma',
      'que tu corazón descanse tranquilo',
    ],
    Mood.passion: [
      'que hoy te sientas profundamente querida',
      'que el cariño te rodee todo el día',
      'que cada latido te recuerde lo valiosa que eres',
    ],
  };

  /// Genera la inspiración del día para [name]. Misma persona + misma fecha
  /// = mismo mensaje, así se siente como una "frase del día" real.
  static DailyInspiration forToday(String name,
      {Mood mood = Mood.joy, DateTime? now}) {
    final date = now ?? DateTime.now();
    final dayKey = date.year * 1000 + _dayOfYear(date);
    final seed = dayKey ^ name.trim().toLowerCase().hashCode;
    final rnd = math.Random(seed);

    final (quote, author) = _quotes[rnd.nextInt(_quotes.length)];
    final wishes = _moodWishes[mood]!;
    final wish = wishes[rnd.nextInt(wishes.length)];
    final cleanName = name.trim().isEmpty ? 'hermosa' : name.trim();

    return DailyInspiration(
      greeting: '${_timeGreeting(date.hour)}, $cleanName: $wish.',
      quote: quote,
      author: author,
    );
  }

  static String _timeGreeting(int hour) {
    if (hour >= 5 && hour < 12) return 'Buenos días';
    if (hour >= 12 && hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  static int _dayOfYear(DateTime d) =>
      d.difference(DateTime(d.year)).inDays + 1;
}

/// "Razones para sonreír" para la caja de recuerdos.
class SmileReasons {
  static const List<(String, String)> _all = [
    ('🌻', 'Porque tu risa es mi sonido favorito.'),
    ('☀️', 'Porque haces que los días grises tengan color.'),
    ('💛', 'Porque alguien está pensando en ti ahora mismo.'),
    ('✨', 'Porque has superado el 100% de tus días difíciles.'),
    ('🦋', 'Porque cada día creces un poquito más bonito.'),
    ('🌈', 'Porque después de la lluvia siempre vienes tú.'),
    ('🎶', 'Porque hay una canción que me recuerda a ti.'),
    ('🍫', 'Porque mereces algo dulce hoy (y siempre).'),
    ('🌙', 'Porque incluso de noche sigues brillando.'),
    ('🤍', 'Porque eres hogar para quienes te quieren.'),
    ('🌷', 'Porque tu bondad deja huella donde pasas.'),
    ('⭐', 'Porque lo mejor de tu historia aún está por escribirse.'),
    ('🫶', 'Porque contigo todo se siente más fácil.'),
    ('🌼', 'Porque eres la flor amarilla de mi jardín.'),
  ];

  /// Selección estable de [count] razones para [name] y la fecha de hoy.
  static List<(String, String)> pick(String name, {int count = 6}) {
    final now = DateTime.now();
    final seed = (now.year * 10000 + now.month * 100 + now.day) ^
        name.trim().toLowerCase().hashCode;
    final list = [..._all]..shuffle(math.Random(seed));
    return list.take(count).toList();
  }
}
