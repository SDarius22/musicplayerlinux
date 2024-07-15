import 'dart:io';
import 'dart:ui';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hovering/hovering.dart';
import 'package:musicplayer/screens/album_widget.dart';
import '../controller/controller.dart';


class Albums extends StatefulWidget{
  final Controller controller;
  const Albums({super.key, required this.controller});

  @override
  _AlbumsState createState() => _AlbumsState();
}


class _AlbumsState extends State<Albums>{

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // var boldSize = height * 0.025;
    // var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    return GridView.builder(
        padding: EdgeInsets.all(width * 0.01),
        itemCount: widget.controller.repo.albums.length + 7,
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
          childAspectRatio: 0.85,
          maxCrossAxisExtent: width * 0.125,
          crossAxisSpacing: width * 0.0125,
          mainAxisSpacing: width * 0.0125,
        ),
        itemBuilder: (BuildContext context, int index) {
          return index < widget.controller.repo.albums.length?
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                /// Something like navigate to album
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return AlbumWidget(controller: widget.controller, album: widget.controller.repo.albums[index]);
                }));

                // for(int i = widget.controller.repo.albums[index].featuredartists.length - 1; i >= 0 ; i--){
                //   if(artistsforalbum.length + widget.controller.repo.albums[index].featuredartists[i].name.length < 75)
                //     artistsforalbum = artistsforalbum + widget.controller.repo.albums[index].featuredartists[i].name + ", ";
                //   else{
                //     artistsforalbum = artistsforalbum.substring(0, artistsforalbum.length - 2);
                //     artistsforalbum = artistsforalbum + " and " + (widget.controller.repo.albums[index].featuredartists.length - i).toString() + " more";
                //     break;
                //   }
                // }
                // if(artistsforalbum.endsWith(", "))
                //   artistsforalbum = artistsforalbum.substring(0, artistsforalbum.length - 2);
                // artistsforalbum.replaceAll("  ", " ").replaceAll(" , ", ", ");
                // setState(() {
                //   displayedalbum = index;
                // });
              },
              child: Column(
                children: [
                  AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      height: width * 0.2,
                      margin: EdgeInsets.only(bottom: width * 0.005),
                      child: FutureBuilder(
                        future: widget.controller.imageRetrieve(widget.controller.repo.albums[index].songs.first.path, false),
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
                    ),
                  ),
                  Text(
                    widget.controller.repo.albums[index].name.length > 25 ?
                    "${widget.controller.repo.albums[index].name.substring(0, 25)}..." :
                    widget.controller.repo.albums[index].name,
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