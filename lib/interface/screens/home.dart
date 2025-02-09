import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:musicplayer/controller/worker_controller.dart';
import '../../controller/data_controller.dart';
import '../../controller/settings_controller.dart';
import 'albums.dart';
import 'artists.dart';
import 'download_screen.dart';

import 'tracks.dart';
import 'playlists.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>{
  int currentPage = 3;
  String userMessage = "No message";
  final PageController _pageController = PageController(initialPage: 5);

  late Future<void> _init;

  @override
  void initState() {
    super.initState();
    _init = Future(() async {
      await WorkerController.retrieveAllSongs();
      if (SettingsController.queue.isEmpty){
        debugPrint("Queue is empty");
        var songs = await DataController.getSongs('');
        SettingsController.queue = songs.map((e) => e.path).toList();
        int newIndex = 0;
        SettingsController.index = newIndex;
      }
      else{
        // debugPrint(SettingsController.index.toString());
        // debugPrint(SettingsController.shuffledQueue.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // var boldSize = height * 0.025;
    // var normalSize = height * 0.02;
    // var smallSize = height * 0.0175;

    return SizedBox(
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
                      height: MediaQuery.of(context).size.height * 0.045,
                      child: ElevatedButton(
                          onPressed: (){
                            //debugPrint("Artists");
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
                              fontSize: currentPage != 0 ?
                              MediaQuery.of(context).size.height * 0.02 : MediaQuery.of(context).size.height * 0.025,
                            ),
                          )
                      )
                  )
              ),
              Expanded(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.045,
                      child: ElevatedButton(
                          onPressed: (){
                            //debugPrint("Artists");
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
                              fontSize: currentPage != 1 ?
                              MediaQuery.of(context).size.height * 0.02 : MediaQuery.of(context).size.height * 0.025,
                            ),
                          )
                      )
                  )
              ),
              Expanded(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.045,
                      child: ElevatedButton(
                          onPressed: (){
                            //debugPrint("Artists");
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
                            "Download",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: currentPage != 2 ?
                              MediaQuery.of(context).size.height * 0.02 : MediaQuery.of(context).size.height * 0.025,
                            ),
                          )
                      )
                  )
              ),
              Expanded(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.045,
                      child: ElevatedButton(
                          onPressed: (){
                            //debugPrint("Artists");
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
                            "Playlists",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: currentPage != 3 ?
                              MediaQuery.of(context).size.height * 0.02 : MediaQuery.of(context).size.height * 0.025,
                            ),
                          )
                      )
                  )
              ),
              Expanded(
                  child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.045,
                      child: ElevatedButton(
                          onPressed: (){
                            //debugPrint("Artists");
                            _pageController.animateToPage(4,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeIn
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: currentPage != 4 ? const Color(0xFF0E0E0E) : const Color(0xFF1b1b1b),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(0),
                            ),
                          ),
                          child: Text(
                            "Tracks",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: currentPage != 4 ?
                              MediaQuery.of(context).size.height * 0.02 : MediaQuery.of(context).size.height * 0.025,
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
              child: FutureBuilder(
                future: _init,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return PageView(
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
                      children: const [
                        Artists(),
                        Albums(),
                        Download(),
                        Playlists(),
                        Tracks(),
                      ],

                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}


