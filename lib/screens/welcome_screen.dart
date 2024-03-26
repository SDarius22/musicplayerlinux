import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

import '../functions.dart';
import 'home.dart';

class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  functions functions1 = functions();

  @override
  void initState() {
    functions1.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Music Player"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome to Music Player!", style: TextStyle(fontSize: 25),),
            Container(
              height: 25,
            ),
            Text( functions1.retrieving ? "Retrieving all your songs" : "Add music to your library by choosing a folder below:", style: const TextStyle(fontSize: 20),),
            Container(
              height: 25,
            ),
            functions1.retrieving ?
            Container(
                width: 500,
                child: Column(
                    children: <Widget>[
                      LinearProgressIndicator(
                        backgroundColor: Colors.cyanAccent,
                        valueColor: new AlwaysStoppedAnimation<Color>(Colors.red),
                        value: functions1.progressvalue,
                      ),
                      Container(
                        height: 10,
                      ),
                      Text('${(functions1.progressvalue * 100).round()}%'),
                    ]
                )
            ):
            Container(
              width: functions1.settings1.directory.length > 0 ? functions1.settings1.directory.length * 15 > 500 ? 500 : functions1.settings1.directory.length * 15 : 100,
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
                    setState(() {
                      functions1.settings1.directory = directory;
                    });
                  }
                },
                child: functions1.settings1.directory.length > 0 ? Text(
                  functions1.settings1.directory.length <= 50 ? functions1.settings1.directory : functions1.settings1.directory.substring(0, 50) + "...",
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

            functions1.retrieving ?
            Container(
              width: 1000,
              height: 150,
            ) : Container(
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
                      file.writeAsStringSync(jsonEncode(functions1.settings1.toJson()));
                      await functions1.songretrieve(true);
                      if (functions1.finished_retrieving){
                        Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                          return HomePage();
                        }));
                      }
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
