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

  String directory = "";

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var boldSize = height * 0.025;
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
        child: Column(
          children: [
            SizedBox(
              height: height * 0.25,
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
              directory.length * 30 > width/3 ? width/3 :
              directory.length * 30 : width/10,
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
                    //print(chosen);
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
              height: height * 0.1,
            ),
            Text(
              "Deezer ARL (Optional, you can add this later in settings)",
              style: TextStyle(
                fontSize: smallSize,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
            ),
            SizedBox(
              height: height * 0.01,
            ),
            SizedBox(
              width: width * 0.5,
              child: TextFormField(
                style: TextStyle(
                  fontSize: normalSize,
                  fontWeight: FontWeight.normal,
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: "Deezer ARL",
                  hintStyle: TextStyle(
                    fontSize: normalSize,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade900,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey.shade900,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onChanged: (value){
                  widget.controller.settings.deezerARL = value;
                },
              ),
            ),
            SizedBox(
              height: height * 0.1,
            ),
            Container(
              width: width,
              padding: EdgeInsets.only(
                right: width * 0.075,
              ),
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(0),
                  foregroundColor: Colors.white, backgroundColor: Colors.grey.shade900,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onPressed: () async {
                  print("Pressed");
                  if (widget.controller.settings.directory == ""){
                    return;
                  }
                  if (widget.controller.settings.deezerARL.isEmpty){
                    widget.controller.settings.deezerARL = "8436641c809f643da885ce7eb45e39e6a9514f882b1541a05282a33485f6f96fc56ddb724424ec3518e25bbaa08de4e7521e5f289a14c512dd65dc2ec0ad10b83138e5d02c1531a5bf5766ecfd492d0157815bafa5f08b90dcfe51a1eba1bbbf";
                  }
                  widget.controller.settings.firstTime = false;
                  widget.controller.settingsBox.put(widget.controller.settings);
                  print(widget.controller.settings.firstTime);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){
                    return HomePage(controller: widget.controller);
                  }));
                },
                child: Icon(FluentIcons.arrow_right_12_filled, color: Colors.white, size: height * 0.03,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
