import 'dart:ui';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hovering/hovering.dart';


import '../domain/metadata_type.dart';
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
    return StreamBuilder<List<MetadataType>>(
      stream: widget.controller.songBox.query().watch(triggerImmediately: true).map((query) => query.find()),
      builder: (context, snapshot){
        if(snapshot.hasData){
          return GridView.builder(
            padding: EdgeInsets.all(width * 0.01),
            itemCount: widget.controller.songBox.query().order(MetadataType_.title).build().find().length + 7,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              childAspectRatio: 0.8275,
              maxCrossAxisExtent: width * 0.125,
              crossAxisSpacing: width * 0.0125,
              mainAxisSpacing: width * 0.0125,
            ),
            itemBuilder: (BuildContext context, int index) {
              MetadataType song = MetadataType();
              if(index < widget.controller.songBox.query().order(MetadataType_.title).build().find().length){
                song = widget.controller.songBox.query().order(MetadataType_.title).build().find()[index];
              }
              return index < widget.controller.songBox.query().order(MetadataType_.title).build().find().length?
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () async {
                    //print("Playing ${widget.controller.indexNotifier.value}");
                    if (widget.controller.settings.playingSongs[widget.controller.indexNotifier.value].path == song.path) {
                      //print("path match");
                      if (widget.controller.playingNotifier.value == true) {
                        //print("Pausing");
                        widget.controller.audioPlayer.pause();
                        widget.controller.playingNotifier.value = false;
                      }
                      else {
                        widget.controller.audioPlayer.resume();
                        widget.controller.playingNotifier.value = true;
                      }
                    }
                    else {
                      widget.controller.audioPlayer.stop();
                      if(widget.controller.settings.playingSongsUnShuffled.equals(widget.controller.songBox.query().order(MetadataType_.title).build().find()) == false){
                        print("Updating playing songs");
                        widget.controller.updatePlaying(widget.controller.songBox.query().order(MetadataType_.title).build().find());
                      }
                      await widget.controller.indexChange(widget.controller.settings.playingSongs.indexOf(song));
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
                            future: widget.controller.imageRetrieve(song.path, false),
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
                                                      // _songstoadd.add(widget.controller.songBox.query().order(MetadataType_.title).build().find()[sindex]);
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
                                                        widget.controller.settings.playingSongs[widget.controller.indexNotifier.value] == song && widget.controller.playingNotifier.value == true ?
                                                        FluentIcons.pause_32_filled : FluentIcons.play_32_filled,
                                                        size: height * 0.1,
                                                        color: Colors.white,
                                                      );
                                                    },
                                                  ),
                                                  IconButton(
                                                    onPressed: (){
                                                      Navigator.push(context, MaterialPageRoute(builder: (context){
                                                        return AlbumWidget(controller: widget.controller, album: widget.controller.albumBox.query(AlbumType_.name.equals(song.album)).build().find().first);
                                                      }));
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
                                        image: Image.memory(File("assets/bg.png").readAsBytesSync()).image,
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
                              song.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: widget.controller.settings.playingSongs.isNotEmpty && widget.controller.settings.playingSongs[widget.controller.indexNotifier.value] == song ? Colors.blue : Colors.white,
                                fontSize: smallSize,
                                fontWeight: FontWeight.normal,
                              ),
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