import 'dart:io';
import 'package:collection/collection.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import '../domain/metadata_type.dart';
import '../utils/hover_widget/hover_widget.dart';
import 'package:musicplayer/domain/artist_type.dart';
import 'package:musicplayer/domain/playlist_type.dart';
import '../controller/controller.dart';

class PlaylistWidget extends StatefulWidget {
  final Controller controller;
  final PlaylistType playlist;
  const PlaylistWidget({super.key, required this.controller, required this.playlist});

  @override
  _PlaylistWidget createState() => _PlaylistWidget();
}

class _PlaylistWidget extends State<PlaylistWidget> {
  String featuredArtists = "";
  String duration = "0 seconds";
  late Future imageFuture;
  late List<MetadataType> songs;


  @override
  void initState() {
    imageFuture = widget.controller.imageRetrieve(widget.playlist.songs.first.path, false);
    int totalDuration = 0;
    for (int i = 0; i < widget.playlist.songs.length; i++){
      totalDuration += widget.playlist.songs[i].duration;
    }
    duration = " ${totalDuration ~/ 3600} hours, ${(totalDuration % 3600 ~/ 60)} minutes and ${(totalDuration % 60)} seconds";
    duration = duration.replaceAll(" 0 hours,", "");
    duration = duration.replaceAll(" 0 minutes and", "");
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    return Scaffold(
      body: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          width: width,
          height: height,
          padding: EdgeInsets.only(
            top: height * 0.02,
            left: width * 0.01,
            right: width * 0.01,
            bottom: height * 0.02
          ),
          alignment: Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: (){
                  print("Back");
                  Navigator.pop(context);
                },
                icon: Icon(
                  FluentIcons.arrow_left_16_filled,
                  size: height * 0.02,
                  color: Colors.white,
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: width * 0.4,
                padding: EdgeInsets.only(
                  top: height * 0.1,
                  bottom: height * 0.05,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[
                    Hero(
                      tag: widget.playlist.name,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        height: height * 0.5,
                        padding: EdgeInsets.only(
                          bottom: height * 0.01,
                        ),
                        //color: Colors.red,
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: FutureBuilder(
                              future: widget.controller.imageRetrieve(widget.playlist.songs.first.path, false),
                              builder: (context, snapshot){
                                if(snapshot.hasData) {
                                  return DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(width * 0.025),
                                      image: DecorationImage(
                                        image: Image.memory(snapshot.data!).image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                }
                                else{
                                  return DecoratedBox(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: Image.memory(File("assets/bg.png").readAsBytesSync()).image,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  );
                                }
                              }
                          ),
                        ),
                      ),
                    ),
                    Text(
                      widget.playlist.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: boldSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.005,
                    ),
                    Text(
                      featuredArtists,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: normalSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.005,
                    ),
                    Text(
                      duration,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: smallSize,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () async {
                              if(widget.controller.settings.playingSongsUnShuffled.equals(widget.playlist.songs) == false){
                                widget.controller.updatePlaying(widget.playlist.songs);
                              }
                              await widget.controller.indexChange(widget.playlist.songs.first);
                              await widget.controller.playSong();

                            },
                            icon: Icon(
                              FluentIcons.play_12_filled,
                              color: Colors.white,
                              size: height * 0.025,
                            ),
                          ),
                          IconButton(
                            onPressed: (){
                              print("Add ${widget.playlist.name}");
                              // for(metadata1 song in allPlaylists[displayedPlaylist].songs) {
                              //   _songstoadd.add(song);
                              // }
                              // setState(() {
                              //   addelement = true;
                              // });
                            },
                            icon: Icon(
                              FluentIcons.add_12_filled,
                              color: Colors.white,
                              size: height * 0.025,
                            ),
                          ),
                        ]
                    ),
                  ]
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: width * 0.45,
                padding: EdgeInsets.only(
                  left: width * 0.02,
                  top: height * 0.1,
                  bottom: height * 0.2,
                ),
                child: ListView.builder(
                  itemCount: widget.playlist.songs.length,
                  itemBuilder: (context, int index) {
                    //print("Building ${widget.playlist.songs[widget.playlist.order[index]].title}");
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      height: height * 0.125,
                      padding: EdgeInsets.only(
                        right: width * 0.01,
                      ),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () async {
                              if(widget.controller.settings.playingSongs.equals(widget.playlist.songs) == false){
                                widget.controller.updatePlaying(widget.playlist.songs);
                              }
                              await widget.controller.indexChange(widget.controller.settings.playingSongsUnShuffled[index]);
                              await widget.controller.playSong();
                            },
                            child: FutureBuilder(
                                future: widget.controller.imageRetrieve(widget.playlist.songs[index].path, false),
                                builder: (context, snapshot){
                                  return HoverWidget(
                                    hoverChild: Container(
                                      padding: EdgeInsets.only(
                                        left: width * 0.0075,
                                        right: width * 0.0075,
                                        top: height * 0.005,
                                        bottom: height * 0.005,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(height * 0.02),
                                        color: const Color(0xFF242424),
                                      ),
                                      child: Row(
                                        children: [
                                          if(snapshot.hasData)
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 500),
                                              height: height * 0.1,
                                              width: height * 0.1,
                                              child: AspectRatio(
                                                aspectRatio: 1.0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      color: Colors.black,
                                                      borderRadius: BorderRadius.circular(height * 0.02),
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: Image.memory(snapshot.data!).image,
                                                      )
                                                  ),
                                                ),
                                              ),
                                            )
                                          else if (snapshot.hasError)
                                            SizedBox(
                                              height: height * 0.1,
                                              width: height * 0.1,
                                              child: Center(
                                                child: Text(
                                                  '${snapshot.error} occurred',
                                                  style: TextStyle(fontSize: normalSize),
                                                ),
                                              ),
                                            )
                                          else
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 500),
                                              height: height * 0.1,
                                              width: height * 0.1,
                                              child: AspectRatio(
                                                aspectRatio: 1.0,
                                                child: Container(
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
                                                ),
                                              ),
                                            ),
                                          SizedBox(
                                            width: width * 0.01,
                                          ),
                                          Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    widget.playlist.songs[index].title.toString().length > 60 ? "${widget.playlist.songs[index].title.toString().substring(0, 60)}..." : widget.playlist.songs[index].title.toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: normalSize,
                                                    )
                                                ),
                                                SizedBox(
                                                  height: height * 0.005,
                                                ),
                                                Text(
                                                    widget.playlist.songs[index].artists.toString().length > 60 ? "${widget.playlist.songs[index].artists.toString().substring(0, 60)}..." : widget.playlist.songs[index].artists.toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: smallSize,
                                                    )
                                                ),
                                              ]
                                          ),
                                          const Spacer(),
                                          Text(
                                              "${widget.playlist.songs[index].duration ~/ 60}:${(widget.playlist.songs[index].duration % 60).toString().padLeft(2, '0')}",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: normalSize,
                                              )
                                          ),
                                        ],
                                      ),
                                    ),
                                    onHover: (event){
                                      return;
                                      //print("Hovering");
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(
                                        left: width * 0.0075,
                                        right: width * 0.0075,
                                        top: height * 0.005,
                                        bottom: height * 0.005,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(height * 0.01),
                                        color: Colors.transparent,
                                      ),
                                      child: Row(
                                        children: [
                                          if(snapshot.hasData)
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 500),
                                              height: height * 0.1,
                                              width: height * 0.1,
                                              child: AspectRatio(
                                                  aspectRatio: 1.0,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius: BorderRadius.circular(height * 0.02),
                                                        image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: Image.memory(snapshot.data!).image,
                                                        )
                                                    ),
                                                  )
                                              ),
                                            )
                                          else if (snapshot.hasError)
                                            SizedBox(
                                              height: height * 0.1,
                                              width: height * 0.1,
                                              child: Center(
                                                child: Text(
                                                  '${snapshot.error} occurred',
                                                  style: TextStyle(fontSize: normalSize),
                                                ),
                                              ),
                                            )
                                          else
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 500),
                                              height: height * 0.1,
                                              width: height * 0.1,
                                              child: AspectRatio(
                                                aspectRatio: 1.0,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(height * 0.02),
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: Image.memory(File("assets/bg.png").readAsBytesSync()).image,
                                                      )
                                                  ),
                                                ),
                                              ),
                                            ),
                                          SizedBox(
                                            width: width * 0.01,
                                          ),
                                          Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    widget.playlist.songs[index].title.toString().length > 60 ? "${widget.playlist.songs[index].title.toString().substring(0, 60)}..." : widget.playlist.songs[index].title.toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: normalSize,
                                                    )
                                                ),
                                                SizedBox(
                                                  height: height * 0.005,
                                                ),
                                                Text(
                                                    widget.playlist.songs[index].artists.toString().length > 60 ? "${widget.playlist.songs[index].artists.toString().substring(0, 60)}..." : widget.playlist.songs[index].artists.toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: smallSize,
                                                    )
                                                ),
                                              ]
                                          ),
                                          const Spacer(),
                                          Text(
                                              "${widget.playlist.songs[index].duration ~/ 60}:${(widget.playlist.songs[index].duration % 60).toString().padLeft(2, '0')}",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: normalSize,
                                              )
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                            )
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}