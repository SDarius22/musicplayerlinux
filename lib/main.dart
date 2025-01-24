import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_single_instance/flutter_single_instance.dart';
import 'interface/screens/main_screen.dart';

Future<void> main(List<String> args) async {

  WidgetsFlutterBinding.ensureInitialized();

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
        MaterialApp(
          theme: ThemeData(
            fontFamily: 'Bahnschrift',
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0E0E0E),
          ),
          debugShowCheckedModeBanner: false,
          //showPerformanceOverlay: true,
          home: MyApp(args: args),
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



