import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/entities/app_settings.dart';
import 'package:musicplayer/providers/audio_provider.dart';
import 'package:musicplayer/services/settings_service.dart';
import 'package:musicplayer/services/worker_service.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:tray_manager/tray_manager.dart';

class AppStateProvider with ChangeNotifier, TrayListener {
  final AudioProvider audioProvider;
  final SettingsService settingsService;
  final navigatorKey = GlobalKey<NavigatorState>();
  bool isDarkMode = true;
  List<String> appActions = [];
  PanelController panelController = PanelController();
  AppSettings appSettings = AppSettings();

  Color lightColor = Colors.white;
  Color darkColor = Colors.black;

  AppStateProvider(this.audioProvider, this.settingsService) {
    appSettings = settingsService.getAppSettings() ?? AppSettings();
    audioProvider.addListener(() async {
      debugPrint('AudioProvider changed, updating tray and colors');
      // await initTray();
      await setColors();
    });
  }

  Future<void> initTray() async {
    MenuItem menuItemPlay = MenuItem(
      key: 'play',
      label: audioProvider.playing ? 'Pause' : 'Play',
      onClick: (menuItem) {
        if (kDebugMode) {
          print('click item play');
        }
        if (audioProvider.playing) {
          audioProvider.pause();
          menuItem.label = 'Play';
        } else {
          audioProvider.play();
          menuItem.label = 'Pause';
        }
      },
    );

    Menu menu =  Menu(
      items: [
        MenuItem(
          key: 'title',
          label: 'Music Player ${kDebugMode ? 'Debug' : ''}',
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'previous',
          label: 'Previous',
          onClick: (menuItem) {
            if (kDebugMode) {
              print('click item previous');
            }
            audioProvider.skipToPrevious();
          },
        ),
        menuItemPlay,
        MenuItem(
          key: 'next',
          label: 'Next',
          onClick: (menuItem) {
            if (kDebugMode) {
              print('click item next');
            }
            audioProvider.skipToNext();
          },
        ),
        MenuItem.separator(),
        MenuItem.checkbox(
          key: 'repeat',
          label: 'Repeat',
          checked: false,
          onClick: (menuItem) {
            if (kDebugMode) {
              print('click item 1');
            }
            menuItem.checked = !(menuItem.checked == true);
            audioProvider.setRepeat(menuItem.checked == true);
          },
        ),
        MenuItem.checkbox(
          key: 'shuffle',
          label: 'Shuffle',
          checked: false,
          onClick: (menuItem) {
            if (kDebugMode) {
              print('click item 2');
            }
            menuItem.checked = !(menuItem.checked == true);
            audioProvider.setShuffle(menuItem.checked == true);
          },
        ),
        MenuItem.separator(),
        MenuItem(
          key: 'show',
          label: 'Show',
          onClick: (menuItem) {
            if (kDebugMode) {
              print('click item show');
            }
            appWindow.show();
          },
        ),
        MenuItem(
          key: 'quit',
          label: 'Quit',
          onClick: (menuItem) {
            if (kDebugMode) {
              print('click item quit');
            }
            appWindow.close();
          },
        ),

      ],
    );

    await trayManager.setIcon(Platform.isLinux ? 'assets/logo.png' : 'assets/logo.ico');
    trayManager.setContextMenu(menu);
    trayManager.addListener(this);
  }

  @override
  void onTrayIconMouseDown() {
    // Handle tray icon click
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseDown() {
    // Handle right click on tray icon
    trayManager.popUpContextMenu();
  }

  Future<void> addAppAction(String action) async {
    if (!appActions.contains(action)) {
      appActions.add(action);
      notifyListeners();
    }
  }

  void updateAppSettings() {
    settingsService.updateAppSettings(appSettings);
    notifyListeners();
  }

  Future<void> setColors() async {
    debugPrint('Setting colors based on image, length: ${audioProvider.image?.length ?? 0}');
    var colors = await WorkerService.getColorIsolate(audioProvider.image ?? Uint8List(0));
    lightColor = colors[0];
    darkColor = colors[1];
    debugPrint('Colors set: lightColor: $lightColor, darkColor: $darkColor');
    notifyListeners();
  }
}