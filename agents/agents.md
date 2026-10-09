# agents.md — Engineering Guide for Amarillas (YellowFlowers)

> Context definition for AI agents and developers collaborating on this repository.
> Read this before writing code. When this file and your assumptions conflict, this file wins —
> but if you find it factually wrong, fix it in the same PR that discovers the problem.

---

## 1. Project Role and Purpose

**Amarillas** (`package: yellow_flowers`) is a **Flutter mobile application for Android and iOS** centered on
*emotional well-being, daily motivation, and connection between people*.

The product thesis:

- **A daily ritual, not a utility.** The app is opened once a day. Every surface is engineered to feel like a small,
  warm, private moment — never a dashboard to be processed.
- **Flowers as the emotional metaphor.** A yellow flower is the object the app gives, grows and keeps. Growth is
  visible and cumulative: progress is felt, never reported as a number.
- **An interactive virtual garden as the core loop.** Every visit plants or advances a flower. Returning daily is
  what makes the garden bloom. Streaks and bloom days are the only quantitative layer, and they are always
  presented as a garden, never as a streak counter.
- **Gifting, not self-tracking.** A flower can be composed for someone else, with a name, a dedication and a mood,
  then shared. That is the emotional payload the whole app exists to deliver.

**Design personality:** premium, calm, warm, feminine-leaning, bilingual-safe. Gold, cream, lavender, pastel pink and
leaf green. Generous whitespace, serif display type, soft shadows. No urgency badges, no red alerts, no engagement
pressure. If a change makes the app feel like a productivity tool, it is probably wrong.

**Language convention:** user-facing strings, comments and documentation are **Spanish**; identifiers, code,
commit messages and this file are **English**. Preserve this split — do not translate existing Spanish strings or
rewrite Spanish comments into English.

**Non-goals:** no accounts/login, no ads. Do not introduce any of these without an explicit product decision.
Analytics, crash reporting and push notifications are now present (see §2.4) — they are anonymous and
non-intrusive by design.

---

## 2. Architecture and Technologies

### 2.1 Toolchain

| Concern | Value |
|---|---|
| Flutter | **3.47.1**, pinned via FVM (`.fvmrc`) — always use `fvm flutter ...`, never bare `flutter` |
| Dart SDK | `^3.5.1` |
| State / DI | `provider` 6.x (`ChangeNotifier`) + `get_it` 8.x service locator (`lib/di/injector.dart`) |
| Backend | Firebase — `firebase_core`, `cloud_firestore` (read-only, collection `songs`), `firebase_messaging` (FCM push), `firebase_crashlytics`, `firebase_analytics` |
| Audio | `just_audio` + `just_audio_background`, remote URLs only |
| Design | `google_fonts`, `flutter_lints` 4.x (`analysis_options.yaml`) |
| Android | AGP 8.13.2, Gradle 9.3.1, Kotlin 2.4.0, `compileSdk`/`targetSdk` 37, `minSdk` 29, Java 21, NDK 28.2.13676358 |
| iOS | Xcode project `ios/Runner`, bundle id `com.grullondev.amarillas`, URL scheme `amarillas` |

Build commands: `fvm flutter run -d <device>`, `fvm flutter build apk --debug`, `fvm flutter build appbundle --release`.
Android release CI (`.github/workflows/android-release.yml`) fires on `v*.*.*` tags and publishes to Firebase App
Distribution. Bump `version:` in `pubspec.yaml` before tagging.

#### Release signing (Android)

`android/app/build.gradle` resolves signing credentials through a three-level cascade. Later sources
overwrite earlier ones, so the effective priority is:

| Priority | Source | Typical use |
|---|---|---|
| 1 (highest) | Environment variables: `STORE_PASSWORD`, `KEY_PASSWORD`, `KEY_ALIAS`, `STORE_FILE`, `STORE_FILE_BASE64`, `KEY_DN` | CI, as masked repository secrets |
| 2 | `.env` at the repository root | Local development machines |
| 3 (lowest) | `android/key.properties` | Legacy setups, still supported |

The legacy camelCase names (`storePassword`, `keyPassword`, `keyAlias`, `storeFile`) are mapped onto
their uppercase equivalents, so an existing `key.properties` keeps working untouched.

The keystore file is resolved separately, through three optional paths:

- **`STORE_FILE_BASE64`** — decoded into `upload-keystore.jks` on the first build. Preferred for CI,
  because it passes the key as a masked secret instead of committing a binary.
