# Guía de Migración a Arquitectura Limpia

Esta guía describe los pasos para migrar gradualmente las features existentes (Mensajes, Ciclo, Bienestar) a la nueva estructura de capas aplicada inicialmente a Música.

## Estructura Objetivo
```
lib/
  core/          -> Result, Failures, UseCase base, utilidades comunes
  di/            -> injector.dart (registro GetIt)
  features/
    music/
      data/      -> datasources, models, repositories (implementaciones)
      domain/    -> entities, repositories (abstract), usecases
      presentation/ -> bloc/controllers/widgets/pages (por mover)
    cycle/
    wellness/
    messages/
```

## Estrategia Incremental
1. Extraer Entities (POCOs sin dependencias externas).
2. Definir repositorio abstracto en dominio.
3. Implementar repositorio data que adapta fuente(s) actuales y convierte errores a `Result`.
4. Crear casos de uso atómicos (un verbo, una responsabilidad).
5. Inyectar dependencias en `injector.dart`.
6. Refactor controlador/bloc para consumir casos de uso (fase parcial: sólo flujos críticos primero).
7. Eliminar código legacy cuando el coverage de casos de uso sea >=80% de llamadas.

## Feature: Cycle
### Entities Sugeridos
- `CycleEntryEntity` (fechaInicio, cicloDias, faseActual, esFertil, energyBoostEnabled)
- `CyclePhaseEntity` (nombre, díaRelativo, duraciónEstim)

### Repositorio Abstracto
```dart
abstract class CycleRepository {
  Future<Result<CycleEntryEntity>> getCurrentCycle();
  Future<Result<void>> saveCycle(CycleEntryEntity entry);
  Future<Result<CyclePhaseEntity>> computePhase(DateTime today);
}
```

### Use Cases
- `GetCurrentCycleUseCase`
- `SaveCycleUseCase`
- `GetCyclePhaseUseCase`
- (Opcional) `ToggleEnergyBoostUseCase`

### Data Layer
- Adaptar `CycleController` actual: dividir lógica de cálculo en un datasource puro.
- Persistencia temporal: SharedPreferences -> envolver en datasource `CycleLocalDataSource`.

## Feature: Wellness
### Entities
- `EmotionEntryEntity` (date, moodScore|enum, note?)
- `DailyPhraseEntity` (text, date)

### Repository
```dart
abstract class WellnessRepository {
  Future<Result<List<EmotionEntryEntity>>> getLast7Days();
  Future<Result<void>> addEmotion(EmotionEntryEntity entry);
  Future<Result<DailyPhraseEntity>> getDailyPhrase();
}
```

### Use Cases
- `GetEmotionHistoryUseCase`
- `AddEmotionUseCase`
- `GetDailyPhraseUseCase`

### Data
- Extraer de `WellnessController` la lógica de almacenamiento (SharedPreferences) a un datasource local.

## Feature: Messages
### Entities
- `SpecialMessageEntity` (id, text, associatedTrackId?, createdAt)

### Repository
```dart
abstract class MessagesRepository {
  Future<Result<List<SpecialMessageEntity>>> getMessages();
  Future<Result<void>> addMessage(SpecialMessageEntity message);
  Future<Result<void>> deleteMessage(String id);
}
```

### Use Cases
- `GetMessagesUseCase`
- `AddMessageUseCase`
- `DeleteMessageUseCase`

### Data
- Si actualmente está en memoria o simple lista, crear `MessagesLocalDataSource` (más adelante backend si aplica).

## Buenas Prácticas
- Evitar que casos de uso retornen `null`; usar `Result<Entidad?>` sólo cuando la ausencia sea válida (ej: dailyRecommendation).
- Cada use case reside en archivo propio: `verb_object_usecase.dart`.
- Re-utilizar mapeos (model <-> entity) en funciones privadas dentro del repositorio data.
- Mantener controladores/blocs del lado presentation; renombrar carpeta a `presentation/` al final.

## Refactor Gradual Recomendado
Orden sugerido: Music (hecho) -> Cycle -> Wellness -> Messages.

Motivo:
1. Cycle comparte lógica de reglas (fase) que es ideal aislar temprano.
2. Wellness depende menos de otras features y es simple.
3. Messages último porque su impacto cruzado es menor.

## Métricas de Progreso
- % de métodos llamados desde UI que pasan por un UseCase.
- Reducción de dependencias directas a paquetes externos en presentation.
- Facilidad de test: número de casos de uso con pruebas unitarias (meta inicial 60%).

## Próximos Pasos Inmediatos
1. Crear `features/cycle/domain/...` con entidades y repositorio.
2. Extraer lógica de cálculo de fase del controller actual -> ciclo de data.
3. Añadir casos de uso y registrarlos en DI.
4. Refactor `CycleController` para delegar en use cases.

## Ejemplo de Test Rápido de UseCase
```dart
void main() {
  test('GetSongsByMoodUseCase retorna lista', () async {
    final repo = _FakeRepo();
    final usecase = GetSongsByMoodUseCase(repo);
    final result = await usecase(GetSongsByMoodParams(Mood.happy));
    expect(result.isSuccess, true);
  });
}
```

## Limpieza Final
Cuando todo esté migrado:
- Mover controladores/BLoCs a `presentation/`.
- Eliminar interfaces legacy duplicadas.
- Centralizar constantes en `core/constants/` si se repiten.

---
Cualquier duda o para priorizar la siguiente feature, continuar con Cycle.
