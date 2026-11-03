enum UserGender { female, male, unspecified }

extension UserGenderUI on UserGender {
  String get label {
    switch (this) {
      case UserGender.female:
        return 'Mujer';
      case UserGender.male:
        return 'Hombre';
      case UserGender.unspecified:
        return 'Prefiero no decir';
    }
  }

  String get emoji {
    switch (this) {
      case UserGender.female:
        return '🌸';
      case UserGender.male:
        return '🌿';
      case UserGender.unspecified:
        return '✨';
    }
  }

  String get description {
    switch (this) {
      case UserGender.female:
        return 'Contenido pensado para ti, incluyendo bienestar y ciclo';
      case UserGender.male:
        return 'Contenido adaptado a tu bienestar emocional';
      case UserGender.unspecified:
        return 'Experiencia completa sin personalización de género';
    }
  }
}
