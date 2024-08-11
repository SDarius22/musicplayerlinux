import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:musicplayer/screens/main_screen.dart';
import 'package:musicplayer/screens/user_message_widget.dart';
import '../controller/controller.dart';
import 'home.dart';


class Settings extends StatefulWidget {
  final Controller controller;
  const Settings({super.key, required this.controller});
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String dropDownValue = "Off";

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    //var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;
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
                  Container(
                      padding: EdgeInsets.only(
                          top: height * 0.02,
                          left: width * 0.01,
                          right: width * 0.01,
                          bottom: height * 0.02
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: (){
                              print("Back");
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              FluentIcons.arrow_left_16_filled,
                              size: height * 0.02,
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            width: width * 0.85,
                            padding: EdgeInsets.only(
                              top: height * 0.1,
                              bottom: height * 0.05,
                            ),
                            alignment: Alignment.center,
                            child: ListView(
                              children: [
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Music Directory",
                                          style: TextStyle(
                                            fontSize: normalSize,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(
                                          height: height * 0.005,
                                        ),
                                        Text("Select the directory where your music is stored", style: TextStyle(
                                          fontSize: smallSize,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey.shade50,
                                        ),),
                                      ],
                                    ),
                                    const Spacer(),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.white, backgroundColor: Colors.grey.shade900,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10.0),
                                        ),
                                      ),
                                      onPressed: () async {
                                        String directory = await FilePicker.platform.getDirectoryPath() ?? "";
                                        if(directory != "") {
                                          setState(() {
                                            widget.controller.settings.directory = directory;
                                          });
                                          widget.controller.settings.playingSongsUnShuffled.clear();
                                          widget.controller.settings.playingSongs.clear();
                                          widget.controller.settings.lastPlayingIndex = 0;
                                          widget.controller.settingsBox.put(widget.controller.settings);
                                          widget.controller.songBox.removeAll();
                                          widget.controller.albumBox.removeAll();
                                          widget.controller.artistBox.removeAll();

                                          widget.controller.finishedRetrievingNotifier.value = false;
                                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyApp(controller: widget.controller,)));

                                        }
                                      },
                                      child: Text(
                                        widget.controller.settings.directory.length <= 40 ? widget.controller.settings.directory : "${widget.controller.settings.directory.substring(0, 40)}...",
                                        style: TextStyle(
                                          fontSize: normalSize,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: height * 0.01,
                                ),
                                Container(
                                  height: 1,
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(
                                  height: height * 0.01,
                                ),

                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Playback Rate",
                                          style: TextStyle(
                                            fontSize: normalSize,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(
                                          height: height * 0.005,
                                        ),
                                        Text("Set the playback rate to a certain value", style: TextStyle(
                                          fontSize: smallSize,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey.shade50,
                                        ),),
                                      ],
                                    ),
                                    const Spacer(),
                                    ValueListenableBuilder(
                                        valueListenable: widget.controller.speedNotifier,
                                        builder: (context, value, child){
                                          return SliderTheme(
                                            data: SliderThemeData(
                                              trackHeight: 2,
                                              thumbColor: Colors.white,
                                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: height * 0.0075),
                                              showValueIndicator: ShowValueIndicator.always,
                                              activeTrackColor: widget.controller.colorNotifier.value,
                                              inactiveTrackColor: Colors.white,
                                              valueIndicatorColor: Colors.white,
                                              valueIndicatorTextStyle: TextStyle(
                                                fontSize: smallSize,
                                                color: Colors.black,
                                              ),
                                              valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                                            ),
                                            child: Slider(
                                              min: 0.0,
                                              max: 2.0,
                                              divisions: 20,
                                              label: value.toStringAsPrecision(2),
                                              mouseCursor: SystemMouseCursors.click,
                                              value: value,
                                              onChanged: (double value) {
                                                widget.controller.speedNotifier.value = value;
                                                widget.controller.audioPlayer.setPlaybackRate(value);
                                              },
                                            ),
                                          );
                                        }
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: height * 0.01,
                                ),
                                Container(
                                  height: 1,
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(
                                  height: height * 0.01,
                                ),

                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Balance",
                                          style: TextStyle(
                                            fontSize: normalSize,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(
                                          height: height * 0.005,
                                        ),
                                        Text("Set the balance to a certain value", style: TextStyle(
                                          fontSize: smallSize,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey.shade50,
                                        ),),
                                      ],
                                    ),
                                    const Spacer(),
                                    ValueListenableBuilder(
                                        valueListenable: widget.controller.balanceNotifier,
                                        builder: (context, value, child){
                                          return SliderTheme(
                                            data: SliderThemeData(
                                              trackHeight: 2,
                                              thumbColor: Colors.white,
                                              thumbShape: RoundSliderThumbShape(enabledThumbRadius: height * 0.0075),
                                              showValueIndicator: ShowValueIndicator.always,
                                              activeTrackColor: widget.controller.colorNotifier.value,
                                              inactiveTrackColor: Colors.white,
                                              valueIndicatorColor: Colors.white,
                                              valueIndicatorTextStyle: TextStyle(
                                                fontSize: smallSize,
                                                color: Colors.black,
                                              ),
                                              valueIndicatorShape: const PaddleSliderValueIndicatorShape(),
                                            ),
                                            child: Slider(
                                              min: -1.0,
                                              max: 1.0,
                                              divisions: 10,
                                              mouseCursor: SystemMouseCursors.click,
                                              value: value,
                                              label: value < 0 ? "Left : ${value.toStringAsPrecision(2)}" : value > 0 ? "Right : ${value.toStringAsPrecision(2)}" : "Center",
                                              onChanged: (double value) {
                                                widget.controller.balanceNotifier.value = value;
                                                widget.controller.audioPlayer.setBalance(value);
                                              },
                                            ),
                                          );
                                        }
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: height * 0.01,
                                ),
                                Container(
                                  height: 1,
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(
                                  height: height * 0.01,
                                ),

                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Timer",
                                          style: TextStyle(
                                            fontSize: normalSize,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(
                                          height: height * 0.005,
                                        ),
                                        Text("Set a timer to stop playback after a certain amount of time", style: TextStyle(
                                          fontSize: smallSize,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey.shade50,
                                        ),),
                                      ],
                                    ),
                                    const Spacer(),
                                    ValueListenableBuilder(
                                        valueListenable: widget.controller.timerNotifier,
                                        builder: (context, value, child){
                                          return DropdownButton<String>(
                                            ///TODO: Style
                                              value: value,
                                              icon: Icon(FluentIcons.chevron_down_16_regular),
                                              items: [
                                                DropdownMenuItem(
                                                  child: Text("Off"),
                                                  value: 'Off',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("1 minute"),
                                                  value: '1 minute',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("15 minutes"),
                                                  value: '15 minutes',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("30 minutes"),
                                                  value: '30 minutes',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("45 minutes"),
                                                  value: '45 minutes',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("1 hour"),
                                                  value: '1 hour',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("2 hours"),
                                                  value: '2 hours',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("3 hours"),
                                                  value: '3 hours',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("4 hours"),
                                                  value: '4 hours',
                                                ),
                                              ],
                                              onChanged: (String? newValue){
                                                widget.controller.setTimer(newValue ?? "Off");
                                              }
                                          );
                                        }
                                    ),

                                  ],
                                ),
                                SizedBox(
                                  height: height * 0.01,
                                ),
                                Container(
                                  height: 1,
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(
                                  height: height * 0.01,
                                ),

                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "System Tray",
                                          style: TextStyle(
                                            fontSize: normalSize,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(
                                          height: height * 0.005,
                                        ),
                                        Text("Show the app in the system tray", style: TextStyle(
                                          fontSize: smallSize,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey.shade50,
                                        ),),
                                      ],
                                    ),
                                    const Spacer(),
                                    ValueListenableBuilder(
                                        valueListenable: widget.controller.timerNotifier,
                                        builder: (context, value, child){
                                          return DropdownButton<String>(
                                            ///TODO: Style
                                              value: value,
                                              icon: Icon(FluentIcons.chevron_down_16_regular),
                                              items: [
                                                DropdownMenuItem(
                                                  child: Text("Off"),
                                                  value: 'Off',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("1 minute"),
                                                  value: '1 minute',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("15 minutes"),
                                                  value: '15 minutes',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("30 minutes"),
                                                  value: '30 minutes',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("45 minutes"),
                                                  value: '45 minutes',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("1 hour"),
                                                  value: '1 hour',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("2 hours"),
                                                  value: '2 hours',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("3 hours"),
                                                  value: '3 hours',
                                                ),
                                                DropdownMenuItem(
                                                  child: Text("4 hours"),
                                                  value: '4 hours',
                                                ),
                                              ],
                                              onChanged: (String? newValue){
                                                widget.controller.setTimer(newValue ?? "Off");
                                              }
                                          );
                                        }
                                    ),

                                  ],
                                ),
                                SizedBox(
                                  height: height * 0.01,
                                ),
                                Container(
                                  height: 1,
                                  color: Colors.grey.shade600,
                                ),
                                SizedBox(
                                  height: height * 0.01,
                                ),


                                ///Possible more settings:
                                ///Crossfade between songs -> not sure if this is possible
                                ///System Tray on or off
                                ///Show notifications on or off
                                ///Change deezer arl
                                ///queue settings - play all tracks or just selected, choose where the track is added to the queue
                                ///playlist settings - choose where the tracks are added
                                ///theme settings - light or dark -> to be decided

                              ],
                            ),
                          ),
                          SizedBox(
                            width: width * 0.02,
                          ),
                        ],
                      )
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

              )
            ),

          ],
        ),
      ),
    );
  }
}