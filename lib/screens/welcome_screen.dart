import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import '../controller/controller.dart';
import 'home.dart';

class WelcomeScreen extends StatefulWidget {
  final Controller controller;
  const WelcomeScreen({super.key, required this.controller});
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var fontSize = height * 0.03;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Music Player"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to Music Player!", style: TextStyle(fontSize: 25),),
            Container(
              height: 25,
            ),
            Text("Add music to your library by choosing a folder below:", style: const TextStyle(fontSize: 20),),
            Container(
              height: 25,
            ),
            // functions1.retrieving ?
            // Container(
            //     width: 500,
            //     child: Column(
            //         children: <Widget>[
            //           LinearProgressIndicator(
            //             backgroundColor: Colors.cyanAccent,
            //             valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
            //             value: functions1.progressvalue,
            //           ),
            //           Container(
            //             height: 10,
            //           ),
            //           Text('${(functions1.progressvalue * 100).round()}%'),
            //         ]
            //     )
            // ):
            Container(
              width: widget.controller.settings.directory.isNotEmpty ?
              widget.controller.settings.directory.length * 15 > 500 ? 500 :
              widget.controller.settings.directory.length * 15 : 100,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.all(0),
                  foregroundColor: Colors.white, backgroundColor: Colors.grey.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () async {
                  String directory = await FilePicker.platform.getDirectoryPath() ?? "";
                  if(directory != "") {
                      widget.controller.settings.directory = directory;
                  }
                },
                child: widget.controller.settings.directory.isNotEmpty ?
                Text(widget.controller.settings.directory.length < 50 ? widget.controller.settings.directory : widget.controller.settings.directory.substring(0, 50) + "...",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.normal,
                    color: Colors.white,
                  ),
                ) : Icon(FluentIcons.folder_24_regular, color: Colors.white, size: 30,),
              ),
            ),
            Container(
              height: 25,
            ),

            // functions1.retrieving ?
            // Container(
            //   width: 1000,
            //   height: 150,
            // ) :
            Container(
              width: 1000,
              height: 150,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(0),
                      foregroundColor: Colors.white, backgroundColor: Colors.grey.shade900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    onPressed: () async {
                      print("Pressed");
                      var file = File("./assets/settings.json");
                      file.writeAsStringSync(jsonEncode(widget.controller.settings.toJson()));
                      // insert in navigator without back
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){
                        return HomePage(controller: widget.controller);
                      }));

                      // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                      //   return HomePage(controller: widget.controller);
                      // }));
                    },
                    child: Icon(FluentIcons.arrow_right_12_filled, color: Colors.white, size: 30,),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
