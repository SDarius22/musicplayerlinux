import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/controller/settings_controller.dart';
import 'package:musicplayer/utils/hover_widget/hover_container.dart';
import 'package:musicplayer/domain/artist_type.dart';
import '../../controller/audio_player_controller.dart';
import '../../controller/data_controller.dart';
import '../../main.dart';
import '../../utils/fluenticons/fluenticons.dart';
import 'add_screen.dart';
import '../widgets/image_widget.dart';

class ArtistScreen extends StatefulWidget {
  final ArtistType artist;
  const ArtistScreen({super.key, required this.artist});

  @override
  _ArtistScreenState createState() => _ArtistScreenState();
}

class _ArtistScreenState extends State<ArtistScreen> {
  String duration = "0 seconds";


  @override
  void initState() {
    int totalDuration = 0;
    for(int i = 0; i < widget.artist.songs.length; i++){
      totalDuration += widget.artist.songs[i].duration;
    }
    duration = " ${totalDuration ~/ 3600} hours, ${(totalDuration % 3600 ~/ 60)} minutes and ${(totalDuration % 60)} seconds";
    duration = duration.replaceAll(" 0 hours,", "");
    duration = duration.replaceAll(" 0 minutes and", "");
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    print(widget.artist.name);
    final dc = DataController();
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(
            top: height * 0.02,
            left: width * 0.01,
            right: width * 0.01,
            bottom: height * 0.02
        ),
        alignment: Alignment.center,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: (){
                print("Back");
                Navigator.pop(context);
              },
              icon: Icon(
                FluentIcons.back,
                size: height * 0.02,
                color: Colors.white,
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: width * 0.4,
              padding: EdgeInsets.only(
                top: height * 0.1,
                bottom: height * 0.05,
              ),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children:[
                    Hero(
                      tag: widget.artist.name,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        height: height * 0.5,
                        padding: EdgeInsets.only(
                          bottom: height * 0.01,
                        ),
                        //color: Colors.red,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(width * 0.025),
                          child: ImageWidget(
                            path: widget.artist.songs.first.path,
                          ),
                        ),

                      ),
                    ),
                    Text(
                      widget.artist.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: boldSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.005,
                    ),
                    Text(
                      duration,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: smallSize,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.005,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () async {
                              var songPaths = widget.artist.songs.map((e) => e.path).toList();
                              if(SettingsController.queue.equals(songPaths) == false){
                                dc.updatePlaying(songPaths, 0);
                              }
                              SettingsController.index = SettingsController.currentQueue.indexOf(widget.artist.songs.first.path);
                             await audioHandler.play();
                            },
                            icon: Icon(
                              FluentIcons.play,
                              color: Colors.white,
                              size: height * 0.025,
                            ),
                          ),
                          IconButton(
                            onPressed: (){
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddScreen(songs: widget.artist.songs)
                                  )
                              );
                            },
                            icon: Icon(
                              FluentIcons.add,
                              color: Colors.white,
                              size: height * 0.025,
                            ),
                          ),
                        ]
                    ),
                  ]
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: width * 0.45,
              padding: EdgeInsets.only(
                left: width * 0.02,
                top: height * 0.1,
                bottom: height * 0.2,
              ),
              child: ListView.builder(
                itemCount: widget.artist.songs.length,
                itemBuilder: (context, int index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    height: height * 0.125,
                    padding: EdgeInsets.only(
                      right: width * 0.01,
                    ),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: () async {
                          var songPaths = widget.artist.songs.map((e) => e.path).toList();
                          if(SettingsController.queue.equals(songPaths) == false){
                            dc.updatePlaying(songPaths, index);
                          }
                          SettingsController.index = SettingsController.currentQueue.indexOf(widget.artist.songs[index].path);
                         await audioHandler.play();
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(width * 0.01),
                          child: HoverContainer(
                            hoverColor: const Color(0xFF242424),
                            normalColor: const Color(0xFF0E0E0E),
                            padding: EdgeInsets.only(
                              left: width * 0.0075,
                              right: width * 0.025,
                              top: height * 0.0075,
                              bottom: height * 0.0075,
                            ),
                            height: height * 0.125,
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(width * 0.01),
                                  child: ImageWidget(
                                    path: widget.artist.songs[index].path,
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
                                          widget.artist.songs[index].title.toString().length > 30 ? "${widget.artist.songs[index].title.toString().substring(0, 30)}..." : widget.artist.songs[index].title.toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: normalSize,
                                          )
                                      ),
                                      SizedBox(
                                        height: height * 0.005,
                                      ),
                                      Text(
                                          widget.artist.songs[index].artists.toString().length > 60 ? "${widget.artist.songs[index].artists.toString().substring(0, 60)}..." : widget.artist.songs[index].artists.toString(),
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: smallSize,
                                          )
                                      ),
                                    ]
                                ),
                                const Spacer(),
                                Text(
                                    widget.artist.songs[index].duration == 0 ? "??:??" : "${widget.artist.songs[index].duration ~/ 60}:${(widget.artist.songs[index].duration % 60).toString().padLeft(2, '0')}",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: normalSize,
                                    )
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(
              width: width * 0.02,
            ),
          ],
        ),
      ),
    );
  }
}