import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/components/custom_tiling/list_component.dart';
import 'package:musicplayer/entities/song.dart';
import 'package:musicplayer/providers/audio_provider.dart';
import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
import 'package:musicplayer/entities/album.dart';
import 'package:musicplayer/components/image_widget.dart';
import 'package:provider/provider.dart';

class AlbumScreen extends StatefulWidget {
  static Route<void> route({required Album album}) {
    return PageRouteBuilder(
      settings: const RouteSettings(name: '/album', arguments: Album),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlbumScreen(album: album);
      },
    );
  }

  final Album album;
  const AlbumScreen({super.key, required this.album});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {

  @override
  void initState() {
    super.initState();
    widget.album.songs.sort((a, b) => a.trackNumber.compareTo(b.trackNumber));
  }

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
                      tag: widget.album.name,
                      child: Container(
                        height: height * 0.5,
                        width: height * 0.5,
                        padding: EdgeInsets.only(
                          bottom: height * 0.01,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(width * 0.025),
                          child: ImageWidget(
                            path: widget.album.songs.isNotEmpty
                                ? widget.album.songs.first.path
                                : '',
                            type: ImageWidgetType.song,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      widget.album.name,
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
                      widget.album.songs.first.albumArtist,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: normalSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      height: height * 0.005,
                    ),
                    Text(
                      Duration(seconds: widget.album.duration,).pretty(),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: smallSize,
                        fontWeight: FontWeight.normal,
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
                              debugPrint("Play ${widget.album.name}");
                              List<String> songPaths = widget.album.songs.map((e) => e.path).toList();
                              var audioProvider = Provider.of<AudioProvider>(context, listen: false);
                              audioProvider.setQueue(songPaths);
                              await audioProvider.setCurrentIndex(widget.album.songs.first.path);
                            },
                            icon: Icon(
                              FluentIcons.play,
                              color: Colors.white,
                              size: height * 0.025,
                            ),
                          ),
                          IconButton(
                            onPressed: (){
                              debugPrint("Add ${widget.album.name}");
                              //Navigator.pushNamed(context, '/add', arguments: widget.album.songs);
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
                  SliverPadding(
                    padding: EdgeInsets.only(
                      bottom: height * 0.02,
                    ),
                    sliver: ListComponent(
                      items: widget.album.songs,
                      itemExtent: height * 0.125,
                      isSelected: (entity) {
                        return false;
                      },
                      onTap: (entity) async {
                        debugPrint("Tapped on ${entity.name}");
                        List<String> songPaths = widget.album.songs.map((e) => e.path).toList();
                        var audioProvider = Provider.of<AudioProvider>(context, listen: false);
                        audioProvider.setQueue(songPaths);
                        await audioProvider.setCurrentIndex((entity as Song).path);

                        // var songPaths = widget.album.songs.map((e) => e.path).toList();
                        // if(SettingsController.queue.equals(songPaths) == false){
                        //   dc.updatePlaying(songPaths, 0);
                        // }
                        // SettingsController.index = SettingsController.currentQueue.indexOf(entity.path);
                        // await AppAudioHandler.play();
                      },
                      onLongPress: (entity) {
                        debugPrint("Long pressed on ${entity.name}");
                        // Show context menu or options
                      },
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