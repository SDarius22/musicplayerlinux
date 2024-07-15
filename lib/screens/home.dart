import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:musicplayer/screens/song_player_widget.dart';
import '../domain/featured_artist_type.dart';
import '../domain/metadata_type.dart';
import '../domain/playlist_type.dart';
import '../controller/controller.dart';
import 'albums.dart';
import 'artists.dart';
import 'tracks.dart';
import 'settings.dart';
import 'playlists.dart';


class HomePage extends StatefulWidget {
  final Controller controller;
  const HomePage(
      {super.key,
        required this.controller,
      });
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  bool isTap = false, isTapped = false;
  bool _volume = true;
  bool create = false, search = false, addelement = false;
  bool _queueinatp = false;

  int _hovereditem3 = -1;
  int displayedalbum = -1, currentPage = 3;
  int _hovereditem = -1;

  String  artistsforalbum = "", playlistname = "New playlist";
  String _usermessage = "No message";

  FocusNode myFocusNode = FocusNode();
  FocusNode searchNode = FocusNode();

  final ValueNotifier<bool> _visible = ValueNotifier(false);

  final ScrollController _scrollController = ScrollController(initialScrollOffset: 0.0);

  MetadataType songtoadd = MetadataType();

  List<PlaylistType> addtoplaylists = [];
  List<MetadataType> _songstoadd = [];


  late Timer timer1;
  final PageController _pageController = PageController(initialPage: 4);



