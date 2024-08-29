import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/screens/image_widget.dart';
import 'package:musicplayer/screens/playlist_screen.dart';
import '../controller/controller.dart';
import '../domain/song_type.dart';
import '../domain/playlist_type.dart';
import '../utils/hover_widget/stack_hover_widget.dart';
import '../utils/objectbox.g.dart';
import 'add_screen.dart';
import 'create_screen.dart';

class Playlists extends StatefulWidget{
  final Controller controller;
  const Playlists({super.key, required this.controller});

  @override
  _PlaylistsState createState() => _PlaylistsState();
}


class _PlaylistsState extends State<Playlists>{

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var smallSize = height * 0.015;
    return FutureBuilder(
        future: widget.controller.getPlaylists(),
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
                    "Error loading playlists",
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
            return GridView.builder(
              padding: EdgeInsets.only(
                left: width * 0.01,
                right: width * 0.01,
                top: height * 0.01,
                bottom: width * 0.125,
              ),
              itemCount: snapshot.data!.length + 1,
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                childAspectRatio: 0.825,
                maxCrossAxisExtent: width * 0.125,
                crossAxisSpacing: width * 0.0125,
                //mainAxisSpacing: width * 0.0125,
              ),
              itemBuilder: (BuildContext context, int index) {
                PlaylistType playlist = PlaylistType();
                if (index > 0){
                  playlist = snapshot.data![index-1];
                }
                return index == 0 ?
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CreateScreen(controller: widget.controller)));
                    },
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(width * 0.01),
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: StackHoverWidget(
                              bottomWidget: Container(
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: Image.asset("assets/create_playlist.png").image,
                                    )
                                ),
                              ),
                              topWidget: ClipRRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    color: Colors.black.withOpacity(0.3),
                                    alignment: Alignment.center,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: height * 0.004,
                        ),
                        Text(
                          "Create a new playlist",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              height: 1,
                              color: Colors.white,
                              fontSize: smallSize,
                              fontWeight: FontWeight.normal
                          ),
                        )
                      ],
                    ),

                  ),

                ) :
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      //print(playlist.name);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PlaylistScreen(controller: widget.controller, playlist: playlist)));
                    },
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(width * 0.01),
                          child: ImageWidget(
                            controller: widget.controller,
                            path: playlist.paths.first,
                            heroTag: playlist.name,
                            buttons: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: (){
                                    print("Add $index");
                                    List<SongType> songs = [];
                                    for (var path in playlist.paths){
                                      songs.add(widget.controller.songBox.query(SongType_.path.equals(path)).build().find().first);
                                    }
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => AddScreen(controller: widget.controller, songs: songs)
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
                                    if(widget.controller.settings.queue.equals(playlist.paths) == false){
                                      widget.controller.updatePlaying(playlist.paths, 0);
                                    }
                                    widget.controller.indexChange(playlist.paths.first);
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
                          height: height * 0.005,
                        ),
                        Text(
                          playlist.name,
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