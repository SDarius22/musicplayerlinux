import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:window_manager/window_manager.dart';

import '../controller/controller.dart';
import 'home.dart';

class WelcomeScreen extends StatefulWidget {
  final Controller controller;
  const WelcomeScreen({super.key, required this.controller});
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

  String directory = "";

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(
          double.maxFinite,
          height * 0.04,
        ),
        child: DragToMoveArea(
          child: ValueListenableBuilder(
              valueListenable: widget.controller.colorNotifier,
              builder: (context, value, child){
                return AppBar(
                  title: Text(
                    'Music Player',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: normalSize,
                    ),
                  ),
                  backgroundColor: widget.controller.colorNotifier2.value,
                  actions: [
                    IconButton(
                      onPressed: () => windowManager.minimize(),
                      icon: Icon(
                        FluentIcons.spacebar_20_filled,
                        size: height * 0.02,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () async {
                        if (await windowManager.isMaximized()) {
                          //print("Restoring");
                          await windowManager.unmaximize();
                          //await windowManager.setSize(Size(width * 0.6, height * 0.6));
                        } else {
                          await windowManager.maximize();
                        }

                      },
                      icon: Icon(
                        FluentIcons.maximize_16_regular,
                        size: height * 0.02,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      onPressed: () => windowManager.close(),
                      icon: Icon(
                        Icons.close_outlined,
                        size: height * 0.02,
                        color: Colors.white,

                      ),
                    ),
                  ],
                );
              }
          ),

        ),
      ),
      body: SafeArea(
        child: Container(
          width: width,
          height: height,
          padding: EdgeInsets.only(
            top: height * 0.005,
            left: width * 0.005,
            right: width * 0.005,
            bottom: height * 0.005,
          ),
          alignment: Alignment.center,
          child: Column(
              children: [
                SizedBox(
                  height: height * 0.33,
                ),
                Text(
                  "Welcome to Music Player!",
                  style: TextStyle(
                    fontSize: boldSize,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: height * 0.025,
                ),
                Text(
                  "Add music to your library by choosing a folder below:",
                  style: TextStyle(
                      fontSize: normalSize,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ),
                SizedBox(
                  height: height * 0.025,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: directory.isNotEmpty ?
                  directory.length * 15 > width/3 ? width/3 :
                  directory.length * 15 : width/10,
                  height: height * 0.06,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(0),
                      foregroundColor: Colors.white, backgroundColor: Colors.grey.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () async {
                      String chosen = await FilePicker.platform.getDirectoryPath() ?? "";
                      if(chosen != "") {
                        print(chosen);
                        setState(() {
                          widget.controller.settings.directory = chosen;
                          directory = chosen;
                        });
                      }
                    },
                    child: directory.isNotEmpty ?
                    Text(directory.length < 50 ? directory : "${directory.substring(0, 50)}...",
                      style: TextStyle(
                        fontSize: normalSize,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                    ) :
                    Icon(
                      FluentIcons.folder_24_regular,
                      color: Colors.white,
                      size: height * 0.03,
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: width,
                  padding: EdgeInsets.only(
                    top: height * 0.25,
                    right: width * 0.075,
                  ),
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(0),
                      foregroundColor: Colors.white, backgroundColor: Colors.grey.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () async {
                      print("Pressed");
                      widget.controller.settings.firstTime = false;
                      widget.controller.settingsBox.put(widget.controller.settings);
                      print(widget.controller.settings.firstTime);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){
                        return HomePage(controller: widget.controller);
                      }));
                    },
                    child: Icon(FluentIcons.arrow_right_12_filled, color: Colors.white, size: 30,),
                  ),
                ),
              ],
            ),
        ),
      )
    );
  }
}
