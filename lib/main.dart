import 'dart:async';
import 'package:flutter/material.dart';
import 'package:musicplayer/controller/objectBox.dart';
import 'screens/main_screen.dart';
import 'package:window_manager/window_manager.dart';
import 'controller/controller.dart';

late ObjectBox objectBox;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    center: true,
    titleBarStyle: TitleBarStyle.hidden,
    // skipTaskbar: true,
  );
  windowManager.waitUntilReadyToShow(windowOptions,() async {
    await windowManager.maximize();
    await windowManager.show();
    await windowManager.focus();
  });
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
          home: MyApp(controller: controller),
      )
  );
  FlutterError.onError = (FlutterErrorDetails details) {
    if (details.exceptionAsString().contains('overflowed by ')){
      print('flutter error hidden from console');
    }
    else{
      FlutterError.dumpErrorToConsole(details, forceReport: false);
    }

    // FlutterError.dumpErrorToConsole(details, forceReport: false);
  };
}





