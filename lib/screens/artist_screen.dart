import 'dart:io';
import 'package:collection/collection.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import '../utils/hover_widget/hover_widget.dart';
import 'package:musicplayer/domain/artist_type.dart';
import '../controller/controller.dart';
import 'image_widget.dart';

class ArtistWidget extends StatefulWidget {
  final Controller controller;
  final ArtistType artist;
  const ArtistWidget({super.key, required this.controller, required this.artist});

  @override
  _ArtistWidget createState() => _ArtistWidget();
}

class _ArtistWidget extends State<ArtistWidget> {
  String duration = "0 seconds";


  @override
  void initState() {
    int totalDuration = 0;
    for(int i = 0; i < widget.artist.songs.length; i++){
      totalDuration += widget.artist.songs[i].duration;
    }
    duration = " ${totalDuration ~/ 3600} hours, ${(totalDuration % 3600 ~/ 60)} minutes and ${(totalDuration % 60)} seconds";
    duration = duration.replaceAll(" 0 hours,", "");
    duration = duration.replaceAll(" 0 minutes and", "");
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    print(widget.artist.name);
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    return Scaffold(
      body: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          padding: EdgeInsets.only(
              top: height * 0.02,
              left: width * 0.01,
              right: width * 0.01,
              bottom: height * 0.02
          ),
          alignment: Alignment.center,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        tag: widget.artist.name,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          height: height * 0.5,
                          padding: EdgeInsets.only(
                            bottom: height * 0.01,
                          ),
                          //color: Colors.red,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(width * 0.025),
                            child: ImageWidget(
                              controller: widget.controller,
                              path: widget.artist.songs.first.path,
                            ),
                          ),

                        ),
                      ),
                      Text(
                        widget.artist.name,
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
                        duration,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: smallSize,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      SizedBox(
                        height: height * 0.005,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              onPressed: () async {
                                //print("Playing ${widget.controller.indexNotifier.value}");
                                if(widget.controller.settings.playingSongsUnShuffled.equals(widget.artist.songs) == false){
                                  widget.controller.updatePlaying(widget.artist.songs);
                                }
                                await widget.controller.indexChange(widget.artist.songs.first);
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
                                print("Add ${widget.artist.name}");
                                // for(metadata1 song in allalbums[displayedalbum].songs) {
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
                  itemCount: widget.artist.songs.length,
                  itemBuilder: (context, int index) {
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
                              //print(widget.controller.playingSongsUnShuffled[index].title);
                              if(widget.controller.settings.playingSongsUnShuffled.equals(widget.artist.songs) == false){
                                widget.controller.updatePlaying(widget.artist.songs);
                              }
                              await widget.controller.indexChange(widget.controller.settings.playingSongsUnShuffled[index]);
                              await widget.controller.playSong();
                            },
                            child: FutureBuilder(
                                future: widget.controller.imageRetrieve(widget.artist.songs[index].path, false),
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
                                                    widget.artist.songs[index].title.toString().length > 60 ? "${widget.artist.songs[index].title.toString().substring(0, 60)}..." : widget.artist.songs[index].title.toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: normalSize,
                                                    )
                                                ),
                                                SizedBox(
                                                  height: height * 0.005,
                                                ),
                                                Text(
                                                    widget.artist.songs[index].artists.toString().length > 60 ? "${widget.artist.songs[index].artists.toString().substring(0, 60)}..." : widget.artist.songs[index].artists.toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: smallSize,
                                                    )
                                                ),
                                              ]
                                          ),
                                          const Spacer(),
                                          Text(
                                              "${widget.artist.songs[index].duration ~/ 60}:${(widget.artist.songs[index].duration % 60).toString().padLeft(2, '0')}",
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
                                                    widget.artist.songs[index].title.toString().length > 60 ? "${widget.artist.songs[index].title.toString().substring(0, 60)}..." : widget.artist.songs[index].title.toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: normalSize,
                                                    )
                                                ),
                                                SizedBox(
                                                  height: height * 0.005,
                                                ),
                                                Text(
                                                    widget.artist.songs[index].artists.toString().length > 60 ? "${widget.artist.songs[index].artists.toString().substring(0, 60)}..." : widget.artist.songs[index].artists.toString(),
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: smallSize,
                                                    )
                                                ),
                                              ]
                                          ),
                                          const Spacer(),
                                          Text(
                                              "${widget.artist.songs[index].duration ~/ 60}:${(widget.artist.songs[index].duration % 60).toString().padLeft(2, '0')}",
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
              SizedBox(
                width: width * 0.02,
              ),
            ],
          ),
        ),
      ),
    );
  }
}