- **`STORE_FILE`** — an absolute path, or one relative to `android/app/`.
- **Neither, but the passwords are set** — the build shells out to `keytool` and generates
  `upload-keystore.jks` (RSA 2048, 10000 days, alias `upload`, DN from `KEY_DN`). `keytool` resolves
  through `JAVA_HOME/bin` first and `PATH` second, appending `.exe` on Windows, so an identical build
  works on macOS and Windows without local configuration.

Generation happens at build time and is cross-platform by design: a contributor who has only the
passwords can produce a signed release build without hand-crafting a keystore.

When signing is incomplete, the `release` build type falls back to `signingConfigs.debug` so local
work is never blocked; an existing `.env` with missing values logs a warning instead of failing.

**Risk — read before relying on generation.** Auto-generation is a convenience, not a safeguard
against key loss. Any machine that holds the passwords but no keystore file will mint a *different*
upload key, and uploading with it breaks the app's signing continuity with Play. Keep a durable
backup of the original `upload-keystore.jks` outside the repository, and prefer `STORE_FILE_BASE64` in
CI over the generator.

**Never commit `.env`, `*.jks`, `*.keystore` or `key.properties`.** `.gitignore` enforces this today
(`.env*` with a single `!.env.example` negation, plus `**/*.jks` and `**/*.keystore`). The template
for new developers is `.env.example`: copy it to `.env`, fill in the values, and keep the real file
local.

### 2.2 Layering

```
lib/
├── main.dart              # bootstrap: Firebase, Crashlytics, JustAudioBackground, DI, FCM, home-widget init
├── app.dart               # MaterialApp, global controllers, navigatorKey, FirebaseAnalyticsObserver, cold-start routing
├── core/                  # design_system.dart, transitions.dart, result.dart, usecase.dart,
│                          # tts/, personalization_service.dart, home_widget_service.dart, launch_params.dart,
│                          # analytics_service.dart, firebase_messaging_service.dart, firestore_sync_service.dart
├── di/injector.dart       # GetIt registrations (the only place services are wired)
├── data/                  # thin Firebase services (music_service/)
├── features/<feature>/    # pages/ · widgets/ · bloc|controller/ · models/ · data/ · domain/
├── theme/                 # app_theme.dart (buildLightTheme/buildDarkTheme), theme_controller.dart
├── utils/                 # base_model.dart, constants.dart
└── widgets/               # cross-feature shared widgets (premium_widgets.dart, glass_card.dart, …)
```

**Rules**

- **Features are self-contained.** A feature may only import from `lib/core`, `lib/theme`, `lib/widgets`,
  `lib/utils` and its own folder. Cross-feature imports (e.g. `flowers → garden/widgets/growing_flower.dart`) are
  currently tolerated for shared *presentational* widgets only; never import one feature's page, bloc or data
  source from another feature.
- **`lib/core` and `lib/widgets` never import from `lib/features/`.** The dependency arrow points one way.
- **`lib/features/music/` is the reference implementation** for Clean Architecture
  (`data/datasource` → `data/repository` → `domain/repositories` → `domain/usecases` → `bloc` → `pages`).
  New features with real data sources should follow it. Do not retrofit it onto screen-local features.
- **Presentation state** lives in `ChangeNotifier` classes named `*Controller` (global, registered in
  `lib/app.dart`) or `*Bloc extends BaseModel` (per-route, provided by `BaseModelScaffold`). Both are consumed
  via `provider`'s `Consumer` / `context.watch`.
- **`*Bloc` here means `ChangeNotifier`, not `flutter_bloc`.** There is no event/state machine, and
  `flutter_bloc` is **not** a dependency. Do not introduce it for a single new feature; if you need real BLoC,
  raise it as an architecture decision first.
- **Services and infrastructure go in `lib/di/injector.dart`** and nowhere else. Register `AudioPlayer`,
  `SharedPreferences`, `FirebaseMusicService`, `PersonalizationService`, `GardenService`, `HomeWidgetService`,
  `AnalyticsService`, `FirebaseMessagingService`, `FirestoreSyncService` here.
  Use `registerLazySingleton` for anything with a lifecycle; guard re-registration with `sl.isRegistered<T>()`
  so hot reload does not throw.
- **Errors:** use the `sealed Result<T>` in `lib/core/result.dart` for data sources and repositories. Do not throw
  raw exceptions across layer boundaries, and never swallow one without a `debugPrint` explaining why.

