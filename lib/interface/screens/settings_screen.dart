import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
import 'package:musicplayer/controller/data_controller.dart';
import 'package:musicplayer/interface/screens/create_screen.dart';
import 'package:musicplayer/interface/screens/export_screen.dart';
import 'package:musicplayer/controller/settings_controller.dart';
import 'package:musicplayer/interface/screens/home.dart';

import '../../controller/app_manager.dart';
import '../../controller/audio_player_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String dropDownValue = "Off";

  @override
  Widget build(BuildContext context) {
    final am = AppManager();
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
                debugPrint("Back");
                Navigator.pop(context);
              },
              icon: Icon(
                FluentIcons.back,
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
                             SettingsController.directory = directory;
                            });
                            SettingsController.queue = [];
                            SettingsController.index = 0;
                            DataController.reset();
                            am.navigatorKey.currentState!.pop(MaterialPageRoute(builder: (context) => const HomePage()));
                            // SettingsController.settingsBox.put(SettingsController.settings);
                            // SettingsController.reset();
                          }
                        },
                        child: Text(
                          SettingsController.directory.length <= 40 ? SettingsController.directory : "${SettingsController.directory.substring(0, 40)}...",
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
                          value: SettingsController.queueAdd,
                          icon: Icon(
                            FluentIcons.down,
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
                             SettingsController.queueAdd = newValue ?? "last";
                            });
                            // SettingsController.settingsBox.put(SettingsController.settings);
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
                          value: SettingsController.queuePlay,
                          icon: Icon(
                            FluentIcons.down,
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
                             SettingsController.queuePlay = newValue ?? "all";
                            });
                            // SettingsController.settingsBox.put(SettingsController.settings);
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
                          valueListenable: SettingsController.speedNotifier,
                          builder: (context, value, child){
                            return SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 2,
                                thumbColor: Colors.white,
                                thumbShape: RoundSliderThumbShape(enabledThumbRadius: height * 0.0075),
                                showValueIndicator: ShowValueIndicator.always,
                                activeTrackColor: SettingsController.lightColorNotifier.value,
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
                                label: "${value.toStringAsPrecision(2)}x",
                                mouseCursor: SystemMouseCursors.click,
                                value: value,
                                onChanged: (double value) {
                                  SettingsController.speedNotifier.value = value;
                                  AudioPlayerController.audioPlayer.setPlaybackRate(value);
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
                          valueListenable: SettingsController.balanceNotifier,
                          builder: (context, value, child){
                            return SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 2,
                                thumbColor: Colors.white,
                                thumbShape: RoundSliderThumbShape(enabledThumbRadius: height * 0.0075),
                                showValueIndicator: ShowValueIndicator.always,
                                activeTrackColor: SettingsController.lightColorNotifier.value,
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
                                  SettingsController.balanceNotifier.value = value;
                                  AudioPlayerController.audioPlayer.setBalance(value);
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
                          valueListenable: SettingsController.sleepTimerNotifier,
                          builder: (context, value, child){
                            String timer = value == 0 ? "Off" : value == 1 ? "1 minute" : value == 15 ? "15 minutes" : value == 30 ? "30 minutes" : value == 45 ? "45 minutes" : value == 60 ? "1 hour" : value == 120 ? "2 hours" : value == 180 ? "3 hours" : "4 hours";
                            return DropdownButton<String>(
                                value: timer,
                                icon: Icon(
                                  FluentIcons.down,
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
                                  final apc = AudioPlayerController();
                                  apc.setTimer(newValue ?? "Off");
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
                        value: SettingsController.systemTray,
                        onChanged: (value){
                          setState(() {
                            SettingsController.systemTray = value;
                          });
                        },
                        trackColor: WidgetStateProperty.all(SettingsController.lightColorNotifier.value),
                        thumbColor: WidgetStateProperty.all(Colors.white),
                        thumbIcon: WidgetStateProperty.all(SettingsController.systemTray ? const Icon(Icons.check, color: Colors.black,) : const Icon(Icons.close, color: Colors.black,)),
                        activeColor: Colors.white,
                      ),


                    ],
                  ),
                  SizedBox(
                    height: height * 0.02,
                  ),

                  ///Close to System Tray
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Close To System Tray",
                            style: TextStyle(
                              fontSize: normalSize,
                              fontWeight: FontWeight.normal,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: height * 0.005,
                          ),
                          Text("Choose whether the app should close to the system tray", style: TextStyle(
                            fontSize: smallSize,
                            fontWeight: FontWeight.normal,
                            color: Colors.grey.shade50,
                          ),),
                        ],
                      ),
                      const Spacer(),
                      Switch(
                        value: !SettingsController.fullClose,
                        onChanged: (value){
                          setState(() {
                            SettingsController.fullClose = !value;
                          });
                          //
                          // final snackBar = SnackBar(
                          //   behavior: SnackBarBehavior.floating,
                          //   margin: EdgeInsets.only(
                          //     bottom: height * 0.9,
                          //     left: width * 0.05,
                          //     right: width * 0.05,
                          //   ),
                          //   content: const Text('Yay! A SnackBar!'),
                          //   action: SnackBarAction(
                          //     label: 'Undo',
                          //     onPressed: () {
                          //       // Some code to undo the change.
                          //     },
                          //   ),
                          // );
                          //
                          // // Find the ScaffoldMessenger in the widget tree
                          // // and use it to show a SnackBar.
                          // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        trackColor: WidgetStateProperty.all(SettingsController.lightColorNotifier.value),
                        thumbColor: WidgetStateProperty.all(Colors.white),
                        thumbIcon: WidgetStateProperty.all(!SettingsController.fullClose ? const Icon(Icons.check, color: Colors.black,) : const Icon(Icons.close, color: Colors.black,)),
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
                        value: SettingsController.appNotifications,
                        onChanged: (value){
                          setState(() {
                            SettingsController.appNotifications = value;
                          });
                        },
                        trackColor: WidgetStateProperty.all(SettingsController.lightColorNotifier.value),
                        thumbColor: WidgetStateProperty.all(Colors.white),
                        thumbIcon: WidgetStateProperty.all(SettingsController.appNotifications ? const Icon(Icons.check, color: Colors.black,) : const Icon(Icons.close, color: Colors.black,)),
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
                          controller: TextEditingController(text: SettingsController.deezerARL),
                          onChanged: (value){
                            SettingsController.deezerARL = value;
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
                            FilePickerResult? result = await FilePicker.platform.pickFiles(initialDirectory: SettingsController.directory, type: FileType.custom, allowedExtensions: ['m3u'], allowMultiple: false);
                            if(result != null) {
                              File file = File(result.files.single.path ?? "");
                              List<String> lines = file.readAsLinesSync();
                              String playlistName = file.path.split("/").last.split(".").first;
                              lines.removeAt(0);
                              for (int i = 0; i < lines.length; i++) {
                                lines[i] = lines[i].split("/").last;
                              }
                              am.navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => CreateScreen(name: playlistName, paths: lines,)));
                            }

                          },
                          icon: Icon(FluentIcons.open, color: Colors.white, size: height * 0.03,)
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
                            am.navigatorKey.currentState!.push(MaterialPageRoute(builder: (context) => const ExportScreen()));
                          },
                          icon: Icon(FluentIcons.open, color: Colors.white, size: height * 0.03,)
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
                  //       value: SettingsController.settings.theme,
                  //       onChanged: (value){
                  //         setState(() {
                  //           SettingsController.settings.theme = value;
                  //           SettingsController.themeNotifier.value = value;
                  //         });
                  //
                  //         SettingsController.settingsBox.put(SettingsController.settings);
                  //       },
                  //       trackColor: WidgetStateProperty.all(SettingsController.colorNotifier2.value),
                  //       thumbColor: WidgetStateProperty.all(Colors.white),
                  //       thumbIcon: WidgetStateProperty.all(SettingsController.settings.theme ? const Icon(Icons.sunny, color: Colors.black,) : const Icon(Icons.nightlight, color: Colors.black,)),
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