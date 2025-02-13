import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/controller/app_manager.dart';
import 'package:musicplayer/controller/online_controller.dart';
import 'package:musicplayer/domain/song_type.dart';
import 'package:musicplayer/interface/screens/add_screen.dart';
import 'package:musicplayer/interface/screens/artists.dart';
import 'package:musicplayer/interface/screens/download_screen.dart';
import 'package:musicplayer/interface/screens/export_screen.dart';
import 'package:musicplayer/interface/screens/loading_screen.dart';
import 'package:musicplayer/interface/screens/playlist_screen.dart';
import 'package:musicplayer/interface/screens/playlists.dart';
import 'package:musicplayer/interface/screens/settings_screen.dart';
import 'package:musicplayer/interface/screens/tracks.dart';
import 'package:musicplayer/interface/screens/user_screen.dart';
import 'package:musicplayer/interface/widgets/drawer_widget.dart';
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
import 'albums.dart';
import 'artist_screen.dart';
import 'create_screen.dart';
import 'details_screen.dart';
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
    // var bigSize = MediaQuery.of(context).size.height * 0.0225;
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
                Row(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: SettingsController.firstTimeNotifier,
                      builder: (context, value, child) {
                        return value ? const SizedBox() : const DrawerWidget();
                      },
                    ),
                    Expanded(
                      child: HeroControllerScope(
                        controller: MaterialApp.createMaterialHeroController(),
                        child: Navigator(
                          key: AppManager().navigatorKey,
                          initialRoute: '/',
                          onGenerateRoute: (settings) {
                            Widget page;
                            page = Scaffold(
                              body: switch (settings.name) {
                                '/' => const LoadingScreen(),
                                '/welcome' => const WelcomeScreen(),
                                '/settings' => const SettingsScreen(),
                                '/user' => const UserScreen(),
                                '/add' => AddScreen(songs: settings.arguments as List<SongType>),
                                '/create' =>
                                    CreateScreen(args: settings.arguments as List<String>),
                                '/export' => const ExportScreen(),
                                '/artist' =>
                                    ArtistScreen(artist: settings.arguments as ArtistType),
                                '/artists' => const Artists(),
                                '/album' => AlbumScreen(album: settings.arguments as AlbumType),
                                '/albums' => const Albums(),
                                '/downloads' => const Download(),
                                '/playlist' =>
                                    PlaylistScreen(playlist: settings.arguments as PlaylistType),
                                '/playlists' => const Playlists(),
                                '/track' => TrackScreen(song: settings.arguments as SongType),
                                '/tracks' => const Tracks(),
                                _ => const LoadingScreen(),
                              },
                            );
                            return MaterialPageRoute(
                                builder: (context) {
                                  return page;
                                }
                            );
                          },
                        ),
                      ),
                    ),

                  ],
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
                ValueListenableBuilder(
                    valueListenable: SettingsController.firstTimeNotifier,
                    builder: (context, value, child) {
                      return value ? const SizedBox() : ValueListenableBuilder(
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
                      );
                    }
                ),

              ],
            ),
            // drawer: SettingsController.firstTime ? null : const DrawerWidget(),
            bottomNavigationBar: SettingsController.firstTime ? null : const NotificationWidget(),
          );
        }
    );
  }
}