### 2.3 Design system and responsive UI

- **Never hard-code a color, radius, spacing step, text style or shadow.** Everything comes from
  `PremiumDesign` in `lib/core/design_system.dart` (palette, `s8…s64` spacing, `serifDisplay`/`serifHeading`/
  `sansBody`/`sansLabel` typography, `deepShadow`/`goldGlow`, motion durations `slow`/`medium`/`fast`).
- **Theme** comes from `lib/theme/app_theme.dart` via `Theme.of(context)` and `context.theme.extension` /
  `ThemeData` color roles. `ThemeController` cycles light → dark → system and persists it.
- **Dark mode is mandatory.** Every new surface must derive its colors from the theme and be legible in both modes.
  `PremiumDesign.isDarkMode(context)` is the escape hatch when a canvas gradient has to be chosen. Hard-coding
  `PremiumDesign.cream` or `Colors.white` in a screen is a bug.
- **Responsive layout:** sizes art and spacing from `MediaQuery.of(context).size` and `LayoutBuilder`; never
  assume a fixed device size or a fixed aspect ratio. Rules:
  - Full-bleed or free-width content → `LayoutBuilder` + `max(constraint.maxWidth, computed)`.
  - Keyboard-driven screens → wrap in `Scaffold(resizeToAvoidBottomInset: true)` and inset with
    `MediaQuery.viewInsets.bottom`.
  - Bottom sheets → cap height (`size.height * 0.85`) or use `DraggableScrollableSheet`; never let content
    overflow on small devices.
  - Text must scale: no fixed `height` on text containers, no `TextOverflow.clip` on user-visible copy.
- **Accessibility is not optional:** every icon-only control needs a `Semantics` label or a tooltip; tap targets
  ≥ 44×44; respect `MediaQuery.disableAnimations` / `accessibleNavigation` for decorative motion.

### 2.4 Firebase services

The project uses Firebase project `yellowflowers-58d52`. Configuration lives in `lib/firebase_options.dart`
(generated by FlutterFire CLI) and `android/app/google-services.json`. iOS requires `GoogleService-Info.plist`
in `ios/Runner/`.

#### Crashlytics (`firebase_crashlytics`)

Active globally. `main.dart` wraps the entire bootstrap in `runZonedGuarded` — uncaught Dart errors are
forwarded to `FirebaseCrashlytics.instance.recordError(error, stack, fatal: true)`. Flutter framework errors
are captured via `FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError`. The Gradle
plugin `com.google.firebase.crashlytics` (version 3.0.3) is applied in `android/app/build.gradle` and
declared in `android/settings.gradle`.

#### Analytics (`firebase_analytics`)

`AnalyticsService` (`lib/core/analytics_service.dart`) wraps `FirebaseAnalytics.instance` with typed helpers:
`logGardenVisit`, `logMoodCheckin`, `logFlowerPlanted`, `logStreakDay`, `logMusicPlay`,
`logSpecialMessageViewed`, `logCyclePageOpened`, `logShare`, `logGiftOpened`, `logOnboardingComplete`.
Automatic screen tracking is enabled via `FirebaseAnalyticsObserver` added to `MaterialApp.navigatorObservers`
in `lib/app.dart`. All events are anonymous — no user identifiers are attached.

#### Cloud Messaging / FCM (`firebase_messaging`)

`FirebaseMessagingService` (`lib/core/firebase_messaging_service.dart`) handles:
- Permission request on `init()` (respects denial gracefully).
- FCM token retrieval and refresh logging.
- Foreground message display via `flutter_local_notifications` on a dedicated Android channel
  (`amarillas_push` / "Notificaciones de Amarillas").
- Background message handling via `_firebaseMessagingBackgroundHandler` (top-level, annotated
  `@pragma('vm:entry-point')`).
- Topic subscribe/unsubscribe for segmented push campaigns.

`NotificationService` (`lib/core/notification_service.dart`) schedules two daily local reminders:
- **Morning (9:00 AM)** — motivational quote prompting a garden visit (id `42`).
- **Evening (8:00 PM)** — gentle mood check-in prompt (id `43`).

Both use `matchDateTimeComponents: DateTimeComponents.time` for daily repetition and
`AndroidScheduleMode.inexactAllowWhileIdle` to respect Doze. Messages are in Spanish.

**Platform configuration:**
- Android: `POST_NOTIFICATIONS` permission declared in `AndroidManifest.xml`. The Crashlytics Gradle plugin is
  in `android/settings.gradle` (version 3.0.3) and applied in `android/app/build.gradle`.
