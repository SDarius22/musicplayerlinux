import 'dart:async';

import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

import 'controller/controller.dart';
import 'controller/objectBox.dart';
import 'screens/main_screen.dart';

late ObjectBox objectBox;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  objectBox = await ObjectBox.create();
  Controller controller = Controller(objectBox);

  runApp(
      MaterialApp(
        theme: ThemeData(
          fontFamily: 'Bahnschrift',
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0E0E0E),
        ),
          debugShowCheckedModeBanner: false,
          //showPerformanceOverlay: true,
          home: MyApp(controller: controller),
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
}



