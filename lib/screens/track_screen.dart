import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
import 'package:musicplayer/entities/song.dart';
import 'package:musicplayer/components/image_widget.dart';

class TrackScreen extends StatefulWidget {
  static Route<void> route({required Song song}) {
    return PageRouteBuilder(
      settings: const RouteSettings(name: '/song', arguments: Song),
      pageBuilder: (context, animation, secondaryAnimation) {
        return TrackScreen(song: song,);
      },
    );
  }
  final Song song;
  const TrackScreen({super.key, required this.song});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    return Scaffold(
      body: Container(
        width: width,
        height: height,
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
                debugPrint("Back");
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
                      tag: widget.song.path,
                      child: Container(
                        height: height * 0.5,
                        width: height * 0.5,
                        padding: EdgeInsets.only(
                          bottom: height * 0.01,
                        ),
                        //color: Colors.red,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(width * 0.025),
                          child: ImageWidget(
                            path: widget.song.path,
                            type: ImageWidgetType.song,
                          )
                        ),
                      ),
                    ),
                    SizedBox(
                      height: height * 0.01,
                    ),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () async {
                              // dc.updatePlaying([widget.song.path], 0);
                              // SettingsController.index = SettingsController.currentQueue.indexOf(widget.song.path);
                              // await AppAudioHandler.play();
                            },
                            icon: Icon(
                              FluentIcons.play,
                              color: Colors.white,
                              size: height * 0.025,
                            ),
                          ),
                          IconButton(
                            onPressed: (){
                              debugPrint("Add ${widget.song.name}");
                              // Navigator.pushNamed(context, '/add', arguments: [widget.song]);
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
                  top: height * 0.1,
                  bottom: height * 0.2,
                  left: width * 0.02,
                ),
                child: CustomScrollView(
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Text(
                            widget.song.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: boldSize,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: height * 0.01,),
                          Text(
                            widget.song.trackArtist,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: normalSize,
                            ),
                          ),
                          SizedBox(height: height * 0.01,),
                          Text(
                            widget.song.album,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: smallSize,
                            ),
                          ),
                          SizedBox(height: height * 0.01,),
                          Text(
                            widget.song.albumArtist,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: smallSize,
                            ),
                          ),
                          SizedBox(height: height * 0.01,),
                          Text(
                            Duration(seconds: widget.song.duration).pretty(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: smallSize,
                            ),
                          ),
                          SizedBox(height: height * 0.01,),
                          Text(
                            widget.song.genre,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: smallSize,
                            ),
                          ),
                          SizedBox(height: height * 0.01,),
                          Text(
                            widget.song.year > 0 ? widget.song.year.toString() : "Unknown year",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: smallSize,
                            ),
                          ),
                          SizedBox(height: height * 0.01,),
                          Text(
                            "Track: ${widget.song.trackNumber} / Disc: ${widget.song.discNumber}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: smallSize,
                            ),
                          ),
                          SizedBox(height: height * 0.01,),
                          Text(
                            "Play Count: ${widget.song.playCount}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: smallSize,
                            ),
                          ),
                          SizedBox(height: height * 0.01,),
                          Text(
                            "Last Played: ${widget.song.lastPlayed != null ? widget.song.lastPlayed!.toLocal().toString() : "Never"}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: smallSize,
                            ),
                          ),
                          SizedBox(height: height * 0.01,),
                          Text(
                            "Lyrics: ${widget.song.lyricsPath.isNotEmpty ? widget.song.lyricsPath : "No lyrics available"}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: smallSize,
                            ),
                          ),
                          SizedBox(height: height * 0.01,),
                          Text(
                            "Path: ${widget.song.path}",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: smallSize,
                            )
                          ),

                        ]
                      ),
                    ),
                  ],
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