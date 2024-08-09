import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/screens/search_widget.dart';
import 'package:musicplayer/screens/song_player_widget.dart';
import 'package:musicplayer/screens/user_message_widget.dart';
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
  final ValueNotifier<bool> _visible = ValueNotifier(false);

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
                            onPressed: () => appWindow.hide(),
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
                            child: !widget.controller.settings.firstTime ? value?
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
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                  SizedBox(
                                    width: width * 0.01,
                                  ),
                                  Text(
                                    "Loading...",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: normalSize,
                                    ),
                                  ),
                                ],
                              ),
                            ) : Container(),
                          );
                        }
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
                                child: SearchWidget(controller: widget.controller),
                              ),
                            ) : Container(
                              key: const Key("Search Off"),
                            ),
                          );
                        }
                    ),
                    ValueListenableBuilder(
                        valueListenable: widget.controller.userMessageNotifier,
                        builder: (context, value, child){
                          return AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: value.isNotEmpty ?
                            SizedBox(
                              key: const Key("User Message Widget"),
                              width: width,
                              height: height,
                              child: UserMessageWidget(controller: widget.controller),
                            ) : Container(
                              key: const Key("User Message Off"),
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
    );
  }
}