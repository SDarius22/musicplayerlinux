import 'dart:io';
import 'dart:ui';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/screens/image_widget.dart';
import 'package:musicplayer/screens/playlist_screen.dart';
import '../controller/controller.dart';
import '../domain/metadata_type.dart';
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
    var query = widget.controller.playlistBox.query().order(PlaylistType_.name).build();
    return StreamBuilder<List<PlaylistType>>(
      stream: widget.controller.playlistBox.query().watch(triggerImmediately: true).map((query) => query.find()),
      builder: (context, snapshot){
        if(snapshot.hasData){
          return GridView.builder(
            padding: EdgeInsets.all(width * 0.01),
            itemCount: query.find().length + 8,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              childAspectRatio: 0.825,
              maxCrossAxisExtent: width * 0.125,
              crossAxisSpacing: width * 0.0125,
              mainAxisSpacing: width * 0.0125,
            ),
            itemBuilder: (BuildContext context, int index) {
              PlaylistType playlist = PlaylistType();
              if (index > 0 && index <= query.find().length){
                playlist = query.find()[index-1];
              }
              return index == 0 ?
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: (){
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) => CreateScreen(controller: widget.controller),
                          transitionDuration: const Duration(milliseconds: 500),
                          reverseTransitionDuration: const Duration(milliseconds: 500),
                          transitionsBuilder: (context, animation1, animation2, child) {
                            animation1 = CurvedAnimation(parent: animation1, curve: Curves.linear);
                            return ScaleTransition(
                              alignment: Alignment.center,
                              scale: animation1,
                              child: child,
                            );
                          },
                        ));
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
                                    image: Image.memory(File("assets/create_playlist.png").readAsBytesSync()).image,
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
                            color: Colors.white,
                            fontSize: smallSize,
                            fontWeight: FontWeight.normal
                        ),
                      )
                    ],
                  ),

                ),

              ) :
              index < widget.controller.playlistBox.query().order(PlaylistType_.name).build().find().length + 1?
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    //print(playlist.name);
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) => PlaylistWidget(controller: widget.controller, playlist: playlist),
                          transitionDuration: const Duration(milliseconds: 500),
                          reverseTransitionDuration: const Duration(milliseconds: 500),
                          transitionsBuilder: (context, animation1, animation2, child) {
                            animation1 = CurvedAnimation(parent: animation1, curve: Curves.linear);
                            return ScaleTransition(
                              alignment: Alignment.center,
                              scale: animation1,
                              child: child,
                            );
                          },
                        ));
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
                                  List<MetadataType> songs = [];
                                  for (var path in playlist.paths){
                                    songs.add(widget.controller.songBox.query(MetadataType_.path.equals(path)).build().find().first);
                                  }
                                  Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation1, animation2) => AddScreen(controller: widget.controller, songs: songs),
                                        transitionDuration: const Duration(milliseconds: 500),
                                        reverseTransitionDuration: const Duration(milliseconds: 500),
                                        transitionsBuilder: (context, animation1, animation2, child) {
                                          animation1 = CurvedAnimation(parent: animation1, curve: Curves.linear);
                                          return ScaleTransition(
                                            alignment: Alignment.center,
                                            scale: animation1,
                                            child: child,
                                          );
                                        },
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
                                onPressed: (){
                                  /// play all the songs of the playlist
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
                        height: height * 0.004,
                      ),
                      Text(
                        playlist.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: smallSize,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),

              ) :
              SizedBox(
                height: width * 0.125,
                width: width * 0.125,
              );

            },
          );
        }
        else if(snapshot.hasError){
          return Center(
            child: Text(
              '${snapshot.error} occurred',
              style: const TextStyle(fontSize: 18),
            ),
          );
        }
        else if (snapshot.connectionState == ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
        else{
          return const Center(
            child: Text(
              'No data',
              style: TextStyle(fontSize: 18),
            ),
          );
        }
      },
    );

  }

}