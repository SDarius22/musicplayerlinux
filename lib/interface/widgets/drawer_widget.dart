import 'package:flutter/material.dart';
import 'package:musicplayer/utils/hover_widget/hover_container.dart';
import '../../controller/app_manager.dart';
import '../../controller/online_controller.dart';
import '../../controller/settings_controller.dart';
import '../../utils/fluenticons/fluenticons.dart';
import 'actions_widget.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({super.key});

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  bool _isBig = false;
  bool _finishedAnimation = false;
  int _selected = 5;
  late List<Map<String, dynamic>> menuItems = [
    {
      "text": "Menu",
      "tooltip": "Expand Menu",
      "icon": FluentIcons.menu,
      "onTap": (BuildContext context) {
        if (_isBig == false) {
          setState(() {
            _isBig = true;
          });
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              setState(() {
                _finishedAnimation = true;
              });
            }
          });
        } else {
          setState(() {
            _isBig = false;
          });
        }
      },
    },
    {
      "text": "User Page",
      "tooltip": "User Page",
      "icon": OnlineController.loggedInNotifier.value
          ? FluentIcons.circlePersonFilled
          : FluentIcons.circlePerson,
      "onTap": (BuildContext context) {
        setState(() {
          _selected = 1;
        });
        AppManager().navigatorKey.currentState!.pushNamed('/user');
      },
    },
    {
      "text": "Albums",
      "tooltip": "Albums",
      "icon": FluentIcons.album,
      "onTap": (BuildContext context) {
        setState(() {
          _selected = 2;
        });
        AppManager().navigatorKey.currentState!.pushNamed('/albums');
      },
    },
    {
      "text": "Artists",
      "tooltip": "Artists",
      "icon": FluentIcons.artists2,
      "onTap": (BuildContext context) {
        setState(() {
          _selected = 3;
        });
        AppManager().navigatorKey.currentState!.pushNamed('/artists');
      },
    },
    {
      "text": "Downloads",
      "tooltip": "Downloads",
      "icon": FluentIcons.download,
      "onTap": (BuildContext context) {
        setState(() {
          _selected = 4;
        });
        AppManager().navigatorKey.currentState!.pushNamed('/downloads');
      },
    },
    {
      "text": "Music",
      "tooltip": "Music",
      "icon": FluentIcons.music,
      "onTap": (BuildContext context) {
        setState(() {
          _selected = 5;
        });
        AppManager().navigatorKey.currentState!.pushNamed('/music');
      }
    },
    {
      "text": "Playlists",
      "tooltip": "Playlists",
      "icon": FluentIcons.playlists,
      "onTap": (BuildContext context) {
        setState(() {
          _selected = 6;
        });
        AppManager().navigatorKey.currentState!.pushNamed('/playlists');
      }
    },
    {
      "text": "Settings",
      "tooltip": "Settings",
      "icon": FluentIcons.settings,
      "onTap": (BuildContext context) {
        setState(() {
          _selected = 7;
        });
        final am = AppManager();
        am.minimizedNotifier.value = true;
        am.navigatorKey.currentState!.pushNamed('/settings');
      },
    },
    {
      "text": "Create",
      "tooltip": "Create",
      "icon": FluentIcons.create,
      "onTap": (BuildContext context) {
        setState(() {
          _selected = 8;
        });
        AppManager().navigatorKey.currentState!.pushNamed('/create', arguments: [""]);
      }
    },
    {
      "text": "Export",
      "tooltip": "Export",
      "icon": FluentIcons.export,
      "onTap": (BuildContext context) {
        setState(() {
          _selected = 9;
        });
        AppManager().navigatorKey.currentState!.pushNamed('/export');
      }
    },
    {
      "text": "Contact us",
      "tooltip": "Contact us",
      "icon": FluentIcons.open,
      "onTap": (BuildContext context) {}, // Placeholder for contact action
    },
    {
      "text": "About us",
      "tooltip": "About us",
      "icon": FluentIcons.open,
      "onTap": (BuildContext context) {
        showAboutDialog(
          context: context,
          applicationIcon: Image.asset(
            'assets/bg.png',
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width * 0.075,
            height: MediaQuery.of(context).size.width * 0.075,
          ),
          applicationName: 'Music Player',
          applicationVersion: 'version: 0.0.1',
          applicationLegalese: '© 2025 Music Player',
          children: const [
            Text('Music Player is a free and open-source music player for Windows, Linux and Android.'),
            Text('Developed by: Darius Sala'),
            Text(''),
            Text('This software is provided as-is, without any warranty or guarantee of any kind. Use at your own risk.'),
          ],
        );
      },
    },
  ];


  Color brighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final brighterHsl = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return brighterHsl.toColor();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var normalSize = height * 0.02;
    return ValueListenableBuilder(
        valueListenable: SettingsController.darkColorNotifier,
        builder: (context, value, child) {
          return AnimatedContainer(
            width: _isBig ? width * 0.125 : width * 0.035,
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: const Color(0xFF0E0E0E),
              border: Border(
                right: BorderSide(
                  color: SettingsController.darkColorNotifier.value,
                  width: 1.0,
                ),
              ),
            ),
            child: Column(
              children: [
                Flexible(
                  child: ListView.builder(
                    itemCount: menuItems.length,
                    itemExtent: height * 0.05,
                    itemBuilder: (context, index) {
                      return AnimatedContainer(
                        height: height * 0.05,
                        duration: const Duration(milliseconds: 300),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Tooltip(
                            message: menuItems[index]["tooltip"],
                            child: GestureDetector(
                              onTap: _selected == index ? null : () {
                                menuItems[index]["onTap"](context);
                              },
                              child: HoverContainer(
                                  hoverColor: brighten(_selected == index ? SettingsController.darkColorNotifier.value : const Color(0xFF0E0E0E), 0.05),
                                  normalColor: _selected == index ? SettingsController.darkColorNotifier.value : const Color(0xFF0E0E0E),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: width * 0.01,
                                      vertical: height * 0.01
                                  ),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        menuItems[index]["icon"],
                                        size: height * 0.025,
                                        color: Colors.white,
                                      ),
                                      if (_isBig && _finishedAnimation)
                                        Expanded(
                                          child: AnimatedContainer(
                                            duration: const Duration(milliseconds: 500),
                                            padding: EdgeInsets.only(left: width * 0.01),
                                            child: Text(
                                              menuItems[index]["text"],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: normalSize,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  )
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    // children: [
                    //   AnimatedContainer(
                    //     height: height * 0.05,
                    //     duration: const Duration(milliseconds: 300),
                    //     child: MouseRegion(
                    //       cursor: SystemMouseCursors.click,
                    //       child: Tooltip(
                    //         message: 'Expand Menu',
                    //         child: GestureDetector(
                    //           onTap: () {
                    //             if (_isBig == false){
                    //               setState(() {
                    //                 _isBig = true;
                    //               });
                    //               Future.delayed(const Duration(milliseconds: 300), () {
                    //                 if (mounted) {
                    //                   setState(() {
                    //                     _finishedAnimation = true;
                    //                   });
                    //                 }
                    //               });
                    //             }
                    //             else {
                    //               setState(() {
                    //                 _isBig = false;
                    //               });
                    //             }
                    //           },
                    //           child: HoverContainer(
                    //               hoverColor: brighten(const Color(0xFF0E0E0E), 0.05),
                    //               normalColor: const Color(0xFF0E0E0E),
                    //               padding: EdgeInsets.symmetric(
                    //                   horizontal: width * 0.01,
                    //                   vertical: height * 0.01
                    //               ),
                    //               alignment: Alignment.center,
                    //               child: Row(
                    //                 mainAxisAlignment: MainAxisAlignment.center,
                    //                 children: [
                    //                   Icon(
                    //                     FluentIcons.moreVertical,
                    //                     size: height * 0.025,
                    //                     color: Colors.white,
                    //                   ),
                    //                   if (_isBig && _finishedAnimation)
                    //                     Expanded(
                    //                       child: AnimatedContainer(
                    //                         duration: const Duration(milliseconds: 500),
                    //                         padding: EdgeInsets.only(left: width * 0.01),
                    //                         child: Text(
                    //                           "Menu",
                    //                           style: TextStyle(
                    //                             color: Colors.white,
                    //                             fontSize: normalSize,
                    //                           ),
                    //                         ),
                    //                       ),
                    //                     ),
                    //                 ],
                    //               )
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    //   AnimatedContainer(
                    //     height: height * 0.05,
                    //     duration: const Duration(milliseconds: 300),
                    //     child: MouseRegion(
                    //       cursor: SystemMouseCursors.click,
                    //       child: Tooltip(
                    //         message: 'User Page',
                    //         child: GestureDetector(
                    //           onTap: () {
                    //             AppManager().navigatorKey.currentState!.pushNamed('/user');
                    //           },
                    //           child: HoverContainer(
                    //               hoverColor: brighten(const Color(0xFF0E0E0E), 0.05),
                    //               normalColor: const Color(0xFF0E0E0E),
                    //               padding: EdgeInsets.symmetric(
                    //                   horizontal: width * 0.01,
                    //                   vertical: height * 0.01
                    //               ),
                    //               alignment: Alignment.center,
                    //               child: Row(
                    //                 mainAxisAlignment: MainAxisAlignment.center,
                    //                 children: [
                    //                   Icon(
                    //                     OnlineController.loggedInNotifier.value ? FluentIcons.circlePersonFilled : FluentIcons.circlePerson,
                    //                     size: height * 0.025,
                    //                     color: Colors.white,
                    //                   ),
                    //                   if (_isBig && _finishedAnimation)
                    //                     Expanded(
                    //                       child: AnimatedContainer(
                    //                         duration: const Duration(milliseconds: 500),
                    //                         padding: EdgeInsets.only(left: width * 0.01),
                    //                         child: Text(
                    //                           OnlineController.loggedInNotifier.value ? SettingsController.email : "Log in",
                    //                           style: TextStyle(
                    //                             color: Colors.white,
                    //                             fontSize: normalSize,
                    //                           ),
                    //                         ),
                    //                       ),
                    //                     ),
                    //                 ],
                    //               )
                    //           ),
                    //         ),
                    //       )
                    //     ),
                    //   ),
                    //   AnimatedContainer(
                    //     height: height * 0.05,
                    //     duration: const Duration(milliseconds: 300),
                    //     child: MouseRegion(
                    //         cursor: SystemMouseCursors.click,
                    //         child: Tooltip(
                    //           message: 'Albums',
                    //           child: GestureDetector(
                    //             onTap: () {
                    //               AppManager().navigatorKey.currentState!.pushNamed('/albums');
                    //             },
                    //             child: HoverContainer(
                    //                 hoverColor: brighten(const Color(0xFF0E0E0E), 0.05),
                    //                 normalColor: const Color(0xFF0E0E0E),
                    //                 padding: EdgeInsets.symmetric(
                    //                     horizontal: width * 0.01,
                    //                     vertical: height * 0.01
                    //                 ),
                    //                 alignment: Alignment.center,
                    //                 child: Row(
                    //                   mainAxisAlignment: MainAxisAlignment.center,
                    //                   children: [
                    //                     Icon(
                    //                       FluentIcons.album,
                    //                       size: height * 0.025,
                    //                       color: Colors.white,
                    //                     ),
                    //                     if (_isBig && _finishedAnimation)
                    //                       Expanded(
                    //                         child: AnimatedContainer(
                    //                           duration: const Duration(milliseconds: 500),
                    //                           padding: EdgeInsets.only(left: width * 0.01),
                    //                           child: Text(
                    //                             "Albums",
                    //                             style: TextStyle(
                    //                               color: Colors.white,
                    //                               fontSize: normalSize,
                    //                             ),
                    //                           ),
                    //                         ),
                    //                       ),
                    //                   ],
                    //                 )
                    //             ),
                    //           ),
                    //         )
                    //     ),
                    //   ),
                    //   AnimatedContainer(
                    //     height: height * 0.05,
                    //     duration: const Duration(milliseconds: 300),
                    //     child: MouseRegion(
                    //         cursor: SystemMouseCursors.click,
                    //         child: Tooltip(
                    //           message: 'Artists',
                    //           child: GestureDetector(
                    //             onTap: () {
                    //               AppManager().navigatorKey.currentState!.pushNamed('/artists');
                    //             },
                    //             child: HoverContainer(
                    //                 hoverColor: brighten(const Color(0xFF0E0E0E), 0.05),
                    //                 normalColor: const Color(0xFF0E0E0E),
                    //                 padding: EdgeInsets.symmetric(
                    //                     horizontal: width * 0.01,
                    //                     vertical: height * 0.01
                    //                 ),
                    //                 alignment: Alignment.center,
                    //                 child: Row(
                    //                   mainAxisAlignment: MainAxisAlignment.center,
                    //                   children: [
                    //                     Icon(
                    //                       FluentIcons.artists2,
                    //                       size: height * 0.025,
                    //                       color: Colors.white,
                    //                     ),
                    //                     if (_isBig && _finishedAnimation)
                    //                       Expanded(
                    //                         child: AnimatedContainer(
                    //                           duration: const Duration(milliseconds: 500),
                    //                           padding: EdgeInsets.only(left: width * 0.01),
                    //                           child: Text(
                    //                             "Artists",
                    //                             style: TextStyle(
                    //                               color: Colors.white,
                    //                               fontSize: normalSize,
                    //                             ),
                    //                           ),
                    //                         ),
                    //                       ),
                    //                   ],
                    //                 )
                    //             ),
                    //           ),
                    //         )
                    //     ),
                    //   ),
                    //   AnimatedContainer(
                    //     height: height * 0.05,
                    //     duration: const Duration(milliseconds: 300),
                    //     child: MouseRegion(
                    //         cursor: SystemMouseCursors.click,
                    //         child: Tooltip(
                    //           message: 'Downloads',
                    //           child: GestureDetector(
                    //             onTap: () {
                    //               AppManager().navigatorKey.currentState!.pushNamed('/downloads');
                    //             },
                    //             child: HoverContainer(
                    //                 hoverColor: brighten(const Color(0xFF0E0E0E), 0.05),
                    //                 normalColor: const Color(0xFF0E0E0E),
                    //                 padding: EdgeInsets.symmetric(
                    //                     horizontal: width * 0.01,
                    //                     vertical: height * 0.01
                    //                 ),
                    //                 alignment: Alignment.center,
                    //                 child: Row(
                    //                   mainAxisAlignment: MainAxisAlignment.center,
                    //                   children: [
                    //                     Icon(
                    //                       FluentIcons.download,
                    //                       size: height * 0.025,
                    //                       color: Colors.white,
                    //                     ),
                    //                     if (_isBig && _finishedAnimation)
                    //                       Expanded(
                    //                         child: AnimatedContainer(
                    //                           duration: const Duration(milliseconds: 500),
                    //                           padding: EdgeInsets.only(left: width * 0.01),
                    //                           child: Text(
                    //                             "Downloads",
                    //                             style: TextStyle(
                    //                               color: Colors.white,
                    //                               fontSize: normalSize,
                    //                             ),
                    //                           ),
                    //                         ),
                    //                       ),
                    //                   ],
                    //                 )
                    //             ),
                    //           ),
                    //         )
                    //     ),
                    //   ),
                    //   AnimatedContainer(
                    //     height: height * 0.05,
                    //     duration: const Duration(milliseconds: 300),
                    //     child: MouseRegion(
                    //         cursor: SystemMouseCursors.click,
                    //         child: Tooltip(
                    //           message: 'Music',
                    //           child: GestureDetector(
                    //             onTap: () {
                    //               AppManager().navigatorKey.currentState!.pushNamed('/music');
                    //             },
                    //             child: HoverContainer(
                    //                 hoverColor: brighten(const Color(0xFF0E0E0E), 0.05),
                    //                 normalColor: const Color(0xFF0E0E0E),
                    //                 padding: EdgeInsets.symmetric(
                    //                     horizontal: width * 0.01,
                    //                     vertical: height * 0.01
                    //                 ),
                    //                 alignment: Alignment.center,
                    //                 child: Row(
                    //                   mainAxisAlignment: MainAxisAlignment.center,
                    //                   children: [
                    //                     Icon(
                    //                       FluentIcons.music,
                    //                       size: height * 0.025,
                    //                       color: Colors.white,
                    //                     ),
                    //                     if (_isBig && _finishedAnimation)
                    //                       Expanded(
                    //                         child: AnimatedContainer(
                    //                           duration: const Duration(milliseconds: 500),
                    //                           padding: EdgeInsets.only(left: width * 0.01),
                    //                           child: Text(
                    //                             "Music",
                    //                             style: TextStyle(
                    //                               color: Colors.white,
                    //                               fontSize: normalSize,
                    //                             ),
                    //                           ),
                    //                         ),
                    //                       ),
                    //                   ],
                    //                 )
                    //             ),
                    //           ),
                    //         )
                    //     ),
                    //   ),
                    //   AnimatedContainer(
                    //     height: height * 0.05,
                    //     duration: const Duration(milliseconds: 300),
                    //     child: MouseRegion(
                    //         cursor: SystemMouseCursors.click,
                    //         child: Tooltip(
                    //           message: 'Playlists',
                    //           child: GestureDetector(
                    //             onTap: () {
                    //               AppManager().navigatorKey.currentState!.pushNamed('/playlists');
                    //             },
                    //             child: HoverContainer(
                    //                 hoverColor: brighten(const Color(0xFF0E0E0E), 0.05),
                    //                 normalColor: const Color(0xFF0E0E0E),
                    //                 padding: EdgeInsets.symmetric(
                    //                     horizontal: width * 0.01,
                    //                     vertical: height * 0.01
                    //                 ),
                    //                 alignment: Alignment.center,
                    //                 child: Row(
                    //                   mainAxisAlignment: MainAxisAlignment.center,
                    //                   children: [
                    //                     Icon(
                    //                       FluentIcons.playlists,
                    //                       size: height * 0.025,
                    //                       color: Colors.white,
                    //                     ),
                    //                     if (_isBig && _finishedAnimation)
                    //                       Expanded(
                    //                         child: AnimatedContainer(
                    //                           duration: const Duration(milliseconds: 500),
                    //                           padding: EdgeInsets.only(left: width * 0.01),
                    //                           child: Text(
                    //                             "Playlists",
                    //                             style: TextStyle(
                    //                               color: Colors.white,
                    //                               fontSize: normalSize,
                    //                             ),
                    //                           ),
                    //                         ),
                    //                       ),
                    //                   ],
                    //                 )
                    //             ),
                    //           ),
                    //         )
                    //     ),
                    //   ),
                    //   AnimatedContainer(
                    //     height: height * 0.05,
                    //     duration: const Duration(milliseconds: 300),
                    //     child: MouseRegion(
                    //       cursor: SystemMouseCursors.click,
                    //       child: Tooltip(
                    //         message: 'Settings',
                    //         child: GestureDetector(
                    //           onTap: () {
                    //             final am = AppManager();
                    //             am.minimizedNotifier.value = true;
                    //             am.navigatorKey.currentState!.pushNamed('/settings');
                    //             // am.navigatorKey.currentState!.push(MaterialPageRoute(builder: (BuildContext context){
                    //             //   return const SettingsScreen();
                    //             // })).then((value) {
                    //             //   setState(() {
                    //             //     _init = Future(() async {
                    //             //       await WorkerController.retrieveAllSongs();
                    //             //       if (SettingsController.queue.isEmpty) {
                    //             //         debugPrint("Queue is empty");
                    //             //         var songs = await DataController.getSongs('');
                    //             //         SettingsController.queue =
                    //             //             songs.map((e) => e.path).toList();
                    //             //         SettingsController.index = 0;
                    //             //       }
                    //             //     });
                    //             //   });
                    //             // });
                    //           },
                    //           child: HoverContainer(
                    //               hoverColor: brighten(const Color(0xFF0E0E0E), 0.05),
                    //               normalColor: const Color(0xFF0E0E0E),
                    //               padding: EdgeInsets.symmetric(
                    //                   horizontal: width * 0.01,
                    //                   vertical: height * 0.01
                    //               ),
                    //               alignment: Alignment.center,
                    //               child: Row(
                    //                 mainAxisAlignment: MainAxisAlignment.center,
                    //                 children: [
                    //                   Icon(
                    //                     FluentIcons.settings,
                    //                     size: height * 0.025,
                    //                     color: Colors.white,
                    //                   ),
                    //                   if (_isBig && _finishedAnimation)
                    //                     Expanded(
                    //                       child: AnimatedContainer(
                    //                         duration: const Duration(milliseconds: 500),
                    //                         padding: EdgeInsets.only(left: width * 0.01),
                    //                         child: Text(
                    //                           "Settings",
                    //                           style: TextStyle(
                    //                             color: Colors.white,
                    //                             fontSize: normalSize,
                    //                           ),
                    //                         ),
                    //                       ),
                    //                     ),
                    //                 ],
                    //               )
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    //   AnimatedContainer(
                    //     height: height * 0.05,
                    //     duration: const Duration(milliseconds: 300),
                    //     child: MouseRegion(
                    //       cursor: SystemMouseCursors.click,
                    //       child: Tooltip(
                    //         message: 'Create',
                    //         child: GestureDetector(
                    //           onTap: () {
                    //             AppManager().navigatorKey.currentState!.pushNamed('/create', arguments: [""]);
                    //           },
                    //           child: HoverContainer(
                    //               hoverColor: brighten(const Color(0xFF0E0E0E), 0.05),
                    //               normalColor: const Color(0xFF0E0E0E),
                    //               padding: EdgeInsets.symmetric(
                    //                   horizontal: width * 0.01,
                    //                   vertical: height * 0.01
                    //               ),
                    //               alignment: Alignment.center,
                    //               child: Row(
                    //                 mainAxisAlignment: MainAxisAlignment.center,
                    //                 children: [
                    //                   Icon(
                    //                     FluentIcons.create,
                    //                     size: height * 0.025,
                    //                     color: Colors.white,
                    //                   ),
                    //                   if (_isBig && _finishedAnimation)
                    //                     Expanded(
                    //                       child: AnimatedContainer(
                    //                         duration: const Duration(milliseconds: 500),
                    //                         padding: EdgeInsets.only(left: width * 0.01),
                    //                         child: Text(
                    //                           "Create",
                    //                           style: TextStyle(
                    //                             color: Colors.white,
                    //                             fontSize: normalSize,
                    //                           ),
                    //                         ),
                    //                       ),
                    //                     ),
                    //                 ],
                    //               )
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    //   AnimatedContainer(
                    //     height: height * 0.05,
                    //     duration: const Duration(milliseconds: 300),
                    //     child: Tooltip(
                    //       message: 'Export',
                    //       child: MouseRegion(
                    //         cursor: SystemMouseCursors.click,
                    //         child: GestureDetector(
                    //           onTap: () {
                    //             AppManager().navigatorKey.currentState!.pushNamed('/export');
                    //           },
                    //           child: HoverContainer(
                    //               hoverColor: brighten(const Color(0xFF0E0E0E), 0.05),
                    //               normalColor: const Color(0xFF0E0E0E),
                    //               padding: EdgeInsets.symmetric(
                    //                   horizontal: width * 0.01,
                    //                   vertical: height * 0.01
                    //               ),
                    //               alignment: Alignment.center,
                    //               child: Row(
                    //                 mainAxisAlignment: MainAxisAlignment.center,
                    //                 children: [
                    //                   Icon(
                    //                     FluentIcons.export,
                    //                     size: height * 0.025,
                    //                     color: Colors.white,
                    //                   ),
                    //                   if (_isBig && _finishedAnimation)
                    //                     Expanded(
                    //                       child: AnimatedContainer(
                    //                         duration: const Duration(milliseconds: 500),
                    //                         padding: EdgeInsets.only(left: width * 0.01),
                    //                         child: Text(
                    //                           "Export",
                    //                           style: TextStyle(
                    //                             color: Colors.white,
                    //                             fontSize: normalSize,
                    //                           ),
                    //                         ),
                    //                       ),
                    //                     ),
                    //                 ],
                    //               )
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    //   AnimatedContainer(
                    //     height: height * 0.05,
                    //     duration: const Duration(milliseconds: 300),
                    //     child: MouseRegion(
                    //       cursor: SystemMouseCursors.click,
                    //       child: Tooltip(
                    //         message: 'Contact us',
                    //         child: GestureDetector(
                    //           onTap: () {
                    //           },
                    //           child: HoverContainer(
                    //               hoverColor: brighten(const Color(0xFF0E0E0E), 0.05),
                    //               normalColor: const Color(0xFF0E0E0E),
                    //               padding: EdgeInsets.symmetric(
                    //                   horizontal: width * 0.01,
                    //                   vertical: height * 0.01
                    //               ),
                    //               alignment: Alignment.center,
                    //               child: Row(
                    //                 mainAxisAlignment: MainAxisAlignment.center,
                    //                 children: [
                    //                   Icon(
                    //                     FluentIcons.open,
                    //                     size: height * 0.025,
                    //                     color: Colors.white,
                    //                   ),
                    //                   if (_isBig && _finishedAnimation)
                    //                     Expanded(
                    //                       child: AnimatedContainer(
                    //                         duration: const Duration(milliseconds: 500),
                    //                         padding: EdgeInsets.only(left: width * 0.01),
                    //                         child: Text(
                    //                           "Contact us",
                    //                           style: TextStyle(
                    //                             color: Colors.white,
                    //                             fontSize: normalSize,
                    //                           ),
                    //                         ),
                    //                       ),
                    //                     ),
                    //                 ],
                    //               )
                    //           ),
                    //         ),
                    //       )
                    //     ),
                    //   ),
                    //   AnimatedContainer(
                    //     height: height * 0.05,
                    //     duration: const Duration(milliseconds: 300),
                    //     child: MouseRegion(
                    //       cursor: SystemMouseCursors.click,
                    //       child: Tooltip(
                    //         message: 'About us',
                    //         child: GestureDetector(
                    //           onTap: () {
                    //             showAboutDialog(
                    //               context: context,
                    //               applicationIcon: Image.asset('assets/bg.png', fit: BoxFit.cover, width: width * 0.075, height: width * 0.075,),
                    //               applicationName: 'Music Player',
                    //               applicationVersion: 'version: 0.0.1',
                    //               applicationLegalese: '© 2025 Music Player',
                    //               children: const [
                    //                 Text('Music Player is a free and open-source music player for Windows, Linux and Android.'),
                    //                 Text('Developed by: Darius Sala'),
                    //                 Text(''),
                    //                 Text('This software is provided as-is, without any warranty or guarantee of any kind. Use at your own risk.'),
                    //               ],
                    //             );
                    //           },
                    //           child: HoverContainer(
                    //               hoverColor: brighten(const Color(0xFF0E0E0E), 0.05),
                    //               normalColor: const Color(0xFF0E0E0E),
                    //               padding: EdgeInsets.symmetric(
                    //                   horizontal: width * 0.01,
                    //                   vertical: height * 0.01
                    //               ),
                    //               alignment: Alignment.center,
                    //               child: Row(
                    //                 mainAxisAlignment: MainAxisAlignment.center,
                    //                 children: [
                    //                   Icon(
                    //                     FluentIcons.open,
                    //                     size: height * 0.025,
                    //                     color: Colors.white,
                    //                   ),
                    //                   if (_isBig && _finishedAnimation)
                    //                     Expanded(
                    //                       child: AnimatedContainer(
                    //                         duration: const Duration(milliseconds: 500),
                    //                         padding: EdgeInsets.only(left: width * 0.01),
                    //                         child: Text(
                    //                           "About us",
                    //                           style: TextStyle(
                    //                             color: Colors.white,
                    //                             fontSize: normalSize,
                    //                           ),
                    //                         ),
                    //                       ),
                    //                     ),
                    //                 ],
                    //               )
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ],
                  ),
                ),
                const ActionsWidget(),
              ],
            ),
          );
        }
    );

  }
}