- iOS: `remote-notification` added to `UIBackgroundModes` in `ios/Runner/Info.plist` alongside the existing
  `audio` mode. APNs must be configured in the Apple Developer portal and linked in the Firebase Console for
  iOS push to work.

#### Firestore sync (`firestore_sync_service.dart`) — prepared, not active

`FirestoreSyncService` (`lib/core/firestore_sync_service.dart`) provides modular methods for cloud backup:
`backupStreak`, `restoreStreak`, `backupMoodHistory`. Data is stored under
`users/{userId}/garden_data/{docId}`. The service is registered in `injector.dart` as a lazy singleton but is
**not called anywhere yet** — it requires an authentication layer (`userId`) before activation. When auth is
added, wire calls from `GardenService` and the mood check-in flow.

---

## 3. Navigation Structure

**Home is the Daily Garden.** It is the app's main screen, its default cold-start destination, and the single
gate through which every other view is reached. It carries the day: the greeting, the daily mood and wellness
check-ins, and the entry to the growing garden. Nothing in the app is reachable except through it.

> **Implementation note (keep in sync):** today `HomePage`
> (`lib/features/home/pages/home_page.dart` + `home_layout.dart`) renders that daily-garden surface — hero,
> mood/wellness chips, "Tu jardín" section — and hosts the growing garden as `GardenPage`
> (`lib/features/garden/`), reachable from the "Mi Jardín" tile and from the `amarillas://garden` home-widget
> deep link. When you add a view, add it as a tile in `HomeBloc.menuItems`
> (`lib/features/home/bloc/home_bloc.dart`) and keep `GardenPage` as the garden sub-surface.

**Navigation mechanics**

- **Navigator 1.0, imperative.** No `go_router`, no named routes, no `routes:` map.
  Use `Navigator.push(context, MaterialPageRoute(builder: …))`, or the project's custom transitions from
  `lib/core/transitions.dart` — `PremiumTransitions.fadeThrough(…)` for primary transitions and
  `PremiumTransitions.slideUp(…)` for forward motion.
- **Root navigation key:** `navigatorKey` in `lib/app.dart` exists for home-widget deep links. Use it *only*
  when there is no `BuildContext` (e.g. a `HomeWidget.widgetClicked` listener). Everywhere else, use the
  context.
- **Cold start** is resolved once in `MyApp._initialPage()` (`lib/app.dart`), in this priority order:
  1. shared link with query params → `LaunchParams.fromUri(Uri.base)` → `FlowerResultPage` (personalized gift)
  2. launched from the home widget → `GardenPage`
  3. otherwise → `HomePage`
  Extend `LaunchParams` rather than adding a fourth ad-hoc branch.
- **Return paths must always be resolvable.** Screens reachable by deep link have no back stack: guard with
  `Navigator.of(context).canPop()` and fall back to `pushReplacement(HomePage)`
  (see `_goBack()` in `flower_result_page.dart`, `garden_page.dart`).
- **Modal surfaces** (bottom sheets, dialogs) are exposed as `showX(context, …)` top-level functions in the
  owning widget file (`showMemoryBox`, `showAmbientSounds`, `MetadataSheet`) so call sites stay declarative.

---

## 4. Coding Rules and Best Practices

### 4.1 Component structure

- One public widget per file; file name = widget name in `snake_case`. Private helpers prefixed with `_` and kept
  in the same file unless reused.
- Split a screen when it exceeds ~400 lines: `pages/foo_page.dart` (state + composition) plus
  `widgets/` and, for heavy visuals, `widgets/screen_parts/`. `home_layout.dart` (37 KB) and
  `cycle_music_page.dart` (23 KB) are the cautionary examples of what not to grow further.
- Widgets take plain values in and callbacks out. No service-locator lookups (`sl<T>()`) inside `build()` —
  resolve in the bloc/controller, or inject via constructor. A widget must be usable in isolation.
- `const` constructors wherever possible; `prefer_single_quotes`, `prefer_const_constructors` and
  `prefer_final_fields` are enforced by lint — run `fvm flutter analyze` before pushing and keep it at
  **zero errors and zero infos**. The `share_plus` deprecations that used to be the only remaining
  infos are fixed: all call sites go through `SharePlus.instance.share(ShareParams(...))`, and
  `album_detail_page.dart`'s `// ignore: deprecated_member_use` is gone. Prefer fixing a deprecation
  over silencing it.
