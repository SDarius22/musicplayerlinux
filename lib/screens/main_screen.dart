import 'dart:async';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/screens/search_widget.dart';
import 'package:musicplayer/screens/song_player_widget.dart';
import '../controller/controller.dart';
import 'package:system_tray/system_tray.dart';
import 'settings.dart';
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
  bool volume = true;
  final ValueNotifier<bool> _visible = ValueNotifier(false);

  @override
  void initState() {
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
    //print(widget.controller.settings.firstTime);
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    var normalSize = height * 0.02;
    Widget finalWidget = widget.controller.settings.firstTime ?
    WelcomeScreen(controller: widget.controller) :
    HomePage(controller: widget.controller);
    return Scaffold(
        body: SafeArea(
          child: SizedBox(
            width: width,
            height: height,
            child: Column(
              children: [
                WindowTitleBarBox(
                  child: ValueListenableBuilder(
                    valueListenable: widget.controller.colorNotifier2,
                    builder: (context, value, child){
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        color: widget.controller.colorNotifier2.value,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                                child: MoveWindow(
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        left: width * 0.01
                                    ),
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      'Music Player',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: normalSize,
                                      ),
                                    ),
                                  ),
                                )
                            ),
                            ValueListenableBuilder(
                              valueListenable: _visible,
                              builder: (context, value, child) =>
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Visibility(
                                      visible: _visible.value,
                                      child: SizedBox(
                                        height: height * 0.05,
                                        width: width * 0.1,
                                        child:
                                        MouseRegion(
                                          onEnter: (event) {
                                            _visible.value = true;
                                          },
                                          onExit: (event) {
                                            _visible.value = false;
                                          },
                                          child: ValueListenableBuilder(
                                              valueListenable: widget.controller.volumeNotifier,
                                              builder: (context, value, child){
                                                return SliderTheme(
                                                  data: SliderThemeData(
                                                    trackHeight: 2,
                                                    thumbShape: RoundSliderThumbShape(enabledThumbRadius: height * 0.0075),
                                                  ),
                                                  child: Slider(
                                                    min: 0.0,
                                                    max: 1.0,
                                                    mouseCursor: SystemMouseCursors.click,
                                                    value: value,
                                                    activeColor: widget.controller.colorNotifier.value,
                                                    thumbColor: Colors.white,
                                                    inactiveColor: Colors.white,
                                                    onChanged: (double value) {
                                                      widget.controller.volumeNotifier.value = value;
                                                      widget.controller.audioPlayer.setVolume(widget.controller.volumeNotifier.value);
                                                    },
                                                  ),
                                                );
                                              }
                                          ),
                                        ),
                                      ),
                                    ),
                                    MouseRegion(
                                      onEnter: (event) {
                                        _visible.value = true;
                                      },
                                      onExit: (event) {
                                        _visible.value = false;
                                      },
                                      child: ValueListenableBuilder(
                                          valueListenable: widget.controller.volumeNotifier,
                                          builder: (context, value, child) {
                                            return IconButton(
                                              icon: volume ? Icon(
                                                FluentIcons.speaker_2_16_filled,
                                                size: height * 0.02,
                                                color: Colors.white,
                                              ) :
                                              Icon(
                                                FluentIcons.speaker_mute_16_filled,
                                                size: height * 0.02,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                if(volume) {
                                                  widget.controller.volumeNotifier.value = 0;
                                                }
                                                else {
                                                  widget.controller.volumeNotifier.value = 0.1;
                                                }
                                                volume = !volume;
                                                widget.controller.audioPlayer.setVolume(widget.controller.volumeNotifier.value);
                                              },
                                            );
                                          }
                                      ),
                                    ),
                                    IconButton(onPressed: (){
                                      print("Search");
                                      widget.controller.searchNotifier.value = !widget.controller.searchNotifier.value;
                                    }, icon: Icon(
                                      FluentIcons.search_16_filled,
                                      size: height * 0.02,
                                      color: Colors.white,
                                    )
                                    ),
                                    IconButton(onPressed: (){
                                      print("Tapped settings");
                                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                                        return Settings(controller: widget.controller,);
                                      }));
                                    }, icon: Icon(
                                      FluentIcons.settings_16_filled,
                                      size: height * 0.02,
                                      color: Colors.white,
                                    )
                                    )//Icon(Icons.more_vert)),
                                  ],
                                ),
                            ),
                            Icon(
                              FluentIcons.divider_tall_16_regular,
                              size: height * 0.02,
                              color: Colors.white,
                            ),
                            MinimizeWindowButton(
                              animate: true,
                              colors: WindowButtonColors(
                                normal: Colors.transparent,
                                iconNormal: Colors.white,
                                iconMouseOver: Colors.white,
                                mouseOver: Colors.grey,
                                mouseDown: Colors.grey,
                              ),
                            ),
                            RestoreWindowButton(
                              animate: true,
                              colors: WindowButtonColors(
                                normal: Colors.transparent,
                                iconNormal: Colors.white,
                                iconMouseOver: Colors.white,
                                mouseOver: Colors.grey,
                                mouseDown: Colors.grey,
                              ),
                            ),
                            CloseWindowButton(
                              animate: true,
                              colors: WindowButtonColors(
                                normal: Colors.transparent,
                                iconNormal: Colors.white,
                                iconMouseOver: Colors.white,
                                mouseOver: Colors.grey,
                                mouseDown: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      );

                    },
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      PopScope(
                        child: MaterialApp(
                          theme: ThemeData(
                            fontFamily: 'Bahnschrift',
                            brightness: Brightness.dark,
                            scaffoldBackgroundColor: const Color(0xFF0E0E0E),
                          ),
                          debugShowCheckedModeBanner: false,
                          home: finalWidget,
                        ),
                      ),
                      ValueListenableBuilder(
                          valueListenable: widget.controller.finishedRetrievingNotifier,
                          builder: (context, value, child) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              alignment: Alignment.bottomCenter,
                              child: value ?
                              SongPlayerWidget(controller: widget.controller) :
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                padding: EdgeInsets.only(
                                  left: width * 0.01,
                                  right: width * 0.01,
                                  bottom: height * 0.01,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(height * 0.1),
                                ),
                                child: const CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }
                      ),
                      ValueListenableBuilder(
                          valueListenable: widget.controller.searchNotifier,
                          builder: (context, value, child){
                            return Visibility(
                              visible: value,
                              child: GestureDetector(
                                onTap: (){
                                  widget.controller.searchNotifier.value = false;
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  width: width,
                                  height: height,
                                  color: value ? Colors.black.withOpacity(0.3) : Colors.transparent,
                                  child: SearchWidget(controller: widget.controller),
                                ),
                              ),
                            );
                          }
                      ),
                    ],
                  ),


                ),
              ],
            )
          ),
        ),
      );
  }




}