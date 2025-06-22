import 'package:duration/duration.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/components/custom_tiling/list_component.dart';
import 'package:musicplayer/providers/app_state_provider.dart';
import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
import 'package:musicplayer/entities/album.dart';
import 'package:musicplayer/components/image_widget.dart';
import 'package:provider/provider.dart';

class AlbumScreen extends StatefulWidget {
  static Route<dynamic> route({required Album album}) {
    return MaterialPageRoute(
      builder: (_) => AlbumScreen(album: album),
      settings: RouteSettings(
        name: '/album',
        arguments: album,
      ),
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
    return Container(
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
              Provider.of<AppStateProvider>(context, listen: false).navigatorKey.currentState?.pop();
              //Navigator.pop(context);
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
                  Container(
                    height: height * 0.5,
                    padding: EdgeInsets.only(
                      bottom: height * 0.01,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(width * 0.025),
                      child: Hero(
                        tag: widget.album.name,
                        child: ImageWidget(
                          path: widget.album.songs.isNotEmpty
                              ? widget.album.songs.first.path
                              : '',
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
                    //"${widget.album.duration ~/ 60}:${(widget.album.duration % 60).toString().padLeft(2, '0')}",
                    // "$duration    |  ${widget.album.songs.length} song${widget.album.songs.length > 1 ? "s" : ""}",
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
                            // var songPaths = widget.album.songs.map((e) => e.path).toList();
                            // if(SettingsController.queue.equals(songPaths) == false){
                            //   dc.updatePlaying(songPaths, 0);
                            // }
                            // SettingsController.index = SettingsController.currentQueue.indexOf(widget.album.songs.first.path);
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
                    onTap: (entity) async {
                      debugPrint("Tapped on ${entity.name}");
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
            // child: ListView.builder(
            //   itemCount: widget.album.songs.length,
            //   itemBuilder: (context, int index) {
            //     return AnimatedContainer(
            //       duration: const Duration(milliseconds: 500),
            //       curve: Curves.easeInOut,
            //       height: height * 0.125,
            //       padding: EdgeInsets.only(
            //         right: width * 0.01,
            //       ),
            //       child: MouseRegion(
            //         cursor: SystemMouseCursors.click,
            //         child: GestureDetector(
            //           behavior: HitTestBehavior.translucent,
            //           onTap: () async {
            //             var songPaths = widget.album.songs.map((e) => e.path).toList();
            //             if(SettingsController.queue.equals(songPaths) == false){
            //               dc.updatePlaying(songPaths, index);
            //             }
            //             SettingsController.index = SettingsController.currentQueue.indexOf(widget.album.songs[index].path);
            //             await AppAudioHandler.play();
            //           },
            //           child: ClipRRect(
            //             borderRadius: BorderRadius.circular(width * 0.01),
            //             child: HoverContainer(
            //               padding: EdgeInsets.only(
            //                 left: width * 0.0075,
            //                 right: width * 0.025,
            //                 top: height * 0.0075,
            //                 bottom: height * 0.0075,
            //               ),
            //               hoverColor: const Color(0xFF242424),
            //               normalColor: const Color(0xFF0E0E0E),
            //               height: height * 0.125,
            //               child: Row(
            //                 children: [
            //                   Stack(
            //                     alignment: Alignment.center,
            //                     children: [
            //                       ClipRRect(
            //                         borderRadius: BorderRadius.circular(height * 0.02),
            //                         child: ImageWidget(
            //                           path: widget.album.songs[index].path,
            //                           heroTag: widget.album.songs[index].path,
            //                         ),
            //                       ),
            //                       BackdropFilter(
            //                           filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
            //                           child: Text(
            //                               "${widget.album.songs[index].trackNumber}",
            //                               style: TextStyle(
            //                                 color: Colors.white,
            //                                 fontSize: boldSize,
            //                               )
            //                           )
            //                       )
            //                     ],
            //                   ),
            //                   SizedBox(
            //                     width: width * 0.01,
            //                   ),
            //                   Column(
            //                       mainAxisAlignment: MainAxisAlignment.center,
            //                       crossAxisAlignment: CrossAxisAlignment.start,
            //                       children: [
            //                         Text(
            //                             widget.album.songs[index].title.toString().length > 40 ? "${widget.album.songs[index].title.toString().substring(0, 40)}..." : widget.album.songs[index].title.toString(),
            //                             style: TextStyle(
            //                               color: Colors.white,
            //                               fontSize: normalSize,
            //                             )
            //                         ),
            //                         SizedBox(
            //                           height: height * 0.005,
            //                         ),
            //                         Text(
            //                             widget.album.songs[index].trackArtist.toString().length > 60 ? "${widget.album.songs[index].trackArtist.toString().substring(0, 60)}..." : widget.album.songs[index].trackArtist.toString(),
            //                             style: TextStyle(
            //                               color: Colors.white,
            //                               fontSize: smallSize,
            //                             )
            //                         ),
            //                       ]
            //                   ),
            //                   const Spacer(),
            //                   Text(
            //                       widget.album.songs[index].duration == 0 ? "??:??" : "${widget.album.songs[index].duration ~/ 60}:${(widget.album.songs[index].duration % 60).toString().padLeft(2, '0')}",
            //                       style: TextStyle(
            //                         color: Colors.white,
            //                         fontSize: normalSize,
            //                       )
            //                   ),
            //                 ],
            //               ),
            //
            //             ),
            //           ),
            //         ),
            //       ),
            //     );
            //   },
            // ),
          ),
          SizedBox(
            width: width * 0.02,
          ),
        ],
      ),
    );
  }
}