- BLoC/controllers must be `dispose()`d in the widget's `dispose()` (note: `BaseModelScaffold` owns the lifecycle
  of the model it creates).
- **No navigation from a bloc.** A bloc may expose an event or a callback; the widget calls `Navigator`. The one
  existing violation is `moments_gallery_bloc.onTapAlbum(BuildContext)` — do not copy it.

### 4.2 Multimedia resources

- **Assets are scarce and precious.** `assets/` holds only `logo.png`, `logo_foreground.png` and
  `lottie/flower_bloom.json`. Reuse the Lottie bloom for any loading/growth flourish rather than adding a new
  animation file; if you must add an asset, keep it under 500 KB and declare it explicitly in
  `pubspec.yaml → flutter.assets`.
- **Audio is remote-only.** Songs live in Firestore (`songs` collection, database `amarillas`) with fields
  `title, artist, audio_url, cover_url, duration, genre, mood, is_active`. There is no bundled audio and no
  file cache (only a `cached_music_*` SharedPreferences cache).
- **`just_audio_background` allows exactly one `AudioPlayer`.** Always resolve the singleton
  (`sl<AudioPlayer>()`); never `AudioPlayer()` inside a widget, and never `dispose()` it from a screen. Sources
  must be tagged: build them with the `song.audioSource` extension (`song_audio_source.dart`) so the
  notification shows title and artwork.
- **Remote audio requires internet + notification permission** (`POST_NOTIFICATIONS`). Gracefully degrade: a
  failed `playSong` must leave the UI idle and playable again, never in a permanent spinner.
- **TTS:** use the single service `lib/core/tts/tts_service.dart`. Do not add a second `FlutterTts` instance.
  Spanish (`es-ES` → `es-419` → `es-MX`), slow rate (0.45).
- **Sharing images** (`share_plus`) goes through `path_provider` into a temp file; do not pass raw bytes.
- **Permissions** (`permission_handler`) must be requested at the moment of need with an explanatory UI, never at
  startup.
- New dependencies require a stated reason in the PR description. The project currently carries unused packages
  (`file_picker`, `intl`, `package_info_plus`, `http`); do not add more without removing those. `url_launcher`
  left this list: `garden_shell.dart` uses it for the beta signup tile.

### 4.3 Animation optimization

Motion is the product's main channel of delight — and its main performance risk.

- **Budget:** 60 fps on a mid-range Android. Any animation that drops frames on a low-end device is a bug.
- **Never `setState` in an animation callback.** Wrap in `AnimatedBuilder` / `ListenableBuilder`, or use
  `CustomPainter`. This is the single most important rule in this section.
- **Merge controllers** with `Listenable.merge([…])` when several animations drive one subtree (see
  `garden_page.dart`). Every `AnimationController` needs a `vsync` (use `TickerProviderStateMixin` /
  `SingleTickerProviderStateMixin` correctly — `SingleTickerProvider` if you truly have one) and must be
  `dispose()`d.
- **Prefer implicit animations** (`AnimatedContainer`, `AnimatedOpacity`, `AnimatedSwitcher`) for small state
  changes; reserve `AnimationController` for orchestrated sequences.
- **Cap continuous animations.** Ambient loops (`..repeat()` / `..repeat(reverse: true)`) must:
  run at ≤ 2 per screen, be short and subtle, and be disabled when the screen is not visible — check
  `TickerMode.of(context)` or stop them in `didChangeAppLifecycleState`. Honor
  `MediaQuery.disableAnimationsOf(context)` by jumping to the end state.
- **Keep `CustomPainter` cheap:** precompute seeds/geometry outside `paint`, avoid allocations inside `paint`,
  implement `shouldRepaint` honestly (return `false` when nothing changed), and wrap large painted areas in
  `RepaintBoundary`.
- **Particle systems** (`particle_layer.dart`) must keep a bounded particle count, drop off-screen particles, and
  be driven by an external controller (`ParticleBurstController`) so bursts are triggered by events, not by
  rebuilding.
- **Sequenced entrances** (the flower result screen: grow → reveal → burst) belong in one orchestrated controller
  chain, not in chained `Future.delayed` calls scattered across widgets.
- **Never block first paint** on data or network: stagger the entrance, keep the splash/API handoff fast, and
  fire non-critical work (e.g. home-widget refresh) without `await`.

### 4.4 Haptics

