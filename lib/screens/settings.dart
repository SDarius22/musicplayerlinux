import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:musicplayer/screens/main_screen.dart';

import '../controller/controller.dart';


class Settings extends StatefulWidget {
  final Controller controller;
  const Settings({super.key, required this.controller});
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool _volume = true, search = false;
  final ValueNotifier<bool> _visible = ValueNotifier(false);
  FocusNode searchNode = FocusNode();
  String dropdownvalue = "Off";

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          Container(
              padding: const EdgeInsets.only(right: 25),
              child: ValueListenableBuilder(
                valueListenable: _visible,
                builder: (context, value, child) =>
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Visibility(
                          visible: _visible.value,
                          child: SizedBox(
                              height: height * 0.05,
                              width: width * 0.1,
                              child: MouseRegion(
                                onEnter: (event) {
                                  _visible.value = true;
                                },
                                onExit: (event) {
                                  _visible.value = false;
                                },
                                child: Slider(
                                  min: 0.0,
                                  max: 1.0,
                                  value: widget.controller.volumeNotifier.value,
                                  activeColor: widget.controller.colorNotifier.value,
                                  thumbColor: Colors.white,
                                  inactiveColor: Colors.white,
                                  onChanged: (double value) {
                                    setState(() {
                                      widget.controller.volumeNotifier.value = value;
                                      widget.controller.setVolume(widget.controller.volumeNotifier.value);
                                    });
                                  },
                                ),
                              )
                          ),
                        ),
                        MouseRegion(
                          onEnter: (event) {
                            _visible.value = true;
                          },
                          onExit: (event) {
                            _visible.value = false;
                          },
                          child: IconButton(
                            icon: _volume ? const Icon(FluentIcons.speaker_2_16_filled) : const Icon(FluentIcons.speaker_mute_16_filled),
                            onPressed: () {
                              if(_volume) {
                                widget.controller.volumeNotifier.value = 0;
                              }
                              else {
                                widget.controller.volumeNotifier.value = 0.1;
                              }
                              _volume = !_volume;
                              setState(() {
                                widget.controller.setVolume(widget.controller.volumeNotifier.value);
                              });
                            },
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        IconButton(onPressed: (){
                          //print("Search");
                          setState(() {
                            search = !search;
                          });
                          searchNode.requestFocus();
                        }, icon: const Icon(FluentIcons.search_16_filled)),
                      ],
                    ),
              )
          )
        ],
      ),
      body: Container(
        padding:  EdgeInsets.only(bottom: 50, left: 50, right: 50, top: 50),
        child: Column(
          children: [
            Container(
              height: 765,
              child: ListView(
                padding: EdgeInsets.only(right: 20),
                children: <Widget>[
                  Container(
                    height: 35,
                    margin: EdgeInsets.only(left: 40),
                    child: Text("Library",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey.shade50,
                      ),
                    ),
                  ),
                  Container(
                    height: 5,
                    color: Colors.transparent,
                  ),
                  Container(
                    height: 100,
                    margin: EdgeInsets.only(left: 20),
                    child : Row(
                      children: [
                        Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Music Directory", style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                              ),),
                              Container(
                                height: 5,
                              ),
                              Text("Select the directory where your music is stored", style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.normal,
                                color: Colors.grey.shade50,
                              ),),
                            ],
                          ),
                        ),
                        Spacer(),
                        Container(
                          child: ElevatedButton(
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
                                setState(() {
                                  widget.controller.settings.firstTime = true;
                                });
                                widget.controller.retrieveSongs();

                              }
                              var file = File("assets/settings.json");
                              file.writeAsStringSync(jsonEncode(widget.controller.settings.toJson()));
                            },
                            child: Text(
                              widget.controller.settings.directory.length <= 40 ? widget.controller.settings.directory : widget.controller.settings.directory.substring(0, 40) + "...",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 35,
                    color: Colors.transparent,
                  ),
                  Container(
                    height: 35,
                    margin: EdgeInsets.only(left: 40),
                    child: Text("Playback",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: Colors.grey.shade50,
                      ),
                    ),
                  ),
                  Container(
                    height: 5,
                    color: Colors.transparent,
                  ),
                  // Container(
                  //   height: 100,
                  //   margin: EdgeInsets.only(left: 20),
                  //   child : Row(
                  //     children: [
                  //       Container(
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             Text("Sleep Timer", style: TextStyle(
                  //               fontSize: 22,
                  //               fontWeight: FontWeight.normal,
                  //               color: Colors.white,
                  //             ),),
                  //             Container(
                  //               height: 5,
                  //             ),
                  //             Text("Set a timer to stop playback after a certain amount of time", style: TextStyle(
                  //               fontSize: 17,
                  //               fontWeight: FontWeight.normal,
                  //               color: Colors.grey.shade50,
                  //             ),),
                  //           ],
                  //         ),
                  //       ),
                  //       Spacer(),
                  //       Container(
                  //         child: DropdownButton(
                  //           value: dropdownvalue,
                  //           icon: const Icon(FluentIcons.chevron_down_16_regular),
                  //           items: [
                  //             DropdownMenuItem(
                  //               child: Text("Off"),
                  //               value: 'Off',
                  //             ),
                  //             DropdownMenuItem(
                  //               child: Text("15 minutes"),
                  //               value: '15 minutes',
                  //             ),
                  //             DropdownMenuItem(
                  //               child: Text("30 minutes"),
                  //               value: '30 minutes',
                  //             ),
                  //             DropdownMenuItem(
                  //               child: Text("45 minutes"),
                  //               value: '45 minutes',
                  //             ),
                  //             DropdownMenuItem(
                  //               child: Text("60 minutes"),
                  //               value: '60 minutes',
                  //             ),
                  //             DropdownMenuItem(
                  //               child: Text("2 hours"),
                  //               value: '2 hours',
                  //             ),
                  //             DropdownMenuItem(
                  //               child: Text("3 hours"),
                  //               value: '3 hours',
                  //             ),
                  //             DropdownMenuItem(
                  //               child: Text("4 hours"),
                  //               value: '4 hours',
                  //             ),
                  //           ],
                  //           onChanged: (String? newValue) {
                  //
                  //
                  //             if(newValue == "15 minutes")
                  //             {
                  //
                  //               timer1 = Timer(Duration(minutes: 15), () {
                  //                 print("timer tick or smth");
                  //                 exit(0);
                  //               });
                  //               print(timer1.isActive.toString());
                  //
                  //             }
                  //             else if(newValue == "30 minutes"){
                  //               timer1 = Timer(Duration(minutes: 30), () {
                  //                 print("timer tick or smth");
                  //                 exit(0);
                  //               });
                  //               print(timer1.isActive.toString());
                  //             }
                  //             else if(newValue == "45 minutes"){
                  //               timer1 = Timer(Duration(minutes: 45), () {
                  //                 print("timer tick or smth");
                  //                 exit(0);
                  //               });
                  //               print(timer1.isActive.toString());
                  //             }
                  //             else if(newValue == "60 minutes"){
                  //               timer1 = Timer(Duration(minutes: 45), () {
                  //                 print("timer tick or smth");
                  //                 exit(0);
                  //               });
                  //               print(timer1.isActive.toString());
                  //             }
                  //             else if(newValue == "2 hours"){
                  //               timer1 = Timer(Duration(minutes: 120), () {
                  //                 print("timer tick or smth");
                  //                 exit(0);
                  //               });
                  //               print(timer1.isActive.toString());
                  //             }
                  //             else if(newValue == "3 hours"){
                  //               timer1 = Timer(Duration(minutes: 180), () {
                  //                 print("timer tick or smth");
                  //                 exit(0);
                  //               });
                  //               print(timer1.isActive.toString());
                  //             }
                  //             else if(newValue == "4 hours"){
                  //               timer1 = Timer(Duration(minutes: 240), () {
                  //                 print("timer tick or smth");
                  //                 exit(0);
                  //               });
                  //               print(timer1.isActive.toString());
                  //             }
                  //             else{
                  //               timer1.cancel();
                  //               print(timer1.isActive.toString());
                  //             }
                  //             setState(() {
                  //               dropdownvalue = newValue!;
                  //
                  //             });
                  //           },
                  //
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // Container(
                  //   height: 100,
                  //   margin: EdgeInsets.only(left: 20),
                  //   child : Row(
                  //     children: [
                  //       Container(
                  //         child: Column(
                  //           crossAxisAlignment: CrossAxisAlignment.start,
                  //           mainAxisAlignment: MainAxisAlignment.center,
                  //           children: [
                  //             Text("Playback Speed", style: TextStyle(
                  //               fontSize: 22,
                  //               fontWeight: FontWeight.normal,
                  //               color: Colors.white,
                  //             ),),
                  //             Container(
                  //               height: 5,
                  //             ),
                  //             Text("Set the playback speed to a certain value", style: TextStyle(
                  //               fontSize: 17,
                  //               fontWeight: FontWeight.normal,
                  //               color: Colors.grey.shade50,
                  //             ),),
                  //           ],
                  //         ),
                  //       ),
                  //       Spacer(),
                  //       Container(
                  //         child: Slider(
                  //             min: 0.0,
                  //             max: 3.0,
                  //             value: speed,
                  //             divisions: 30,
                  //             label: "${speed.toStringAsPrecision(2)}",
                  //             activeColor: color,
                  //             thumbColor: Colors.white,
                  //             inactiveColor: Colors.white,
                  //             onChanged: (double value) {
                  //               print("value : ${speed}");
                  //               setState(() {
                  //                 speed = value;
                  //                 audioPlayer?.setPlaybackRate(speed);
                  //               });
                  //             },
                  //             onChangeStart: (double value) {
                  //               isTapped = true;
                  //             },
                  //             onChangeEnd: (double value) {
                  //               isTapped = false;
                  //               setState(() {
                  //                 speed = value;
                  //                 audioPlayer?.setPlaybackRate(speed);
                  //               });
                  //             }
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}