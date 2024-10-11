import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_single_instance/flutter_single_instance.dart';

import 'controller/controller.dart';
import 'controller/objectBox.dart';
import 'screens/main_screen.dart';

Future<void> main(List<String> args) async {
  //print(args);
  await ObjectBox.initialize();
  WidgetsFlutterBinding.ensureInitialized();
  Controller controller = Controller(args);

  if(await FlutterSingleInstance.platform.isFirstInstance()){
    final docsDir = await getApplicationDocumentsDirectory();
    File logFile = File('${docsDir.path}/.musicplayer database/log.txt');
    // File argsFile = File('${docsDir.path}/.musicplayerdatabase/args.txt');
    // if (args.isNotEmpty) {
    //   argsFile.writeAsStringSync(args.join(' '));
    // }


    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.dumpErrorToConsole(details, forceReport: true);
      logFile.writeAsStringSync('${DateTime.now()}: ${details.toString()}\n', mode: FileMode.append);
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
          home: MyApp(controller: controller,),
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
  }else{
    print("App is already running");
    exit(0);
  }



}



