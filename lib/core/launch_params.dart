import 'package:yellow_flowers/features/flowers/models/personalization.dart';

/// Parámetros de entrada por URL para abrir directamente el regalo.
///
/// Ejemplo (web): `https://.../?para=Ana&de=Jorge&mood=passion&tema=rose&mensaje=Te%20quiero`
class LaunchParams {
  const LaunchParams({
    required this.recipient,
    required this.sender,
    this.message,
    this.mood = Mood.joy,
    this.theme = FlowerTheme.sunflower,
  });

  final String recipient;
  final String sender;
  final String? message;
  final Mood mood;
  final FlowerTheme theme;

  /// Devuelve `null` si la URL no trae al menos el destinatario (`para`).
  static LaunchParams? fromUri(Uri uri) {
    final q = uri.queryParameters;
    final recipient = (q['para'] ?? q['to'] ?? q['name'])?.trim();
    if (recipient == null || recipient.isEmpty) return null;

    final message = (q['mensaje'] ?? q['message'])?.trim();
    return LaunchParams(
      recipient: _clip(recipient, 40),
      sender: _clip((q['de'] ?? q['from'] ?? 'Alguien especial').trim(), 40),
      message: message == null || message.isEmpty ? null : _clip(message, 280),
      mood: Mood.values.asNameMap()[q['mood']] ?? Mood.joy,
      theme: FlowerTheme.values.asNameMap()[q['tema'] ?? q['theme']] ??
          FlowerTheme.sunflower,
    );
  }

  static String _clip(String s, int max) =>
      s.length > max ? s.substring(0, max) : s;
}