- Haptics are part of the emotional signature: a touch must feel like a petal landing.
- **Use only `HapticFeedback`** (no `SystemSound`, no platform channels). Vocabulary, applied consistently:
  | Intent | Call |
  |---|---|
  | Selecting / changing a chip, pill, track | `HapticFeedback.selectionClick()` |
  | Light confirmation (tap on a flower, subtle action) | `HapticFeedback.lightImpact()` |
  | Meaningful moment (planting, opening the envelope, "continue") | `HapticFeedback.mediumImpact()` |
  | Celebration / completion | `HapticFeedback.heavyImpact()` (sparingly) |
- Fire haptics **at the moment of the user's action**, not in a post-frame callback, and never on scroll or on
  every rebuild.
- Pair every haptic with a visual response. Haptic without visual feedback reads as a glitch.
- Honor the platform: on iOS these map to the system impact styles; do not add sound — the app is silent by
  design.

---

## 5. Git and Commit Conventions

### 5.1 Branches

```
main      # production / releases only (tagged v*.*.*, triggers Firebase App Distribution)
develop   # integration branch — the default target of every PR
feature/* # short-lived branches cut from develop
```

- **All work branches from `develop` and merges back into `develop`.** `main` is only updated by a release.
- Never commit directly to `main` or `develop`.
- Branch names: `feature/…`, `fix/…`, `refactor/…`, `chore/…` (e.g. `feature/garden-streaks`). Keep the
  existing `New-Improvements`-style long-lived branch only as an explicit exception agreed with the maintainer.
- Rebase or merge from an up-to-date `develop` before requesting review; resolve conflicts in the smallest
  possible commits.

### 5.2 Commits

Follow **Conventional Commits**, as in the existing history:

```
<type>(<optional scope>): <subject>

<body: what changed and why, wrapped at ~72 cols>
```

- **Allowed types:** `feat`, `fix`, `refactor`, `perf`, `style`, `docs`, `test`, `build`, `chore`, `revert`.
- **Subject:** imperative mood, English, no trailing period, ≤ 72 chars. `feat(garden): add bloom streak`
  not `added bloom streak`.
- **Body:** required for anything non-trivial — explain *why*, list the user-visible effect, and call out
  migrations, version bumps or native config changes. Reference the issue when one exists.
- **Scope = feature area** (`garden`, `music`, `flowers`, `home`, `widget`, `android`, `ios`) when it narrows the
  change usefully.
- **Atomic commits:** each commit builds and makes sense on its own. Do not mix a feature with an unrelated
  formatting sweep; do not split a single logical change across commits just to make the history prettier.
- **No secrets, ever:** `firebase_options.dart` is tracked; `android/key.properties`, keystores, tokens and
  service-account JSON must never be committed (`.gitignore` covers them — verify before `git add -A`).
- Tag releases as `v<major>.<minor>.<patch>` after bumping `version:` in `pubspec.yaml`.

### 5.3 Before you push

```bash
fvm flutter pub get
fvm flutter analyze                 # must be clean: no errors, no new infos
fvm flutter build apk --debug       # Android must compile
fvm flutter run                     # smoke-test the changed flow on a real device
```

Open the PR against **`develop`**, describe the user-visible change, attach a screen recording for any UI or
animation work, and flag every platform-specific difference (Android vs iOS).

---

## 6. Known Debt — do not build on these

- `test/` contains only the unmodified Flutter counter template; it cannot pass. Treat the suite as empty and add
  a real test with any feature.
- Unreferenced files: `features/experience/**`, `features/mood/mood_entry_page.dart`,
  `features/cycle/widgets/cycle_phase_bar.dart`, `features/flowers/pages/flower_screen.dart`,
  `features/music/pages/romantic_music_page.dart` (duplicate of `music_page.dart`, declares a second
  `MusicPage`), `lib/utils/app_theme.dart`, `lib/core/failures.dart` (duplicates `result.dart`).
- `.github/workflows/android-release.yml` pins Flutter 3.35.2 while `.fvmrc` pins 3.47.1; the CI has no analyze or
  test step.
- Flutter warns that AGP 8.x support will be dropped (requires AGP ≥ 9.0.1). Migrating means adopting the AGP 9
  DSL in `android/build.gradle` — plan it, don't do it inside a feature PR.
- `share_helper.dart` lives in `features/garden/widgets/` but is a function, not a widget, so it
  breaks the one-public-widget-per-file convention in §4.1. Moving it to `features/garden/` would
  also let the messages feature reuse it.
