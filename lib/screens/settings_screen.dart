import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
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
    var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
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
                          IconButton(
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              icon: Icon(
                                FluentIcons.arrow_left_24_regular,
                                size: height * 0.02,
                                color: Colors.white,
                              ),
                          ),
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
                child: Container(
                  padding:  EdgeInsets.only(
                    top: height * 0.02,
                    left: width * 0.02,
                    right: width * 0.02,
                    bottom: height * 0.02
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
                                    widget.controller.settingsBox.put(widget.controller.settings);
                                  });
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){
                                    return HomePage(controller: widget.controller);
                                  }));

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

                        ///TODO: Add more settings to the app!

                        Row(
                          children: [

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
                ),
            ],
          ),
        ),

      ),
    );
  }
}