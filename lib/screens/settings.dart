import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:musicplayer/screens/main_screen.dart';

import '../functions.dart';
import 'welcome_screen.dart';


class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  functions functions1 = functions();
  String dropdownvalue = "Off";
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:  EdgeInsets.only(bottom: 50, left: 50, right: 50, top: 50),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                  padding: EdgeInsets.all(0),
                  onPressed: (){
                    print("Tapped back");
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                      return MyApp();
                    }));
                  }, icon: Icon(FluentIcons.arrow_left_16_filled)),
              Container(
                width: 50,
              ),
              Container(
                height: 33,
                alignment: Alignment.bottomCenter,
                child: Text("Settings",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 25, fontWeight: FontWeight.normal),),
              )

            ],
          ),
          Container(
            height: 35,
          ),
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
                                functions1.settings1.directory = directory;
                              });
                              setState(() {
                                functions1.settings1.firsttime = true;
                              });
                              functions1.songretrieve(true);

                            }
                            var file = File("assets/settings.json");
                            file.writeAsStringSync(jsonEncode(functions1.settings1.toJson()));
                          },
                          child: Text(
                            functions1.settings1.directory.length <= 40 ? functions1.settings1.directory : functions1.settings1.directory.substring(0, 40) + "...",
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
    );
  }
}