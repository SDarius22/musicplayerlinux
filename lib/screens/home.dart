import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:musicplayer/screens/search_widget.dart';
import 'package:musicplayer/screens/song_player_widget.dart';
import 'package:musicplayer/utils/objectbox.g.dart';
import 'package:window_manager/window_manager.dart';
import '../controller/controller.dart';
import 'albums.dart';
import 'artists.dart';
import 'tracks.dart';
import 'settings.dart';
import 'playlists.dart';


class HomePage extends StatefulWidget {
  final Controller controller;
  const HomePage({super.key, required this.controller});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>{
  bool volume = true;

  int currentPage = 3;
  String userMessage = "No message";
  final ValueNotifier<bool> _visible = ValueNotifier(false);
  final ScrollController _scrollController = ScrollController(initialScrollOffset: 0.0);
  final PageController _pageController = PageController(initialPage: 4);



  @override
  void initState(){
    widget.controller.retrieveSongs();
    widget.controller.found.value = widget.controller.songBox.query().order(MetadataType_.title).build().find();
    // widget.controller.indexNotifier.value= widget.controller.settings.lastPlayingIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size(
            double.maxFinite,
            height * 0.04,
        ),
        child: DragToMoveArea(
          child: ValueListenableBuilder(
            valueListenable: widget.controller.colorNotifier,
            builder: (context, value, child){
              return AppBar(
                title: Text(
                    'Music Player',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: normalSize,
                    ),
                ),
                backgroundColor: widget.controller.colorNotifier2.value,
                actions: [
                  Container(
                      alignment: Alignment.center,
                      child: ValueListenableBuilder(
                        valueListenable: _visible,
                        builder: (context, value, child) =>
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                      child: ValueListenableBuilder(
                                          valueListenable: widget.controller.volumeNotifier,
                                          builder: (context, value, child){
                                            return SliderTheme(
                                                data: SliderThemeData(
                                                  trackHeight: 2,
                                                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: height * 0.0075),
                                                ),
                                                child: Slider(
                                                  min: 0.0,
                                                  max: 1.0,
                                                  mouseCursor: SystemMouseCursors.click,
                                                  value: value,
                                                  activeColor: widget.controller.colorNotifier.value,
                                                  thumbColor: Colors.white,
                                                  inactiveColor: Colors.white,
                                                  onChanged: (double value) {
                                                    widget.controller.volumeNotifier.value = value;
                                                    widget.controller.audioPlayer.setVolume(widget.controller.volumeNotifier.value);
                                                  },
                                                ),
                                            );
                                          }
                                      ),
                                    ),
                                  ),
                                ),
                                MouseRegion(
                                  onEnter: (event) {
                                    _visible.value = true;
                                  },
                                  onExit: (event) {
                                    _visible.value = false;
                                  },
                                  child: ValueListenableBuilder(
                                      valueListenable: widget.controller.volumeNotifier,
                                      builder: (context, value, child) {
                                        return IconButton(
                                          icon: volume ? Icon(
                                              FluentIcons.speaker_2_16_filled,
                                            size: height * 0.02,
                                            color: Colors.white,
                                          ) :
                                          Icon(
                                              FluentIcons.speaker_mute_16_filled,
                                            size: height * 0.02,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            if(volume) {
                                              widget.controller.volumeNotifier.value = 0;
                                            }
                                            else {
                                              widget.controller.volumeNotifier.value = 0.1;
                                            }
                                            volume = !volume;
                                            widget.controller.audioPlayer.setVolume(widget.controller.volumeNotifier.value);
                                          },
                                        );
                                      }
                                  ),
                                ),
                                IconButton(onPressed: (){
                                  print("Search");
                                  widget.controller.searchNotifier.value = !widget.controller.searchNotifier.value;
                                }, icon: Icon(
                                    FluentIcons.search_16_filled,
                                  size: height * 0.02,
                                  color: Colors.white,
                                  )
                                ),
                                IconButton(onPressed: (){
                                  print("Tapped settings");
                                  Navigator.push(context, MaterialPageRoute(builder: (BuildContext context){
                                    return Settings(controller: widget.controller,);
                                  }));
                                }, icon: Icon(
                                    FluentIcons.settings_16_filled,
                                  size: height * 0.02,
                                  color: Colors.white,
                                  )
                                )//Icon(Icons.more_vert)),
                              ],
                            ),
                      )),
                  Icon(
                      FluentIcons.divider_tall_16_regular,
                    size: height * 0.02,
                    color: Colors.white,
                  ),
                  IconButton(
                    onPressed: () => windowManager.minimize(),
                    icon: Icon(
                        FluentIcons.spacebar_20_filled,
                      size: height * 0.02,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (await windowManager.isMaximized()) {
                        //print("Restoring");
                        await windowManager.unmaximize();
                        //await windowManager.setSize(Size(width * 0.6, height * 0.6));
                      } else {
                        await windowManager.maximize();
                      }

                    },
                    icon: Icon(
                      FluentIcons.maximize_16_regular,
                      size: height * 0.02,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    onPressed: () => windowManager.close(),
                    icon: Icon(
                        Icons.close_outlined,
                      size: height * 0.02,
                      color: Colors.white,

                    ),
                  ),
                ],
              );
            }
          ),

        ),
      ),
      body: SafeArea(
        child: Container(
          width: width,
          height: height,
          padding: EdgeInsets.only(
            top: height * 0.005,
            left: width * 0.005,
            right: width * 0.005,
            bottom: height * 0.005,
          ),
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
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    alignment: Alignment.bottomCenter,
                    child: value ?
                      SongPlayerWidget(controller: widget.controller) :
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        padding: EdgeInsets.only(
                          left: width * 0.01,
                          right: width * 0.01,
                          bottom: height * 0.01,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(height * 0.1),
                        ),
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                  );
                }
              ),
              ValueListenableBuilder(
                  valueListenable: widget.controller.searchNotifier,
                  builder: (context, value, child){
                    return Visibility(
                      visible: value,
                      child: GestureDetector(
                        onTap: (){
                          widget.controller.searchNotifier.value = false;
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: width,
                          height: height,
                          color: value ? Colors.black.withOpacity(0.3) : Colors.transparent,
                          child: SearchWidget(controller: widget.controller),
                        ),
                      ),
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
            ],
          ),
        ),
      ),
    );
  }
}


