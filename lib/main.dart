import 'dart:async';
import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_single_instance/flutter_single_instance.dart';
import 'interface/screens/my_app.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  doWhenWindowReady(() {
    final win = appWindow;
    win.minSize = const Size(800, 600);
    win.alignment = Alignment.center;
    win.title = 'Music Player';
    win.maximize();
    win.show();
  });
  if(await FlutterSingleInstance.platform.isFirstInstance()){
    final docsDir = await getApplicationDocumentsDirectory();
    File logFile = File(kDebugMode ? '${docsDir.path}/MusicPlayer-Debug${Platform.operatingSystem}/log.txt' : '${docsDir.path}/MusicPlayer${Platform.operatingSystem}/log.txt');
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
      MaterialApp(
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0E0E0E),
        ),
        debugShowCheckedModeBanner: false,
        //showPerformanceOverlay: true,
        home: const MyApp(),
      ),
    );

  } else {
    if (args.isNotEmpty) {
      debugPrint("App is already running, should add to queue!");
      // Settings newSettings = SettingsController.settings;
      // newSettings.queue = args;
      // newSettings.index = -100;
      // SettingsController.settings = newSettings;
    }
    else{
      debugPrint("App is already running");
    }
    exit(0);
  }



}



