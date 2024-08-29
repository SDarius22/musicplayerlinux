import 'package:collection/collection.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/screens/add_screen.dart';
import 'package:musicplayer/screens/image_widget.dart';


import '../domain/song_type.dart';
import '../utils/objectbox.g.dart';
import '../controller/controller.dart';
import 'album_screen.dart';

class Tracks extends StatefulWidget{
  final Controller controller;
  const Tracks({super.key, required this.controller});

  @override
  _TracksState createState() => _TracksState();
}


class _TracksState extends State<Tracks>{
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // var boldSize = height * 0.025;
    // var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    return FutureBuilder(
      future: widget.controller.getSongs(),
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
                  "Error loading songs",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: smallSize,
                  ),
                ),
                ElevatedButton(
                  onPressed: (){
                    setState(() {});
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
                    if (widget.controller.controllerQueue[widget.controller.indexNotifier.value] != song.path) {
                      //print("path match");
                      var songPaths = snapshot.data!.map((e) => e.path).toList();
                      if(widget.controller.settings.queue.equals(songPaths) == false){
                        print("Updating playing songs");
                        widget.controller.updatePlaying(songPaths, index);
                      }
                      widget.controller.indexChange(song.path);
                    }
                    await widget.controller.playSong();
                  },
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(width * 0.01),
                        child: ImageWidget(
                          controller: widget.controller,
                          path: song.path,
                          heroTag: "${song.path}+$index",
                          buttons: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: (){
                                  print("Add $index");
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AddScreen(controller: widget.controller, songs: [song])
                                      )
                                  );
                                },
                                padding: const EdgeInsets.all(0),
                                icon: Icon(
                                  FluentIcons.add_12_filled,
                                  color: Colors.white,
                                  size: height * 0.035,
                                ),
                              ),
                              ValueListenableBuilder(
                                valueListenable: widget.controller.playingNotifier,
                                builder: (context, value, child){
                                  return Icon(
                                    widget.controller.controllerQueue.isNotEmpty && widget.controller.controllerQueue[widget.controller.indexNotifier.value] == song.path && widget.controller.playingNotifier.value == true ?
                                    FluentIcons.pause_32_filled : FluentIcons.play_32_filled,
                                    size: height * 0.1,
                                    color: Colors.white,
                                  );
                                },
                              ),
                              IconButton(
                                onPressed: (){
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(builder: (context) => AlbumScreen(controller: widget.controller, album: widget.controller.albumBox.query(AlbumType_.name.equals(song.album)).build().find().first))
                                  );
                                },
                                padding: const EdgeInsets.all(0),
                                icon: Icon(
                                  FluentIcons.album_20_filled,
                                  color: Colors.white,
                                  size: height * 0.035,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.005,
                      ),
                      ValueListenableBuilder(
                          valueListenable: widget.controller.indexNotifier,
                          builder: (context, value, child){
                            return Text(
                              song.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                height: 1,
                                color: widget.controller.controllerQueue.isNotEmpty && widget.controller.controllerQueue[widget.controller.indexNotifier.value] == song.path ? Colors.blue : Colors.white,
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
    );
  }

}