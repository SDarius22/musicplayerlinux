import 'dart:io';
import 'dart:ui';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hovering/hovering.dart';
import '../controller/controller.dart';


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
    return GridView.builder(
      padding: EdgeInsets.all(width * 0.01),
      itemCount: widget.controller.repo.artists.length + 7,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        childAspectRatio: 0.85,
        maxCrossAxisExtent: width * 0.125,
        crossAxisSpacing: width * 0.0125,
        mainAxisSpacing: width * 0.0125,
      ),
      itemBuilder: (BuildContext context, int index) {
        return index < widget.controller.repo.artists.length?
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              /// Something like navigate to artist page
            },
            child: Column(
              children: [
                AspectRatio(
                  aspectRatio: 1.0,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    height: width * 0.2,
                    margin: EdgeInsets.only(bottom: width * 0.005),
                    child: FutureBuilder(
                      future: widget.controller.imageRetrieve(widget.controller.repo.artists[index].songs.first.path, false),
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
                                              /// play all the songs of the artist
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
                    // child: Stack(
                    //   children: [
                    //     if (_hovereditem == sindex)
                    //       ClipRRect(
                    //         // Clip it cleanly.
                    //         child: BackdropFilter(
                    //           filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    //           child: Container(
                    //             color: Colors.black.withOpacity(0.3),
                    //             alignment: Alignment.center,
                    //             child: Row(
                    //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    //               crossAxisAlignment: CrossAxisAlignment.center,
                    //               children: [
                    //                 IconButton(onPressed: (){
                    //                   print("Add ${sindex}");
                    //                   // _songstoadd.add(widget.controller.allmetadata[sindex]);
                    //                   // setState(() {
                    //                   //   addelement = true;
                    //                   // });
                    //                 },
                    //                   padding: EdgeInsets.all(0),
                    //                   icon:
                    //                   Icon(FluentIcons.add_12_filled, color: Colors.white, size: 40,),
                    //                 ),
                    //
                    //                 Icon(FluentIcons.open_16_filled, size: 110, color: Colors.white,),
                    //
                    //                 IconButton(onPressed: (){
                    //                   widget.controller.playingsongs.clear();
                    //                   widget.controller.playingsongs_unshuffled.clear();
                    //
                    //                   widget.controller.playingsongs.addAll(widget.controller.allalbums[sindex].songs);
                    //                   widget.controller.playingsongs_unshuffled.addAll(widget.controller.allalbums[sindex].songs);
                    //
                    //                   if(widget.controller.shuffle == true)
                    //                     widget.controller.playingsongs.shuffle();
                    //
                    //                   var file = File("assets/settings.json");
                    //                   widget.controller.settings1.lastplaying.clear();
                    //
                    //                   for(int i = 0; i < widget.controller.playingsongs.length; i++){
                    //                     widget.controller.settings1.lastplaying.add(widget.controller.playingsongs[i].path);
                    //                   }
                    //                   widget.controller.settings1.lastplayingindex = widget.controller.playingsongs.indexOf(widget.controller.playingsongs_unshuffled[0]);
                    //                   file.writeAsStringSync(jsonEncode(widget.controller.settings1.toJson()));
                    //
                    //                   widget.controller.index = widget.controller.settings1.lastplayingindex;
                    //                   widget.controller.playSong();
                    //                 },
                    //                   padding: EdgeInsets.all(0),
                    //                   icon: Icon(FluentIcons.play_12_filled, color: Colors.white, size: 40,),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //   ],
                    // ),
                  ),
                ),
                Text(
                  widget.controller.repo.artists[index].name.length > 25 ?
                  "${widget.controller.repo.artists[index].name.substring(0, 25)}..." :
                  widget.controller.repo.artists[index].name,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: smallSize,
                    fontWeight: FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
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