import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/controller/settings_controller.dart';
import 'package:musicplayer/controller/worker_controller.dart';
import 'package:provider/provider.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:musicplayer/controller/app_manager.dart';
import 'package:musicplayer/controller/audio_player_controller.dart';
import 'package:musicplayer/controller/data_controller.dart';
import 'package:musicplayer/controller/online_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_single_instance/flutter_single_instance.dart';
import 'repository/objectBox.dart';
import 'screens/main_screen.dart';

Future<void> main(List<String> args) async {
  //print(args);
  await ObjectBox.initialize();
  WidgetsFlutterBinding.ensureInitialized();

  // var settingsBox = ObjectBox.store.box<Settings>();
  // Settings settings = settingsBox.query().build().findFirst() ?? Settings();
  // if (args.isNotEmpty) {
  //   settings.queue.clear();
  //   settings.queue.addAll(args);
  //   settings.index = 0;
  // }
  // settingsBox.put(settings);


  SettingsController.init();
  WorkerController.init();
  if (args.isNotEmpty){
    SettingsController.queue = args;
    SettingsController.index = 0;
  }

  if(await FlutterSingleInstance.platform.isFirstInstance()){
    final docsDir = await getApplicationDocumentsDirectory();
    File logFile = File(kDebugMode ? '${docsDir.path}/musicplayer-debug ${Platform.operatingSystem}/log.txt' : '${docsDir.path}/musicplayer ${Platform.operatingSystem}/log.txt');
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details, forceReport: true);
      try{
        logFile.writeAsStringSync('${DateTime.now()}: ${details.toString()}\n', mode: FileMode.append);
      } catch (e) {
        logFile.createSync(recursive: true);
        logFile.writeAsStringSync('${DateTime.now()}: ${details.toString()}\n', mode: FileMode.append);
      }
    };

    runApp(
        MultiProvider(
          providers: [
            Provider(create: (_) => AudioPlayerController()),
            Provider(create: (_) => OnlineController()),
            Provider(create: (_) => DataController()),
            Provider(create: (_) => AppManager()),
            // ChangeNotifierProvider(create: (_) => SettingsController()),
          ],
          child: MaterialApp(
            theme: ThemeData(
              fontFamily: 'Bahnschrift',
              brightness: Brightness.dark,
              scaffoldBackgroundColor: const Color(0xFF0E0E0E),
            ),
            debugShowCheckedModeBanner: false,
            //showPerformanceOverlay: true,
            home: const MyApp(),
          ),
        )
    );

    doWhenWindowReady(() {
      final win = appWindow;
      win.minSize = const Size(800, 600);
      win.alignment = Alignment.center;
      win.title = 'Music Player';
      win.maximize();
      win.show();
    });

  } else {
    if (args.isNotEmpty) {
      SettingsController.queue = args;
      SettingsController.index = 0;
    }
    else{
      print("App is already running");
    }
    exit(0);
  }



}



