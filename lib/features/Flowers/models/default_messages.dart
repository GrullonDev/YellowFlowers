import 'dart:math' as math;

class DefaultMessages {
  static const List<String> poeticMessages = [
    'Eres mi sol en un día nublado. Gracias por brillar siempre.',
    'Que este pequeño detalle florezca en tu corazón tanto como tú en el mío.',
    'Cultivé esta flor pensando en lo especial que eres para mí.',
    'Eres magia pura, nunca dejes de ser tú misma.',
    'A veces el mundo necesita más personas como tú: llenas de luz.',
    'Esta flor representa todo lo positivo que traes a mi vida.',
    'Que tu día sea tan hermoso como la sonrisa que hoy me regalaste.',
    'Florece con fuerza, con ganas, con todo el amor que mereces.',
    'Eres el jardín donde siempre quiero quedarme.',
    'Un detalle para recordarte que eres increíble y capaz de todo.',
    'Que la alegría de esta flor te acompañe en cada paso que des hoy.',
    'Eres la primavera que mi invierno necesitaba.',
    'Nunca olvides que tienes un brillo propio que ilumina a los demás.',
    'Gracias por ser esa persona que hace que todo valga la pena.',
    'Eres un regalo para este mundo, recuérdalo siempre.',
    'Cada pétalo de esta flor lleva un pensamiento positivo para ti.',
    'Eres la prueba de que las cosas más bellas crecen con amor.',
    'Que hoy florezcan nuevas oportunidades y mucha paz en tu vida.',
    'Eres luz, eres paz, eres el motivo por el cual sonrío hoy.',
    'Simplemente quería recordarte lo mucho que te aprecio.',
  ];

  static String getRandom() {
    final rnd = math.Random();
    return poeticMessages[rnd.nextInt(poeticMessages.length)];
  }
}
