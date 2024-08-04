import 'dart:io';
import 'dart:ui';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/screens/image_widget.dart';
import 'package:musicplayer/utils/hover_widget/stack_hover_widget.dart';
import 'package:musicplayer/utils/objectbox.g.dart';
import '../domain/playlist_type.dart';
import 'package:musicplayer/domain/metadata_type.dart';
import '../controller/controller.dart';

class AddScreen extends StatefulWidget {
  final Controller controller;
  final List<MetadataType> songs;
  const AddScreen({super.key, required this.controller, required this.songs});

  @override
  _AddScreenState createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  List<int> selected = [];
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    //var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    var query = widget.controller.playlistBox.query().order(PlaylistType_.name).build();
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: width,
          height: height,
          padding: EdgeInsets.only(
              top: height * 0.02,
              left: width * 0.01,
              right: width * 0.01,
              bottom: height * 0.02
          ),
          alignment: Alignment.center,
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    Text(
                      "Choose one or more playlists to add the selected songs to:",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: normalSize,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: (){
                        print("Add to new playlist");
                        for(int i in selected){
                          if(i == 0){
                            widget.controller.addToQueue(widget.songs);
                          }
                          else{
                            var playlist = query.find()[i-1];
                            playlist.songs.addAll(widget.songs);
                            widget.controller.playlistBox.put(playlist);
                          }
                        }
                        Navigator.pop(context);
                      },
                      child: Text(
                        "Done",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: normalSize
                        ),
                      )
                    ),

                  ],
                ),
                SizedBox(
                  height: height * 0.8,
                  child: GridView.builder(
                    padding: EdgeInsets.all(width * 0.01),
                    itemCount: query.find().length + 8,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      childAspectRatio: 0.8275,
                      maxCrossAxisExtent: width * 0.125,
                      crossAxisSpacing: width * 0.0125,
                      mainAxisSpacing: width * 0.0125,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      PlaylistType playlist = PlaylistType();
                      if(index > 0 && index <= query.find().length){
                        playlist = query.find()[index-1];
                      }
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            print("Tapped on $index");
                            setState(() {
                              selected.contains(index) ? selected.remove(index) : selected.add(index);
                            });
                          },
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(width * 0.01),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    if(index == 0)
                                      AspectRatio(
                                        aspectRatio: 1.0,
                                        child: StackHoverWidget(
                                          bottomWidget: Container(
                                            decoration: BoxDecoration(
                                                color: Colors.black,
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: Image.memory(File("assets/current_queue.png").readAsBytesSync()).image,
                                                )
                                            ),
                                          ),
                                          topWidget: ClipRRect(
                                            child: BackdropFilter(
                                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                              child: Container(
                                                color: Colors.black.withOpacity(0.3),
                                                alignment: Alignment.center,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    else
                                      ImageWidget(
                                        controller: widget.controller,
                                        path: playlist.songs.first.path,
                                      ),
                                    if(selected.contains(index))
                                      BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                        child: Container(
                                          alignment: Alignment.center,
                                          child: Icon(
                                            FluentIcons.checkmark_16_filled,
                                            size: height * 0.1,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),

                                  ],
                                ),

                              ),
                              SizedBox(
                                height: height * 0.004,
                              ),
                              Text(
                                index == 0 ? "Current Queue" : playlist.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: smallSize,
                                    fontWeight: FontWeight.normal
                                ),
                              )


                            ],
                          ),
                        ),
                      );
                      // return index == 0 ?
                      //     StackHoverWidget(
                      //         topWidget: ClipRRect(
                      //           child: BackdropFilter(
                      //             filter: ImageFilter.blur(
                      //                 sigmaX: selected.contains(index) ? 10 : 0,
                      //                 sigmaY: selected.contains(index) ? 10 : 0
                      //             ),
                      //             child: Container(
                      //               color: _queueinatp ? Colors.black.withOpacity(0.3) : Colors.transparent,
                      //               alignment: Alignment.center,
                      //               child: _queueinatp ? Icon(FluentIcons.checkmark_16_filled, size: 100, color: Colors.white,) : null,
                      //             ),
                      //           ),
                      //         ),
                      //         bottomWidget: Container(
                      //           height: 250,
                      //           width: 250,
                      //           child: DecoratedBox(
                      //             decoration: BoxDecoration(
                      //               borderRadius: BorderRadius.circular(10),
                      //             ),
                      //             child: Icon(FluentIcons.text_bullet_list_add_20_filled, size: 100, color: Colors.white,),
                      //           ),
                      //         ),
                      //     ) :
                      // // MouseRegion(
                      // //   cursor: SystemMouseCursors.click,
                      // //   onEnter: (event){
                      // //     setState(() {
                      // //       _hovereditem3 = -2;
                      // //     });
                      // //   },
                      // //   onExit: _incrementExit3,
                      // //   child: GestureDetector(
                      // //     onTap: (){
                      // //       print("tapped on queue");
                      // //       if(_queueinatp)
                      // //       {
                      // //         setState(() {
                      // //           _queueinatp = false;
                      // //         });
                      // //       }
                      // //       else
                      // //       {
                      // //         setState(() {
                      // //           _queueinatp = true;
                      // //         });
                      // //       }
                      // //     },
                      // //     child: Column(
                      // //       children: [
                      // //         Container(
                      // //             height: 200,
                      // //             width: 200,
                      // //             child: Stack(
                      // //               children: [
                      // //
                      // //
                      // //
                      // //               ],
                      // //             )
                      // //         ),
                      // //
                      // //         Container(
                      // //           height: 10,
                      // //         ),
                      // //         Text(
                      // //           "Current queue",
                      // //           style: TextStyle(
                      // //             color: Colors.white,
                      // //             fontSize: 18,
                      // //             fontWeight: FontWeight.bold,
                      // //           ),
                      // //           textAlign: TextAlign.center,
                      // //         ),
                      // //       ],
                      // //     ),
                      // //   ),
                      // //
                      // // ) :
                      // Container(
                      //   child:
                      //   MouseRegion(
                      //     cursor: SystemMouseCursors.click,
                      //     onEnter: (event){
                      //       setState(() {
                      //         _hovereditem3 = index-1;
                      //       });
                      //     },
                      //     onExit: _incrementExit3,
                      //     child: GestureDetector(
                      //       onTap: (){
                      //         print("tapped on ${allplaylists[index-1].name}");
                      //         if(addtoplaylists.contains(allplaylists[index-1])){
                      //           addtoplaylists.remove(allplaylists[index-1]);
                      //         }
                      //         else{
                      //           addtoplaylists.add(allplaylists[index-1]);
                      //         }
                      //         setState(() {
                      //
                      //         });
                      //       },
                      //       child: Column(
                      //         children: [
                      //           Container(
                      //               height: 200,
                      //               width: 200,
                      //               child: Stack(
                      //                 children: [
                      //                   allplaylists[index-1].songs.first.imageloaded?
                      //                   Container(
                      //                       height: 200,
                      //                       width: 200,
                      //                       child: DecoratedBox(
                      //                         decoration: BoxDecoration(
                      //                             color: Colors.black,
                      //                             borderRadius: BorderRadius.circular(10),
                      //                             image: DecorationImage(
                      //                               fit: BoxFit.cover,
                      //                               image: Image.memory(allplaylists[index-1].songs.first.image).image,
                      //                             )
                      //                         ),
                      //                       )
                      //                   ):
                      //                   loading?
                      //                   Container(
                      //                       height: 200,
                      //                       width: 200,
                      //                       child: DecoratedBox(
                      //                         decoration: BoxDecoration(
                      //                             color: Colors.black,
                      //                             borderRadius: BorderRadius.circular(10),
                      //                             image: DecorationImage(
                      //                               fit: BoxFit.cover,
                      //                               image: Image.memory(File("assets\\bg.png").readAsBytesSync()).image,
                      //                             )
                      //                         ),
                      //                         child: Center(
                      //                           child: CircularProgressIndicator(
                      //                             color: Colors.white,
                      //                           ),
                      //                         ),
                      //                       )
                      //                   ):
                      //                   FutureBuilder(
                      //                     builder: (ctx, snapshot) {
                      //                       if (snapshot.hasData) {
                      //                         return
                      //                           Container(
                      //                               height: 200,
                      //                               width: 200,
                      //                               child: DecoratedBox(
                      //                                 decoration: BoxDecoration(
                      //                                     color: Colors.black,
                      //                                     borderRadius: BorderRadius.circular(10),
                      //                                     image: DecorationImage(
                      //                                       fit: BoxFit.cover,
                      //                                       image: Image.memory(snapshot.data!).image,
                      //                                     )
                      //                                 ),
                      //                               )
                      //                           );
                      //                       }
                      //                       else if (snapshot.hasError) {
                      //                         return Center(
                      //                           child: Text(
                      //                             '${snapshot.error} occurred',
                      //                             style: TextStyle(fontSize: 18),
                      //                           ),
                      //                         );
                      //                       } else{
                      //                         return
                      //                           Container(
                      //                               height: 200,
                      //                               width: 200,
                      //                               child: DecoratedBox(
                      //                                 decoration: BoxDecoration(
                      //                                     color: Colors.black,
                      //                                     borderRadius: BorderRadius.circular(10),
                      //                                     image: DecorationImage(
                      //                                       fit: BoxFit.cover,
                      //                                       image: Image.memory(File("assets\\bg.png").readAsBytesSync()).image,
                      //                                     )
                      //                                 ),
                      //                                 child: Center(
                      //                                   child: CircularProgressIndicator(
                      //                                     color: Colors.white,
                      //                                   ),
                      //                                 ),
                      //                               )
                      //                           );
                      //                       }
                      //                     },
                      //                     future: imageretriever(allplaylists[index-1].songs.first.path),
                      //                   ),
                      //                   ClipRRect(
                      //                     // Clip it cleanly.
                      //                     child: BackdropFilter(
                      //                       filter: addtoplaylists.contains(allplaylists[index-1]) || _hovereditem3 == index-1 ? ImageFilter.blur(sigmaX: 10, sigmaY: 10) : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                      //                       child: Container(
                      //                         color: addtoplaylists.contains(allplaylists[index-1]) ? Colors.black.withOpacity(0.3) : Colors.transparent,
                      //                         alignment: Alignment.center,
                      //                         child: addtoplaylists.contains(allplaylists[index-1]) ? Icon(FluentIcons.checkmark_16_filled, size: 100, color: Colors.white,) : null,
                      //                       ),
                      //                     ),
                      //                   ),
                      //
                      //                 ],
                      //               )
                      //           ),
                      //
                      //           Container(
                      //             height: 10,
                      //           ),
                      //           Text(
                      //             allplaylists[index-1].name.length > 45 ? allplaylists[index-1].name.substring(0, 45) + "..." : allplaylists[index-1].name,
                      //             style: TextStyle(
                      //               color: Colors.white,
                      //               fontSize: 18,
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //             textAlign: TextAlign.center,
                      //           ),
                      //         ],
                      //       ),
                      //     ),
                      //
                      //   ),
                      // );

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