import 'dart:convert';
import 'dart:ui';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/functions.dart';
import 'dart:io';


class Tracks extends StatefulWidget{
  final functions functions1;
  Tracks({super.key, required this.functions1});

  @override
  _TracksState createState() => _TracksState(functions1);
}


class _TracksState extends State<Tracks>{
  final functions functions1;
  _TracksState(this.functions1);
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
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.01),
        controller: _scrollController,
        itemCount: functions1.allmetadata.length + 12,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            childAspectRatio: 0.8 ,
            maxCrossAxisExtent: MediaQuery.of(context).size.width* 0.14,
            crossAxisSpacing: MediaQuery.of(context).size.width * 0.01,
            mainAxisSpacing: MediaQuery.of(context).size.width * 0.01
        ),
        itemBuilder: (BuildContext context, int sindex) {
          return sindex < functions1.allmetadata.length?
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
                print("Playing ${functions1.index}");
                if (functions1.playing && functions1.playingsongs[functions1.index].path == functions1.allmetadata[sindex].path) {
                  functions1.audioPlayer?.pause();
                  functions1.playing = false;
                }
                else {
                  functions1.playingsongs.clear();
                  functions1.playingsongs_unshuffled.clear();

                  functions1.playingsongs.addAll(functions1.allmetadata);
                  functions1.playingsongs_unshuffled.addAll(functions1.allmetadata);

                  if(functions1.shuffle == true)
                    functions1.playingsongs.shuffle();

                  var file = File("assets/settings.json");
                  functions1.settings1.lastplaying.clear();

                  for(int i = 0; i < functions1.playingsongs.length; i++){
                    functions1.settings1.lastplaying.add(functions1.playingsongs[i].path);
                  }
                  functions1.settings1.lastplayingindex = sindex;
                  file.writeAsStringSync(jsonEncode(functions1.settings1.toJson()));

                  functions1.index = functions1.playingsongs.indexOf(functions1.allmetadata[sindex]);
                  functions1.playSong();
                }
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
                            functions1.allmetadata[sindex].imageloaded ?
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: BorderRadius.circular(10),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: Image.memory(functions1.allmetadata[sindex].image).image,
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
                              future: functions1.imageretrieve(functions1.allmetadata[sindex].path),
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

                                      functions1.playingsongs[functions1.index] == functions1.allmetadata[sindex] && functions1.playing == true ? Icon(FluentIcons.pause_32_filled, size: 100, color: Colors.white,) : Icon(FluentIcons.play_32_filled, size: 100, color: Colors.white,),

                                      IconButton(onPressed: (){
                                        int indextodisplay = 0;
                                        for(int i = 0; i < functions1.allalbums.length; i++){
                                          if(functions1.allalbums[i].name == functions1.allmetadata[sindex].album){
                                            indextodisplay = i;
                                            break;
                                          }
                                        }
                                        artistsforalbum = '';
                                        for(int i = functions1.allalbums[indextodisplay].featuredartists.length - 1; i >= 0 ; i--){
                                          if(artistsforalbum.length + functions1.allalbums[indextodisplay].featuredartists[i].name.length < 75)
                                            artistsforalbum = artistsforalbum + functions1.allalbums[indextodisplay].featuredartists[i].name + ", ";
                                          else{
                                            artistsforalbum = artistsforalbum.substring(0, artistsforalbum.length - 2);
                                            artistsforalbum = artistsforalbum + " and " + (functions1.allalbums[indextodisplay].featuredartists.length - i).toString() + " more";
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
                      ),
                  ),
                  Text(
                    functions1.allmetadata[sindex].title.length > 35 ? functions1.allmetadata[sindex].title.substring(0, 35) + "..." : functions1.allmetadata[sindex].title,
                    style: TextStyle(
                      color: functions1.playingsongs[functions1.index] == functions1.allmetadata[sindex] ? Colors.blue : Colors.white,
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