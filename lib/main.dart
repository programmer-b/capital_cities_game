import 'dart:developer';

import 'package:capital_cities_game/firebase_options.dart';
import 'package:capital_cities_game/src/ads/ads_controller.dart';
import 'package:capital_cities_game/src/app_lifecycle/app_lifecycle.dart';
import 'package:capital_cities_game/src/audio/audio_controller.dart';
import 'package:capital_cities_game/src/crashlytics/crashlytics.dart';
import 'package:capital_cities_game/src/games_services/games_services.dart';
import 'package:capital_cities_game/src/in_app_purchase/in_app_purchase.dart';
import 'package:capital_cities_game/src/level_selection/level_selection_screen.dart';
import 'package:capital_cities_game/src/level_selection/levels.dart';
import 'package:capital_cities_game/src/play_session/play_session_screen.dart';
import 'package:capital_cities_game/src/player_progress/persistence/player_progress_persistence.dart';
import 'package:capital_cities_game/src/player_progress/player_progress.dart';
import 'package:capital_cities_game/src/settings/persistence/local_storage_settings_persistence.dart';
import 'package:capital_cities_game/src/settings/persistence/settings_persistence.dart';
import 'package:capital_cities_game/src/settings/settings.dart';
import 'package:capital_cities_game/src/settings/settings_screen.dart';
import 'package:capital_cities_game/src/style/my_transition.dart';
import 'package:capital_cities_game/src/style/palette.dart';
import 'package:capital_cities_game/src/win_game/win_game_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:provider/provider.dart';

import 'src/games_services/score.dart';
import 'src/main_menu/main_menu_screen.dart';
import 'src/player_progress/persistence/local_storage_player_progress_persistence.dart';
import 'src/style/snack_bar.dart';

Future<void> main() async {
  FirebaseCrashlytics? crashlytics;

  if (!kIsWeb) {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);

      crashlytics = FirebaseCrashlytics.instance;
    } catch (e) {
      log("Firebase couldn't be initialized $e");
    }
  }

  void guardedMain() {
    if (kReleaseMode) {
      Logger.root.level = Level.WARNING;
    }

    Logger.root.onRecord.listen((event) {
      log('${event.level.name}: ${event.time}: '
          '${event.loggerName}: '
          '${event.message}');
    });

    WidgetsFlutterBinding.ensureInitialized();


    _log.info('Going full screen');
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  AdsController? adsController;
  GamesServicesController? gamesServicesController;
  InAppPurchaseController? inAppPurchaseController;

  await guardWithCrashLytics(guardedMain, crashlytics: crashlytics);
  await initialize();
  enterFullScreen();


  runApp(MyApp(
    settingsPersistence: LocalStorageSettingsPersistence(),
    playerProgressPersistence: LocalStoragePlayerProgressPersistence(),
    inAppPurchaseController: inAppPurchaseController,
    adsController: adsController,
    gamesServicesController: gamesServicesController,
  ));
}

Logger _log = Logger('main.dart');

class MyApp extends StatelessWidget {
  static final _router = GoRouter(routes: [
    GoRoute(
        path: '/',
        builder: (context, state) => const MainMenuScreen(
              key: Key('main menu'),
            ),
        routes: [
          GoRoute(
              path: 'play',
              pageBuilder: (context, state) => buildMyTransition<void>(
                  child: const LevelSelectionScreen(
                    key: Key('level selection'),
                  ),
                  color: context.watch<Palette>().backgroundLevelSelection),
              routes: [
                GoRoute(
                    path: 'session/:level',
                    pageBuilder: (context, state) {
                      final levelNumber = int.parse(state.params['level']!);
                      final level = gameLevels.singleWhere(
                          (element) => element.number == levelNumber);
                      return buildMyTransition(
                          child: PlaySessionScreen(
                            level,
                            key: const Key('play session'),
                          ),
                          color:
                              context.watch<Palette>().backgroundPlaySession);
                    }),
                GoRoute(
                    path: 'won',
                    pageBuilder: (context, state) {
                      final map = state.extra! as Map<String, dynamic>;
                      final score = map['score'] as Score;
                      return buildMyTransition<void>(
                          child: WinGameScreen(
                            score: score,
                            key: const Key('win game'),
                          ),
                          color:
                              context.watch<Palette>().backgroundPlaySession);
                    })
              ]),
          GoRoute(
              path: 'settings',
              builder: (context, state) => const SettingsScreen(
                    key: Key('settings'),
                  ))
        ]),
  ]);

  final PlayerProgressPersistence playerProgressPersistence;
  final SettingsPersistence settingsPersistence;
  final GamesServicesController? gamesServicesController;
  final InAppPurchaseController? inAppPurchaseController;
  final AdsController? adsController;

  const MyApp(
      {super.key,
      required this.playerProgressPersistence,
      required this.settingsPersistence,
      this.gamesServicesController,
      this.inAppPurchaseController,
      this.adsController});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AppLifecycleObserver(
        child: MultiProvider(
            providers: [
          ChangeNotifierProvider(create: (context) {
            var progress = PlayerProgress(playerProgressPersistence);
            progress.getLatestFromStore();
            return progress;
          }),
          Provider<GamesServicesController?>.value(
              value: gamesServicesController),
          Provider<AdsController?>.value(value: adsController),
          ChangeNotifierProvider<InAppPurchaseController?>.value(
            value: inAppPurchaseController,
          ),
          Provider<SettingsController>(
            lazy: false,
            create: (context) =>
                SettingsController(persistence: settingsPersistence)
                  ..loadStateFromPersistence(),
          ),
          ProxyProvider2<SettingsController, ValueNotifier<AppLifecycleState>,
              AudioController>(
            lazy: false,
            create: (context) => AudioController()..initialize(),
            update: (context, settings, lifecycleNotifier, audio) {
              if (audio == null) throw ArgumentError.notNull();
              audio.attachSettings(settings);
              audio.attachLifecycleNotifier(lifecycleNotifier);
              return audio;
            },
            dispose: (context, audio) => audio.dispose(),
          ),
          Provider(create: (context) => Palette())
        ],
            child: Builder(builder: (context) {
              final palette = context.watch<Palette>();
              return MaterialApp.router(
                title: 'Flutter Demo',
                theme: ThemeData.from(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: palette.darkPen,
                    background: palette.backgroundMain,
                  ),
                  textTheme: TextTheme(
                    bodyMedium: TextStyle(
                      color: palette.ink,
                    ),
                  ),
                  useMaterial3: true,
                ),
                routeInformationProvider: _router.routeInformationProvider,
                routeInformationParser: _router.routeInformationParser,
                routerDelegate: _router.routerDelegate,
                scaffoldMessengerKey: scaffoldMessengerKey,
              );
            })));
  }
}