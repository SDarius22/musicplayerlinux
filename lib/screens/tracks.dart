import 'dart:convert';
import 'dart:ui';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hovering/hovering.dart';
import 'dart:io';

import '../controller/controller.dart';

class Tracks extends StatefulWidget{
  final Controller controller;
  const Tracks({super.key, required this.controller});

  @override
  _TracksState createState() => _TracksState();
}


class _TracksState extends State<Tracks>{
  GlobalKey<State> key = GlobalKey();
  bool loading = false;
  ScrollController _scrollController = ScrollController(initialScrollOffset: 0.0);
  int displayedalbum = -1;
  String artistsforalbum = "", playlistname = "New playlist";
  


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: ValueListenableBuilder(
        valueListenable: widget.controller.repo.songs,
        builder: (context, value, child){
          return GridView.builder(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
            controller: _scrollController,
            itemCount: widget.controller.repo.songs.value.length + 12,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                childAspectRatio: 0.8 ,
                maxCrossAxisExtent: MediaQuery.of(context).size.width* 0.14,
                crossAxisSpacing: MediaQuery.of(context).size.width * 0.01,
                mainAxisSpacing: MediaQuery.of(context).size.width * 0.01
            ),
            itemBuilder: (BuildContext context, int sindex) {
              return sindex < widget.controller.repo.songs.value.length?
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    print("Playing ${widget.controller.indexNotifier.value}");
                    if (widget.controller.playingNotifier.value && widget.controller.playingSongs[widget.controller.indexNotifier.value].path == widget.controller.repo.songs.value[sindex].path) {
                      widget.controller.audioPlayer.pause();
                      widget.controller.playingNotifier.value = false;
                    }
                    else {
                      widget.controller.playingSongs.clear();
                      widget.controller.playingSongsUnShuffled.clear();

                      widget.controller.playingSongs.addAll(widget.controller.repo.songs.value);
                      widget.controller.playingSongsUnShuffled.addAll(widget.controller.repo.songs.value);

                      if(widget.controller.shuffleNotifier.value == true) {
                        widget.controller.playingSongs.shuffle();
                      }

                      var file = File("assets/settings.json");
                      widget.controller.settings.lastPlaying.clear();

                      for(int i = 0; i < widget.controller.playingSongs.length; i++){
                        widget.controller.settings.lastPlaying.add(widget.controller.playingSongs[i].path);
                      }
                      widget.controller.settings.lastPlayingIndex = sindex;
                      file.writeAsStringSync(jsonEncode(widget.controller.settings.toJson()));

                      widget.controller.indexNotifier.value = widget.controller.playingSongs.indexOf(widget.controller.repo.songs.value[sindex]);
                      widget.controller.playSong();
                    }
                  },
                  child: Column(
                    children: [
                      AspectRatio(
                        aspectRatio: 1.0,
                        child: Container(
                          height: MediaQuery.of(context).size.width * 0.2,
                          margin: EdgeInsets.only(bottom: 10),
                          child: FutureBuilder(
                            future: widget.controller.imageRetrieve(widget.controller.repo.songs.value[sindex].path, false),
                            builder: (ctx, snapshot) {
                              if (snapshot.hasData) {
                                return HoverWidget(
                                    hoverChild: Stack(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.circular(10),
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: Image.memory(snapshot.data!).image,
                                              )
                                          ),
                                        ),
                                        ClipRRect(
                                          // Clip it cleanly.
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                            child: Container(
                                              color: Colors.black.withOpacity(0.3),
                                              alignment: Alignment.center,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  IconButton(onPressed: (){
                                                    print("Add ${sindex}");
                                                    // _songstoadd.add(widget.controller.repo.songs.value[sindex]);
                                                    // setState(() {
                                                    //   addelement = true;
                                                    // });
                                                  },
                                                    padding: EdgeInsets.all(0),
                                                    icon:
                                                    Icon(FluentIcons.add_12_filled, color: Colors.white, size: 40,),
                                                  ),

                                                  widget.controller.playingSongs.isNotEmpty && widget.controller.playingSongs[widget.controller.indexNotifier.value] == widget.controller.repo.songs.value[sindex] && widget.controller.playingNotifier.value == true ? Icon(FluentIcons.pause_32_filled, size: 100, color: Colors.white,) : Icon(FluentIcons.play_32_filled, size: 100, color: Colors.white,),

                                                  IconButton(onPressed: (){
                                                    int indextodisplay = 0;
                                                    for(int i = 0; i < widget.controller.repo.albums.length; i++){
                                                      if(widget.controller.repo.albums[i].name == widget.controller.repo.songs.value[sindex].album){
                                                        indextodisplay = i;
                                                        break;
                                                      }
                                                    }
                                                    artistsforalbum = '';
                                                    for(int i = widget.controller.repo.albums[indextodisplay].featuredartists.length - 1; i >= 0 ; i--){
                                                      if(artistsforalbum.length + widget.controller.repo.albums[indextodisplay].featuredartists[i].name.length < 75)
                                                        artistsforalbum = artistsforalbum + widget.controller.repo.albums[indextodisplay].featuredartists[i].name + ", ";
                                                      else{
                                                        artistsforalbum = artistsforalbum.substring(0, artistsforalbum.length - 2);
                                                        artistsforalbum = artistsforalbum + " and " + (widget.controller.repo.albums[indextodisplay].featuredartists.length - i).toString() + " more";
                                                        break;
                                                      }
                                                    }
                                                    if(artistsforalbum.endsWith(", ")) {
                                                      artistsforalbum = artistsforalbum.substring(0, artistsforalbum.length - 2);
                                                    }
                                                    artistsforalbum.replaceAll("  ", " ").replaceAll(" , ", ", ");
                                                    setState(() {
                                                      displayedalbum = indextodisplay;
                                                    });
                                                  },
                                                    padding: EdgeInsets.all(0),
                                                    icon: Icon(FluentIcons.album_20_filled, color: Colors.white, size: 40,),
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
                                          borderRadius: BorderRadius.circular(10),
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: Image.memory(snapshot.data!).image,
                                          )
                                      ),
                                    )
                                );
                                // Container(
                                //   decoration: BoxDecoration(
                                //       color: Colors.black,
                                //       borderRadius: BorderRadius.circular(10),
                                //       image: DecorationImage(
                                //         fit: BoxFit.cover,
                                //         image: Image.memory(snapshot.data!).image,
                                //       )
                                //   ),
                                // );
                              }
                              else if (snapshot.hasError) {
                                return Center(
                                  child: Text(
                                    '${snapshot.error} occurred',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                );
                              } else{
                                return Container(
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(10),
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
                        widget.controller.repo.songs.value[sindex].title.length > 35 ? "${widget.controller.repo.songs.value[sindex].title.substring(0, 35)}..." : widget.controller.repo.songs.value[sindex].title,
                        style: TextStyle(
                          color: widget.controller.playingSongs.isNotEmpty && widget.controller.playingSongs[widget.controller.indexNotifier.value] == widget.controller.repo.songs.value[sindex] ? Colors.blue : Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

              ) :
              Container(
                height: 250,
                width: 250,
              );

            },
          );
        },
      ),
    );
  }

}