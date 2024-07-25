import 'dart:io';
import 'dart:ui';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hovering/hovering.dart';
import 'package:musicplayer/screens/playlist_screen.dart';
import '../controller/controller.dart';
import '../domain/playlist_type.dart';
import '../utils/objectbox.g.dart';

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
    return GridView.builder(
      padding: EdgeInsets.all(width * 0.01),
      itemCount: widget.controller.playlistBox.query().order(PlaylistType_.name).build().find().length + 8,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        childAspectRatio: 0.825,
        maxCrossAxisExtent: width * 0.125,
        crossAxisSpacing: width * 0.0125,
        mainAxisSpacing: width * 0.0125,
      ),
      itemBuilder: (BuildContext context, int index) {
        PlaylistType playlist = PlaylistType();
        if (index > 0 && index < widget.controller.playlistBox.query().order(PlaylistType_.name).build().find().length + 1){
          playlist = widget.controller.playlistBox.query().order(PlaylistType_.name).build().find()[index-1];
        }
        return index == 0 ?
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: (){
              widget.controller.found.value = widget.controller.songBox.getAll();
            },
            child: AspectRatio(
              aspectRatio: 1.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                margin: EdgeInsets.only(bottom: width * 0.02),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(height * 0.01),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(height * 0.01),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          color: Colors.black.withOpacity(0.3),
                          alignment: Alignment.center,
                          child: Icon(
                            FluentIcons.collections_add_20_filled,
                            size: height * 0.125,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                  ],
                )
              ),
            ),
          ),

        ) :
        index < widget.controller.playlistBox.query().order(PlaylistType_.name).build().find().length + 1?
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return PlaylistWidget(controller: widget.controller, playlist: playlist);
              }));
            },
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    margin: EdgeInsets.only(bottom: width * 0.005),
                    child: FutureBuilder(
                      future: widget.controller.imageRetrieve(playlist.songs.first.path, false),
                      builder: (ctx, snapshot) {
                        if (snapshot.hasData) {
                          return HoverWidget(
                              hoverChild: Stack(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(height * 0.01),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: Image.memory(snapshot.data!).image,
                                        )
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(height * 0.01),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                      child: Container(
                                        color: Colors.black.withOpacity(0.3),
                                        alignment: Alignment.center,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            IconButton(
                                              onPressed: (){
                                                print("Add $index");
                                                // _songstoadd.add(widget.controller.repo.songs.value[sindex]);
                                                // setState(() {
                                                //   addelement = true;
                                                // });
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
                                  ),
                                ],
                              ),
                              onHover: (event){
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(height * 0.01),
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: Image.memory(snapshot.data!).image,
                                    )
                                ),
                              )
                          );
                        }
                        else if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              '${snapshot.error} occurred',
                              style: const TextStyle(fontSize: 18),
                            ),
                          );
                        }
                        else{
                          return Container(
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(height * 0.01),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: Image.memory(File("./assets/bg.png").readAsBytesSync()).image,
                                )
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
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

}