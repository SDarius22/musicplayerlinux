import 'dart:ui';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import '../controller/controller.dart';


class Playlists extends StatefulWidget{
  final Controller controller;
  const Playlists({super.key, required this.controller});

  @override
  _PlaylistsState createState() => _PlaylistsState();
}


class _PlaylistsState extends State<Playlists>{
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
        itemCount: widget.controller.repo.playlists.length + 12,
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
                  widget.controller.found.value = widget.controller.repo.songs.value;
                  // setState(() {
                  //   found = repo.songs;
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
          sindex < widget.controller.repo.playlists.length?
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
                for(int i = widget.controller.repo.playlists[sindex-1].featuredartists.length - 1; i >= 0 ; i--){
                  if(artistsforalbum.length + widget.controller.repo.playlists[sindex-1].featuredartists[i].name.length < 75)
                    artistsforalbum = artistsforalbum + widget.controller.repo.playlists[sindex-1].featuredartists[i].name + ", ";
                  else{
                    artistsforalbum = artistsforalbum.substring(0, artistsforalbum.length - 2);
                    artistsforalbum = artistsforalbum + " and " + (widget.controller.repo.playlists[sindex-1].featuredartists.length - i).toString() + " more";
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
                      // child: Stack(
                      //   children: [
                      //
                      //     widget.controller.repo.playlists[sindex].songs.first.imageloaded ?
                      //     Container(
                      //       decoration: BoxDecoration(
                      //           color: Colors.black,
                      //           borderRadius: BorderRadius.circular(10),
                      //           image: DecorationImage(
                      //             fit: BoxFit.cover,
                      //             image: Image.memory(widget.controller.repo.playlists[sindex].songs.first.image).image,
                      //           )
                      //       ),
                      //     ) :
                      //     widget.controller.loading?
                      //     Container(
                      //       decoration: BoxDecoration(
                      //           color: Colors.black,
                      //           borderRadius: BorderRadius.circular(10),
                      //           image: DecorationImage(
                      //             fit: BoxFit.cover,
                      //             image: Image.memory(File("assets\\bg.png").readAsBytesSync()).image,
                      //           )
                      //       ),
                      //       child: const Center(
                      //         child: CircularProgressIndicator(
                      //           color: Colors.white,
                      //         ),
                      //       ),
                      //     ) :
                      //     FutureBuilder(
                      //       future: widget.controller.imageretrieve(widget.controller.repo.playlists[sindex].songs.first.path),
                      //       builder: (ctx, snapshot) {
                      //         if (snapshot.hasData) {
                      //           return
                      //             Container(
                      //               decoration: BoxDecoration(
                      //                   color: Colors.black,
                      //                   borderRadius: BorderRadius.circular(10),
                      //                   image: DecorationImage(
                      //                     fit: BoxFit.cover,
                      //                     image: Image.memory(snapshot.data!).image,
                      //                   )
                      //               ),
                      //             );
                      //         }
                      //         else if (snapshot.hasError) {
                      //           return Center(
                      //             child: Text(
                      //               '${snapshot.error} occurred',
                      //               style: TextStyle(fontSize: 18),
                      //             ),
                      //           );
                      //         } else{
                      //           return Container(
                      //             decoration: BoxDecoration(
                      //                 color: Colors.black,
                      //                 borderRadius: BorderRadius.circular(10),
                      //                 image: DecorationImage(
                      //                   fit: BoxFit.cover,
                      //                   image: Image.memory(File("assets\\bg.png").readAsBytesSync()).image,
                      //                 )
                      //             ),
                      //             child: Center(
                      //               child: CircularProgressIndicator(
                      //                 color: Colors.white,
                      //               ),
                      //             ),
                      //           );
                      //         }
                      //       },
                      //     ),
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
                      //                   // _songstoadd.add(widget.controller.repo.songs[sindex]);
                      //                   // setState(() {
                      //                   //   addelement = true;
                      //                   // });
                      //                 },
                      //                   padding: EdgeInsets.all(0),
                      //                   icon:
                      //                   Icon(FluentIcons.add_12_filled, color: Colors.white, size: 40,),
                      //                 ),
                      //
                      //                 widget.controller.playingsongs[widget.controller.index] == widget.controller.repo.songs[sindex] && widget.controller.playingNotifier.value == true ? Icon(FluentIcons.pause_32_filled, size: 100, color: Colors.white,) : Icon(FluentIcons.play_32_filled, size: 100, color: Colors.white,),
                      //
                      //                 IconButton(onPressed: (){
                      //                   int indextodisplay = 0;
                      //                   for(int i = 0; i < widget.controller.allalbums.length; i++){
                      //                     if(widget.controller.allalbums[i].name == widget.controller.repo.songs[sindex].album){
                      //                       indextodisplay = i;
                      //                       break;
                      //                     }
                      //                   }
                      //                   artistsforalbum = '';
                      //                   for(int i = widget.controller.allalbums[indextodisplay].featuredartists.length - 1; i >= 0 ; i--){
                      //                     if(artistsforalbum.length + widget.controller.allalbums[indextodisplay].featuredartists[i].name.length < 75)
                      //                       artistsforalbum = artistsforalbum + widget.controller.allalbums[indextodisplay].featuredartists[i].name + ", ";
                      //                     else{
                      //                       artistsforalbum = artistsforalbum.substring(0, artistsforalbum.length - 2);
                      //                       artistsforalbum = artistsforalbum + " and " + (widget.controller.allalbums[indextodisplay].featuredartists.length - i).toString() + " more";
                      //                       break;
                      //                     }
                      //                   }
                      //                   if(artistsforalbum.endsWith(", ")) {
                      //                     artistsforalbum = artistsforalbum.substring(0, artistsforalbum.length - 2);
                      //                   }
                      //                   artistsforalbum.replaceAll("  ", " ").replaceAll(" , ", ", ");
                      //                   setState(() {
                      //                     displayedalbum = indextodisplay;
                      //                   });
                      //                 },
                      //                   padding: EdgeInsets.all(0),
                      //                   icon: Icon(FluentIcons.album_20_filled, color: Colors.white, size: 40,),
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
                    widget.controller.repo.playlists[sindex].name.length > 35 ? widget.controller.repo.playlists[sindex].name.substring(0, 35) + "..." : widget.controller.repo.playlists[sindex].name,
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