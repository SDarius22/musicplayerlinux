import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:musicplayer/screens/main_screen.dart';
import 'package:musicplayer/screens/user_message_widget.dart';
import '../controller/controller.dart';

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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        "Library Settings",
                                      style: TextStyle(
                                        fontSize: smallSize,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * 0.01,
                                    ),
                                    Container(
                                      height: 1,
                                      color: Colors.grey.shade400,
                                    ),
                                    SizedBox(
                                      height: height * 0.01,
                                    ),
                                  ],
                                ),
                                ///Music Directory
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
                                          borderRadius: BorderRadius.circular(width * 0.01),
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
                                  height: height * 0.02,
                                ),

                                ///Queue Settings
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Queue Settings",
                                          style: TextStyle(
                                            fontSize: normalSize,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(
                                          height: height * 0.005,
                                        ),
                                        Text("Choose where the tracks are added to the queue", style: TextStyle(
                                          fontSize: smallSize,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey.shade50,
                                        ),),
                                      ],
                                    ),
                                    const Spacer(),
                                    DropdownButton<String>(
                                        value: widget.controller.settings.queueAdd,
                                        icon: Icon(
                                          FluentIcons.chevron_down_16_filled,
                                          color: Colors.white,
                                          size: height * 0.025,
                                        ),
                                        style: TextStyle(
                                          fontSize: normalSize,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white,
                                        ),
                                        underline: Container(
                                          height: 0,
                                        ),
                                        borderRadius: BorderRadius.circular(width * 0.01),
                                        padding: EdgeInsets.zero,
                                        alignment: Alignment.center,
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'first',
                                            child: Text("At the beginning"),
                                          ),
                                          DropdownMenuItem(
                                            value: 'next',
                                            child: Text("After Current"),
                                          ),
                                          DropdownMenuItem(
                                            value: 'last',
                                            child: Text("At the end"),
                                          ),
                                        ],
                                        onChanged: (String? newValue){
                                          setState(() {
                                            widget.controller.settings.queueAdd = newValue ?? "last";
                                          });
                                          widget.controller.settingsBox.put(widget.controller.settings);
                                        }
                                    ),



                                  ],
                                ),
                                SizedBox(
                                  height: height * 0.025,
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Playback Settings",
                                      style: TextStyle(
                                        fontSize: smallSize,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * 0.01,
                                    ),
                                    Container(
                                      height: 1,
                                      color: Colors.grey.shade400,
                                    ),
                                    SizedBox(
                                      height: height * 0.01,
                                    ),
                                  ],
                                ),

                                ///Playback Rate
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
                                              activeTrackColor: widget.controller.colorNotifier2.value,
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
                                  height: height * 0.02,
                                ),

                                ///Balance
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
                                              activeTrackColor: widget.controller.colorNotifier2.value,
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
                                  height: height * 0.02,
                                ),

                                ///Timer
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
                                              value: value,
                                              icon: Icon(
                                                FluentIcons.chevron_down_16_filled,
                                                color: Colors.white,
                                                size: height * 0.025,
                                              ),
                                              style: TextStyle(
                                                fontSize: normalSize,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.white,
                                              ),
                                              underline: Container(
                                                height: 0,
                                              ),
                                              borderRadius: BorderRadius.circular(width * 0.01),
                                              padding: EdgeInsets.zero,
                                              alignment: Alignment.center,
                                              items: const [
                                                DropdownMenuItem(
                                                  value: 'Off',
                                                  child: Text("Off"),
                                                ),
                                                DropdownMenuItem(
                                                  value: '1 minute',
                                                  child: Text("1 minute"),
                                                ),
                                                DropdownMenuItem(
                                                  value: '15 minutes',
                                                  child: Text("15 minutes"),
                                                ),
                                                DropdownMenuItem(
                                                  value: '30 minutes',
                                                  child: Text("30 minutes"),
                                                ),
                                                DropdownMenuItem(
                                                  value: '45 minutes',
                                                  child: Text("45 minutes"),
                                                ),
                                                DropdownMenuItem(
                                                  value: '1 hour',
                                                  child: Text("1 hour"),
                                                ),
                                                DropdownMenuItem(
                                                  value: '2 hours',
                                                  child: Text("2 hours"),
                                                ),
                                                DropdownMenuItem(
                                                  value: '3 hours',
                                                  child: Text("3 hours"),
                                                ),
                                                DropdownMenuItem(
                                                  value: '4 hours',
                                                  child: Text("4 hours"),
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
                                  height: height * 0.025,
                                ),

                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Application Settings",
                                      style: TextStyle(
                                        fontSize: smallSize,
                                        fontWeight: FontWeight.normal,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                    SizedBox(
                                      height: height * 0.01,
                                    ),
                                    Container(
                                      height: 1,
                                      color: Colors.grey.shade400,
                                    ),
                                    SizedBox(
                                      height: height * 0.01,
                                    ),
                                  ],
                                ),

                                ///System Tray
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
                                    Switch(
                                      value: widget.controller.settings.showSystemTray,
                                      onChanged: (value){
                                        setState(() {
                                          widget.controller.settings.showSystemTray = value;
                                        });
                                        widget.controller.settingsBox.put(widget.controller.settings);
                                        widget.controller.initSystemTray();
                                      },
                                      trackColor: WidgetStateProperty.all(widget.controller.colorNotifier2.value),
                                      thumbColor: WidgetStateProperty.all(Colors.white),
                                      thumbIcon: WidgetStateProperty.all(widget.controller.settings.showSystemTray ? const Icon(Icons.check, color: Colors.black,) : const Icon(Icons.close, color: Colors.black,)),
                                      activeColor: Colors.white,
                                    ),


                                  ],
                                ),
                                SizedBox(
                                  height: height * 0.02,
                                ),

                                ///In-App Notifications
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "In-App Notifications",
                                          style: TextStyle(
                                            fontSize: normalSize,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(
                                          height: height * 0.005,
                                        ),
                                        Text("Show notifications in the app", style: TextStyle(
                                          fontSize: smallSize,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey.shade50,
                                        ),),
                                      ],
                                    ),
                                    const Spacer(),
                                    Switch(
                                      value: widget.controller.settings.showAppNotifications,
                                      onChanged: (value){
                                        setState(() {
                                          widget.controller.settings.showAppNotifications = value;
                                        });
                                        widget.controller.settingsBox.put(widget.controller.settings);
                                      },
                                      trackColor: WidgetStateProperty.all(widget.controller.colorNotifier2.value),
                                      thumbColor: WidgetStateProperty.all(Colors.white),
                                      thumbIcon: WidgetStateProperty.all(widget.controller.settings.showSystemTray ? const Icon(Icons.check, color: Colors.black,) : const Icon(Icons.close, color: Colors.black,)),
                                      activeColor: Colors.white,
                                    ),


                                  ],
                                ),
                                SizedBox(
                                  height: height * 0.02,
                                ),

                                ///Deezer ARL
                                Row(
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Deezer ARL",
                                          style: TextStyle(
                                            fontSize: normalSize,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(
                                          height: height * 0.005,
                                        ),
                                        Text("Your Deezer ARL token", style: TextStyle(
                                          fontSize: smallSize,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.grey.shade50,
                                        ),),
                                      ],
                                    ),
                                    const Spacer(),
                                    SizedBox(
                                      width: width * 0.3,
                                      child: TextField(
                                        controller: TextEditingController(text: widget.controller.settings.deezerToken),
                                        onChanged: (value){
                                          widget.controller.settings.deezerToken = value;
                                          widget.controller.settingsBox.put(widget.controller.settings);
                                        },
                                        style: TextStyle(
                                          fontSize: normalSize,
                                          fontWeight: FontWeight.normal,
                                          color: Colors.white,
                                        ),
                                        decoration: InputDecoration(
                                          isDense: true,
                                          hintText: "Deezer ARL",
                                          hintStyle: TextStyle(
                                            color: Colors.grey.shade50,
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(width * 0.01),
                                            borderSide: const BorderSide(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          focusedBorder: const OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(
                                  height: height * 0.02,
                                ),

                                ///Possible more settings:
                                ///Crossfade between songs -> not sure if this is possible
                                ///Theme settings - maybe in the future
                                // Row(
                                //   children: [
                                //     Column(
                                //       crossAxisAlignment: CrossAxisAlignment.start,
                                //       mainAxisAlignment: MainAxisAlignment.center,
                                //       children: [
                                //         Text(
                                //           "Theme Settings",
                                //           style: TextStyle(
                                //             fontSize: normalSize,
                                //             fontWeight: FontWeight.normal,
                                //             color: Colors.white,
                                //           ),
                                //         ),
                                //         SizedBox(
                                //           height: height * 0.005,
                                //         ),
                                //         Text("Choose between light and dark theme", style: TextStyle(
                                //           fontSize: smallSize,
                                //           fontWeight: FontWeight.normal,
                                //           color: Colors.grey.shade50,
                                //         ),),
                                //       ],
                                //     ),
                                //     const Spacer(),
                                //     Switch(
                                //       value: widget.controller.settings.theme,
                                //       onChanged: (value){
                                //         setState(() {
                                //           widget.controller.settings.theme = value;
                                //           widget.controller.themeNotifier.value = value;
                                //         });
                                //
                                //         widget.controller.settingsBox.put(widget.controller.settings);
                                //       },
                                //       trackColor: WidgetStateProperty.all(widget.controller.colorNotifier2.value),
                                //       thumbColor: WidgetStateProperty.all(Colors.white),
                                //       thumbIcon: WidgetStateProperty.all(widget.controller.settings.theme ? const Icon(Icons.sunny, color: Colors.black,) : const Icon(Icons.nightlight, color: Colors.black,)),
                                //       activeColor: Colors.white,
                                //     ),
                                //
                                //
                                //   ],
                                // ),
                                // SizedBox(
                                //   height: height * 0.01,
                                // ),
                                // Container(
                                //   height: 1,
                                //   color: Colors.grey.shade600,
                                // ),
                                // SizedBox(
                                //   height: height * 0.01,
                                // ),
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