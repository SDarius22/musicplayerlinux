import 'package:collection/collection.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/controller/data_controller.dart';
import 'package:musicplayer/controller/settings_controller.dart';
import 'package:musicplayer/screens/add_screen.dart';
import 'package:musicplayer/screens/image_widget.dart';
import 'dart:async';


import '../controller/audio_player_controller.dart';
import '../domain/song_type.dart';
import '../repository/objectbox.g.dart';
import 'album_screen.dart';

class Tracks extends StatefulWidget{
  const Tracks({super.key});

  @override
  _TracksState createState() => _TracksState();
}


class _TracksState extends State<Tracks>{
  FocusNode searchNode = FocusNode();

  Timer? _debounce;

  late Future<List<SongType>> songsFuture;

  @override
  void initState(){
    super.initState();
    songsFuture = DataController.getSongs('');
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        songsFuture = DataController.getSongs(query);
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final dc = DataController();
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    return Column(
      children: [
        Container(
          height: height * 0.05,
          margin: EdgeInsets.only(
            left: width * 0.01,
            right: width * 0.01,
            bottom: height * 0.01,
          ),
          alignment: Alignment.center,
          child: TextFormField(
            initialValue: '',
            focusNode: searchNode,
            onChanged: _onSearchChanged,
            cursorColor: Colors.white,
            style: TextStyle(
              color: Colors.white,
              fontSize: normalSize,
            ),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(width * 0.02),
                borderSide: const BorderSide(
                  color: Colors.white,
                ),
              ),
              contentPadding: EdgeInsets.only(
                left: width * 0.01,
                right: width * 0.01,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.never,
              labelStyle: TextStyle(
                color: Colors.white,
                fontSize: smallSize,
              ),
              labelText: 'Search', suffixIcon: Icon(FluentIcons.search_16_filled, color: Colors.white, size: height * 0.02,),
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder(
              future: songsFuture,
              builder: (context, snapshot){
                if(snapshot.hasError){
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FluentIcons.error_circle_24_regular,
                          size: height * 0.1,
                          color: Colors.red,
                        ),
                        Text(
                          snapshot.error.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: smallSize,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: (){
                            setState(() {
                              songsFuture = DataController.getSongs('');
                            });
                          },
                          child: Text(
                            "Retry",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: smallSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                else if(snapshot.hasData){
                  if (snapshot.data!.isEmpty){
                    return Center(
                      child: Text("No songs found", style: TextStyle(color: Colors.white, fontSize: smallSize),),
                    );
                  }
                  return GridView.builder(
                    padding: EdgeInsets.only(
                      left: width * 0.01,
                      right: width * 0.01,
                      top: height * 0.01,
                      bottom: width * 0.125,
                    ),
                    itemCount: snapshot.data!.length,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      childAspectRatio: 0.825,
                      maxCrossAxisExtent: width * 0.125,
                      crossAxisSpacing: width * 0.0125,
                      //mainAxisSpacing: width * 0.0125,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      SongType song = snapshot.data![index];
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () async {
                            //print("Playing ${widget.controller.indexNotifier.value}");
                            try {
                              if (SettingsController.currentSongPath != song.path) {
                                //print("path match");
                                var songPaths = snapshot.data!.map((e) => e.path).toList();
                                if (SettingsController.queue.equals(songPaths) == false) {
                                  print("Updating playing songs");
                                  dc.updatePlaying(songPaths, index);
                                }
                                SettingsController.index = SettingsController.currentQueue.indexOf(song.path);
                                await AudioPlayerController.playSong();
                              }
                              else {
                                if (SettingsController.playing == true) {
                                  await AudioPlayerController.pauseSong();
                                }
                                else {
                                  await AudioPlayerController.playSong();
                                }
                              }
                            }
                            catch (e) {
                              print(e);
                              var songPaths = snapshot.data!.map((e) => e.path).toList();
                              dc.updatePlaying(songPaths, index);
                              SettingsController.index = index;
                              await AudioPlayerController.playSong();
                            }
                          },
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(width * 0.01),
                                child: ImageWidget(
                                  path: song.path,
                                  heroTag: "${song.path}+$index",
                                  buttons: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: width * 0.035,
                                        child: IconButton(
                                          onPressed: (){
                                            print("Add $index");
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => AddScreen(songs: [song])
                                                )
                                            );
                                          },
                                          padding: const EdgeInsets.all(0),
                                          icon: Icon(
                                            FluentIcons.add_12_filled,
                                            color: Colors.white,
                                            size: height * 0.03,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: ValueListenableBuilder(
                                          valueListenable: SettingsController.playingNotifier,
                                          builder: (context, value, child){
                                            return FittedBox(
                                              fit: BoxFit.fill,
                                              child: Icon(
                                                SettingsController.currentSongPath  == song.path && SettingsController.playing == true ?
                                                FluentIcons.pause_32_filled : FluentIcons.play_32_filled,
                                                color: Colors.white,
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.035,
                                        child: IconButton(
                                          onPressed: (){
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => AlbumScreen(album: DataController.albumBox.query(AlbumType_.name.equals(song.album)).build().findFirst()))
                                            );
                                          },
                                          padding: const EdgeInsets.all(0),
                                          icon: Icon(
                                            FluentIcons.album_24_filled,
                                            color: Colors.white,
                                            size: height * 0.03,
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: height * 0.005,
                              ),
                              ValueListenableBuilder(
                                  valueListenable: SettingsController.indexNotifier,
                                  builder: (context, value, child){
                                    return Text(
                                      song.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        height: 1,
                                        color: SettingsController.currentSongPath == song.path ? Colors.blue : Colors.white,
                                        fontSize: smallSize,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    );
                                  }
                              ),
                            ],
                          ),
                        ),

                      );

                    },
                  );
                }
                else{
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }
              }
          ),
        ),

      ],
    );
  }

}