import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/screens/search_widget.dart';
import 'package:musicplayer/screens/song_player_widget.dart';
import '../controller/controller.dart';
import 'settings_screen.dart';
import 'home.dart';
import 'welcome_screen.dart';

class MyApp extends StatefulWidget {
  final Controller controller;
  const MyApp({super.key, required this.controller});
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>{
  bool volume = true;
  final ValueNotifier<bool> _dragging = ValueNotifier(false);
  final ValueNotifier<bool> _visible = ValueNotifier(false);

  @override
  void initState(){
    super.initState();
    widget.controller.finishedRetrievingNotifier.addListener(() {
      setState(() {

      });
    });
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
      body: SizedBox(
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
                                    IconButton(
                                      onPressed: (){
                                        print("Search");
                                        widget.controller.searchNotifier.value = !widget.controller.searchNotifier.value;
                                        widget.controller.downloadNotifier.value = false;
                                      },
                                      icon: Icon(
                                        FluentIcons.search_16_filled,
                                        size: height * 0.02,
                                        color: Colors.white,
                                      )
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        print("Download");
                                        widget.controller.downloadNotifier.value = !widget.controller.downloadNotifier.value;
                                        widget.controller.searchNotifier.value = false;
                                      },
                                      icon: Icon(
                                        FluentIcons.arrow_download_16_filled,
                                        size: height * 0.02,
                                        color: Colors.white,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: (){
                                        print("Tapped settings");
                                        widget.controller.navigatorKey.currentState!.push(MaterialPageRoute(builder: (BuildContext context){
                                          return SettingsScreen(controller: widget.controller,);
                                        }));
                                      },
                                      icon: Icon(
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
                              if(widget.controller.settings.fullClose){
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
                        key: widget.controller.navigatorKey,
                        onGenerateRoute: (settings) {
                          return MaterialPageRoute(
                            builder: (context) => finalWidget,
                          );
                        },
                      ),
                    ),
                    if(!widget.controller.settings.firstTime)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        alignment: Alignment.bottomCenter,
                        child: SongPlayerWidget(controller: widget.controller),
                      ),
                    ValueListenableBuilder(
                        valueListenable: widget.controller.searchNotifier,
                        builder: (context, value, child){
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: value ? GestureDetector(
                              key: const Key("Search Widget"),
                              onTap: (){
                                widget.controller.searchNotifier.value = false;
                              },
                              child: Container(
                                width: width,
                                height: height,
                                color: Colors.black.withOpacity(0.3),
                                child: SearchWidget(controller: widget.controller, download: false,),
                              ),
                            ) : Container(
                              key: const Key("Search Off"),
                            ),
                          );
                        }
                    ),
                    ValueListenableBuilder(
                        valueListenable: widget.controller.downloadNotifier,
                        builder: (context, value, child){
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: value ? GestureDetector(
                              key: const Key("Search Widget"),
                              onTap: (){
                                widget.controller.downloadNotifier.value = false;
                              },
                              child: Container(
                                width: width,
                                height: height,
                                color: Colors.black.withOpacity(0.3),
                                child: SearchWidget(controller: widget.controller, download: true),
                              ),
                            ) : Container(
                              key: const Key("Search Off"),
                            ),
                          );
                        }
                    ),
                    // ValueListenableBuilder(
                    //     valueListenable: widget.controller.userMessageNotifier,
                    //     builder: (context, value, child){
                    //       return AnimatedSwitcher(
                    //         duration: const Duration(milliseconds: 500),
                    //         child: value.isNotEmpty ?
                    //         AnimatedContainer(
                    //           duration: const Duration(milliseconds: 500),
                    //           key: const Key("User Message Widget"),
                    //           alignment: Alignment.topCenter,
                    //           child: NotificationWidget(controller: widget.controller),
                    //         ) : Container(
                    //           key: const Key("User Message Off"),
                    //         ),
                    //       );
                    //     }
                    // ),
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
                              widget.controller.finishedRetrievingNotifier.value = false;
                              for(var song in songs){
                                await widget.controller.getSong(song);
                              }
                              widget.controller.updatePlaying(songs, 0);
                              widget.controller.indexChange(songs[0]);
                              await widget.controller.playSong();
                              //widget.controller.showNotification("Playing ${songs.length} new song${songs.length == 1 ? '' : 's'}. Do you want to add ${songs.length == 1 ? 'it' : 'them'} to your library?", 7500);
                              widget.controller.showNotification("Playing ${songs.length} new song${songs.length == 1 ? '' : 's'} and adding them to your library", 7500);
                              widget.controller.finishedRetrievingNotifier.value = true;

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
    );
  }
}