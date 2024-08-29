import 'dart:ui';
import 'package:flutter/material.dart';
import '../controller/controller.dart';
import 'albums.dart';
import 'artists.dart';
import 'tracks.dart';
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
  final PageController _pageController = PageController(initialPage: 4);



  @override
  void initState(){
    super.initState();
    widget.controller.initDeezer();
    //widget.controller.retrieveSongs();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    return Scaffold(
      body: SizedBox(
        width: width,
        height: height,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // artists, albums, playlists, tracks
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    child: SizedBox(
                        height: height * 0.05,
                        child: ElevatedButton(
                            onPressed: (){
                              //print("Artists");
                              _pageController.animateToPage(0,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeIn
                              );
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
                    child: SizedBox(
                        height: height * 0.05,
                        child: ElevatedButton(
                            onPressed: (){
                              //print("Artists");
                              _pageController.animateToPage(1,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeIn
                              );
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
                    child: SizedBox(
                        height: height * 0.05,
                        child: ElevatedButton(
                            onPressed: (){
                              //print("Artists");
                              _pageController.animateToPage(2,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeIn
                              );
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
                    child: SizedBox(
                        height: height * 0.05,
                        child: ElevatedButton(
                            onPressed: (){
                              //print("Artists");
                              _pageController.animateToPage(3,
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeIn
                              );
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
            Expanded(
              child: Container(
                padding: EdgeInsets.only(
                    top: height * 0.02,
                    left: width * 0.01,
                    right: width * 0.01,
                    bottom: height * 0.02
                ),
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
            ),
          ],
        ),
      ),
    );
  }
}


