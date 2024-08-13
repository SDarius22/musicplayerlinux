import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:musicplayer/screens/create_screen.dart';
import 'package:musicplayer/screens/export_screen.dart';
import 'package:musicplayer/screens/main_screen.dart';
import 'package:musicplayer/screens/user_message_widget.dart';
import '../controller/controller.dart';

class SettingsScreen extends StatefulWidget {
  final Controller controller;
  const SettingsScreen({super.key, required this.controller});
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String dropDownValue = "Off";

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    //var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    return Scaffold(
      body: Container(
        width: width,
        height: height,
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
                top: height * 0.05,
                bottom: height * 0.125,
              ),
              alignment: Alignment.center,
              child: ListView(
                padding: EdgeInsets.only(
                  bottom: height * 0.05,
                  right: width * 0.01,
                ),
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
                      SizedBox(
                        width: width * 0.025,
                      ),
                      const Tooltip(
                        message: 'Changing the directory will clear the current queue and possibly make your playlists unusable.',
                        child: Icon(
                          Icons.warning,
                        ),
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

                  ///Add Order Settings
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Queue Add Order",
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
                      SizedBox(
                        width: width * 0.025,
                      ),
                      const Tooltip(
                        message: 'At the beginning: Add the selected tracks at the beginning of the queue\nAfter Current: Add the selected tracks after the currently playing track\nAt the end: Add the selected tracks at the end of the queue',
                        child: Icon(
                          Icons.info,
                        ),
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

                  ///Play Settings
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Play Settings",
                            style: TextStyle(
                              fontSize: normalSize,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: height * 0.005,
                          ),
                          Text("Choose how you want playing a song to behave", style: TextStyle(
                            fontSize: smallSize,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey.shade50,
                          ),),
                        ],
                      ),
                      SizedBox(
                        width: width * 0.025,
                      ),
                      const Tooltip(
                        message: 'Play All Tracks: Replace the current queue with the playlist of the played track\nPlay Selected Track: Add the selected track to the queue',
                        child: Icon(
                          Icons.info,
                        ),
                      ),
                      const Spacer(),
                      DropdownButton<String>(
                          value: widget.controller.settings.queuePlay,
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
                              value: 'all',
                              child: Text("Play All Tracks"),
                            ),
                            DropdownMenuItem(
                              value: 'selected',
                              child: Text("Play Selected Track"),
                            ),
                          ],
                          onChanged: (String? newValue){
                            setState(() {
                              widget.controller.settings.queuePlay = newValue ?? "all";
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

                  ///Playback Speed
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Playback Speed",
                            style: TextStyle(
                              fontSize: normalSize,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: height * 0.005,
                          ),
                          Text("Set the playback speed to a certain value", style: TextStyle(
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

                  ///Playback Balance
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Playback Balance",
                            style: TextStyle(
                              fontSize: normalSize,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: height * 0.005,
                          ),
                          Text("Set the playback balance to a certain value", style: TextStyle(
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

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Playlist Settings",
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

                  ///Import Playlists
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Import Playlist",
                            style: TextStyle(
                              fontSize: normalSize,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: height * 0.005,
                          ),
                          Text("Import a playlist from your library", style: TextStyle(
                            fontSize: smallSize,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey.shade50,
                          ),),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                          onPressed: () async {
                            FilePickerResult? result = await FilePicker.platform.pickFiles(initialDirectory: widget.controller.settings.directory, type: FileType.custom, allowedExtensions: ['m3u'], allowMultiple: false);
                            if(result != null) {
                              File file = File(result.files.single.path ?? "");
                              List<String> lines = file.readAsLinesSync();
                              String playlistName = file.path.split("/").last.split(".").first;
                              lines.removeAt(0);
                              widget.controller.navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => CreateScreen(controller: widget.controller, name: playlistName, paths: lines,)));
                            }

                          },
                          icon: Icon(FluentIcons.open_12_regular, color: Colors.white, size: height * 0.03,)
                      ),
                    ],
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),

                  ///Export Playlists
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Export Playlists",
                            style: TextStyle(
                              fontSize: normalSize,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: height * 0.005,
                          ),
                          Text("Export playlists to your library", style: TextStyle(
                            fontSize: smallSize,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey.shade50,
                          ),),
                        ],
                      ),
                      const Spacer(),
                      IconButton(
                          onPressed: (){
                            widget.controller.navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => ExportScreen(controller: widget.controller,)));
                          },
                          icon: Icon(FluentIcons.open_12_regular, color: Colors.white, size: height * 0.03,)
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
    );
  }
}