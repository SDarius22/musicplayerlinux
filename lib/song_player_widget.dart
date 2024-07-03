import 'dart:io';
import 'dart:convert';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hovering/hovering.dart';
import 'package:musicplayer/multivaluelistenablebuilder/mvlb.dart';
import 'controller/controller.dart';
import 'domain/metadata_type.dart';
import 'lyric_reader/lyrics_reader.dart';
import '../progress_bar/audio_video_progress_bar.dart';

class SongPlayerWidget extends StatefulWidget {
  final Controller controller;
  const SongPlayerWidget(
      {super.key,
        required this.controller,
      });

  @override
  _SongPlayerWidget createState() => _SongPlayerWidget();
}

class _SongPlayerWidget extends State<SongPlayerWidget> {
  late ScrollController itemScrollController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      itemScrollController = ScrollController();
    });
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    widget.controller.updateContext(context);
    return MultiValueListenableBuilder(
      valueListenables: [widget.controller.minimizedNotifier, widget.controller.indexNotifier],
      builder: (context, values, child){
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.linear,
          height: values[0] ? height * 0.175 : height,
          width: values[0] ? width * 0.925 : width,
          padding: EdgeInsets.only(
            left: width * 0.01,
            right: width * 0.01,
            top: height * 0.01,
            bottom: height * 0.01,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0E0E0E),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            children: [
              //Song Artwork. Details or List and Lyrics
              ValueListenableBuilder(
                valueListenable: widget.controller.listNotifier,
                builder: (context, value, child){
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    height: values[0] ? height * 0.15 : height * 0.55,
                    width: values[0] ? width * 0.15 : width * 0.55,
                    padding: values[0]? EdgeInsets.zero : EdgeInsets.only(
                      left: width * 0.02,
                      top: height * 0.05,
                      bottom: height * 0.05,
                    ),
                    child: value == true?
                    // List of Songs
                    ListView.builder(
                      controller: itemScrollController,
                      itemCount: widget.controller.playingSongsUnShuffled.length,
                      itemBuilder: (context, int index) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: height * 0.125,
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: (){
                                print(widget.controller.playingSongsUnShuffled[index].title);
                                widget.controller.indexNotifier.value = widget.controller.playingSongs.indexOf(widget.controller.playingSongsUnShuffled[index]);
                                var file = File("assets/settings.json");
                                widget.controller.settings.lastPlayingIndex = widget.controller.indexNotifier.value;
                                file.writeAsStringSync(jsonEncode(widget.controller.settings.toJson()));
                                widget.controller.indexChange(widget.controller.indexNotifier.value);
                                widget.controller.playSong();
                              },
                              child: FutureBuilder(
                                future: widget.controller.imageRetrieve(widget.controller.repo.songs.value[index].path, false),
                                builder: (context, snapshot){
                                  return HoverWidget(
                                    hoverChild: Container(
                                      padding: EdgeInsets.all(width * 0.005),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(height * 0.01),
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
                                                      borderRadius: BorderRadius.circular(height * 0.01),
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: Image.memory(snapshot.data!).image,
                                                      )
                                                  ),
                                                ),
                                              ),
                                            )
                                          else if (snapshot.hasError)
                                            Center(
                                              child: Text(
                                                '${snapshot.error} occurred',
                                                style: TextStyle(fontSize: normalSize),
                                              ),
                                            )
                                          else
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
                                            ),
                                          SizedBox(
                                            width: width * 0.01,
                                          ),
                                          Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    widget.controller.playingSongsUnShuffled[index].title.toString().length > 60 ? widget.controller.playingSongsUnShuffled[index].title.toString().substring(0, 60) + "..." : widget.controller.playingSongsUnShuffled[index].title.toString(),
                                                    style: TextStyle(
                                                      color: widget.controller.playingSongsUnShuffled[index] != widget.controller.playingSongs[widget.controller.indexNotifier.value] ? Colors.white : Colors.blue,
                                                      fontSize: normalSize,
                                                    )
                                                ),
                                                Container(
                                                  height: 5,
                                                ),
                                                Text(widget.controller.playingSongsUnShuffled[index].artists.toString().length > 60 ? widget.controller.playingSongsUnShuffled[index].artists.toString().substring(0, 60) + "..." : widget.controller.playingSongsUnShuffled[index].artists.toString(),
                                                    style: TextStyle(
                                                      color: widget.controller.playingSongsUnShuffled[index] != widget.controller.playingSongs[widget.controller.indexNotifier.value] ? Colors.white : Colors.blue,
                                                      fontSize: smallSize,
                                                    )
                                                ),
                                              ]
                                          ),
                                          const Spacer(),
                                          Text(
                                              "${widget.controller.playingSongs[index].duration ~/ 60}:${(widget.controller.playingSongs[index].duration % 60).toString().padLeft(2, '0')}",
                                              style: TextStyle(
                                                color: widget.controller.playingSongsUnShuffled[index] != widget.controller.playingSongs[widget.controller.indexNotifier.value] ? Colors.white : Colors.blue,
                                                fontSize: normalSize,
                                              )
                                          ),
                                          Container(
                                            width: 35,
                                          ),
                                        ],
                                      ),
                                    ),
                                    onHover: (event){
                                      print("Hovering");
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(width * 0.005),
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
                                                      borderRadius: BorderRadius.circular(height * 0.01),
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: Image.memory(snapshot.data!).image,
                                                      )
                                                  ),
                                                ),
                                              ),
                                            )
                                          else if (snapshot.hasError)
                                            Center(
                                              child: Text(
                                                '${snapshot.error} occurred',
                                                style: TextStyle(fontSize: normalSize),
                                              ),
                                            )
                                          else
                                            Container(
                                              height: height * 0.1,
                                              width: height * 0.1,
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
                                            ),
                                          SizedBox(
                                            width: width * 0.01,
                                          ),
                                          Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    widget.controller.playingSongsUnShuffled[index].title.toString().length > 60 ? widget.controller.playingSongsUnShuffled[index].title.toString().substring(0, 60) + "..." : widget.controller.playingSongsUnShuffled[index].title.toString(),
                                                    style: TextStyle(
                                                      color: widget.controller.playingSongsUnShuffled[index] != widget.controller.playingSongs[widget.controller.indexNotifier.value] ? Colors.white : Colors.blue,
                                                      fontSize: normalSize,
                                                    )
                                                ),
                                                Container(
                                                  height: 5,
                                                ),
                                                Text(widget.controller.playingSongsUnShuffled[index].artists.toString().length > 60 ? widget.controller.playingSongsUnShuffled[index].artists.toString().substring(0, 60) + "..." : widget.controller.playingSongsUnShuffled[index].artists.toString(),
                                                    style: TextStyle(
                                                      color: widget.controller.playingSongsUnShuffled[index] != widget.controller.playingSongs[widget.controller.indexNotifier.value] ? Colors.white : Colors.blue,
                                                      fontSize: smallSize,
                                                    )
                                                ),
                                              ]
                                          ),
                                          const Spacer(),
                                          Text(
                                              "${widget.controller.playingSongs[index].duration ~/ 60}:${(widget.controller.playingSongs[index].duration % 60).toString().padLeft(2, '0')}",
                                              style: TextStyle(
                                                color: widget.controller.playingSongsUnShuffled[index] != widget.controller.playingSongs[widget.controller.indexNotifier.value] ? Colors.white : Colors.blue,
                                                fontSize: normalSize,
                                              )
                                          ),
                                          Container(
                                            width: 35,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              )
                              // child: Container(
                              //   color: _hovereditem2 == indexNotifier.value ? Color(0xFF242424) : Colors.transparent,
                              //   child: Row(
                              //     children: [
                              //       widget.controller.repo.songs[widget.controller.repo.songs.indexOf(widget.controller.playingSongsUnShuffled[indexNotifier.value])].imageloaded?
                              //       Container(
                              //         height: 100,
                              //         width: 100,
                              //         padding: EdgeInsets.only(left: 10),
                              //         decoration: BoxDecoration(
                              //             color: Colors.black,
                              //             borderRadius: BorderRadius.circular(10),
                              //             image: DecorationImage(
                              //               fit: BoxFit.cover,
                              //               image: Image.memory(widget.controller.repo.songs[widget.controller.repo.songs.indexOf(widget.controller.playingSongsUnShuffled[indexNotifier.value])].image).image,
                              //             )
                              //         ),
                              //       ) : loading == true?
                              //       Container(
                              //         height: 100,
                              //         width: 100,
                              //         padding: EdgeInsets.only(left: 10),
                              //         decoration: BoxDecoration(
                              //             color: Colors.black,
                              //             borderRadius: BorderRadius.circular(10),
                              //             image: DecorationImage(
                              //               fit: BoxFit.cover,
                              //               image: Image.memory(widget.controller.repo.songs[widget.controller.repo.songs.indexOf(widget.controller.playingSongsUnShuffled[indexNotifier.value])].image).image,
                              //             )
                              //         ),
                              //         child: const Center(
                              //           child: CircularProgressIndicator(
                              //             color: Colors.white,
                              //           ),
                              //         ),
                              //       ) : FutureBuilder(
                              //         future: widget.controller.imageretrieve(widget.controller.playingSongsUnShuffled[indexNotifier.value].path),
                              //         builder: (ctx, snapshot) {
                              //           if (snapshot.hasData) {
                              //             return
                              //               Container(
                              //                 height: 100,
                              //                 width: 100,
                              //                 padding: EdgeInsets.only(left: 10),
                              //                 decoration: BoxDecoration(
                              //                     color: Colors.black,
                              //                     borderRadius: BorderRadius.circular(10),
                              //                     image: DecorationImage(
                              //                       fit: BoxFit.cover,
                              //                       image: Image.memory(snapshot.data!).image,
                              //                     )
                              //                 ),
                              //               );
                              //           }
                              //           else if (snapshot.hasError) {
                              //             return Center(
                              //               child: Text(
                              //                 '${snapshot.error} occurred',
                              //                 style: TextStyle(fontSize: 18),
                              //               ),
                              //             );
                              //           } else{
                              //             return Container(
                              //               height: 100,
                              //               width: 100,
                              //               padding: EdgeInsets.only(left: 10),
                              //               decoration: BoxDecoration(
                              //                   color: Colors.black,
                              //                   borderRadius: BorderRadius.circular(10),
                              //                   image: DecorationImage(
                              //                     fit: BoxFit.cover,
                              //                     image: Image.memory(File("./assets/bg.png").readAsBytesSync()).image,
                              //                   )
                              //               ),
                              //               child: Center(
                              //                 child: CircularProgressIndicator(
                              //                   color: Colors.white,
                              //                 ),
                              //               ),
                              //             );
                              //           }
                              //         },
                              //       ),
                              //       Container(
                              //         width: 20,
                              //       ),
                              //       Column(
                              //           mainAxisAlignment: MainAxisAlignment.center,
                              //           crossAxisAlignment: CrossAxisAlignment.start,
                              //           children: [
                              //             Text(
                              //               widget.controller.playingSongsUnShuffled[indexNotifier.value].title.toString().length > 60 ? widget.controller.playingSongsUnShuffled[indexNotifier.value].title.toString().substring(0, 60) + "..." : widget.controller.playingSongsUnShuffled[indexNotifier.value].title.toString(),
                              //               style: widget.controller.playingSongsUnShuffled[indexNotifier.value] != widget.controller.playingSongs[widget.controller.indexNotifier.value] ? TextStyle(
                              //                 color: Colors.white,
                              //                 fontSize: 20,
                              //               ) : TextStyle(
                              //                 color: Colors.blue,
                              //                 fontSize: 20,
                              //               ),
                              //             ),
                              //             Container(
                              //               height: 5,
                              //             ),
                              //             Text(widget.controller.playingSongsUnShuffled[indexNotifier.value].artists.toString().length > 60 ? widget.controller.playingSongsUnShuffled[indexNotifier.value].artists.toString().substring(0, 60) + "..." : widget.controller.playingSongsUnShuffled[indexNotifier.value].artists.toString(),
                              //               style:  widget.controller.playingSongsUnShuffled[indexNotifier.value] != widget.controller.playingSongs[widget.controller.indexNotifier.value]  ? TextStyle(
                              //                 color: Colors.white,
                              //                 fontSize: 18,
                              //               ) : TextStyle(
                              //                 color: Colors.blue,
                              //                 fontSize: 18,
                              //               ),
                              //             ),
                              //           ]
                              //       ),
                              //       const Spacer(),
                              //       Text(
                              //         widget.controller.playingSongsUnShuffled[indexNotifier.value].durationString,
                              //         style:  widget.controller.playingSongsUnShuffled[indexNotifier.value] != widget.controller.playingSongs[widget.controller.indexNotifier.value]  ? TextStyle(
                              //           color: Colors.white,
                              //           fontSize: 18,
                              //         ) : TextStyle(
                              //           color: Colors.blue,
                              //           fontSize: 18,
                              //         ),
                              //       ),
                              //       Container(
                              //           width: 10
                              //       ),
                              //       _hovereditem2 == indexNotifier.value?
                              //       Column(
                              //         mainAxisAlignment: MainAxisAlignment.center,
                              //         crossAxisAlignment: CrossAxisAlignment.center,
                              //         children: [
                              //           GestureDetector(
                              //               onTap: (){
                              //                 print("add to playlist song ${widget.controller.playingSongsUnShuffled[indexNotifier.value]}");
                              //                 // _songstoadd.add(widget.controller.playingSongsUnShuffled[_index]);
                              //                 // if(addelement == false)
                              //                 //   setState(() {
                              //                 //     addelement = true;
                              //                 //   });
                              //               },
                              //               child: Icon(FluentIcons.add_12_filled, color: widget.controller.playingSongsUnShuffled[indexNotifier.value] != widget.controller.playingSongs[widget.controller.indexNotifier.value] ? Colors.white : Colors.blue, size: 25,)
                              //           ),
                              //
                              //           Container(
                              //             height: 10,
                              //           ),
                              //
                              //           GestureDetector(
                              //               onTap: (){
                              //                 //print("remove from queue song ${widget.controller.playingSongsUnShuffled[_index].title}");
                              //                 setState(() {
                              //                   if(widget.controller.playingSongsUnShuffled.length == 1){
                              //
                              //                     _usermessage = "You must have at least 1 song in queue";
                              //                     Future.delayed(const Duration(seconds: 5)).then((value) {
                              //                       setState(() {
                              //                         _usermessage = "No message";
                              //                       });
                              //                     });
                              //
                              //
                              //                   }else {
                              //                     metadata_type playingsong = widget.controller.playingSongs[widget.controller.indexNotifier.value];
                              //                     metadata_type playingsong2 = widget.controller.playingSongsUnShuffled[indexNotifier.value];
                              //                     // print(playingsong.title);
                              //                     widget.controller.playingSongs.removeAt(widget.controller.playingSongs.indexOf(widget.controller.playingSongsUnShuffled[indexNotifier.value]));
                              //                     widget.controller.playingSongsUnShuffled.removeAt(indexNotifier.value);
                              //
                              //                     if (playingsong2 == playingsong){
                              //
                              //                       setState(() {
                              //                         widget.controller.indexNotifier.value = widget.controller.playingSongs.indexOf(widget.controller.playingSongsUnShuffled[0]);
                              //                         widget.controller.lyricModelReset();
                              //                         widget.controller.sliderProgress = 0;
                              //                         widget.controller.playProgress = 0;
                              //                         widget.controller.currentpostlabel = "00:00";
                              //                       });
                              //                       if(widget.controller.playing == true) {
                              //                         widget.controller.playSong();
                              //                       }
                              //                       else{
                              //                         widget.controller.resetAudio();
                              //                       }
                              //                     }
                              //                     else {
                              //                       widget.controller.indexNotifier.value = widget.controller.playingSongs.indexOf(playingsong);
                              //                     }
                              //                     setState(() {
                              //
                              //                     });
                              //                   }
                              //                   var file = File(
                              //                       "assets/settings.json");
                              //                   widget.controller.settings1.lastplayingindex =
                              //                       widget.controller.indexNotifier.value;
                              //                   widget.controller.settings1.lastplaying.clear();
                              //                   for(int i = 0; i < widget.controller.playingSongsUnShuffled.length; i++){
                              //                     widget.controller.settings1.lastplaying.add(widget.controller.playingSongsUnShuffled[i].path);
                              //                   }
                              //                   file.writeAsStringSync(
                              //                       jsonEncode(widget.controller.settings1
                              //                           .toJson()));
                              //                 });
                              //               },
                              //               child: Icon(FluentIcons.subtract_12_filled, color: widget.controller.playingSongsUnShuffled[indexNotifier.value] != widget.controller.playingSongs[widget.controller.indexNotifier.value] ? Colors.white : Colors.blue, size: 25,)
                              //           ),
                              //         ],
                              //       ):
                              //       Container(width: 25,),
                              //     ],
                              //   ),
                              // ),
                            ),
                          )
                        );
                      },
                    ) :
                    // Song Details
                    Row(
                      children: [
                        // Song Artwork
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          padding: EdgeInsets.only(
                            left: values[0] ? width * 0.005  : width * 0.02,
                            right: values[0] ? width * 0.005 : width * 0.02,
                          ),
                          width: values[0] ? width * 0.09 : width * 0.27,
                          child: AspectRatio(
                            aspectRatio: 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                  color: Colors.black,
                                  borderRadius: values[0] ? BorderRadius.circular(width * 0.005) : BorderRadius.circular(width * 0.015),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: Image.memory(widget.controller.image).image,
                                  )
                              ),
                            ),
                          ),
                        ),
                        if (!values[0])
                        // Song Details
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                            padding: EdgeInsets.only(
                              left: width * 0.02,
                            ),
                            width: width * 0.25,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Track:",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: normalSize,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                SizedBox(
                                  height: height * 0.005,
                                ),
                                Text(
                                  widget.controller.playingSongs[widget.controller.indexNotifier.value].title.toString().length > 50 ? widget.controller.playingSongs[widget.controller.indexNotifier.value].title.toString().substring(0, 50) + "..." : widget.controller.playingSongs[widget.controller.indexNotifier.value].title.toString(),
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: boldSize,
                                    fontWeight: FontWeight.bold
                                    ,
                                  ),
                                ),
                                SizedBox(
                                  height: height * 0.03,
                                ),
                                Text(
                                  "Artists:",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: normalSize,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                SizedBox(
                                  height: height * 0.005,
                                ),
                                Text(
                                  widget.controller.playingSongs[widget.controller.indexNotifier.value].artists.toString().length > 60 ? widget.controller.playingSongs[widget.controller.indexNotifier.value].artists.toString().substring(0, 60) + "..." : widget.controller.playingSongs[widget.controller.indexNotifier.value].artists.toString(),
                                  style: TextStyle(
                                    fontSize: boldSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: height * 0.03,
                                ),
                                Text(
                                  "Album:",
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    fontSize: normalSize,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                                SizedBox(
                                  height: height * 0.005,
                                ),

                                Text(
                                  widget.controller.playingSongs[widget.controller.indexNotifier.value].album.toString().length > 60 ? widget.controller.playingSongs[widget.controller.indexNotifier.value].album.toString().substring(0, 60) + "..." : widget.controller.playingSongs[widget.controller.indexNotifier.value].album.toString(),
                                  style: TextStyle(
                                    fontSize: boldSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                }
              ),
              //Lyrics
              if(!values[0])
                MultiValueListenableBuilder(
                    valueListenables: [widget.controller.lyricModelNotifier, widget.controller.sliderNotifier, widget.controller.lyricUINotifier, widget.controller.playingNotifier, widget.controller.colorNotifier],
                    builder: (context, value, child){
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        padding: widget.controller.minimizedNotifier.value? EdgeInsets.zero : EdgeInsets.only(
                          top: height * 0.1,
                        ),
                        child: LyricsReader(
                          model: widget.controller.lyricModelNotifier.value,
                          position: widget.controller.sliderNotifier.value,
                          lyricUi: widget.controller.lyricUINotifier.value,
                          playing: widget.controller.playingNotifier.value,
                          size: Size(
                            width * 0.3,
                            height * 0.35,
                          ),
                          selectLineBuilder: (progress, confirm) {
                            return Row(
                              children: [
                                Icon(FluentIcons.play_12_filled, color: widget.controller.colorNotifier.value),
                                Expanded(
                                  child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                      onTap: () {
                                        confirm.call();
                                        setState(() {
                                          widget.controller.seekAudio(Duration(milliseconds: progress));
                                        });
                                      },
                                    ),
                                  ),
                                ),
                                Text(
                                  //progress.toString(),
                                  "${progress ~/ 1000 ~/ 60}:${(progress ~/ 1000 % 60).toString().padLeft(2, '0')}",
                                  style: TextStyle(color: widget.controller.colorNotifier.value),
                                )
                              ],
                            );
                          },
                          emptyBuilder: () => const Center(
                            child: Text(
                              "No lyrics",
                              style: TextStyle(color: Colors.white, fontFamily: 'Bahnscrift', fontSize: 20),
                            ),
                          ),
                        ),
                      );
                    }
                ),

              if(!values[0])
              Column(
                children: [
                  // Minimize/Maximize button
                  IconButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: (){
                        widget.controller.minimizedNotifier.value = !widget.controller.minimizedNotifier.value;
                        widget.controller.listNotifier.value = false;
                      }, icon: Icon(
                    widget.controller.minimizedNotifier.value ? FluentIcons.arrow_maximize_16_filled : FluentIcons.arrow_minimize_16_filled, color: Colors.white,
                    size: width * 0.01,
                  )
                  ),
                  if (!widget.controller.minimizedNotifier.value)
                    IconButton(
                        onPressed: () {
                          setState(() {
                            widget.controller.listNotifier.value = !widget.controller.listNotifier.value;
                          });
                          if (widget.controller.listNotifier.value == true) {
                            Future.delayed(const Duration(milliseconds: 200), () {
                              if (itemScrollController.hasClients) {
                                itemScrollController.animateTo(
                                  widget.controller.indexNotifier.value * height * 0.125,
                                  duration: const Duration(milliseconds: 250),
                                  curve: Curves.easeInOut,
                                );
                              }
                            });
                          }
                        },
                        padding: const EdgeInsets.all(0),
                        icon: Icon(FluentIcons.list_20_filled, size: width * 0.01)),


                ],
              ),

              Column(
                children: [
                  if(values[0])
                  Container(
                    padding: widget.controller.minimizedNotifier.value ?
                    EdgeInsets.only(
                      top: height * 0.02,
                    ) :
                    EdgeInsets.only(
                      top: height * 0.1,
                    ),
                    child: Text(
                      // Song Title - Artist with maximum 65 characters
                      "${widget.controller.playingSongs[widget.controller.indexNotifier.value].title} - ${widget.controller.playingSongs[widget.controller.indexNotifier.value].artists}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: normalSize,
                        fontFamily: 'Bahnschrift',
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  //ProgressBar
                  MultiValueListenableBuilder(
                      valueListenables: [widget.controller.sliderNotifier, widget.controller.colorNotifier],
                      builder: (context, values, child){
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          width: widget.controller.minimizedNotifier.value ? width * 0.7 : width * 0.9,
                          padding: widget.controller.minimizedNotifier.value ?
                          EdgeInsets.only(
                            top: height * 0.01,
                          ) :
                          EdgeInsets.only(
                            top: height * 0.1,
                          ),
                          child: ProgressBar(
                            progress: Duration(milliseconds: values[0]),
                            total: Duration(seconds: widget.controller.playingSongs.isNotEmpty? widget.controller.playingSongs[widget.controller.indexNotifier.value].duration : 0),
                            progressBarColor: values[1],
                            baseBarColor: Colors.white.withOpacity(0.24),
                            bufferedBarColor: Colors.white.withOpacity(0.24),
                            thumbColor: Colors.white,
                            barHeight: 4.0,
                            thumbRadius: 7.0,
                            timeLabelLocation: widget.controller.minimizedNotifier.value ? TimeLabelLocation.sides : TimeLabelLocation.below,
                            timeLabelTextStyle: TextStyle(
                              color: Colors.white,
                              fontSize: height * 0.02,
                              fontFamily: 'Bahnschrift',
                              fontWeight: FontWeight.normal,
                            ),
                            timeLabelPadding: 10,
                            onSeek: (duration) {
                              widget.controller.seekAudio(duration);
                            },
                          ),
                        );
                      }
                  ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: width * 0.7,
                    padding: EdgeInsets.only(
                      top : height * 0.01,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                            onPressed: () {
                              setState(() {
                                if(widget.controller.shuffleNotifier.value == false) {
                                  widget.controller.shuffleNotifier.value = true;
                                  MetadataType song = widget.controller.playingSongs[widget.controller.indexNotifier.value];
                                  widget.controller.playingSongs.shuffle();
                                  setState(() {
                                    widget.controller.indexNotifier.value = widget.controller.playingSongs.indexOf(song);
                                  });
                                }
                                else{
                                  widget.controller.shuffleNotifier.value = false;
                                  MetadataType song = widget.controller.playingSongs[widget.controller.indexNotifier.value];
                                  widget.controller.playingSongs.clear();
                                  widget.controller.playingSongs.addAll(widget.controller.playingSongsUnShuffled);
                                  setState(() {
                                    widget.controller.indexNotifier.value = widget.controller.playingSongsUnShuffled.indexOf(song);

                                  });
                                }
                              });
                            },
                            icon: widget.controller.shuffleNotifier.value == false ?
                            Icon(FluentIcons.arrow_shuffle_off_16_filled, size: height * 0.024) :
                            Icon(FluentIcons.arrow_shuffle_16_filled, size: height * 0.024)),
                        IconButton(
                          onPressed: () async {
                            print("previous");
                            await widget.controller.previousSong();
                          },
                          icon: Icon(
                            FluentIcons.previous_16_filled,
                            color: Colors.white,
                            size: height * 0.022,
                          ),
                        ),
                        ValueListenableBuilder(
                            valueListenable: widget.controller.playingNotifier,
                            builder: (context, value, child){
                              return IconButton(
                                onPressed: () async {
                                  print("pressed");
                                  widget.controller.playSong();
                                },
                                icon: widget.controller.playingNotifier.value ?
                                Icon(FluentIcons.pause_16_filled, color: Colors.white, size: height * 0.023,) :
                                Icon(FluentIcons.play_16_filled, color: Colors.white, size: height * 0.023,),
                              );
                            }
                        ),
                        IconButton(
                          onPressed: () async {
                            print("next");
                            return await widget.controller.nextSong();
                          },
                          icon: Icon(FluentIcons.next_16_filled, color: Colors.white, size: height * 0.022, ),
                        ),
                        IconButton(
                            onPressed: () {
                              if(widget.controller.repeatNotifier.value == false) {
                                widget.controller.repeatNotifier.value = true;
                              } else {
                                widget.controller.repeatNotifier.value = false;
                              }
                              setState(() {});
                            },
                            icon: widget.controller.repeatNotifier.value == false ?
                            Icon(FluentIcons.arrow_repeat_all_16_filled, size: height * 0.024,) :
                            Icon(FluentIcons.arrow_repeat_1_16_filled, size: height * 0.024)
                        ),

                      ],
                    ),
                  ),
                  //Player Controls - Previous, Play/Pause, Next

                ],
              ),

              if(values[0])
                Column(
                  children: [
                    // Minimize/Maximize button
                    IconButton(
                        padding: const EdgeInsets.all(0),
                        onPressed: (){
                          widget.controller.minimizedNotifier.value = !widget.controller.minimizedNotifier.value;
                          widget.controller.listNotifier.value = false;
                        }, icon: Icon(
                      widget.controller.minimizedNotifier.value ? FluentIcons.arrow_maximize_16_filled : FluentIcons.arrow_minimize_16_filled, color: Colors.white,
                      size: width * 0.01,
                    )
                    ),
                  ],
                ),


            ],

          ),
        );
      }
    );
  }
}
