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
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // var boldSize = height * 0.025;
    // var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    return ValueListenableBuilder(
      valueListenable: widget.controller.repo.songs,
      builder: (context, value, child){
        return GridView.builder(
          padding: EdgeInsets.all(width * 0.01),
          itemCount: widget.controller.repo.songs.value.length + 7,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            childAspectRatio: 0.85,
            maxCrossAxisExtent: width * 0.125,
            crossAxisSpacing: width * 0.0125,
            mainAxisSpacing: width * 0.0125,
          ),
          itemBuilder: (BuildContext context, int index) {
            return index < widget.controller.repo.songs.value.length?
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  print("Playing ${widget.controller.indexNotifier.value}");
                  if (widget.controller.playingNotifier.value && widget.controller.playingSongs[widget.controller.indexNotifier.value].path == widget.controller.repo.songs.value[index].path) {
                    print("Pausing");
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
                    widget.controller.settings.lastPlayingIndex = index;
                    file.writeAsStringSync(jsonEncode(widget.controller.settings.toJson()));
                    widget.controller.indexChange(widget.controller.playingSongs.indexOf(widget.controller.repo.songs.value[index]));
                    widget.controller.playSong();
                  }
                },
                child: Column(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        margin: EdgeInsets.only(bottom: width * 0.005),
                        child: FutureBuilder(
                          future: widget.controller.imageRetrieve(widget.controller.repo.songs.value[index].path, false),
                          builder: (ctx, snapshot) {
                            if (snapshot.hasData) {
                              return HoverWidget(
                                hoverChild: Stack(
                                  alignment: Alignment.center,
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
                                              ValueListenableBuilder(
                                                valueListenable: widget.controller.playingNotifier,
                                                builder: (context, value, child){
                                                return Icon(
                                                  widget.controller.indexNotifier.value == index && value == true ?
                                                  FluentIcons.pause_32_filled : FluentIcons.play_32_filled,
                                                  size: height * 0.1,
                                                  color: Colors.white,
                                                  );
                                                },
                                              ),
                                              IconButton(
                                                onPressed: (){

                                                  /// SOMETHING LIKE NAVIGATE TO ALBUM
                                                // int indextodisplay = 0;
                                                // for(int i = 0; i < widget.controller.repo.albums.length; i++){
                                                //   if(widget.controller.repo.albums[i].name == widget.controller.repo.songs.value[index].album){
                                                //     indextodisplay = i;
                                                //     break;
                                                //   }
                                                // }
                                                // artistsforalbum = '';
                                                // for(int i = widget.controller.repo.albums[indextodisplay].featuredartists.length - 1; i >= 0 ; i--){
                                                //   if(artistsforalbum.length + widget.controller.repo.albums[indextodisplay].featuredartists[i].name.length < 75) {
                                                //     artistsforalbum = artistsforalbum + widget.controller.repo.albums[indextodisplay].featuredartists[i].name + ", ";
                                                //   } else{
                                                //     artistsforalbum = artistsforalbum.substring(0, artistsforalbum.length - 2);
                                                //     artistsforalbum = "$artistsforalbum and ${widget.controller.repo.albums[indextodisplay].featuredartists.length - i} more";
                                                //     break;
                                                //   }
                                                // }
                                                // if(artistsforalbum.endsWith(", ")) {
                                                //   artistsforalbum = artistsforalbum.substring(0, artistsforalbum.length - 2);
                                                // }
                                                // artistsforalbum.replaceAll("  ", " ").replaceAll(" , ", ", ");
                                                // setState(() {
                                                //   displayedalbum = indextodisplay;
                                                // });
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
                    ValueListenableBuilder(
                      valueListenable: widget.controller.indexNotifier,
                      builder: (context, value, child){
                        return Text(
                          widget.controller.repo.songs.value[index].title.length > 25 ?
                          "${widget.controller.repo.songs.value[index].title.substring(0, 25)}..." :
                          widget.controller.repo.songs.value[index].title,
                          style: TextStyle(
                            color: widget.controller.playingSongs.isNotEmpty && widget.controller.playingSongs[widget.controller.indexNotifier.value] == widget.controller.repo.songs.value[index] ? Colors.blue : Colors.white,
                            fontSize: smallSize,
                            fontWeight: FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                        );
                      }
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
      },
    );
  }

}