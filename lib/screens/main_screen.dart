import 'dart:async';

import 'package:flutter/material.dart';
import '../controller/controller.dart';
import 'package:system_tray/system_tray.dart';
import 'home.dart';
import 'welcome_screen.dart';


class MyApp extends StatefulWidget {
  final Controller controller;
  const MyApp({super.key, required this.controller});
  @override
  _MyAppState createState() => _MyAppState();
}

String getTrayImagePath(String imageName) {
  return 'assets/bg.png';
}

String getImagePath(String imageName) {
  return 'assets/bg.png';
}


class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  final SystemTray _systemTray = SystemTray();
  final Menu _menuMain = Menu();
  final Menu _menuSimple = Menu();

  Timer? _timer;
  bool _toogleTrayIcon = true;

  bool _toogleMenu = true;

  @override
  void initState() {
    widget.controller.context = context;
    super.initState();
    initSystemTray();
  }

  Future<void> initSystemTray() async {
    // We first init the systray menu and then add the menu entries
    await _systemTray.initSystemTray(iconPath: 'assets/bg.png');

    // handle system tray event
    _systemTray.registerSystemTrayEventHandler((eventName) {
      debugPrint("eventName: $eventName");
      if (eventName == kSystemTrayEventClick) {
        _systemTray.popUpContextMenu();
      }
    });

    await _menuMain.buildFrom(
      [
        MenuItemLabel(
          label: 'Music Player',
          image: 'assets/bg.png',
          enabled: false,
        ),
        MenuSeparator(),
        MenuItemLabel(
            label: 'Show',
            image: getImagePath('darts_icon'),
            //onClicked: (menuItem) => _appWindow.show()
        ),
        MenuItemLabel(
            label: 'Hide',
            image: getImagePath('darts_icon'),
            //onClicked: (menuItem) => _appWindow.hide()),
        ),
        MenuItemLabel(
          label: 'Start flash tray icon',
          image: getImagePath('darts_icon'),
          onClicked: (menuItem) {
            debugPrint("Start flash tray icon");

            _timer ??= Timer.periodic(
              const Duration(milliseconds: 500),
                  (timer) {
                _toogleTrayIcon = !_toogleTrayIcon;
                _systemTray.setImage(
                    _toogleTrayIcon ? "" : getTrayImagePath('app_icon'));
              },
            );
          },
        ),
        MenuItemLabel(
          label: 'Stop flash tray icon',
          image: getImagePath('darts_icon'),
          onClicked: (menuItem) {
            debugPrint("Stop flash tray icon");

            _timer?.cancel();
            _timer = null;

            _systemTray.setImage(getTrayImagePath('app_icon'));
          },
        ),
        MenuSeparator(),
        SubMenu(
          label: "Test API",
          image: getImagePath('gift_icon'),
          children: [
            SubMenu(
              label: "setSystemTrayInfo",
              image: getImagePath('darts_icon'),
              children: [
                MenuItemLabel(
                  label: 'setTitle',
                  image: getImagePath('darts_icon'),
                  onClicked: (menuItem) {
                    final String text = 'Flutter System Tray';
                    debugPrint("click 'setTitle' : $text");
                    _systemTray.setTitle(text);
                  },
                ),
                MenuItemLabel(
                  label: 'setImage',
                  image: getImagePath('gift_icon'),
                  onClicked: (menuItem) {
                    print("click 'setImage'");
                  },
                ),
                MenuItemLabel(
                  label: 'setToolTip',
                  image: getImagePath('darts_icon'),
                  onClicked: (menuItem) {
                    //final String text = WordPair.random().asPascalCase;
                    debugPrint("click 'setToolTip'");
                    _systemTray.setToolTip("How to use system tray with Flutter");
                  },
                ),
                MenuItemLabel(
                  label: 'getTitle',
                  image: getImagePath('gift_icon'),
                  onClicked: (menuItem) async {
                    String title = await _systemTray.getTitle();
                    debugPrint("click 'getTitle' : $title");
                  },
                ),
              ],
            ),
            MenuItemLabel(
                label: 'disabled Item',
                name: 'disableItem',
                image: getImagePath('gift_icon'),
                enabled: false),
          ],
        ),
        MenuSeparator(),
        MenuItemCheckbox(
          label: 'Checkbox 1',
          name: 'checkbox1',
          checked: true,
          onClicked: (menuItem) async {
            debugPrint("click 'Checkbox 1'");

            MenuItemCheckbox? checkbox1 =
            _menuMain.findItemByName<MenuItemCheckbox>("checkbox1");
            await checkbox1?.setCheck(!checkbox1.checked);

            MenuItemCheckbox? checkbox2 =
            _menuMain.findItemByName<MenuItemCheckbox>("checkbox2");
            await checkbox2?.setEnable(checkbox1?.checked ?? true);

            debugPrint(
                "click name: ${checkbox1?.name} menuItemId: ${checkbox1?.menuItemId} label: ${checkbox1?.label} checked: ${checkbox1?.checked}");
          },
        ),

        MenuItemCheckbox(
          label: 'Checkbox 3',
          name: 'checkbox3',
          checked: true,
          onClicked: (menuItem) async {
            debugPrint("click 'Checkbox 3'");

            await menuItem.setCheck(!menuItem.checked);
            debugPrint(
                "click name: ${menuItem.name} menuItemId: ${menuItem.menuItemId} label: ${menuItem.label} checked: ${menuItem.checked}");
          },
        ),
      ],
    );

    await _menuSimple.buildFrom([
      MenuItemLabel(
        label: 'Change Context Menu',
        image: getImagePath('app_icon'),
        onClicked: (menuItem) {
          debugPrint("Change Context Menu");

          _toogleMenu = !_toogleMenu;
          _systemTray.setContextMenu(_toogleMenu ? _menuMain : _menuSimple);
        },
      ),
      MenuSeparator(),
      MenuItemLabel(
          label: 'Show',
          image: getImagePath('app_icon'),
          //onClicked: (menuItem) => _appWindow.show()),
      ),
      MenuItemLabel(
          label: 'Hide',
          image: getImagePath('app_icon'),
          // onClicked: (menuItem) => _appWindow.hide()),
      ),
      MenuItemLabel(
        label: 'Exit',
        image: getImagePath('app_icon'),
        // onClicked: (menuItem) => _appWindow.close(),
      ),
    ]);

    _systemTray.setContextMenu(_menuMain);
  }



  @override
  Widget build(BuildContext context) {
    Widget finalWidget = widget.controller.settings.firstTime ?
    WelcomeScreen(controller: widget.controller) :
    HomePage(controller: widget.controller);
    return PopScope(
      canPop: false,
      child: finalWidget,
    );
  }




}