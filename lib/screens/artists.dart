import 'package:collection/collection.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import '../controller/controller.dart';
import '../domain/artist_type.dart';
import 'add_screen.dart';
import 'artist_screen.dart';
import 'image_widget.dart';

class Artists extends StatefulWidget{
  final Controller controller;
  const Artists({super.key, required this.controller});

  @override
  _ArtistsState createState() => _ArtistsState();
}


class _ArtistsState extends State<Artists>{
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var smallSize = height * 0.015;
    return FutureBuilder(
        future: widget.controller.getArtists(),
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
                    "Error loading artists",
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
                child: Text("No artists found.", style: TextStyle(color: Colors.white, fontSize: smallSize),),
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
                ArtistType artist = snapshot.data![index];
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      //print(artist.name);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ArtistScreen(controller: widget.controller, artist: artist)));
                    },
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(width * 0.01),
                          child: ImageWidget(
                            controller: widget.controller,
                            path: artist.songs.first.path,
                            heroTag: artist.name,
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
                                            builder: (context) => AddScreen(controller: widget.controller, songs: artist.songs)
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
                                Icon(
                                  FluentIcons.open_16_filled,
                                  size: height * 0.1,
                                  color: Colors.white,
                                ),
                                IconButton(
                                  onPressed: () async {
                                    var songPaths = artist.songs.map((e) => e.path).toList();
                                    if(widget.controller.settings.queue.equals(songPaths) == false){
                                      widget.controller.updatePlaying(songPaths, 0);
                                    }
                                    widget.controller.indexChange(songPaths.first);
                                    await widget.controller.playSong();
                                  },
                                  padding: const EdgeInsets.all(0),
                                  icon: Icon(
                                    FluentIcons.play_12_filled,
                                    color: Colors.white,
                                    size: height * 0.035,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: width * 0.005,
                        ),
                        Text(
                          artist.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            height: 1,
                            color: Colors.white,
                            fontSize: smallSize,
                            fontWeight: FontWeight.normal,
                          ),
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