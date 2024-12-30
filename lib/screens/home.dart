import 'dart:ui';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/controller/worker_controller.dart';
import 'package:musicplayer/screens/settings_screen.dart';
import 'package:musicplayer/screens/song_player_widget.dart';
import 'package:musicplayer/screens/user_screen.dart';
import 'package:provider/provider.dart';
import '../controller/app_manager.dart';
import '../controller/audio_player_controller.dart';
import '../controller/data_controller.dart';
import '../controller/online_controller.dart';
import '../controller/settings_controller.dart';
import 'albums.dart';
import 'artists.dart';
import 'download_screen.dart';
import 'notification_widget.dart';
import 'tracks.dart';
import 'playlists.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  bool volume = true;

  int currentPage = 3;
  String userMessage = "No message";
  final PageController _pageController = PageController(initialPage: 5);

  final ValueNotifier<bool> _dragging = ValueNotifier(false);
  final ValueNotifier<bool> _visible = ValueNotifier(false);

  late Future<void> _init;

  @override
  void initState() {
    super.initState();
    _init = Future(() async {
      await WorkerController.retrieveAllSongs();
      if (SettingsController.queue.isEmpty){
        print("Queue is empty");
        var songs = await DataController.getSongs('');
        SettingsController.queue = songs.map((e) => e.path).toList();
        int newIndex = 0;
        SettingsController.index = newIndex;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    final dc = Provider.of<DataController>(context);
    final am = Provider.of<AppManager>(context);
    final apc = Provider.of<AudioPlayerController>(context);
    final oc = Provider.of<OnlineController>(context);

    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    var smallSize = height * 0.0175;

    return Scaffold(
      body: SizedBox(
          width: width,
          height: height,
          child: Column(
            children: [
              WindowTitleBarBox(
                child: ValueListenableBuilder(
                  valueListenable: SettingsController.darkColorNotifier,
                  builder: (context, value, child){
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
                                              valueListenable: SettingsController.volumeNotifier,
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
                                                    activeColor: SettingsController.lightColorNotifier.value,
                                                    thumbColor: Colors.white,
                                                    inactiveColor: Colors.white,
                                                    onChanged: (double value) {
                                                      SettingsController.volume = value;
                                                      AudioPlayerController.audioPlayer.setVolume(value);
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
                                          valueListenable: SettingsController.volumeNotifier,
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
                                                  SettingsController.volume = 0;
                                                }
                                                else {
                                                  SettingsController.volume = 0.1;
                                                }
                                                volume = !volume;
                                                AudioPlayerController.audioPlayer.setVolume(SettingsController.volume);
                                              },
                                            );
                                          }
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: (){
                                          print("Tapped settings");
                                          am.minimizedNotifier.value = true;
                                          am.navigatorKey.currentState!.push(MaterialPageRoute(builder: (BuildContext context){
                                            return const SettingsScreen();
                                          })).then((value) {
                                            setState(() {
                                              _init = Future(() async {
                                                await WorkerController.retrieveAllSongs();
                                                if (SettingsController.queue.isEmpty) {
                                                  print("Queue is empty");
                                                  var songs = await DataController.getSongs('');
                                                  SettingsController.queue =
                                                      songs.map((e) => e.path).toList();
                                                  SettingsController.index = 0;
                                                }
                                              });
                                            });
                                          });;
                                        },
                                        icon: Icon(
                                          FluentIcons.settings_16_filled,
                                          size: height * 0.02,
                                          color: Colors.white,
                                        )
                                    ),
                                    ValueListenableBuilder(
                                      valueListenable: oc.loggedInNotifier,
                                      builder: (context, value, child) =>
                                          ElevatedButton.icon(
                                            onPressed: () async {
                                              print("Tapped user");
                                              am.minimizedNotifier.value = true;
                                                am.navigatorKey.currentState!.push(
                                                    MaterialPageRoute(
                                                        builder: (BuildContext context) {
                                                          return const UserScreen();
                                                        }));
                                            },
                                            iconAlignment: IconAlignment.end,
                                            label: Text(
                                              value ? SettingsController.email : "Log in",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: smallSize,
                                              ),
                                            ),
                                            icon: Icon(
                                              value ? FluentIcons.person_24_filled : FluentIcons.person_24_regular,
                                              size: height * 0.02,
                                              color: Colors.white,
                                            ),
                                            style: ButtonStyle(
                                              backgroundColor: WidgetStateProperty.all<Color>(Colors.transparent),
                                              elevation: WidgetStateProperty.all<double>(0),
                                              padding: WidgetStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.symmetric(horizontal: width * 0.01)),
                                            ),
                                          ),
                                    ),


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
                            onPressed: (){
                              if(SettingsController.fullClose){
                                appWindow.close();
                              }
                              else{
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
              Expanded(
                child: Stack(
                  children: [
                    HeroControllerScope(
                      controller: MaterialApp.createMaterialHeroController(),
                      child: Navigator(
                        key: am.navigatorKey,
                        onGenerateRoute: (settings) {
                          return MaterialPageRoute(
                            builder: (context) => FutureBuilder(
                                future: _init,
                                builder: (context, snapshot){
                                  return snapshot.connectionState == ConnectionState.done ?
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      // artists, albums, playlists, tracks
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Expanded(
                                              child: SizedBox(
                                                  height: height * 0.05,
                                                  child: ElevatedButton(
                                                      onPressed: (){
                                                        //print("Artists");
                                                        _pageController.animateToPage(0,
                                                            duration: const Duration(milliseconds: 500),
                                                            curve: Curves.easeIn
                                                        );
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: currentPage != 0 ? const Color(0xFF0E0E0E) : const Color(0xFF1b1b1b),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(0),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        "Artists",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: currentPage != 0 ? normalSize : boldSize,
                                                        ),
                                                      )
                                                  )
                                              )
                                          ),
                                          Expanded(
                                              child: SizedBox(
                                                  height: height * 0.05,
                                                  child: ElevatedButton(
                                                      onPressed: (){
                                                        //print("Artists");
                                                        _pageController.animateToPage(1,
                                                            duration: const Duration(milliseconds: 500),
                                                            curve: Curves.easeIn
                                                        );
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: currentPage != 1 ? const Color(0xFF0E0E0E) : const Color(0xFF1b1b1b),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(0),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        "Albums",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: currentPage != 1 ? normalSize : boldSize,
                                                        ),
                                                      )
                                                  )
                                              )
                                          ),
                                          Expanded(
                                              child: SizedBox(
                                                  height: height * 0.05,
                                                  child: ElevatedButton(
                                                      onPressed: (){
                                                        //print("Artists");
                                                        _pageController.animateToPage(2,
                                                            duration: const Duration(milliseconds: 500),
                                                            curve: Curves.easeIn
                                                        );
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: currentPage != 2 ? const Color(0xFF0E0E0E) : const Color(0xFF1b1b1b),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(0),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        "Download",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: currentPage != 2 ? normalSize : boldSize,
                                                        ),
                                                      )
                                                  )
                                              )
                                          ),
                                          Expanded(
                                              child: SizedBox(
                                                  height: height * 0.05,
                                                  child: ElevatedButton(
                                                      onPressed: (){
                                                        //print("Artists");
                                                        _pageController.animateToPage(3,
                                                            duration: const Duration(milliseconds: 500),
                                                            curve: Curves.easeIn
                                                        );
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: currentPage != 3 ? const Color(0xFF0E0E0E) : const Color(0xFF1b1b1b),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(0),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        "Playlists",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: currentPage != 3 ? normalSize : boldSize,
                                                        ),
                                                      )
                                                  )
                                              )
                                          ),
                                          Expanded(
                                              child: SizedBox(
                                                  height: height * 0.05,
                                                  child: ElevatedButton(
                                                      onPressed: (){
                                                        //print("Artists");
                                                        _pageController.animateToPage(4,
                                                            duration: const Duration(milliseconds: 500),
                                                            curve: Curves.easeIn
                                                        );
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: currentPage != 4 ? const Color(0xFF0E0E0E) : const Color(0xFF1b1b1b),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(0),
                                                        ),
                                                      ),
                                                      child: Text(
                                                        "Tracks",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: currentPage != 4 ? normalSize : boldSize,
                                                        ),
                                                      )
                                                  )
                                              )
                                          ),
                                        ],
                                      ),
                                      // current page
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              top: height * 0.02,
                                              left: width * 0.01,
                                              right: width * 0.01,
                                              bottom: height * 0.02
                                          ),
                                          child: PageView(
                                            onPageChanged: (int index){
                                              setState(() {
                                                currentPage = index;
                                              });
                                            },
                                            controller: _pageController,
                                            scrollDirection: Axis.horizontal,
                                            scrollBehavior: ScrollConfiguration.of(context).copyWith(
                                              dragDevices: {
                                                PointerDeviceKind.touch,
                                                PointerDeviceKind.mouse,
                                              },
                                            ),
                                            physics: const AlwaysScrollableScrollPhysics(),
                                            children: const [
                                              Artists(),
                                              Albums(),
                                              Download(),
                                              Playlists(),
                                              Tracks(),
                                            ],

                                          ),
                                        ),
                                      ),
                                    ],
                                  ) :
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                            )
                          );
                        },
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      alignment: Alignment.bottomCenter,
                      child: const SongPlayerWidget(),
                    ),
                    ValueListenableBuilder(
                      valueListenable: _dragging,
                      builder: (context, value, child){
                        return DropTarget(
                            onDragDone: (detail) async {
                              List<String> songs = [];
                              for (final file in detail.files) {
                                if (file.path.endsWith(".mp3") || file.path.endsWith(".wav") || file.path.endsWith(".flac") || file.path.endsWith(".m4a")) {
                                  songs.add(file.path);
                                }
                              }
                              if(songs.isNotEmpty) {
                                // widget.controller.finishedRetrievingNotifier.value = false;
                                // for(var song in songs){
                                //   await widget.controller.getSong(song);
                                // }
                                dc.updatePlaying(songs, 0);
                                // DataController.indexChange(songs[0]);
                                // await widget.controller.playSong();
                                //widget.controller.showNotification("Playing ${songs.length} new song${songs.length == 1 ? '' : 's'}. Do you want to add ${songs.length == 1 ? 'it' : 'them'} to your library?", 7500);
                                am.showNotification("Playing ${songs.length} new song${songs.length == 1 ? '' : 's'} and adding them to your library", 7500);
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
                                height: height,
                                color: _dragging.value ? Colors.black.withOpacity(0.3) : Colors.transparent,
                                child: _dragging.value ?
                                Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        FluentIcons.drag_20_regular,
                                        size: height * 0.1,
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
              ),
            ],
          )
      ),
      bottomNavigationBar: const NotificationWidget(),
    );
  }
}


