import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/controller/data_controller.dart';
import 'package:musicplayer/controller/settings_controller.dart';
import 'package:musicplayer/interface/widgets/image_widget.dart';
import 'dart:async';
import '../../controller/app_audio_handler.dart';
import '../../domain/song_type.dart';
import '../../repository/objectbox.g.dart';
import '../../utils/text_scroll/text_scroll.dart';

class Tracks extends StatefulWidget{
  const Tracks({super.key});

  @override
  State<Tracks> createState() => _TracksState();
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
              labelText: 'Search', suffixIcon: Icon(FluentIcons.search, color: Colors.white, size: height * 0.02,),
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
                        FluentIcons.error,
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
                    maxCrossAxisExtent: width * 0.125,
                    crossAxisSpacing: width * 0.0125,
                    mainAxisSpacing: width * 0.0125,
                  ),
                  itemBuilder: (BuildContext context, int index) {
                    SongType song = snapshot.data![index];
                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () async {
                          //debugPrint("Playing ${widget.controller.indexNotifier.value}");
                          try {
                            if (SettingsController.currentSongPath != song.path) {
                              //debugPrint("path match");
                              var songPaths = snapshot.data!.map((e) => e.path).toList();
                              if (SettingsController.queue.equals(songPaths) == false) {
                                debugPrint("Updating playing songs");
                                dc.updatePlaying(songPaths, index);
                              }
                              SettingsController.index = SettingsController.currentQueue.indexOf(song.path);
                             await AppAudioHandler.play();
                            }
                            else {
                              if (SettingsController.playing == true) {
                                await AppAudioHandler.pause();
                              }
                              else {
                               await AppAudioHandler.play();
                              }
                            }
                          }
                          catch (e) {
                            debugPrint(e.toString());
                            var songPaths = snapshot.data!.map((e) => e.path).toList();
                            dc.updatePlaying(songPaths, index);
                            SettingsController.index = index;
                            await AppAudioHandler.play();
                          }
                        },
                        onLongPress: (){
                          debugPrint("Select song $index");
                          DataController.selected = List.from(DataController.selected)..add(song.path);
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(width * 0.01),
                          child: ImageWidget(
                            path: song.path,
                            heroTag: song.path,
                            hoveredChild: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: width * 0.035,
                                      height: width * 0.035,
                                      child: IconButton(
                                        onPressed: (){
                                          debugPrint("Add $index");
                                          Navigator.pushNamed(context, '/add', arguments: [song]);
                                        },
                                        padding: const EdgeInsets.all(0),
                                        icon: Icon(
                                          FluentIcons.addSingle,
                                          color: Colors.white,
                                          size: height * 0.03,
                                        ),
                                      ),
                                    ),

                                    SizedBox(
                                      width: width * 0.035,
                                      height: width * 0.035,
                                      child: IconButton(
                                        onPressed: (){
                                          debugPrint("Play Next: $index");
                                          dc.addNextToQueue([song.path]);
                                        },
                                        padding: const EdgeInsets.all(0),
                                        icon: Icon(
                                          FluentIcons.playNext2,
                                          color: Colors.white,
                                          size: height * 0.03,
                                        ),
                                      ),
                                    ),

                                  ],
                                ),
                                Expanded(
                                  child: ValueListenableBuilder(
                                    valueListenable: SettingsController.playingNotifier,
                                    builder: (context, value, child){
                                      return FittedBox(
                                        fit: BoxFit.fill,
                                        child: Icon(
                                          SettingsController.currentSongPath  == song.path && SettingsController.playing == true ?
                                          FluentIcons.pause : FluentIcons.play,
                                          color: Colors.white,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: width * 0.035,
                                      height: width * 0.035,
                                      child: IconButton(
                                        onPressed: (){
                                          Navigator.pushNamed(context, '/album', arguments: DataController.albumBox.query(AlbumType_.name.equals(song.album)).build().findFirst());
                                        },
                                        padding: const EdgeInsets.all(0),
                                        icon: Icon(
                                          FluentIcons.album,
                                          color: Colors.white,
                                          size: height * 0.03,
                                        ),
                                      ),
                                    ),
                                    ValueListenableBuilder(
                                      valueListenable: DataController.selectedPaths,
                                      builder: (context, value, child){
                                        return SizedBox(
                                          width: width * 0.035,
                                          height: width * 0.035,
                                          child: IconButton(
                                            onPressed: (){
                                              debugPrint("Select $index");
                                              if (DataController.selected.contains(song.path)){
                                                DataController.selected = List.from(DataController.selected)..remove(song.path);
                                                return;
                                              }
                                              DataController.selected = List.from(DataController.selected)..add(song.path);
                                            },
                                            padding: const EdgeInsets.all(0),
                                            icon: Icon(
                                              DataController.selected.contains(song.path) ? FluentIcons.checkCircleOn : FluentIcons.checkCircleOff,
                                              color: Colors.white,
                                              size: height * 0.03,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                            child: Container(
                              alignment: Alignment.bottomCenter,
                              padding: EdgeInsets.only(
                                bottom: height * 0.005,
                              ),
                              decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                      begin: FractionalOffset.center,
                                      end: FractionalOffset.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.0),
                                        Colors.black.withOpacity(0.5),
                                        Colors.black,
                                      ],
                                      stops: const [0.0, 0.5, 1.0]
                                  )
                              ),
                              child: TextScroll(
                                song.title,
                                mode: TextScrollMode.bouncing,
                                velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
                                style: TextStyle(
                                  color: SettingsController.currentSongPath == song.path ? Colors.blue : Colors.white,
                                  fontSize: normalSize,
                                  fontWeight: FontWeight.bold,
                                ),
                                pauseOnBounce: const Duration(seconds: 2),
                                delayBefore: const Duration(seconds: 2),
                                pauseBetween: const Duration(seconds: 2),
                              ),
                          ),
                          ),
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