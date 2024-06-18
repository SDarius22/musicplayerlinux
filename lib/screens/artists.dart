import 'dart:convert';
import 'dart:ui';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/functions.dart';
import 'dart:io';


class Artists extends StatefulWidget{
  final functions functions1;
  Artists({super.key, required this.functions1});

  @override
  _ArtistsState createState() => _ArtistsState(functions1);
}


class _ArtistsState extends State<Artists>{
  final functions functions1;
  _ArtistsState(this.functions1);
  int _hovereditem = -1;
  bool loading = false;
  ScrollController _scrollController = ScrollController(initialScrollOffset: 0.0);
  int displayedalbum = -1;
  String artistsforalbum = "", playlistname = "New playlist";



  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: GridView.builder(
        cacheExtent: 1000,
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
        controller: _scrollController,
        itemCount: functions1.allartists.length + 12,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            childAspectRatio: 0.8 ,
            maxCrossAxisExtent: MediaQuery.of(context).size.width* 0.14,
            crossAxisSpacing: MediaQuery.of(context).size.width * 0.01,
            mainAxisSpacing: MediaQuery.of(context).size.width * 0.01
        ),
        itemBuilder: (BuildContext context, int sindex) {
          return sindex < functions1.allartists.length?
          MouseRegion(
            cursor: SystemMouseCursors.click,
            onEnter: (event){
              setState(() {
                _hovereditem = sindex;
              });
            },
            onExit: (event){
              setState(() {
                _hovereditem = -1;
              });
            },
            child: GestureDetector(
              onTap: () {
                setState(() {
                  displayedalbum = sindex;
                });
              },
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      height: MediaQuery.of(context).size.width * 0.2,
                      margin: EdgeInsets.only(bottom: 10),
                      child: Stack(
                        children: [

                          functions1.allartists[sindex].songs.first.imageloaded ?
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: Image.memory(functions1.allartists[sindex].songs.first.image).image,
                                )
                            ),
                          ) :
                          functions1.loading?
                          Container(
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
                          ) :
                          FutureBuilder(
                            future: functions1.imageretrieve(functions1.allartists[sindex].songs.first.path),
                            builder: (ctx, snapshot) {
                              if (snapshot.hasData) {
                                return
                                  Container(
                                    decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(10),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: Image.memory(snapshot.data!).image,
                                        )
                                    ),
                                  );
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
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }
                            },
                          ),
                          if (_hovereditem == sindex)
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
                                        // _songstoadd.add(functions1.allmetadata[sindex]);
                                        // setState(() {
                                        //   addelement = true;
                                        // });
                                      },
                                        padding: EdgeInsets.all(0),
                                        icon:
                                        Icon(FluentIcons.add_12_filled, color: Colors.white, size: 40,),
                                      ),

                                      Icon(FluentIcons.open_16_filled, size: 110, color: Colors.white,),

                                      IconButton(onPressed: (){
                                        functions1.playingsongs.clear();
                                        functions1.playingsongs_unshuffled.clear();

                                        functions1.playingsongs.addAll(functions1.allalbums[sindex].songs);
                                        functions1.playingsongs_unshuffled.addAll(functions1.allalbums[sindex].songs);

                                        if(functions1.shuffle == true)
                                          functions1.playingsongs.shuffle();

                                        var file = File("assets/settings.json");
                                        functions1.settings1.lastplaying.clear();

                                        for(int i = 0; i < functions1.playingsongs.length; i++){
                                          functions1.settings1.lastplaying.add(functions1.playingsongs[i].path);
                                        }
                                        functions1.settings1.lastplayingindex = functions1.playingsongs.indexOf(functions1.playingsongs_unshuffled[0]);
                                        file.writeAsStringSync(jsonEncode(functions1.settings1.toJson()));

                                        functions1.index = functions1.settings1.lastplayingindex;
                                        functions1.playSong();
                                      },
                                        padding: EdgeInsets.all(0),
                                        icon: Icon(FluentIcons.play_12_filled, color: Colors.white, size: 40,),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Text(
                    functions1.allartists[sindex].name.length > 35 ? functions1.allartists[sindex].name.substring(0, 35) + "..." : functions1.allartists[sindex].name,
                    style: TextStyle(
                      color: Colors.white,
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
      ),
    );
  }

}