import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';

import 'package:yellow_flowers/core/launch_params.dart';
import 'package:yellow_flowers/features/cycle/cycle_controller.dart';
import 'package:yellow_flowers/features/flowers/pages/flower_result_page.dart';
import 'package:yellow_flowers/features/garden/pages/garden_page.dart';
import 'package:yellow_flowers/features/mood/mood_controller.dart';
import 'package:yellow_flowers/features/wellness/wellness_controller.dart';
import 'package:yellow_flowers/features/flowers/bloc/flower_bloc.dart';
import 'package:yellow_flowers/theme/app_theme.dart';
import 'package:yellow_flowers/theme/theme_controller.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.openGarden = false});

  /// La app se abrió tocando el widget de la pantalla de inicio.
  final bool openGarden;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Uri?>? _widgetClicks;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      // Toques en el widget con la app ya abierta -> "Mi Jardín"
      _widgetClicks = HomeWidget.widgetClicked.listen((uri) {
        if (uri?.host == 'garden') {
          navigatorKey.currentState?.push(
              MaterialPageRoute(builder: (_) => const GardenPage()));
        }
      });
    }
  }

  @override
  void dispose() {
    _widgetClicks?.cancel();
    super.dispose();
  }

  /// Si la URL trae `?para=...`, abre directamente el regalo personalizado.
  /// De lo contrario, el jardín diario es la pantalla principal.
  Widget _initialPage() {
    final params = LaunchParams.fromUri(Uri.base);
    if (params == null) {
      return const GardenPage();
    }
    return FlowerResultPage(
      sender: params.sender,
      recipient: params.recipient,
      dedication: params.message,
      theme: params.theme,
      mood: params.mood,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => MoodController()),
        ChangeNotifierProvider(create: (_) => WellnessController()),
        ChangeNotifierProvider(create: (_) => CycleController()),
        ChangeNotifierProvider(create: (_) => FlowerBloc()),
      ],
      child: Consumer<ThemeController>(
        builder: (context, themeCtrl, _) => MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          title: 'Flores Amarillas',
          theme: buildLightTheme(),
          darkTheme: buildDarkTheme(),
          themeMode: themeCtrl.mode,
          home: _initialPage(),
        ),
      ),
    );
  }
}