  @override
  void initState(){
    widget.controller.retrieveSongs();
    widget.controller.found.value = widget.controller.repo.songs.value;
    widget.controller.indexNotifier.value= widget.controller.settings.lastPlayingIndex;
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      searchNode.addListener(() {
        if(searchNode.hasFocus == false){
          Future.delayed(const Duration(seconds: 2)).then((value) {
            setState(() {
              if(searchNode.hasFocus == false) {
                search = false;
              }
            });
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Music Player'),
        actions: [
          Container(
              padding: const EdgeInsets.only(right: 25),
              child: ValueListenableBuilder(
                valueListenable: _visible,
                builder: (context, value, child) =>
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                      Visibility(
                        visible: _visible.value,
                        child: SizedBox(
                          height: height * 0.05,
                          width: width * 0.1,
                          child:
                          MouseRegion(
                            onEnter: (event) {
                              _visible.value = true;
                            },
                            onExit: (event) {
                              _visible.value = false;
                            },
                            child: Slider(
                              min: 0.0,
                              max: 1.0,
                              value: widget.controller.volumeNotifier.value,
                              activeColor: widget.controller.colorNotifier.value,
                              thumbColor: Colors.white,
                              inactiveColor: Colors.white,
                              onChanged: (double value) {
                                setState(() {
                                  widget.controller.volumeNotifier.value = value;
                                  widget.controller.setVolume(widget.controller.volumeNotifier.value);
                                });
                              },
                            ),
                          )
                      ),
                    ),
                    MouseRegion(
                      onEnter: (event) {
                        _visible.value = true;
                      },
                      onExit: (event) {
                        _visible.value = false;
                      },
                      child: IconButton(
                        icon: _volume ? const Icon(FluentIcons.speaker_2_16_filled) : const Icon(FluentIcons.speaker_mute_16_filled),
                        onPressed: () {
                          if(_volume) {
                            widget.controller.volumeNotifier.value = 0;
                          }
                          else {
                            widget.controller.volumeNotifier.value = 0.1;
                          }
                          _volume = !_volume;
                          setState(() {
                            widget.controller.setVolume(widget.controller.volumeNotifier.value);
                          });
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    IconButton(onPressed: (){
                      print("Search");
                      setState(() {
                        search = !search;
                      });
                      searchNode.requestFocus();
                    }, icon: const Icon(FluentIcons.search_16_filled)),
                    Container(
                      width: 20,
                    ),
                    IconButton(onPressed: (){
                      print("Tapped settings");
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                        return Settings(controller: widget.controller,);
                      }));
                    }, icon: const Icon(FluentIcons.settings_16_filled))//Icon(Icons.more_vert)),
                  ],
                ),
              ))
        ],
      ),
      body: SafeArea(
        child: Container(
          width: width,
          height: height,
          padding: EdgeInsets.all(height * 0.01),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // artists, albums, playlists, tracks
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: height * 0.05,
                          child: ElevatedButton(
                            onPressed: (){
                              //print("Artists");
                              _pageController.animateToPage(0,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeIn
                              );
                              setState(() {
                                create = false;
                                playlistname = "New playlist";
                                artistsforalbum = "";
                                if(_scrollController.positions.isNotEmpty) {
                                  _scrollController.jumpTo(_scrollController.position.minScrollExtent);
                                }
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: currentPage != 0 ? const Color(0xFF0E0E0E) : const Color(0xFF1b1b1b),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                            child: Text(
                                "Artists",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: currentPage != 0 ? normalSize : boldSize,
                                ),
                            )
                          )
                        )
                      ),
                      Expanded(
                          child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              height: height * 0.05,
                              child: ElevatedButton(
                                  onPressed: (){
                                    //print("Artists");
                                    _pageController.animateToPage(1,
                                        duration: const Duration(milliseconds: 500),
                                        curve: Curves.easeIn
                                    );
                                    setState(() {
                                      create = false;
                                      playlistname = "New playlist";
                                      artistsforalbum = "";
                                      if(_scrollController.positions.isNotEmpty) {
                                        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
                                      }
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: currentPage != 1 ? const Color(0xFF0E0E0E) : const Color(0xFF1b1b1b),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: Text(
                                    "Albums",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: currentPage != 1 ? normalSize : boldSize,
                                    ),
                                  )
                              )
                          )
                      ),
                      Expanded(
                          child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              height: height * 0.05,
                              child: ElevatedButton(
                                  onPressed: (){
                                    //print("Artists");
                                    _pageController.animateToPage(2,
                                        duration: const Duration(milliseconds: 500),
                                        curve: Curves.easeIn
                                    );
                                    setState(() {
                                      create = false;
                                      playlistname = "New playlist";
                                      artistsforalbum = "";
                                      if(_scrollController.positions.isNotEmpty) {
                                        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
                                      }
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: currentPage != 2 ? const Color(0xFF0E0E0E) : const Color(0xFF1b1b1b),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: Text(
                                    "Playlists",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: currentPage != 2 ? normalSize : boldSize,
                                    ),
                                  )
                              )
                          )
                      ),
                      Expanded(
                          child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              height: height * 0.05,
                              child: ElevatedButton(
                                  onPressed: (){
                                    //print("Artists");
                                    _pageController.animateToPage(3,
                                        duration: const Duration(milliseconds: 500),
                                        curve: Curves.easeIn
                                    );
                                    setState(() {
                                      create = false;
                                      playlistname = "New playlist";
                                      artistsforalbum = "";
                                      if(_scrollController.positions.isNotEmpty) {
                                        _scrollController.jumpTo(_scrollController.position.minScrollExtent);
                                      }
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: currentPage != 3 ? const Color(0xFF0E0E0E) : const Color(0xFF1b1b1b),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(0),
                                    ),
                                  ),
                                  child: Text(
                                    "Tracks",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: currentPage != 3 ? normalSize : boldSize,
                                    ),
                                  )
                              )
                          )
                      ),
                    ],
                  ),
                  // current page
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    padding: EdgeInsets.only(left: width * 0.02, right: width * 0.02),
                    width: width,
                    height: height * 0.8,
                    child: PageView(
                      onPageChanged: (int index){
                        setState(() {
                          currentPage = index;
                        });
                      },
                      controller: _pageController,
                      scrollDirection: Axis.horizontal,
                      scrollBehavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: {
                          PointerDeviceKind.touch,
                          PointerDeviceKind.mouse,
                        },
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        Artists(controller: widget.controller),
                        Albums(controller: widget.controller),
                        Playlists(controller: widget.controller),
                        Tracks(controller: widget.controller),
                      ],

                    ),
                  ),
                ],
              ),
              ValueListenableBuilder(
                valueListenable: widget.controller.finishedRetrievingNotifier,
                builder: (context, value, child) {
                  return value ?
                  SongPlayerWidget(controller: widget.controller) :
                  ValueListenableBuilder(
                      valueListenable: widget.controller.progressNotifier,
                      builder: (context, value, child) {
                        return LinearProgressIndicator(
                          backgroundColor: Colors.grey,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
                          value: widget.controller.progressNotifier.value,
                        );
                      }
                  );
                }
              ),
              // Container(
              //   padding: EdgeInsets.all(width * 0.01),
              //   child: Stack(
              //     alignment: Alignment.bottomCenter,
              //     children: [
              //
              //         // Container(
              //         //   height: _down == false ? 225 : 150,
              //         //   child: Column(
              //         //     children: [
              //         //       if(_usermessage != "No message")
              //         //         Container(
              //         //           height: 40,
              //         //           width: _usermessage.length * 20.0,
              //         //           alignment: Alignment.center,
              //         //           decoration: BoxDecoration(
              //         //             color: Colors.black,
              //         //             borderRadius: BorderRadius.circular(20),
              //         //
              //         //           ),
              //         //           child: Text(
              //         //             _usermessage,
              //         //             textAlign: TextAlign.center,
              //         //             style: TextStyle(
              //         //               color: Colors.white,
              //         //               fontSize: 24,
              //         //             ),
              //         //           ),
              //         //         ),
              //         //       ValueListenableBuilder(
              //         //           valueListenable: widget.controller.finishedRetrievingNotifier,
              //         //           builder: (context, value, child){
              //         //             return Container(
              //         //               height: _down == false ? 150 : 45,
              //         //               padding: EdgeInsets.only(left: 5),
              //         //               color: Color(0xFF0E0E0E),
              //         //               child:
              //         //               Column(
              //         //                 children: [
              //         //                   if (!value)
              //         //                   ValueListenableBuilder(
              //         //                       valueListenable: widget.controller.progressNotifier,
              //         //                       builder: (context, value, child){
              //         //                         return LinearProgressIndicator(
              //         //                           backgroundColor: Colors.grey,
              //         //                           valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurpleAccent),
              //         //                           value: widget.controller.progressNotifier.value,
              //         //                         );
              //         //                       }
              //         //                   ),
              //         //                   Row(
              //         //                     crossAxisAlignment: CrossAxisAlignment.end,
              //         //                     children: [
              //         //                       _down == false ? Container(
              //         //                         height: 140,
              //         //                         width: 140,
              //         //                       ) :
              //         //                       Container(
              //         //                         width: 140,
              //         //                       ),
              //         //                       _down == false ? Container(
              //         //                         padding: EdgeInsets.only(left: 40),
              //         //                         child: Column(
              //         //                           mainAxisAlignment: MainAxisAlignment.center,
              //         //                           crossAxisAlignment: CrossAxisAlignment.start,
              //         //                           children: [
              //         //                             Container(
              //         //                               width: 410,
              //         //                               child: Text(
              //         //                                 widget.controller.playingSongs.isNotEmpty? widget.controller.playingSongs[widget.controller.indexNotifier.value].title.length > 45 ? widget.controller.playingSongs[widget.controller.indexNotifier.value].title.substring(0, 45) + "..." : widget.controller.playingSongs[widget.controller.indexNotifier.value].title : "",
              //         //                                 style: TextStyle(
              //         //                                   color: Colors.white,
              //         //                                   fontSize: 22,
              //         //                                   fontWeight: FontWeight.bold,
              //         //                                 ),
              //         //                                 textAlign: TextAlign.left,
              //         //                               ),
              //         //                             ),
              //         //                             Container(
              //         //                               width: 410,
              //         //                               child: Text(
              //         //                                 widget.controller.playingSongs.isNotEmpty? widget.controller.playingSongs[widget.controller.indexNotifier.value].artists.length > 75 ? widget.controller.playingSongs[widget.controller.indexNotifier.value].artists.substring(0, 75) + "..." : widget.controller.playingSongs[widget.controller.indexNotifier.value].artists : "",
              //         //                                 style: TextStyle(
              //         //                                   color: Colors.white,
              //         //                                   fontSize: 19,
              //         //                                   fontWeight: FontWeight.bold,
              //         //                                 ),
              //         //                                 textAlign: TextAlign.left,
              //         //                               ),
              //         //                             ),
              //         //
              //         //                           ],
              //         //                         ),
              //         //                       ) :
              //         //                       Container(
              //         //                           width: 410
              //         //                       ),
              //         //                       Column(
              //         //                         children: [
              //         //                           Container(
              //         //                             width: 1025,
              //         //                             height: 45,
              //         //                             child:
              //         //                             Row(
              //         //                                 mainAxisAlignment: MainAxisAlignment.end,
              //         //                                 crossAxisAlignment: CrossAxisAlignment.center,
              //         //                                 children: [
              //         //                                   IconButton(onPressed: (){
              //         //                                     setState(() {
              //         //                                       _down = !_down;
              //         //                                     });
              //         //                                   }, icon: _down == false ? Icon(FluentIcons.chevron_down_16_filled) : Icon(FluentIcons.chevron_up_16_filled)),
              //         //                                   Container(
              //         //                                     width: 10,
              //         //                                   ),
              //         //                                   IconButton(onPressed: (){
              //         //                                     setState(() {
              //         //                                       widget.controller.minimizedNotifier.value = !widget.controller.minimizedNotifier.value;
              //         //                                     });
              //         //                                   }, icon: Icon(FluentIcons.arrow_maximize_16_filled)),
              //         //
              //         //                                 ]
              //         //                             ),
              //         //                           ),
              //         //                           Container(
              //         //                             height: _down == false ? 15 : 0,
              //         //                           ),
              //         //                           _down == false ?
              //         //                           Container(
              //         //                             padding: EdgeInsets.only(left: 25),
              //         //                             child:
              //         //                             Row(
              //         //                               children: [
              //         //                                 Container(
              //         //                                   width: 750,
              //         //                                   child: Row(), /// PROGRESS WIDGET
              //         //                                 ),
              //         //                                 Container(
              //         //                                   width: 25,
              //         //                                 ),
              //         //                                 //widget.controller.buildPlayControl(_minimized, context)[2],
              //         //                                 Container(
              //         //                                   width: 10,
              //         //                                 ),
              //         //                               ],
              //         //                             ),
              //         //                           ) : Container(),
              //         //                         ],
              //         //                       ),
              //         //
              //         //
              //         //                     ],
              //         //                   ),
              //         //                 ],
              //         //               ),
              //         //
              //         //             );
              //         //
              //         //           }
              //         //       ),
              //         //     ],
              //         //   ),
              //         // ),
              //         // addelement == true ?
              //         // ClipRect(
              //         //   child: BackdropFilter(
              //         //       filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              //         //       child: Container(
              //         //         margin: EdgeInsets.only(bottom: 100, top: 25, left: 100, right: 100),
              //         //         padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
              //         //         decoration: BoxDecoration(
              //         //           color: Colors.black,
              //         //           borderRadius: BorderRadius.circular(20),
              //         //         ),
              //         //         width: double.maxFinite,
              //         //         height: double.maxFinite,
              //         //         child: Column(
              //         //           mainAxisAlignment: MainAxisAlignment.center,
              //         //           crossAxisAlignment: CrossAxisAlignment.start,
              //         //           children: [
              //         //             Container(
              //         //               height: 40,
              //         //               width: 500,
              //         //               alignment: Alignment.centerLeft,
              //         //               padding: EdgeInsets.only(left: 20),
              //         //               child: Text("Choose playlist:", style: TextStyle(color: Colors.white, fontSize: 24),),
              //         //             ),
              //         //             Container(
              //         //               height: 10,
              //         //             ),
              //         //             Container(
              //         //                 width: 1000,
              //         //                 height: 620,
              //         //                 child: GridView.builder(
              //         //                   padding: EdgeInsets.only(right: 20),
              //         //                   itemCount: widget.controller.repo.playlists.length + 1,
              //         //                   gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              //         //                       childAspectRatio: 0.8 ,
              //         //                       maxCrossAxisExtent: 250,
              //         //                       crossAxisSpacing: 25,
              //         //                       mainAxisSpacing: 10),
              //         //                   itemBuilder: (BuildContext context, int sindex) {
              //         //                     return sindex == 0 ?
              //         //                     Container(
              //         //                       child : MouseRegion(
              //         //                         cursor: SystemMouseCursors.click,
              //         //                         onEnter: (event){
              //         //                           setState(() {
              //         //                             _hovereditem3 = -2;
              //         //                           });
              //         //                         },
              //         //                         onExit: _incrementExit3,
              //         //                         child: GestureDetector(
              //         //                           onTap: (){
              //         //                             print("tapped on queue");
              //         //                             if(_queueinatp)
              //         //                             {
              //         //                               setState(() {
              //         //                                 _queueinatp = false;
              //         //                               });
              //         //                             }
              //         //                             else
              //         //                             {
              //         //                               setState(() {
              //         //                                 _queueinatp = true;
              //         //                               });
              //         //                             }
              //         //                           },
              //         //                           child: Column(
              //         //                             children: [
              //         //                               Container(
              //         //                                   height: 200,
              //         //                                   width: 200,
              //         //                                   child: Stack(
              //         //                                     children: [
              //         //                                       Container(
              //         //                                         height: 250,
              //         //                                         width: 250,
              //         //                                         child: DecoratedBox(
              //         //                                           decoration: BoxDecoration(
              //         //                                             borderRadius: BorderRadius.circular(10),
              //         //                                           ),
              //         //                                           child: Icon(FluentIcons.text_bullet_list_add_20_filled, size: 100, color: Colors.white,),
              //         //                                         ),
              //         //                                       ),
              //         //                                       ClipRRect(
              //         //                                         // Clip it cleanly.
              //         //                                         child: BackdropFilter(
              //         //                                           filter: _queueinatp || _hovereditem3 == -2 ? ImageFilter.blur(sigmaX: 10, sigmaY: 10) : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              //         //                                           child: Container(
              //         //                                             color: _queueinatp ? Colors.black.withOpacity(0.3) : Colors.transparent,
              //         //                                             alignment: Alignment.center,
              //         //                                             child: _queueinatp ? Icon(FluentIcons.checkmark_16_filled, size: 100, color: Colors.white,) : null,
              //         //                                           ),
              //         //                                         ),
              //         //                                       ),
              //         //
              //         //                                     ],
              //         //                                   )
              //         //                               ),
              //         //
              //         //                               Container(
              //         //                                 height: 10,
              //         //                               ),
              //         //                               Text(
              //         //                                 "Current queue",
              //         //                                 style: TextStyle(
              //         //                                   color: Colors.white,
              //         //                                   fontSize: 18,
              //         //                                   fontWeight: FontWeight.bold,
              //         //                                 ),
              //         //                                 textAlign: TextAlign.center,
              //         //                               ),
              //         //                             ],
              //         //                           ),
              //         //                         ),
              //         //
              //         //                       ),
              //         //                     ) :
              //         //                     Container(
              //         //                       child:
              //         //                       MouseRegion(
              //         //                         cursor: SystemMouseCursors.click,
              //         //                         onEnter: (event){
              //         //                           setState(() {
              //         //                             _hovereditem3 = sindex-1;
              //         //                           });
              //         //                         },
              //         //                         onExit: _incrementExit3,
              //         //                         child: GestureDetector(
              //         //                           onTap: (){
              //         //                             print("tapped on ${widget.controller.repo.playlists[sindex-1].name}");
              //         //                             if(addtoplaylists.contains(widget.controller.repo.playlists[sindex-1])){
              //         //                               addtoplaylists.remove(widget.controller.repo.playlists[sindex-1]);
              //         //                             }
              //         //                             else{
              //         //                               addtoplaylists.add(widget.controller.repo.playlists[sindex-1]);
              //         //                             }
              //         //                             setState(() {
              //         //
              //         //                             });
              //         //                           },
              //         //                           child: Column(
              //         //                             children: [
              //         //                               // Container(
              //         //                               //     height: 200,
              //         //                               //     width: 200,
              //         //                               //     child: Stack(
              //         //                               //       children: [
              //         //                               //         widget.controller.repo.playlists[sindex-1].songs.first.imageloaded?
              //         //                               //         Container(
              //         //                               //             height: 200,
              //         //                               //             width: 200,
              //         //                               //             child: DecoratedBox(
              //         //                               //               decoration: BoxDecoration(
              //         //                               //                   color: Colors.black,
              //         //                               //                   borderRadius: BorderRadius.circular(10),
              //         //                               //                   image: DecorationImage(
              //         //                               //                     fit: BoxFit.cover,
              //         //                               //                     image: Image.memory(widget.controller.repo.playlists[sindex-1].songs.first.image).image,
              //         //                               //                   )
              //         //                               //               ),
              //         //                               //             )
              //         //                               //         ):
              //         //                               //         loading?
              //         //                               //         Container(
              //         //                               //             height: 200,
              //         //                               //             width: 200,
              //         //                               //             child: DecoratedBox(
              //         //                               //               decoration: BoxDecoration(
              //         //                               //                   color: Colors.black,
              //         //                               //                   borderRadius: BorderRadius.circular(10),
              //         //                               //                   image: DecorationImage(
              //         //                               //                     fit: BoxFit.cover,
              //         //                               //                     image: Image.memory(File("./assets/bg.png").readAsBytesSync()).image,
              //         //                               //                   )
              //         //                               //               ),
              //         //                               //               child: Center(
              //         //                               //                 child: CircularProgressIndicator(
              //         //                               //                   color: Colors.white,
              //         //                               //                 ),
              //         //                               //               ),
              //         //                               //             )
              //         //                               //         ):
              //         //                               //         FutureBuilder(
              //         //                               //           builder: (ctx, snapshot) {
              //         //                               //             if (snapshot.hasData) {
              //         //                               //               return
              //         //                               //                 Container(
              //         //                               //                     height: 200,
              //         //                               //                     width: 200,
              //         //                               //                     child: DecoratedBox(
              //         //                               //                       decoration: BoxDecoration(
              //         //                               //                           color: Colors.black,
              //         //                               //                           borderRadius: BorderRadius.circular(10),
              //         //                               //                           image: DecorationImage(
              //         //                               //                             fit: BoxFit.cover,
              //         //                               //                             image: Image.memory(snapshot.data!).image,
              //         //                               //                           )
              //         //                               //                       ),
              //         //                               //                     )
              //         //                               //                 );
              //         //                               //             }
              //         //                               //             else if (snapshot.hasError) {
              //         //                               //               return Center(
              //         //                               //                 child: Text(
              //         //                               //                   '${snapshot.error} occurred',
              //         //                               //                   style: TextStyle(fontSize: 18),
              //         //                               //                 ),
              //         //                               //               );
              //         //                               //             } else{
              //         //                               //               return
              //         //                               //                 Container(
              //         //                               //                     height: 200,
              //         //                               //                     width: 200,
              //         //                               //                     child: DecoratedBox(
              //         //                               //                       decoration: BoxDecoration(
              //         //                               //                           color: Colors.black,
              //         //                               //                           borderRadius: BorderRadius.circular(10),
              //         //                               //                           image: DecorationImage(
              //         //                               //                             fit: BoxFit.cover,
              //         //                               //                             image: Image.memory(File("./assets/bg.png").readAsBytesSync()).image,
              //         //                               //                           )
              //         //                               //                       ),
              //         //                               //                       child: Center(
              //         //                               //                         child: CircularProgressIndicator(
              //         //                               //                           color: Colors.white,
              //         //                               //                         ),
              //         //                               //                       ),
              //         //                               //                     )
              //         //                               //                 );
              //         //                               //             }
              //         //                               //           },
              //         //                               //           future: widget.controller.imageretrieve(widget.controller.repo.playlists[sindex-1].songs.first.path),
              //         //                               //         ),
              //         //                               //         ClipRRect(
              //         //                               //           // Clip it cleanly.
              //         //                               //           child: BackdropFilter(
              //         //                               //             filter: addtoplaylists.contains(widget.controller.repo.playlists[sindex-1]) || _hovereditem3 == sindex-1 ? ImageFilter.blur(sigmaX: 10, sigmaY: 10) : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
              //         //                               //             child: Container(
              //         //                               //               color: addtoplaylists.contains(widget.controller.repo.playlists[sindex-1]) ? Colors.black.withOpacity(0.3) : Colors.transparent,
              //         //                               //               alignment: Alignment.center,
              //         //                               //               child: addtoplaylists.contains(widget.controller.repo.playlists[sindex-1]) ? Icon(FluentIcons.checkmark_16_filled, size: 100, color: Colors.white,) : null,
              //         //                               //             ),
              //         //                               //           ),
              //         //                               //         ),
              //         //                               //
              //         //                               //       ],
              //         //                               //     )
              //         //                               // ),
              //         //
              //         //                               Container(
              //         //                                 height: 10,
              //         //                               ),
              //         //                               Text(
              //         //                                 widget.controller.repo.playlists[sindex-1].name.length > 45 ? widget.controller.repo.playlists[sindex-1].name.substring(0, 45) + "..." : widget.controller.repo.playlists[sindex-1].name,
              //         //                                 style: TextStyle(
              //         //                                   color: Colors.white,
              //         //                                   fontSize: 18,
              //         //                                   fontWeight: FontWeight.bold,
              //         //                                 ),
              //         //                                 textAlign: TextAlign.center,
              //         //                               ),
              //         //                             ],
              //         //                           ),
              //         //                         ),
              //         //
              //         //                       ),
              //         //                     );
              //         //
              //         //                   },
              //         //                 )
              //         //             ),
              //         //             Container(
              //         //               height: 2,
              //         //               color: Colors.white,
              //         //             ),
              //         //             Row(
              //         //               mainAxisAlignment: MainAxisAlignment.center,
              //         //               children: [
              //         //                 Container(
              //         //                   height: 50,
              //         //                   width: 150,
              //         //                   padding: EdgeInsets.only(right: 20),
              //         //                   child: ElevatedButton(
              //         //                     style: ElevatedButton.styleFrom(
              //         //                       backgroundColor: Colors.transparent,
              //         //                     ),
              //         //                     onPressed: (){
              //         //
              //         //                       setState(() {
              //         //                         addtoplaylists.clear();
              //         //                         _queueinatp = false;
              //         //                         addelement = false;
              //         //                         _songstoadd.clear();
              //         //                       });
              //         //                     },
              //         //                     child: Text("Cancel", style: TextStyle(color: Colors.white, fontSize: 22),),
              //         //                   ),
              //         //                 ),
              //         //                 Spacer(),
              //         //                 Container(
              //         //                   height: 50,
              //         //                   width: 70,
              //         //                   padding: EdgeInsets.only(right: 20),
              //         //                   alignment: Alignment.center,
              //         //                   child: MouseRegion(
              //         //                     cursor: addtoplaylists.isEmpty && _queueinatp == false? SystemMouseCursors.basic : SystemMouseCursors.click,
              //         //                     child: GestureDetector(
              //         //                       onTap:(){
              //         //                         print("looooook to add: ${_songstoadd[0].title}");
              //         //                         if(addtoplaylists.isEmpty && _queueinatp == false){
              //         //                           //_usermessage = "Please select at least 1 playlist";
              //         //                         }
              //         //                         else{
              //         //                           if(_queueinatp){
              //         //                             setState(() {
              //         //                               widget.controller.playingSongsUnShuffled.addAll(_songstoadd);
              //         //                               widget.controller.playingSongs.addAll(_songstoadd);
              //         //                             });
              //         //                             var file = File("assets/settings.json");
              //         //                             widget.controller.settings.lastPlaying.add(_songstoadd[0].path);
              //         //                             file.writeAsStringSync(jsonEncode(widget.controller.settings.toJson()));
              //         //                           }
              //         //
              //         //                           for(int i = 0; i < addtoplaylists.length; i++) {
              //         //                             for (int j = 0; j < _songstoadd.length; j++) {
              //         //                               if (widget.controller.repo.playlists[widget.controller.repo.playlists.indexOf(addtoplaylists[i])].paths.contains(_songstoadd[j].path) == false) {
              //         //                                 widget.controller.repo.playlists[widget.controller.repo.playlists.indexOf(
              //         //                                     addtoplaylists[i])].songs.add(
              //         //                                     _songstoadd[j]);
              //         //                                 widget.controller.repo.playlists[widget.controller.repo.playlists.indexOf(
              //         //                                     addtoplaylists[i])].paths.add(
              //         //                                     _songstoadd[j].path);
              //         //                                 int playlistduration = 0;
              //         //                                 for (int k = 0; k <
              //         //                                     widget.controller.repo.playlists[widget.controller.repo.playlists
              //         //                                         .indexOf(addtoplaylists[i])]
              //         //                                         .songs.length; k++) {
              //         //                                   playlistduration +=
              //         //                                       widget.controller.repo.playlists[widget.controller.repo.playlists
              //         //                                           .indexOf(
              //         //                                           addtoplaylists[i])]
              //         //                                           .songs[k].duration;
              //         //                                 }
              //         //                                 int shours = Duration(
              //         //                                     milliseconds: playlistduration)
              //         //                                     .inHours;
              //         //                                 int sminutes = Duration(
              //         //                                     milliseconds: playlistduration)
              //         //                                     .inMinutes;
              //         //                                 int sseconds = Duration(
              //         //                                     milliseconds: playlistduration)
              //         //                                     .inSeconds;
              //         //                                 int rhours = shours;
              //         //                                 int rminutes = sminutes -
              //         //                                     (shours * 60);
              //         //                                 int rseconds = sseconds -
              //         //                                     (sminutes * 60);
              //         //
              //         //                                 if (rhours == 0) {
              //         //                                   if (rminutes == 0) {
              //         //                                     widget.controller.repo.playlists[widget.controller.repo.playlists
              //         //                                         .indexOf(addtoplaylists[i])]
              //         //                                         .duration =
              //         //                                     "$rseconds seconds";
              //         //                                   }
              //         //                                   else if (rseconds == 0) {
              //         //                                     widget.controller.repo.playlists[widget.controller.repo.playlists
              //         //                                         .indexOf(addtoplaylists[i])]
              //         //                                         .duration =
              //         //                                     "$rminutes minutes";
              //         //                                   }
              //         //                                   else {
              //         //                                     widget.controller.repo.playlists[widget.controller.repo.playlists
              //         //                                         .indexOf(addtoplaylists[i])]
              //         //                                         .duration =
              //         //                                     "$rminutes minutes and $rseconds seconds";
              //         //                                   }
              //         //                                 }
              //         //                                 else {
              //         //                                   if (rhours != 1) {
              //         //                                     if (rminutes == 0) {
              //         //                                       widget.controller.repo.playlists[widget.controller.repo.playlists
              //         //                                           .length - 1].duration =
              //         //                                       "$rhours hours and $rseconds seconds";
              //         //                                     }
              //         //                                     else if (rseconds == 0) {
              //         //                                       widget.controller.repo.playlists[widget.controller.repo.playlists
              //         //                                           .length - 1].duration =
              //         //                                       "$rhours hours and $rminutes minutes";
              //         //                                     }
              //         //                                     else {
              //         //                                       widget.controller.repo.playlists[widget.controller.repo.playlists
              //         //                                           .length - 1].duration =
              //         //                                       "$rhours hours, $rminutes minutes and $rseconds seconds";
              //         //                                     }
              //         //                                   }
              //         //                                   else {
              //         //                                     if (rminutes == 0) {
              //         //                                       widget.controller.repo.playlists[widget.controller.repo.playlists
              //         //                                           .length - 1].duration =
              //         //                                       "$rhours hour and $rseconds seconds";
              //         //                                     }
              //         //                                     else if (rseconds == 0) {
              //         //                                       widget.controller.repo.playlists[widget.controller.repo.playlists
              //         //                                           .length - 1].duration =
              //         //                                       "$rhours hour and $rminutes minutes";
              //         //                                     }
              //         //                                     else {
              //         //                                       widget.controller.repo.playlists[widget.controller.repo.playlists
              //         //                                           .length - 1].duration =
              //         //                                       "$rhours hour, $rminutes minutes and $rseconds seconds";
              //         //                                     }
              //         //                                   }
              //         //                                 }
              //         //
              //         //                                 List<FeaturedArtistType> playlistfeatured = [];
              //         //                                 for (int k = 0; k <
              //         //                                     widget.controller.repo.playlists[widget.controller.repo.playlists
              //         //                                         .indexOf(addtoplaylists[i])]
              //         //                                         .songs.length; k++) {
              //         //                                   List artists = widget.controller.repo.playlists[widget.controller.repo.playlists
              //         //                                       .indexOf(addtoplaylists[i])]
              //         //                                       .songs[k].artists.split("; ");
              //         //                                   for (int l = 0; l <
              //         //                                       artists.length; l++) {
              //         //                                     bool artistsexists = false;
              //         //                                     for (int m = 0; m <
              //         //                                         playlistfeatured
              //         //                                             .length; m++) {
              //         //                                       if (playlistfeatured[m]
              //         //                                           .name == artists[l]) {
              //         //                                         artistsexists = true;
              //         //                                         playlistfeatured[m]
              //         //                                             .appearances++;
              //         //                                         break;
              //         //                                       }
              //         //                                     }
              //         //                                     if (artistsexists == false) {
              //         //                                       FeaturedArtistType newartist = FeaturedArtistType();
              //         //                                       newartist.name = artists[l];
              //         //                                       newartist.appearances = 1;
              //         //                                       playlistfeatured.add(
              //         //                                           newartist);
              //         //                                     }
              //         //                                   }
              //         //                                   widget.controller.repo.playlists[widget.controller.repo.playlists.indexOf(
              //         //                                       addtoplaylists[i])]
              //         //                                       .featuredartists.clear();
              //         //                                   widget.controller.repo.playlists[widget.controller.repo.playlists.indexOf(
              //         //                                       addtoplaylists[i])]
              //         //                                       .featuredartists.addAll(
              //         //                                       playlistfeatured);
              //         //                                 }
              //         //                               }
              //         //                             }
              //         //
              //         //
              //         //                             var file = File(
              //         //                                 "assets/playlists.json");
              //         //                             List<dynamic> towrite2 = [];
              //         //                             for (int j = 0; j <
              //         //                                 widget.controller.repo.playlists.length; j++) {
              //         //                               towrite2.add(
              //         //                                   widget.controller.repo.playlists[j].toJson());
              //         //                             }
              //         //                             file.writeAsStringSync(
              //         //                                 jsonEncode(towrite2));
              //         //
              //         //                           }
              //         //                           _usermessage = "";
              //         //                           print(_queueinatp);
              //         //                           if (_songstoadd.length == 1) {
              //         //                             if (addtoplaylists.length == 1) {
              //         //                               _usermessage =
              //         //                               "Song added to playlist";
              //         //                             }
              //         //                             else {
              //         //                               _usermessage =
              //         //                               "Song added to playlists";
              //         //                             }
              //         //                           }
              //         //                           else {
              //         //                             if (addtoplaylists.length == 1) {
              //         //                               _usermessage =
              //         //                               "Songs added to playlist";
              //         //                             }
              //         //                             else {
              //         //                               _usermessage =
              //         //                               "Songs added to playlists";
              //         //                             }
              //         //                           }
              //         //
              //         //                           Future.delayed(
              //         //                               Duration(seconds: 5), () {
              //         //                             setState(() {
              //         //                               _usermessage = "No message";
              //         //                             });
              //         //                           });
              //         //                         }
              //         //                         setState(() {
              //         //                           addtoplaylists.clear();
              //         //                           addelement = false;
              //         //                           _songstoadd.clear();
              //         //                           _queueinatp = false;
              //         //                         });
              //         //                       },
              //         //                       child: Text("Add", style: TextStyle(color: addtoplaylists.isEmpty && !_queueinatp ? Colors.grey :Colors.white, fontSize: 22),),
              //         //                     ),
              //         //                   ),
              //         //
              //         //                 )
              //         //               ],
              //         //             ),
              //         //
              //         //           ],
              //         //         ),
              //         //       )
              //         //   ),
              //         // )
              //         //     :
              //         // Container(),
              //       ]
              //   )
              // ),
              Visibility(
                visible: search,
                child: Container(
                  width: 400,
                  height: 500,
                  color: Colors.black,
                  padding: EdgeInsets.only(left: 10, right: 10, top: 10),
                  child:  Column(
                    children: [
                      TextFormField(
                        focusNode: searchNode,
                        onChanged: (value) => widget.controller.filter(value),
                        cursorColor: Colors.white,
                        style: TextStyle(color: Colors.white, fontSize: 20),
                        decoration: const InputDecoration(
                            labelStyle: TextStyle(color: Colors.white, fontSize: 18),
                            labelText: 'Search', suffixIcon: Icon(FluentIcons.search_16_filled, color: Colors.white,)),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Expanded(
                        child: widget.controller.found.value.isNotEmpty ?
                        ListView.builder(
                          itemCount: widget.controller.found.value.length+1,
                          itemBuilder: (context, int _index) {
                            return _index < widget.controller.found.value.length ?
                            Container(
                              height: 85,
                              padding: EdgeInsets.only(bottom: 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF0E0E0E),
                                ),
                                onPressed: () {
                                  widget.controller.playingSongs.clear();
                                  widget.controller.playingSongsUnShuffled.clear();

                                  widget.controller.playingSongs.addAll(widget.controller.found.value);
                                  widget.controller.playingSongsUnShuffled.addAll(widget.controller.found.value);

                                  if(widget.controller.shuffleNotifier.value == true)
                                    widget.controller.playingSongs.shuffle();

                                  var file = File("assets/settings.json");
                                  widget.controller.settings.lastPlaying.clear();

                                  for(int i = 0; i < widget.controller.playingSongs.length; i++){
                                    widget.controller.settings.lastPlaying.add(widget.controller.playingSongs[i].path);
                                  }
                                  widget.controller.settings.lastPlayingIndex = widget.controller.playingSongs.indexOf(widget.controller.playingSongsUnShuffled[_index]);
                                  file.writeAsStringSync(jsonEncode(widget.controller.settings.toJson()));

                                  widget.controller.indexNotifier.value = widget.controller.settings.lastPlayingIndex;
                                  widget.controller.playSong();
                                },
                                child: Row(
                                  children: [
                                    Stack(
                                      // children: [
                                      //   widget.controller.found.value[_index].imageloaded ?
                                      //   Container(
                                      //     height: 75,
                                      //     width: 75,
                                      //     child: DecoratedBox(
                                      //       decoration: BoxDecoration(
                                      //         borderRadius: BorderRadius.circular(10),
                                      //         image: DecorationImage(
                                      //           image: Image.memory(widget.controller.found.value[_index].image).image,
                                      //           fit: BoxFit.cover,
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ) :
                                      //   loading?
                                      //   Container(
                                      //     height: 75,
                                      //     width: 75,
                                      //     child: DecoratedBox(
                                      //       decoration: BoxDecoration(
                                      //         borderRadius: BorderRadius.circular(10),
                                      //         image: DecorationImage(
                                      //           image: Image.memory(File("./assets/bg.png").readAsBytesSync()).image,
                                      //           fit: BoxFit.cover,
                                      //         ),
                                      //       ),
                                      //       child:
                                      //       Center(
                                      //         child: CircularProgressIndicator(
                                      //           color: Colors.white,
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   )
                                      //       : FutureBuilder(
                                      //     future: widget.controller.imageretrieve(widget.controller.found.value[_index].path),
                                      //     builder: (ctx, snapshot) {
                                      //       if (snapshot.hasData) {
                                      //         return
                                      //           Container(
                                      //             height: 75,
                                      //             width: 75,
                                      //             padding: EdgeInsets.only(left: 10),
                                      //             child: DecoratedBox(
                                      //               decoration: BoxDecoration(
                                      //                 borderRadius: BorderRadius.circular(10),
                                      //                 image: DecorationImage(
                                      //                   image: Image.memory(snapshot.data!).image,
                                      //                   fit: BoxFit.cover,
                                      //                 ),
                                      //               ),
                                      //             ),
                                      //           );
                                      //       }
                                      //       else if (snapshot.hasError) {
                                      //         return Center(
                                      //           child: Text(
                                      //             '${snapshot.error} occurred',
                                      //             style: TextStyle(fontSize: 18),
                                      //           ),
                                      //         );
                                      //       } else{
                                      //         return
                                      //           Container(
                                      //             height: 75,
                                      //             width: 75,
                                      //             child: DecoratedBox(
                                      //               decoration: BoxDecoration(
                                      //                 borderRadius: BorderRadius.circular(10),
                                      //                 image: DecorationImage(
                                      //                   image: Image.memory(File("./assets/bg.png").readAsBytesSync()).image,
                                      //                   fit: BoxFit.cover,
                                      //                 ),
                                      //               ),
                                      //               child:
                                      //               Center(
                                      //                 child: CircularProgressIndicator(
                                      //                   color: Colors.white,
                                      //                 ),
                                      //               ),
                                      //             ),
                                      //           );
                                      //       }
                                      //     },
                                      //   ),
                                      //   ClipRRect(
                                      //     // Clip it cleanly.
                                      //     child: BackdropFilter(
                                      //       filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
                                      //       child: Container(
                                      //         width: 75,
                                      //         height: 75,
                                      //         color: Colors.black.withOpacity(0.3),
                                      //         alignment: Alignment.center,
                                      //         child: Row(
                                      //           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      //           crossAxisAlignment: CrossAxisAlignment.center,
                                      //           children: [
                                      //             Container(
                                      //               width: 5,
                                      //             ),
                                      //             Container(
                                      //               width: 25,
                                      //               height: 100,
                                      //               child: IconButton(
                                      //                 padding: EdgeInsets.all(0),
                                      //                 onPressed: () {
                                      //                   setState(() {
                                      //                     if(_songstoadd.contains(widget.controller.found.value[_index])){
                                      //                       _songstoadd.remove(widget.controller.found.value[_index]);
                                      //                     }
                                      //                     else{
                                      //                       _songstoadd.add(widget.controller.found.value[_index]);
                                      //                     }
                                      //                     addelement = true;
                                      //                   });
                                      //                 },
                                      //                 icon: Icon(FluentIcons.add_16_filled, color: Colors.white, size: 30,),
                                      //               ),
                                      //             ),
                                      //             Container(
                                      //               width: 5,
                                      //             ),
                                      //             Container(
                                      //               height: 100,
                                      //               width: 15,
                                      //               child: IconButton(
                                      //                 padding: EdgeInsets.all(0),
                                      //                 onPressed: () {
                                      //                   widget.controller.playingSongs.clear();
                                      //                   widget.controller.playingSongsUnShuffled.clear();
                                      //
                                      //                   widget.controller.playingSongs.addAll(widget.controller.found.value);
                                      //                   widget.controller.playingSongsUnShuffled.addAll(widget.controller.found.value);
                                      //
                                      //                   if(widget.controller.shuffleNotifier.value == true)
                                      //                     widget.controller.playingSongs.shuffle();
                                      //
                                      //                   var file = File("assets/settings.json");
                                      //                   widget.controller.settings.lastplaying.clear();
                                      //
                                      //                   for(int i = 0; i < widget.controller.playingSongs.length; i++){
                                      //                     widget.controller.settings.lastplaying.add(widget.controller.playingSongs[i].path);
                                      //                   }
                                      //                   widget.controller.settings.lastplayingindex = widget.controller.playingSongs.indexOf(widget.controller.playingSongsUnShuffled[_index]);
                                      //                   file.writeAsStringSync(jsonEncode(widget.controller.settings.toJson()));
                                      //
                                      //                   widget.controller.indexNotifier.value = widget.controller.settings.lastplayingindex;
                                      //                   widget.controller.playSong();
                                      //                 },
                                      //                 icon: Icon(FluentIcons.play_12_filled, color: Colors.white, size: 30,),
                                      //               ),
                                      //             ),
                                      //             Container(
                                      //               width: 20,
                                      //             ),
                                      //           ],
                                      //         ),
                                      //       ),
                                      //     ),
                                      //   ),
                                      // ],
                                    ),

                                    Container(
                                      width: 15,
                                    ),
                                    Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                              widget.controller.found.value[_index].title.toString().length > 25 ? widget.controller.found.value[_index].title.toString().substring(0, 25) + "..." : widget.controller.found.value[_index].title.toString(),
                                              style: widget.controller.found.value[_index] != widget.controller.playingSongs[widget.controller.indexNotifier.value] ? TextStyle(
                                                color: Colors.white,
                                                fontSize: 18,
                                              ) : TextStyle(
                                                color: Colors.blue,
                                                fontSize: 18,
                                              )
                                          ),
                                          Container(
                                            height: 5,
                                          ),
                                          Text(
                                              widget.controller.found.value[_index].artists.toString().length > 30 ? widget.controller.found.value[_index].artists.toString().substring(0, 30) + "..." : widget.controller.found.value[_index].artists.toString(),
                                              style: widget.controller.found.value[_index] != widget.controller.playingSongs[widget.controller.indexNotifier.value] ? TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                              ) : TextStyle(
                                                color: Colors.blue,
                                                fontSize: 16,
                                              )
                                          ),
                                        ]
                                    ),
                                  ],
                                ),
                              ),

                            ) :
                            Container(
                              height:100,
                            );
                          },
                        )

                            : const Text(
                          'No results found',
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _incrementExit3(PointerEvent details) {
    setState(() {
      _hovereditem3 = -1;
    });
  }

}


