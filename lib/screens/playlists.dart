import 'dart:convert';
import 'dart:ui';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/functions.dart';
import 'dart:io';


class Playlists extends StatefulWidget{
  final functions functions1;
  Playlists({super.key, required this.functions1});

  @override
  _PlaylistsState createState() => _PlaylistsState(functions1);
}


class _PlaylistsState extends State<Playlists>{
  final functions functions1;
  _PlaylistsState(this.functions1);
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
        itemCount: functions1.allplaylists.length + 12,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            childAspectRatio: 0.8 ,
            maxCrossAxisExtent: MediaQuery.of(context).size.width* 0.14,
            crossAxisSpacing: MediaQuery.of(context).size.width * 0.01,
            mainAxisSpacing: MediaQuery.of(context).size.width * 0.01
        ),
        itemBuilder: (BuildContext context, int sindex) {
          return sindex == 0 ?
          Container(
            child:
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
                onTap: (){
                  functions1.found = functions1.allmetadata;
                  // setState(() {
                  //   found = allmetadata;
                  //   create = true;
                  //   myFocusNode.requestFocus();
                  // });
                },
                child: Column(
                  children: [
                    Container(
                        height: 250,
                        width: 250,
                        child: Stack(
                          children: [
                            Container(
                              height: 250,
                              width: 250,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            ClipRRect(
                              // Clip it cleanly.
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  color: Colors.black.withOpacity(0.3),
                                  alignment: Alignment.center,
                                  child: Icon(FluentIcons.collections_add_20_filled, size: 125, color: Colors.white,),
                                ),
                              ),
                            ),

                          ],
                        )
                    ),
                  ],
                ),
              ),

            ),
          ) :
          sindex < functions1.allplaylists.length?
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
                for(int i = functions1.allplaylists[sindex-1].featuredartists.length - 1; i >= 0 ; i--){
                  if(artistsforalbum.length + functions1.allplaylists[sindex-1].featuredartists[i].name.length < 75)
                    artistsforalbum = artistsforalbum + functions1.allplaylists[sindex-1].featuredartists[i].name + ", ";
                  else{
                    artistsforalbum = artistsforalbum.substring(0, artistsforalbum.length - 2);
                    artistsforalbum = artistsforalbum + " and " + (functions1.allplaylists[sindex-1].featuredartists.length - i).toString() + " more";
                    break;
                  }
                }
                if(artistsforalbum.endsWith(", "))
                  artistsforalbum = artistsforalbum.substring(0, artistsforalbum.length - 2);
                artistsforalbum.replaceAll("  ", " ").replaceAll(" , ", ", ");
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

                          functions1.allplaylists[sindex].songs.first.imageloaded ?
                          Container(
                            decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10),
                                image: DecorationImage(
                                  fit: BoxFit.cover,
                                  image: Image.memory(functions1.allplaylists[sindex].songs.first.image).image,
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
                                  image: Image.memory(File("assets\\bg.png").readAsBytesSync()).image,
                                )
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ) :
                          FutureBuilder(
                            future: functions1.imageretrieve(functions1.allplaylists[sindex].songs.first.path),
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
                                        image: Image.memory(File("assets\\bg.png").readAsBytesSync()).image,
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
                    functions1.allplaylists[sindex].name.length > 35 ? functions1.allplaylists[sindex].name.substring(0, 35) + "..." : functions1.allplaylists[sindex].name,
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