import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:musicplayer/domain/playlist_type.dart';
import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
import '../../controller/data_controller.dart';
import '../../controller/settings_controller.dart';


class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});
  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {

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
            if (SettingsController.songPlaces.isEmpty)
            Text(
              "Add music to your library by choosing a folder below:",
              style: TextStyle(
                fontSize: normalSize,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
            if (SettingsController.songPlaces.isEmpty)
            SizedBox(
              height: height * 0.025,
            ),
            if (SettingsController.songPlaces.isEmpty)
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: width * 0.1,
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
                      SettingsController.songPlaces = [chosen];
                      SettingsController.mainSongPlace = chosen;
                      SettingsController.songPlaceIncludeSubfolders = [1];
                      setState(() {
                      });
                    }
                  },
                  child: Icon(
                    FluentIcons.folder,
                    color: Colors.white,
                    size: height * 0.03,
                  ),

                ),
              )
            else
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                child: DataTable(
                  columns: [
                    DataColumn(
                      label: Text(
                        "Folder",
                        style: TextStyle(
                          fontSize: normalSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "Main",
                        style: TextStyle(
                          fontSize: normalSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    DataColumn(
                      headingRowAlignment: MainAxisAlignment.center,
                      label: Text(
                        "Include subfolders",
                        style: TextStyle(
                          fontSize: normalSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        "",
                        style: TextStyle(
                          fontSize: normalSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  rows: List<DataRow>.generate(
                    SettingsController.songPlaces.length + 1,
                    (index) {
                      return index < SettingsController.songPlaces.length?
                      DataRow(
                        cells: [
                          DataCell(
                            Text(
                              SettingsController.songPlaces[index],
                              style: TextStyle(
                                fontSize: normalSize,
                                fontWeight: FontWeight.normal,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: Icon(
                                SettingsController.mainSongPlace ==
                                    SettingsController.songPlaces[index]
                                    ? FluentIcons.checkCircleOn
                                    : FluentIcons.checkCircleOff,
                                color: Colors.white,
                                size: height * 0.03,
                              ),
                              onPressed: SettingsController.songPlaces.length <= 1 ? null : () {
                                setState(() {
                                  SettingsController.mainSongPlace =
                                  SettingsController.songPlaces[index];
                                });
                              },
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: Icon(
                                SettingsController.songPlaceIncludeSubfolders[index] == 1
                                    ? FluentIcons.checkCircleOn
                                    : FluentIcons.checkCircleOff,
                                color: Colors.white,
                                size: height * 0.03,
                              ),
                              onPressed: () {
                                if (SettingsController.songPlaceIncludeSubfolders[index] == 1) {
                                  debugPrint("Setting to 0");
                                  final updatedList = List<int>.from(
                                      SettingsController.songPlaceIncludeSubfolders);
                                  updatedList[index] = 0;
                                  SettingsController.songPlaceIncludeSubfolders = updatedList;
                                } else {
                                  debugPrint("Setting to 1");
                                  final updatedList = List<int>.from(
                                      SettingsController.songPlaceIncludeSubfolders);
                                  updatedList[index] = 1;
                                  SettingsController.songPlaceIncludeSubfolders = updatedList;
                                }
                                setState(() {});
                              },
                            ),
                          ),
                          DataCell(
                            IconButton(
                              icon: Icon(
                                FluentIcons.trash,
                                color: Colors.red,
                                size: height * 0.03,
                              ),
                              onPressed: () {
                                String current = SettingsController.songPlaces[index];
                                SettingsController.songPlaces = List<String>.from(SettingsController.songPlaces)..removeAt(index);
                                SettingsController.songPlaceIncludeSubfolders = List<int>.from(SettingsController.songPlaceIncludeSubfolders)..removeAt(index);
                                if (SettingsController.mainSongPlace == current) {
                                  try {
                                    SettingsController.mainSongPlace = SettingsController.songPlaces[0];
                                  } catch (e) {
                                    SettingsController.mainSongPlace = "";
                                  }
                                }
                                setState(() {
                                });
                              },
                            ),
                          ),
                        ],
                      ) :
                      DataRow(
                        cells: [
                          const DataCell(
                            Text("")
                          ),
                          const DataCell(
                            Text("")
                          ),
                          const DataCell(
                            Text("")
                          ),
                          DataCell(
                            IconButton(
                              onPressed: () async {
                                String chosen = await FilePicker.platform.getDirectoryPath() ?? "";
                                if(chosen != "") {
                                  //debugPrint(chosen);
                                  SettingsController.songPlaces = List<String>.from(SettingsController.songPlaces)..add(chosen);
                                  SettingsController.songPlaceIncludeSubfolders = List<int>.from(SettingsController.songPlaceIncludeSubfolders)..add(1);
                                  setState(() {
                                  });
                                }
                              },
                              tooltip: "Add Another Folder",
                              icon: Icon(FluentIcons.folderAdd, color: Colors.white, size: height * 0.03,),
                            ),
                          ),
                        ],
                      );
                    }
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
                onPressed: SettingsController.songPlaces.isEmpty? null : () async {
                  debugPrint("Pressed");
                  if (SettingsController.deezerARL.isEmpty){
                    SettingsController.deezerARL = "";
                  }
                  SettingsController.firstTime = false;
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
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: Icon(FluentIcons.forward, color: Colors.white, size: height * 0.03,),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
