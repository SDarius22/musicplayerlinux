import 'dart:async';
import 'package:flutter/material.dart';
import 'package:musicplayer/controller/objectBox.dart';
import 'domain/metadata_type.dart';
import 'utils/objectbox.g.dart';
import 'screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:system_tray/system_tray.dart';
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
  // FlutterError.onError = (FlutterErrorDetails details) {
  //   print('flutter error hidden from console');
  //   // FlutterError.dumpErrorToConsole(details, forceReport: false);
  // };
}





