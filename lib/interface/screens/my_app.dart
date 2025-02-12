import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/controller/app_manager.dart';
import 'package:musicplayer/controller/online_controller.dart';
import 'package:musicplayer/domain/song_type.dart';
import 'package:musicplayer/interface/screens/add_screen.dart';
import 'package:musicplayer/interface/screens/export_screen.dart';
import 'package:musicplayer/interface/screens/loading_screen.dart';
import 'package:musicplayer/interface/screens/playlist_screen.dart';
import 'package:musicplayer/interface/screens/settings_screen.dart';
import 'package:musicplayer/interface/screens/user_screen.dart';
import 'package:musicplayer/interface/widgets/actions_widget.dart';
import 'package:musicplayer/interface/widgets/notification_widget.dart';

import '../../controller/app_audio_handler.dart';
import '../../controller/audio_player_controller.dart';
import '../../controller/data_controller.dart';
import '../../controller/settings_controller.dart';
import '../../controller/worker_controller.dart';
import '../../domain/album_type.dart';
import '../../domain/artist_type.dart';
import '../../domain/playlist_type.dart';
import '../../repository/objectBox.dart';
import '../../utils/fluenticons/fluenticons.dart';
import '../widgets/song_player_widget.dart';
import 'album_screen.dart';
import 'artist_screen.dart';
import 'create_screen.dart';
import 'details_screen.dart';
import 'home.dart';
import 'welcome_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool volume = true;
  final ValueNotifier<bool> _dragging = ValueNotifier(false);
  final ValueNotifier<bool> _visible = ValueNotifier(false);

  late Future<void> _init;

  @override
  void initState() {
    super.initState();
    _init = Future(() async {
      await ObjectBox.initialize();
      SettingsController.init();
      WorkerController.init();
      DataController.init();
      await AppAudioHandler.init();
      AppManager.init();
      OnlineController.init();

      final apc = AudioPlayerController();
      apc.updateCurrentSong(SettingsController.currentSongPath);
    });
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var normalSize = MediaQuery.of(context).size.height * 0.02;
    // var smallSize = MediaQuery.of(context).size.height * 0.0175;
    var bigSize = MediaQuery.of(context).size.height * 0.0225;
    return FutureBuilder(
        future: _init,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              appBar: PreferredSize(
                preferredSize: Size.fromHeight(MediaQuery
                    .of(context)
                    .size
                    .height * 0.1),
                child: WindowTitleBarBox(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    color: Colors.black.withOpacity(0.896),
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
                                    fontSize: MediaQuery
                                        .of(context)
                                        .size
                                        .height * 0.02,
                                  ),
                                ),
                              ),
                            )
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
                        appWindow.isMaximized ?
                        RestoreWindowButton(
                          animate: true,
                          colors: WindowButtonColors(
                            normal: Colors.transparent,
                            iconNormal: Colors.white,
                            iconMouseOver: Colors.white,
                            mouseOver: Colors.grey,
                            mouseDown: Colors.grey,
                          ),
                        ) :
                        MaximizeWindowButton(
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
                          onPressed: () {
                            if (SettingsController.fullClose) {
                              appWindow.close();
                            }
                            else {
                              appWindow.hide();
                            }
                          },
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
                  ),
                ),
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          return Scaffold(
            appBar: SettingsController.firstTime?
            PreferredSize(
              preferredSize: Size.fromHeight(MediaQuery
                  .of(context)
                  .size
                  .height * 0.1),
              child: WindowTitleBarBox(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  color: Colors.black.withOpacity(0.896),
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
                                  fontSize: MediaQuery
                                      .of(context)
                                      .size
                                      .height * 0.02,
                                ),
                              ),
                            ),
                          )
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
                      appWindow.isMaximized ?
                      RestoreWindowButton(
                        animate: true,
                        colors: WindowButtonColors(
                          normal: Colors.transparent,
                          iconNormal: Colors.white,
                          iconMouseOver: Colors.white,
                          mouseOver: Colors.grey,
                          mouseDown: Colors.grey,
                        ),
                      ) :
                      MaximizeWindowButton(
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
                        onPressed: () {
                          if (SettingsController.fullClose) {
                            appWindow.close();
                          }
                          else {
                            appWindow.hide();
                          }
                        },
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
                ),
              ),
            ) :
            PreferredSize(
              preferredSize: Size.fromHeight(MediaQuery
                  .of(context)
                  .size
                  .height * 0.1),
              child: WindowTitleBarBox(
                child: ValueListenableBuilder(
                  valueListenable: SettingsController.darkColorNotifier,
                  builder: (context, value, child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      color: SettingsController.darkColorNotifier.value,
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
                                      fontSize: MediaQuery
                                          .of(context)
                                          .size
                                          .height * 0.02,
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
                                        height: MediaQuery
                                            .of(context)
                                            .size
                                            .height * 0.05,
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
                                              valueListenable: SettingsController
                                                  .volumeNotifier,
                                              builder: (context, value, child) {
                                                return SliderTheme(
                                                  data: SliderThemeData(
                                                    trackHeight: 2,
                                                    thumbShape: RoundSliderThumbShape(
                                                        enabledThumbRadius: MediaQuery
                                                            .of(context)
                                                            .size
                                                            .height * 0.0075),
                                                  ),
                                                  child: Slider(
                                                    min: 0.0,
                                                    max: 1.0,
                                                    mouseCursor: SystemMouseCursors
                                                        .click,
                                                    value: value,
                                                    activeColor: SettingsController
                                                        .lightColorNotifier.value,
                                                    thumbColor: Colors.white,
                                                    inactiveColor: Colors.white,
                                                    onChanged: (double value) {
                                                      SettingsController.volume =
                                                          value;
                                                      AudioPlayerController
                                                          .audioPlayer.setVolume(
                                                          value);
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
                                          valueListenable: SettingsController
                                              .volumeNotifier,
                                          builder: (context, value, child) {
                                            return IconButton(
                                              icon: volume ? Icon(
                                                FluentIcons.volumeOn,
                                                size: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .height * 0.0175,
                                                color: Colors.white,
                                              ) :
                                              Icon(
                                                FluentIcons.volumeOff,
                                                size: MediaQuery
                                                    .of(context)
                                                    .size
                                                    .height * 0.0175,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                if (volume) {
                                                  SettingsController.volume = 0;
                                                }
                                                else {
                                                  SettingsController.volume = 0.1;
                                                }
                                                volume = !volume;
                                                AudioPlayerController.audioPlayer
                                                    .setVolume(
                                                    SettingsController.volume);
                                              },
                                            );
                                          }
                                      ),
                                    ),
                                  ],
                                ),
                          ),
                          ValueListenableBuilder(
                            valueListenable: OnlineController.loggedInNotifier,
                            builder: (context, value, child) =>
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    debugPrint("Tapped user");
                                    Scaffold.of(context).openEndDrawer();
                                  },
                                  iconAlignment: IconAlignment.end,
                                  label: Text(
                                    value ? SettingsController.email : "Log in",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: MediaQuery
                                          .of(context)
                                          .size
                                          .height * 0.0175,
                                    ),
                                  ),
                                  icon: Icon(
                                    value
                                        ? FluentIcons.circlePersonFilled
                                        : FluentIcons.circlePerson,
                                    size: MediaQuery
                                        .of(context)
                                        .size
                                        .height * 0.02,
                                    color: Colors.white,
                                  ),
                                  style: ButtonStyle(
                                    backgroundColor: WidgetStateProperty.all<Color>(
                                        Colors.transparent),
                                    elevation: WidgetStateProperty.all<double>(0),
                                    padding: WidgetStateProperty.all<
                                        EdgeInsetsGeometry>(EdgeInsets.symmetric(
                                        horizontal: width * 0.01)),
                                  ),
                                ),
                          ),
                          Icon(
                            FluentIcons.divider,
                            size: MediaQuery
                                .of(context)
                                .size
                                .height * 0.02,
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
                          appWindow.isMaximized ?
                          RestoreWindowButton(
                            animate: true,
                            colors: WindowButtonColors(
                              normal: Colors.transparent,
                              iconNormal: Colors.white,
                              iconMouseOver: Colors.white,
                              mouseOver: Colors.grey,
                              mouseDown: Colors.grey,
                            ),
                          ) :
                          MaximizeWindowButton(
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
                            onPressed: () {
                              if (SettingsController.fullClose) {
                                appWindow.close();
                              }
                              else {
                                appWindow.hide();
                              }
                            },
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
            ),
            body: Stack(
              children: [
                HeroControllerScope(
                  controller: MaterialApp.createMaterialHeroController(),
                  child: Navigator(
                    key: AppManager().navigatorKey,
                    initialRoute: SettingsController.firstTime ? '/welcome' : '/home',
                    onGenerateRoute: (settings) {
                      Widget page;
                      page = Scaffold(
                        body: Stack(
                          children: [
                            switch (settings.name) {
                              '/' => const LoadingScreen(),
                              '/home' => const HomeScreen(),
                              '/welcome' => const WelcomeScreen(),
                              '/settings' => const SettingsScreen(),
                              '/user' => const UserScreen(),
                              '/add' => AddScreen(songs: settings.arguments as List<SongType>),
                              '/create' =>
                                  CreateScreen(args: settings.arguments as List<String>),
                              '/export' => const ExportScreen(),
                              '/artist' =>
                                  ArtistScreen(artist: settings.arguments as ArtistType),
                              '/album' => AlbumScreen(album: settings.arguments as AlbumType),
                              '/playlist' =>
                                  PlaylistScreen(playlist: settings.arguments as PlaylistType),
                              '/details' => DetailsScreen(song: settings.arguments as SongType),
                              _ => const LoadingScreen(),
                            },
                            if (settings.name != '/welcome' && settings.name != '/')
                              ValueListenableBuilder(
                                valueListenable: _dragging,
                                builder: (context, value, child) {
                                  return DropTarget(
                                      onDragDone: (detail) async {
                                        List<String> songs = [];
                                        for (final file in detail.files) {
                                          if (file.path.endsWith(".mp3") ||
                                              file.path.endsWith(".wav") ||
                                              file.path.endsWith(".flac") ||
                                              file.path.endsWith(".m4a")) {
                                            songs.add(file.path);
                                          }
                                        }
                                        if (songs.isNotEmpty) {
                                          // widget.controller.finishedRetrievingNotifier.value = false;
                                          for (var song in songs) {
                                            await DataController.getSong(song);
                                          }
                                          final dc = DataController();
                                          dc.updatePlaying(songs, 0);
                                          SettingsController.index =
                                              SettingsController.currentQueue.indexOf(songs[0]);
                                          await AppAudioHandler.play();
                                          // DataController.indexChange(songs[0]);
                                          // await widget.controller.playSong();
                                          //widget.controller.showNotification("Playing ${songs.length} new song${songs.length == 1 ? '' : 's'}. Do you want to add ${songs.length == 1 ? 'it' : 'them'} to your library?", 7500);
                                          final am = AppManager();
                                          am.showNotification(
                                              "Playing ${songs.length} new song${songs.length ==
                                                  1
                                                  ? ''
                                                  : 's'} and adding them to your library",
                                              7500);
                                          //widget.controller.finishedRetrievingNotifier.value = true;
                                        }
                                      },
                                      onDragEntered: (detail) {
                                        _dragging.value = true;
                                      },
                                      onDragExited: (detail) {
                                        _dragging.value = false;
                                      },
                                      child: IgnorePointer(
                                        child: Container(
                                          width: width,
                                          height: MediaQuery
                                              .of(context)
                                              .size
                                              .height,
                                          color: _dragging.value
                                              ? Colors.black.withOpacity(0.3)
                                              : Colors.transparent,
                                          child: _dragging.value ?
                                          Center(
                                            child: Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  FluentIcons.drag,
                                                  size: MediaQuery
                                                      .of(context)
                                                      .size
                                                      .height * 0.1,
                                                  color: Colors.white,
                                                ),
                                                Text(
                                                  "Drop files here",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: normalSize,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ) :
                                          Container(),
                                        ),
                                      )
                                  );
                                },
                              ),
                          ],
                        ),
                      );
                      return MaterialPageRoute(
                        builder: (context) {
                          return page;
                        }
                      );
                    },
                  ),
                ),
                ValueListenableBuilder(
                  valueListenable: SettingsController.firstTimeNotifier,
                  builder: (context, value, child) {
                    return value ? const SizedBox() :
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      alignment: Alignment.bottomCenter,
                      child: const SongPlayerWidget(),
                    );
                  }
                ),

              ],
            ),
            endDrawer: SettingsController.firstTime ? null :
            ValueListenableBuilder(
              valueListenable: SettingsController.darkColorNotifier,
              builder: (context, value, child) {
                return Drawer(
                  width: width * 0.2,
                  backgroundColor: SettingsController.darkColorNotifier.value,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Flexible(
                        child: ListView(
                          children: [
                            ListTile(
                              dense: true,
                              visualDensity: const VisualDensity(vertical: 4),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: width * 0.01,
                                  vertical: MediaQuery.of(context).size.height * 0.025,
                              ),
                              title: Text(
                                OnlineController.loggedInNotifier.value ? SettingsController.email : "Log in",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: bigSize,
                                ),
                              ),
                              subtitle: OnlineController.loggedInNotifier.value ? const Text("Logged in") : null,
                              leading: OnlineController.loggedInNotifier.value ? const Icon(FluentIcons.circlePersonFilled) : const Icon(FluentIcons.circlePerson),
                              trailing: OnlineController.loggedInNotifier.value ? IconButton(
                                icon: const Icon(FluentIcons.back),
                                onPressed: () async {
                                  // await OnlineController().signOut();
                                },
                              ) : null,
                              onTap: () {
                                Navigator.pop(context);
                                AppManager().navigatorKey.currentState!.pushNamed('/user');
                              },
                            ),
                            ListTile(
                              dense: true,
                              title: Text(
                                "Settings",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: normalSize,
                                ),
                              ),
                              leading: Icon(FluentIcons.settings, size: MediaQuery.of(context).size.height * 0.025,),
                              onTap: () {
                                debugPrint("Tapped settings");
                                final am = AppManager();
                                am.minimizedNotifier.value = true;
                                Navigator.pop(context);
                                am.navigatorKey.currentState!.pushNamed('/settings');
                                // Navigator.pushNamed(context, '/settings');
                                // am.minimizedNotifier.value = true;
                                // am.navigatorKey.currentState!.push(MaterialPageRoute(builder: (BuildContext context){
                                //   return const SettingsScreen();
                                // })).then((value) {
                                //   setState(() {
                                //     _init = Future(() async {
                                //       await WorkerController.retrieveAllSongs();
                                //       if (SettingsController.queue.isEmpty) {
                                //         debugPrint("Queue is empty");
                                //         var songs = await DataController.getSongs('');
                                //         SettingsController.queue =
                                //             songs.map((e) => e.path).toList();
                                //         SettingsController.index = 0;
                                //       }
                                //     });
                                //   });
                                // });
                              },
                            ),
                            ListTile(
                              dense: true,
                              title: Text(
                                "Create",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: normalSize,
                                ),
                              ),
                              leading: Icon(FluentIcons.create, size: MediaQuery.of(context).size.height * 0.025,),
                              onTap: () {
                                Navigator.pop(context);
                                AppManager().navigatorKey.currentState!.pushNamed('/create', arguments: [""]);
                              },
                            ),
                            ListTile(
                              dense: true,
                              title: Text(
                                "Export",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: normalSize,
                                ),
                              ),
                              leading: Icon(FluentIcons.export, size: MediaQuery.of(context).size.height * 0.025,),
                              onTap: () {
                                Navigator.pop(context);
                                AppManager().navigatorKey.currentState!.pushNamed('/export');
                              },
                            ),
                            ListTile(
                              dense: true,
                              title: Text(
                                "Contact us",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: normalSize,
                                ),
                              ),
                              leading: Icon(FluentIcons.open, size: MediaQuery.of(context).size.height * 0.025,),
                              onTap: () {

                              },
                            ),
                            ListTile(
                              dense: true,
                              title: Text(
                                "About",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: normalSize,
                                ),
                              ),
                              leading: Icon(FluentIcons.open, size: MediaQuery.of(context).size.height * 0.025,),
                              onTap: () {
                                showAboutDialog(
                                  context: context,
                                  applicationIcon: Image.asset('assets/bg.png', fit: BoxFit.cover, width: width * 0.075, height: width * 0.075,),
                                  applicationName: 'Music Player',
                                  applicationVersion: 'version: 0.0.1',
                                  applicationLegalese: '© 2025 Music Player',
                                  children: [
                                    Text('Music Player is a free and open-source music player for Windows, Linux and Android.'),
                                    Text('Developed by: Darius Sala'),
                                    Text(''),
                                    Text('This software is provided as-is, without any warranty or guarantee of any kind. Use at your own risk.'),
                                  ],
                                );
                              },
                            )
                          ],
                        ),
                      ),
                      const ActionsWidget(),
                    ],
                  ),
                );
              }
            ),

            bottomNavigationBar: SettingsController.firstTime ? null : const NotificationWidget(),
          );
        }
    );
  }
}