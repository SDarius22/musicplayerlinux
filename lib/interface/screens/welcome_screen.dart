import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:musicplayer/domain/playlist_type.dart';
import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
import '../../controller/data_controller.dart';
import '../../controller/settings_controller.dart';
import 'home.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
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
      body: SizedBox(
          width: width,
          height: height,
          child: Column(
            children: [
              WindowTitleBarBox(
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
                      onPressed: (){
                        if(SettingsController.fullClose){
                          appWindow.close();
                        }
                        else{
                          appWindow.hide();
                        }
                      },
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
              ),
              Expanded(
                child: Container(
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
                              //debugPrint(chosen);
                              setState(() {
                                SettingsController.directory = chosen;
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
                            FluentIcons.folder,
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
                            SettingsController.deezerARL = value;
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
                            debugPrint("Pressed");
                            if (SettingsController.directory == ""){
                              return;
                            }
                            if (SettingsController.deezerARL.isEmpty){
                              SettingsController.deezerARL = "b907c256773be4ea86dd637b2c50fe45232de28cb81e31230b01029e7be5d4132e343bc77f18cfa2daaadfd31f5773c5a9d9e2f5b70ff07a23f04c73e17e21dc770855560de5759305281200096cfcb810b26e7d944819adc8755b9b4e271b8c";
                            }
                            SettingsController.firstTime = false;
                            // widget.controller.settingsBox.put(widget.controller.settings);
                            debugPrint(SettingsController.firstTime.toString());
                            final dc = DataController();
                            PlaylistType favorites = PlaylistType();
                            favorites.name = "Favorites";
                            favorites.paths = [];
                            favorites.indestructible = true;
                            dc.createPlaylist(favorites);
                            PlaylistType mostPlayed = PlaylistType();
                            mostPlayed.name = "Most Played";
                            mostPlayed.paths = [];
                            mostPlayed.indestructible = true;
                            dc.createPlaylist(mostPlayed);
                            PlaylistType recentlyPlayed = PlaylistType();
                            recentlyPlayed.name = "Recently Played";
                            recentlyPlayed.paths = [];
                            recentlyPlayed.indestructible = true;
                            dc.createPlaylist(recentlyPlayed);
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext context){
                              return const HomePage();
                            }));
                          },
                          child: Icon(FluentIcons.forward, color: Colors.white, size: height * 0.03,),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
      ),
    );
  }
}
