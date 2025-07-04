import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_miniplayer/flutter_miniplayer.dart';
import 'package:mesh_gradient/mesh_gradient.dart';
import 'package:musicplayer/entities/app_settings.dart';
import 'package:musicplayer/providers/audio_provider.dart';
import 'package:musicplayer/services/settings_service.dart';
import 'package:musicplayer/services/worker_service.dart';
import 'package:tray_manager/tray_manager.dart';

class AppStateProvider with ChangeNotifier, TrayListener{
  final AudioProvider audioProvider;
  final SettingsService settingsService;
  final navigatorKey = GlobalKey<NavigatorState>();
  bool isDarkMode = true;
  bool isDrawerOpen = false;
  List<String> appActions = [];

  MiniplayerController miniPlayerController = MiniplayerController();
  AnimatedMeshGradientController animatedMeshGradientController = AnimatedMeshGradientController();
  ScrollController itemScrollController = ScrollController();

  AppSettings appSettings = AppSettings();

  ValueNotifier<bool> isPanelOpen = ValueNotifier(false);

  Color lightColor = Colors.white;
  Color darkColor = Colors.black;


  AppStateProvider(this.audioProvider, this.settingsService) {
    trayManager.addListener(this);
    initTray();
    appSettings = settingsService.getAppSettings() ?? AppSettings();
    audioProvider.addListener(() async {
      debugPrint('AudioProvider changed, updating colors');
      setColors();
    });
    audioProvider.playingNotifier.addListener(() {
      if (audioProvider.playingNotifier.value) {
        animatedMeshGradientController.start();
      } else {
        animatedMeshGradientController.stop();
      }
      initTray();
    });
  }

  Future<void> initTray() async {
    MenuItem menuItemPlay = MenuItem(
      key: 'play',
      label: audioProvider.playingNotifier.value ? 'Pause' : 'Play',
      onClick: (menuItem) {
        if (kDebugMode) {
          print('click item play');
        }
        if (audioProvider.playingNotifier.value) {
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
          onClick: (menuItem) async {
            if (kDebugMode) {
              print('click item previous');
            }
            await audioProvider.skipToPrevious();
          },
        ),
        menuItemPlay,
        MenuItem(
          key: 'next',
          label: 'Next',
          onClick: (menuItem) async {
            if (kDebugMode) {
              print('click item next');
            }
            await audioProvider.skipToNext();
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

    trayManager.setIcon(Platform.isLinux ? 'assets/logo.png' : 'assets/logo.ico');
    trayManager.setTitle('Music Player${kDebugMode ? ' Debug' : ''}');
    trayManager.setContextMenu(menu);
  }

  @override
  void onTrayIconMouseDown() async {
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
    var colors = await WorkerService.extractColors(audioProvider.image ?? Uint8List(0));
    lightColor = colors[0];
    darkColor = colors[1];
    debugPrint('Colors set: lightColor: $lightColor, darkColor: $darkColor');
    notifyListeners();
  }

  void setDrawerOpen(bool isOpen) {
    isDrawerOpen = isOpen;
    notifyListeners();
  }
}