import 'dart:async';
import 'dart:typed_data';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/controller/audio_player_controller.dart';
import 'package:musicplayer/controller/settings_controller.dart';
import 'package:musicplayer/controller/worker_controller.dart';
import 'package:musicplayer/main.dart';
import 'package:system_tray/system_tray.dart';


class AppManager{
  static final AppManager _instance = AppManager._internal();

  factory AppManager() => _instance;

  AppManager._internal();


  static final Menu _menuMain = Menu();
  static final SystemTray _systemTray = SystemTray();
  final navigatorKey = GlobalKey<NavigatorState>();
  ValueNotifier<bool> minimizedNotifier = ValueNotifier<bool>(true);
  ValueNotifier<String> notificationMessage = ValueNotifier<String>('');
  Widget actions = const SizedBox();

  static void init(){
    initSystemTray();
    SettingsController.systemTrayNotifier.addListener(() async {
      await initSystemTray();
    });
    SettingsController.repeatNotifier.addListener(() async {
      await initSystemTray();
    });
    SettingsController.shuffleNotifier.addListener(() async {
      await initSystemTray();
    });
  }

  void showNotification(String message, int duration, {Widget newActions = const SizedBox()}) {
    if (SettingsController.appNotifications == false) {
      return;
    }
    notificationMessage.value = message;
    actions = newActions;
    Timer.periodic(
      Duration(milliseconds: duration),
          (timer) {
        notificationMessage.value = '';
        actions = const SizedBox();
        timer.cancel();
      },
    );
  }

  static Future<void> initSystemTray() async {
    if (SettingsController.systemTray == false) {
      try {
      await _systemTray.destroy();
      } catch (e) {
        debugPrint(e.toString());
      }

    } else {
      await _systemTray.initSystemTray(iconPath: 'assets/bg.png');
      _systemTray.registerSystemTrayEventHandler((eventName) {
        // debugPrint("eventName: $eventName");
        if (eventName == kSystemTrayEventClick) {
          _systemTray.popUpContextMenu();
        }
      });

      await _menuMain.buildFrom(
        [
          MenuItemLabel(
            label: 'Music Player',
            //image: 'bg.png',
            enabled: false,
          ),
          MenuSeparator(),
          MenuItemLabel(
            label: 'Previous',
            //image: getImagePath('darts_icon'),
            onClicked: (menuItem) async {
              debugPrint("click 'Previous'");
              await audioHandler.skipToPrevious();
            },
          ),
          MenuItemLabel(
            label: SettingsController.playing ? 'Pause' : 'Play',
            //image: getImagePath('darts_icon'),
            onClicked: (menuItem) async {
              debugPrint("click 'Play'");
              SettingsController.playing ? await audioHandler.pause() : await audioHandler.play();
            },
          ),
          MenuItemLabel(
            label: 'Next',
            //image: getImagePath('darts_icon'),
            onClicked: (menuItem) async {
              debugPrint("click 'Next'");
              await audioHandler.skipToNext();
            },
          ),
          MenuSeparator(),
          MenuItemCheckbox(
            label: 'Repeat',
            name: 'repeat',
            checked: SettingsController.repeat,
            onClicked: (menuItem) async {
              debugPrint("click 'Repeat'");
              await menuItem.setCheck(!menuItem.checked);
              SettingsController.repeat = !SettingsController.repeat;
            },
          ),
          MenuItemCheckbox(
            label: 'Shuffle',
            name: 'shuffle',
            checked: SettingsController.shuffle,
            onClicked: (menuItem) async {
              debugPrint("click 'Shuffle'");
              await menuItem.setCheck(!menuItem.checked);
              SettingsController.shuffle = !SettingsController.shuffle;
            },
          ),
          MenuSeparator(),
          MenuItemLabel(
              label: 'Show',
              //image: getImagePath('darts_icon'),
              onClicked: (menuItem) => appWindow.show()),
          MenuItemLabel(
              label: 'Exit',
              //image: getImagePath('darts_icon'),
              onClicked: (menuItem) => appWindow.close()),
        ],
      );
      _systemTray.setContextMenu(_menuMain);
    }
  }

  static Future<void> updateColors(Uint8List image) async {
    var colors = await WorkerController.getColorIsolate(image);
    SettingsController.lightColorNotifier.value = colors[0];
    SettingsController.darkColorNotifier.value = colors[1];

  }


}