import 'dart:async';
import 'package:flutter/material.dart';
import 'screens/main_screen.dart';
import 'package:provider/provider.dart';
import 'package:window_manager/window_manager.dart';
import 'package:system_tray/system_tray.dart';
import 'controller/controller.dart';


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
  Controller controller = Controller();

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
}





