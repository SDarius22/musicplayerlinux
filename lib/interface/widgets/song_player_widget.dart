import 'dart:ui';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/controller/audio_player_controller.dart';
import 'package:musicplayer/controller/data_controller.dart';
import 'package:musicplayer/utils/hover_widget/hover_container.dart';
import '../../controller/app_audio_handler.dart';
import '../../controller/app_manager.dart';
import '../../controller/settings_controller.dart';
import '../../domain/song_type.dart';
import '../../repository/objectbox.g.dart';
import '../../utils/fluenticons/fluenticons.dart';
import '../../utils/multivaluelistenablebuilder/mvlb.dart';
import '../../utils/lyric_reader/lyrics_reader.dart';
import '../../utils/progress_bar/audio_video_progress_bar.dart';
import '../../utils/text_scroll/text_scroll.dart';
import 'image_widget.dart';

class SongPlayerWidget extends StatefulWidget {
  const SongPlayerWidget({super.key});

  @override
  State<SongPlayerWidget> createState() => _SongPlayerWidgetState();
}


class _SongPlayerWidgetState extends State<SongPlayerWidget> {

  ScrollController itemScrollController = ScrollController();
  var lyricUI = UINetease(
      defaultTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      defaultExtTextStyle: const TextStyle(color: Colors.grey, fontSize: 16),
      otherMainTextStyle: const TextStyle(color: Colors.grey, fontSize: 20),
      bias : 0.5,
      lineGap : 5,
      inlineGap : 5,
      highlightColor: Colors.blue,
      lyricAlign : LyricAlign.CENTER,
      lyricBaseLine : LyricBaseLine.CENTER,
      highlight : false
  );
  ValueNotifier<bool> editMode = ValueNotifier<bool>(false);
  ValueNotifier<bool> hiddenNotifier = ValueNotifier<bool>(false);
  ValueNotifier<bool> likedNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    itemScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dc = DataController();
    final am = AppManager();
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    lyricUI = UINetease(
        defaultTextStyle: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.height * 0.022),
        defaultExtTextStyle: TextStyle(color: Colors.grey, fontSize: MediaQuery.of(context).size.height * 0.020),
        otherMainTextStyle: TextStyle(color: Colors.grey, fontSize: MediaQuery.of(context).size.height * 0.020),
        bias : 0.5,
        lineGap : 5,
        inlineGap : 5,
        highlightColor: SettingsController.lightColorNotifier.value,
        lyricAlign : LyricAlign.CENTER,
        lyricBaseLine : LyricBaseLine.CENTER,
        highlight : false
    );
    return MultiValueListenableBuilder(
        valueListenables: [am.minimizedNotifier, hiddenNotifier, AudioPlayerController.imageNotifier, SettingsController.lightColorNotifier],
        builder: (context, values, child){
          return Stack(
            alignment: Alignment.center,
            children: [
              IgnorePointer(
                ignoring: values[1],
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.linear,
                  height: values[0] ? height * 0.15 : (MediaQuery.of(context).size.height - appWindow.titleBarHeight),
                  width: width,
                  alignment: values[0] ? Alignment.centerLeft : Alignment.center,
                  padding: EdgeInsets.only(
                    left: values[0] ? width * 0.001 : width * 0.05,
                    right: values[0] ? width * 0.001 : width * 0.05,
                  ),
                  margin: values[0] ? EdgeInsets.only(
                    bottom: height * 0.025,
                    left: width * 0.125,
                    right: width * 0.125,
                  ) : null,
                  decoration: BoxDecoration(
                    color: values[0] ? SettingsController.darkColorNotifier.value.withOpacity(values[1] ? 0.0 : 1) : const Color(0xFF0E0E0E),
                    borderRadius: values[0] ? BorderRadius.circular(width * 0.2) : BorderRadius.circular(0),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: values[0] ? WrapCrossAlignment.center : WrapCrossAlignment.start,
                    children: [

                      // Queue
                      if (!values[0])
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          height: width * 0.275,
                          width: width * 0.275,
                          child: ListView.builder(
                            controller: itemScrollController,
                            itemCount: SettingsController.queue.length,
                            padding: EdgeInsets.only(
                                right: width * 0.01
                            ),
                            itemExtent: height * 0.11,
                            itemBuilder: (context, int index) {
                              return FutureBuilder(
                                future: Future.delayed(const Duration(milliseconds: 500), () async {
                                  return await DataController.getSong(SettingsController.queue[index]);
                                }),
                                builder: (context, snapshot){
                                  if (snapshot.hasData) {
                                    var song = snapshot.data ?? SongType();
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                      height: height * 0.11,
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: GestureDetector(
                                            behavior: HitTestBehavior.translucent,
                                            onTap: () async {
                                              //debugPrint(SettingsController.playingSongsUnShuffled[index].title);
                                              //widget.controller.audioPlayer.stop();
                                              // DataController.indexChange(SettingsController.queue[index]);
                                              SettingsController.index = SettingsController.currentQueue.indexOf(SettingsController.queue[index]);
                                              await AppAudioHandler.play();
                                            },
                                            child: ClipRRect(
                                              borderRadius: BorderRadius.circular(width * 0.005),
                                              child: HoverContainer(
                                                hoverColor: const Color(0xFF242424),
                                                normalColor: const Color(0xFF0E0E0E),
                                                padding: EdgeInsets.all(width * 0.005),
                                                child: Row(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius: BorderRadius.circular(width * 0.005),
                                                      child: ImageWidget(
                                                        path: SettingsController.queue[index],
                                                        heroTag: "${SettingsController.queue[index]} $index",
                                                        hoveredChild: IconButton(
                                                          onPressed: () async {
                                                            debugPrint("Delete song from queue");
                                                            await dc.removeFromQueue(SettingsController.queue[index]);
                                                            setState(() {});
                                                          },
                                                          icon: Icon(
                                                            FluentIcons.trash,
                                                            color: Colors.white,
                                                            size: width * 0.0125,
                                                          ),
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
                                                          SizedBox(
                                                            width: width * 0.15,
                                                            child: TextScroll(
                                                              song.title,
                                                              mode: TextScrollMode.bouncing,
                                                              velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
                                                              style: TextStyle(
                                                                color: SettingsController.currentSongPath != song.path ? Colors.white : Colors.blue,
                                                                fontSize: normalSize,
                                                                fontWeight: FontWeight.normal,
                                                              ),
                                                              pauseOnBounce: const Duration(seconds: 2),
                                                              delayBefore: const Duration(seconds: 2),
                                                              pauseBetween: const Duration(seconds: 2),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: height * 0.005,
                                                          ),
                                                          Text(song.artists.toString().length > 60 ? "${song.artists.toString().substring(0, 60)}..." : song.artists.toString(),
                                                              style: TextStyle(
                                                                color: SettingsController.currentSongPath != song.path ? Colors.white : Colors.blue,
                                                                fontSize: smallSize,
                                                              )
                                                          ),
                                                        ]
                                                    ),
                                                    const Spacer(),
                                                    Text(
                                                        "${song.duration ~/ 60}:${(song.duration % 60).toString().padLeft(2, '0')}",
                                                        style: TextStyle(
                                                          color: SettingsController.currentSongPath != song.path ? Colors.white : Colors.blue,
                                                          fontSize: normalSize,
                                                        )
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                        ),
                                      ),
                                    );
                                  }
                                  else {
                                    return AnimatedContainer(
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                      height: height * 0.11,
                                      child: MouseRegion(
                                        cursor: SystemMouseCursors.click,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(width * 0.005),
                                          child: HoverContainer(
                                            hoverColor: const Color(0xFF242424),
                                            normalColor: const Color(0xFF0E0E0E),
                                            padding: EdgeInsets.all(width * 0.005),
                                            child: Row(
                                              children: [
                                                ClipRRect(
                                                  borderRadius: BorderRadius.circular(width * 0.005),
                                                  child: ImageWidget(
                                                    path: "",
                                                    heroTag: "null $index",
                                                    hoveredChild: IconButton(
                                                      onPressed: () async {
                                                        debugPrint("Delete song from queue");
                                                        await dc.removeFromQueue(SettingsController.queue[index]);
                                                        setState(() {});
                                                      },
                                                      icon: Icon(
                                                        FluentIcons.trash,
                                                        color: Colors.white,
                                                        size: width * 0.0125,
                                                      ),
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
                                                      SizedBox(
                                                        width: width * 0.15,
                                                        child: TextScroll(
                                                          "Loading...",
                                                          mode: TextScrollMode.bouncing,
                                                          velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: normalSize,
                                                            fontWeight: FontWeight.normal,
                                                          ),
                                                          pauseOnBounce: const Duration(seconds: 2),
                                                          delayBefore: const Duration(seconds: 2),
                                                          pauseBetween: const Duration(seconds: 2),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        height: height * 0.005,
                                                      ),
                                                      Text(
                                                          "Loading...",
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: smallSize,
                                                          )
                                                      ),
                                                    ]
                                                ),
                                                const Spacer(),
                                                Text(
                                                    "??:??",
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
                                    );
                                  }
                                },
                              );
                              // if(index >= 0 && index < SettingsController.queue.length){
                              //   var song = snapshot.data![index];
                              //   return AnimatedContainer(
                              //     duration: const Duration(milliseconds: 500),
                              //     curve: Curves.easeInOut,
                              //     height: height * 0.11,
                              //     child: MouseRegion(
                              //       cursor: SystemMouseCursors.click,
                              //       child: GestureDetector(
                              //           behavior: HitTestBehavior.translucent,
                              //           onTap: () async {
                              //             //debugPrint(SettingsController.playingSongsUnShuffled[index].title);
                              //             //widget.controller.audioPlayer.stop();
                              //             // DataController.indexChange(SettingsController.queue[index]);
                              //             SettingsController.index = SettingsController.currentQueue.indexOf(SettingsController.queue[index]);
                              //             await AppAudioHandler.play();
                              //           },
                              //           child: ClipRRect(
                              //             borderRadius: BorderRadius.circular(width * 0.005),
                              //             child: HoverContainer(
                              //               hoverColor: const Color(0xFF242424),
                              //               normalColor: const Color(0xFF0E0E0E),
                              //               padding: EdgeInsets.all(width * 0.005),
                              //               child: Row(
                              //                 children: [
                              //                   ClipRRect(
                              //                     borderRadius: BorderRadius.circular(width * 0.005),
                              //                     child: ImageWidget(
                              //                       path: SettingsController.queue[index],
                              //                       buttons: IconButton(
                              //                         onPressed: () async {
                              //                           debugPrint("Delete song from queue");
                              //                           await dc.removeFromQueue(SettingsController.queue[index]);
                              //                           setState(() {});
                              //                         },
                              //                         icon: Icon(
                              //                           FluentIcons.trash,
                              //                           color: Colors.white,
                              //                           size: width * 0.0125,
                              //                         ),
                              //                       ),
                              //                     ),
                              //                   ),
                              //                   SizedBox(
                              //                     width: width * 0.01,
                              //                   ),
                              //                   Column(
                              //                       mainAxisAlignment: MainAxisAlignment.center,
                              //                       crossAxisAlignment: CrossAxisAlignment.start,
                              //                       children: [
                              //                         SizedBox(
                              //                           width: width * 0.15,
                              //                           child: TextScroll(
                              //                             song.title,
                              //                             mode: TextScrollMode.bouncing,
                              //                             velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
                              //                             style: TextStyle(
                              //                               color: SettingsController.currentSongPath != song.path ? Colors.white : Colors.blue,
                              //                               fontSize: normalSize,
                              //                               fontWeight: FontWeight.normal,
                              //                             ),
                              //                             pauseOnBounce: const Duration(seconds: 2),
                              //                             delayBefore: const Duration(seconds: 2),
                              //                             pauseBetween: const Duration(seconds: 2),
                              //                           ),
                              //                         ),
                              //                         SizedBox(
                              //                           height: height * 0.005,
                              //                         ),
                              //                         Text(song.artists.toString().length > 60 ? "${song.artists.toString().substring(0, 60)}..." : song.artists.toString(),
                              //                             style: TextStyle(
                              //                               color: SettingsController.currentSongPath != song.path ? Colors.white : Colors.blue,
                              //                               fontSize: smallSize,
                              //                             )
                              //                         ),
                              //                       ]
                              //                   ),
                              //                   const Spacer(),
                              //                   Text(
                              //                       "${song.duration ~/ 60}:${(song.duration % 60).toString().padLeft(2, '0')}",
                              //                       style: TextStyle(
                              //                         color: SettingsController.currentSongPath != song.path ? Colors.white : Colors.blue,
                              //                         fontSize: normalSize,
                              //                       )
                              //                   ),
                              //                 ],
                              //               ),
                              //             ),
                              //           )
                              //       ),
                              //     ),
                              //   );
                              // }
                              // return null;
                            },
                          ),
                          // child: FutureBuilder(
                          //   future: DataController.getQueue(),
                          //   builder: (context, snapshot){
                          //     if(snapshot.hasData){
                          //       return ListView.builder(
                          //         controller: itemScrollController,
                          //         itemCount: snapshot.data!.length,
                          //         padding: EdgeInsets.only(
                          //             right: width * 0.01
                          //         ),
                          //         itemBuilder: (context, int index) {
                          //           if(index >= 0 && index < SettingsController.queue.length){
                          //             var song = snapshot.data![index];
                          //             return AnimatedContainer(
                          //               duration: const Duration(milliseconds: 500),
                          //               curve: Curves.easeInOut,
                          //               height: height * 0.11,
                          //               child: MouseRegion(
                          //                 cursor: SystemMouseCursors.click,
                          //                 child: GestureDetector(
                          //                     behavior: HitTestBehavior.translucent,
                          //                     onTap: () async {
                          //                       //debugPrint(SettingsController.playingSongsUnShuffled[index].title);
                          //                       //widget.controller.audioPlayer.stop();
                          //                       // DataController.indexChange(SettingsController.queue[index]);
                          //                       SettingsController.index = SettingsController.currentQueue.indexOf(SettingsController.queue[index]);
                          //                       await AppAudioHandler.play();
                          //                     },
                          //                     child: ClipRRect(
                          //                       borderRadius: BorderRadius.circular(width * 0.005),
                          //                       child: HoverContainer(
                          //                         hoverColor: const Color(0xFF242424),
                          //                         normalColor: const Color(0xFF0E0E0E),
                          //                         padding: EdgeInsets.all(width * 0.005),
                          //                         child: Row(
                          //                           children: [
                          //                             ClipRRect(
                          //                               borderRadius: BorderRadius.circular(width * 0.005),
                          //                               child: ImageWidget(
                          //                                 path: SettingsController.queue[index],
                          //                                 buttons: IconButton(
                          //                                   onPressed: () async {
                          //                                     debugPrint("Delete song from queue");
                          //                                     await dc.removeFromQueue(SettingsController.queue[index]);
                          //                                     setState(() {});
                          //                                   },
                          //                                   icon: Icon(
                          //                                     FluentIcons.trash,
                          //                                     color: Colors.white,
                          //                                     size: width * 0.0125,
                          //                                   ),
                          //                                 ),
                          //                               ),
                          //                             ),
                          //                             SizedBox(
                          //                               width: width * 0.01,
                          //                             ),
                          //                             Column(
                          //                                 mainAxisAlignment: MainAxisAlignment.center,
                          //                                 crossAxisAlignment: CrossAxisAlignment.start,
                          //                                 children: [
                          //                                   SizedBox(
                          //                                     width: width * 0.15,
                          //                                     child: TextScroll(
                          //                                       song.title,
                          //                                       mode: TextScrollMode.bouncing,
                          //                                       velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
                          //                                       style: TextStyle(
                          //                                         color: SettingsController.currentSongPath != song.path ? Colors.white : Colors.blue,
                          //                                         fontSize: normalSize,
                          //                                         fontWeight: FontWeight.normal,
                          //                                       ),
                          //                                       pauseOnBounce: const Duration(seconds: 2),
                          //                                       delayBefore: const Duration(seconds: 2),
                          //                                       pauseBetween: const Duration(seconds: 2),
                          //                                     ),
                          //                                   ),
                          //                                   SizedBox(
                          //                                     height: height * 0.005,
                          //                                   ),
                          //                                   Text(song.artists.toString().length > 60 ? "${song.artists.toString().substring(0, 60)}..." : song.artists.toString(),
                          //                                       style: TextStyle(
                          //                                         color: SettingsController.currentSongPath != song.path ? Colors.white : Colors.blue,
                          //                                         fontSize: smallSize,
                          //                                       )
                          //                                   ),
                          //                                 ]
                          //                             ),
                          //                             const Spacer(),
                          //                             Text(
                          //                                 "${song.duration ~/ 60}:${(song.duration % 60).toString().padLeft(2, '0')}",
                          //                                 style: TextStyle(
                          //                                   color: SettingsController.currentSongPath != song.path ? Colors.white : Colors.blue,
                          //                                   fontSize: normalSize,
                          //                                 )
                          //                             ),
                          //                           ],
                          //                         ),
                          //                       ),
                          //                     )
                          //                 ),
                          //               ),
                          //             );
                          //           }
                          //           return null;
                          //         },
                          //       );
                          //     }
                          //     else if(snapshot.hasError){
                          //       return _errorWidget(snapshot.error.toString());
                          //     }
                          //     else{
                          //       return const CircularProgressIndicator(
                          //         valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          //       );
                          //     }
                          //   },
                          // ),
                        ),

                      // Album Art
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                        alignment: Alignment.center,
                        height: values[0]? height * 0.15 : width * 0.275,
                        width: values[0] ? height * 0.15 : width * 0.275,
                        child: AspectRatio(
                          aspectRatio: 1.0,
                          child: Container(
                            decoration: BoxDecoration(
                                shape: values[0] ? BoxShape.circle : BoxShape.rectangle,
                                color: Colors.black.withOpacity(values[1] ? 0.3 : 1),
                                borderRadius: values[0] ? null : BorderRadius.circular(width * 0.025),
                                image: DecorationImage(
                                  opacity: values[1] ? 0.5 : 1,
                                  fit: BoxFit.cover,
                                  image: Image.memory(AudioPlayerController.image).image,
                                )
                            ),
                            child: Container(
                                alignment: Alignment.bottomCenter,
                                padding: EdgeInsets.only(
                                  bottom: height * 0.01,
                                ),
                                decoration: BoxDecoration(
                                    shape: values[0] ? BoxShape.circle : BoxShape.rectangle,
                                    color: Colors.black.withOpacity(values[1] ? 0.3 : 1),
                                    borderRadius: values[0] ? null : BorderRadius.circular(width * 0.025),
                                    gradient: LinearGradient(
                                        begin: FractionalOffset.center,
                                        end: FractionalOffset.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.0),
                                          Colors.black.withOpacity(0.75),
                                          Colors.black,
                                        ],
                                        stops: const [0.0, 0.5, 1.0]
                                    )
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    TextScroll(
                                      AudioPlayerController.song.title,
                                      mode: TextScrollMode.bouncing,
                                      velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: values[0] ? normalSize: boldSize,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      pauseOnBounce: const Duration(seconds: 2),
                                      delayBefore: const Duration(seconds: 2),
                                      pauseBetween: const Duration(seconds: 2),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        if (!values[0])
                                          SizedBox(
                                            width: width * 0.01,
                                          ),
                                        if (!values[0])
                                          Expanded(
                                            // width: width * 0.13,
                                            // alignment: Alignment.centerRight,
                                            child: TextButton.icon(
                                              onPressed:AudioPlayerController.song.albumArtist != "Unknown album artist" ? () {
                                                am.minimizedNotifier.value = true;
                                                am.navigatorKey.currentState!.pushNamed('/artist', arguments: DataController.artistBox.query(ArtistType_.name.equals(AudioPlayerController.song.albumArtist)).build().findFirst());
                                              } : null,
                                              icon: Icon(
                                                FluentIcons.open,
                                                color: Colors.white,
                                                size: smallSize,
                                              ),
                                              iconAlignment: IconAlignment.end,
                                              label: TextScroll(
                                                AudioPlayerController.song.artists,
                                                mode: TextScrollMode.bouncing,
                                                velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: values[0] ? smallSize: normalSize,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                                pauseOnBounce: const Duration(seconds: 2),
                                                delayBefore: const Duration(seconds: 2),
                                                pauseBetween: const Duration(seconds: 2),
                                              ),
                                            ),
                                          )
                                        else
                                          TextScroll(
                                            AudioPlayerController.song.artists,
                                            mode: TextScrollMode.bouncing,
                                            velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: values[0] ? smallSize: normalSize,
                                              fontWeight: FontWeight.normal,
                                            ),
                                            pauseOnBounce: const Duration(seconds: 2),
                                            delayBefore: const Duration(seconds: 2),
                                            pauseBetween: const Duration(seconds: 2),
                                          ),
                                        if (!values[0])
                                        Icon(
                                          FluentIcons.divider,
                                          color: Colors.white,
                                          size: normalSize,
                                        ),
                                        if (!values[0])
                                        Expanded(
                                          // width: width * 0.13,
                                          child: TextButton.icon(
                                            onPressed: () async {
                                              am.minimizedNotifier.value = true;
                                              am.navigatorKey.currentState!.pushNamed('/album', arguments:  DataController.albumBox.query(AlbumType_.name.equals(AudioPlayerController.song.album)).build().findFirst());
                                            },
                                            icon: Icon(
                                              FluentIcons.open,
                                              color: Colors.white,
                                              size: smallSize,
                                            ),
                                            label: TextScroll(
                                              AudioPlayerController.song.album,
                                              mode: TextScrollMode.bouncing,
                                              velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: values[0] ? smallSize: normalSize,
                                                fontWeight: FontWeight.normal,
                                              ),
                                              pauseOnBounce: const Duration(seconds: 2),
                                              delayBefore: const Duration(seconds: 2),
                                              pauseBetween: const Duration(seconds: 2),
                                            ),
                                          ),
                                        ),
                                        if (!values[0])
                                          SizedBox(
                                            width: width * 0.01,
                                          ),

                                      ],
                                    )
                                  ],
                                )
                            ),
                          ),
                        ),
                      ),

                      // Lyrics
                      if(!values[0])
                        FutureBuilder(
                            future: Future(() async {
                              try {
                                List<String> lyrics = await DataController.getLyrics(SettingsController.currentSongPath);
                                return lyrics;
                              } catch (e) {
                                debugPrint(e.toString());
                                return ["No lyrics found", "No lyrics found"];
                              }
                            }),
                            builder: (context, snapshot){
                              if(snapshot.hasData){
                                String plainLyric = snapshot.data![0];
                                var lyricModel = LyricsModelBuilder.create().bindLyricToMain(snapshot.data![1]).getModel();
                                return MultiValueListenableBuilder(
                                    valueListenables: [SettingsController.sliderNotifier, SettingsController.playingNotifier],
                                    builder: (context, value, child){
                                      return AnimatedContainer(
                                        duration: const Duration(milliseconds: 500),
                                        height: width * 0.275,
                                        width: width * 0.275,
                                        padding: EdgeInsets.symmetric(
                                          horizontal: width * 0.01,
                                          vertical: height * 0.01,
                                        ),
                                        child: LyricsReader(
                                          model: lyricModel,
                                          position: value[0],
                                          lyricUi: lyricUI,
                                          playing: SettingsController.playing,
                                          size: Size.infinite,
                                          padding: EdgeInsets.only(
                                            right: width * 0.02,
                                            left: width * 0.02,
                                          ),
                                          selectLineBuilder: (progress, confirm) {
                                            return Row(
                                              children: [
                                                Icon(FluentIcons.play, color: SettingsController.lightColorNotifier.value),
                                                Expanded(
                                                  child: MouseRegion(
                                                    cursor: SystemMouseCursors.click,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        confirm.call();
                                                        setState(() {
                                                          AudioPlayerController.audioPlayer.seek(Duration(milliseconds: progress));
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                ),
                                                Text(
                                                  //progress.toString(),
                                                  "${progress ~/ 1000 ~/ 60}:${(progress ~/ 1000 % 60).toString().padLeft(2, '0')}",
                                                  style: TextStyle(color: SettingsController.lightColorNotifier.value),
                                                )
                                              ],
                                            );
                                          },
                                          emptyBuilder: () => plainLyric.contains("No lyrics") || plainLyric.contains("Searching")?
                                          Center(
                                              child: Text(
                                                plainLyric,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: normalSize,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              )
                                          ):
                                          ScrollConfiguration(
                                            behavior: ScrollConfiguration.of(context).copyWith(
                                              dragDevices: {
                                                PointerDeviceKind.touch,
                                                PointerDeviceKind.mouse,
                                              },
                                            ),
                                            child: SingleChildScrollView(
                                              scrollDirection: Axis.vertical,
                                              physics: const BouncingScrollPhysics(),
                                              child: SingleChildScrollView(
                                                  scrollDirection: Axis.horizontal,
                                                  child: Text(
                                                    plainLyric,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: normalSize,
                                                      fontWeight: FontWeight.normal,
                                                    ),
                                                  )
                                              ),
                                            ),
                                          ),

                                        ),
                                      );
                                    }
                                );
                              }
                              else {
                                return Center(
                                    child: Text(
                                      "Searching for lyrics...",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: normalSize,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    )
                                );
                              }
                            }
                        ),

                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if(values[0])
                            IgnorePointer(
                              ignoring: true,
                              child: AnimatedOpacity(
                                opacity: hiddenNotifier.value ? 0.0 : 1.0,
                                duration: const Duration(milliseconds: 500),
                                child: Container(
                                  width: width * 0.635,
                                  margin: EdgeInsets.only(
                                    top: height * 0.01,
                                    bottom: height * 0.01,
                                  ),
                                  alignment: Alignment.center,
                                  child: FutureBuilder(
                                      future: Future(() async {
                                        try {
                                          List<String> lyrics = await DataController.getLyrics(SettingsController.currentSongPath);
                                          return lyrics;
                                        } catch (e) {
                                          debugPrint(e.toString());
                                          return ["No lyrics found", "No lyrics found"];
                                        }
                                      }),
                                      builder: (context, snapshot){
                                        if(snapshot.hasData){
                                          var lyricModel = LyricsModelBuilder.create().bindLyricToMain(snapshot.data![1]).getModel();
                                          if (lyricModel.lyrics.isNotEmpty) {
                                            return MultiValueListenableBuilder(
                                                valueListenables: [SettingsController.sliderNotifier, SettingsController.playingNotifier],
                                                builder: (context, value, child){
                                                  return LyricsReader(
                                                    model: lyricModel,
                                                    position: value[0],
                                                    lyricUi: lyricUI,
                                                    playing: SettingsController.playing,
                                                    size: Size(width * 0.6, height * 0.021),
                                                  );
                                                }
                                            );
                                          }
                                          else {
                                            return Text(
                                              "No lyrics found",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: normalSize,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            );
                                          }
                                        }
                                        else {
                                          return const SizedBox();
                                        }
                                      }
                                  ),
                                ),
                              ),
                            ),

                          if (!values[0])
                            SizedBox(
                              height: height * 0.01,
                              width: width,
                            ),

                          // ProgressBar
                          MultiValueListenableBuilder(
                              valueListenables: [SettingsController.sliderNotifier, SettingsController.lightColorNotifier],
                              builder: (context, values, child){
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOut,
                                  width:  am.minimizedNotifier.value ? width * 0.635 : width * 0.8,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: width * 0.02,
                                    vertical:  am.minimizedNotifier.value ? 0 : height * 0.05,
                                  ),
                                  alignment: Alignment.center,
                                  child: FutureBuilder(
                                    future: DataController.getDuration(AudioPlayerController.song),
                                    builder: (context, snapshot){
                                      return ProgressBar(
                                        progress: Duration(milliseconds: values[0]),
                                        total: snapshot.hasData ? snapshot.data as Duration : Duration.zero,
                                        progressBarColor: values[1].withOpacity(hiddenNotifier.value ? 0.0 : 1.0),
                                        baseBarColor: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 0.24),
                                        bufferedBarColor: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 0.24),
                                        thumbColor: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1.0),
                                        barHeight: 4.0,
                                        thumbRadius: 7.0,
                                        timeLabelLocation:  TimeLabelLocation.sides,
                                        timeLabelTextStyle: TextStyle(
                                          color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1.0),
                                          fontSize: height * 0.02,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        onSeek: (duration) {
                                          AudioPlayerController.audioPlayer.seek(duration);
                                        },
                                      );
                                    },
                                  ),
                                );
                              }
                          ),

                          if (!values[0])
                            SizedBox(
                              height: height * 0.01,
                              width: width,
                            ),

                          // Player Controls - Previous, Play/Pause, Next
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 500),
                            width:  am.minimizedNotifier.value ? width * 0.635 : width * 0.8,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                if (!values[0])
                                  ValueListenableBuilder(
                                      valueListenable: likedNotifier,
                                      builder: (context, likedVal, child) {
                                        return IconButton(
                                            padding: const EdgeInsets.all(0),
                                            onPressed: () async {
                                              debugPrint("Liked");
                                              var currentSong = AudioPlayerController.song;
                                              await dc.updateLiked(currentSong);
                                              likedNotifier.value = !likedNotifier.value;
                                              if (currentSong.liked) {
                                                am.showNotification("Added ${currentSong.title} to Favorites", 3000);
                                              }
                                              else {
                                                am.showNotification("Removed ${currentSong.title} from Favorites", 3000);
                                              }

                                            },
                                            icon: Icon(
                                                AudioPlayerController.song.liked ? FluentIcons.liked : FluentIcons.unliked,
                                                size: height * 0.025,
                                                color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1)
                                            )
                                        );
                                      }
                                  ),
                                ValueListenableBuilder(
                                    valueListenable: SettingsController.shuffleNotifier,
                                    builder: (context, value, child){
                                      return IconButton(
                                        onPressed: () {
                                          SettingsController.shuffle = !SettingsController.shuffle;
                                        },
                                        icon:
                                        Icon(
                                            value == false ? FluentIcons.shuffleOff : FluentIcons.shuffleOn,
                                            size: height * 0.025,
                                            color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1)
                                        ),
                                      );
                                    }
                                ),
                                IconButton(
                                  onPressed: () async {
                                    await AppAudioHandler.skipToPrevious();
                                  },
                                  icon: Icon(
                                    FluentIcons.previous,
                                    color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1.0),
                                    size: height * 0.025,
                                  ),
                                ),
                                MultiValueListenableBuilder(
                                    valueListenables: [SettingsController.playingNotifier],
                                    builder: (context, value, child){
                                      return IconButton(
                                        onPressed: () async {
                                          //debugPrint("pressed pause play");
                                          if (SettingsController.playing) {
                                            await AppAudioHandler.pause();
                                          } else {
                                            await AppAudioHandler.play();
                                          }
                                        },
                                        icon: Icon(
                                          SettingsController.playing ?
                                          FluentIcons.pause :
                                          FluentIcons.play,
                                          color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1.0),
                                          size: height * 0.025,
                                        ),
                                      );
                                    }
                                ),
                                IconButton(
                                  onPressed: () async {
                                    debugPrint("next");
                                    return await AppAudioHandler.skipToNext();
                                  },
                                  icon: Icon(
                                    FluentIcons.next,
                                    color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1.0),
                                    size: height * 0.025,
                                  ),
                                ),
                                ValueListenableBuilder(
                                    valueListenable: SettingsController.repeatNotifier,
                                    builder: (context, value, child){
                                      return IconButton(
                                        onPressed: () {
                                          SettingsController.repeat = !SettingsController.repeat;
                                        },
                                        icon:
                                        Icon(
                                            value == false ? FluentIcons.repeatOff: FluentIcons.repeatOn,
                                            size: height * 0.025,
                                            color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1.0)),
                                      );
                                    }
                                ),
                                if (!values[0])
                                  IconButton(
                                      padding: const EdgeInsets.all(0),
                                      onPressed: (){
                                        am.minimizedNotifier.value = !am.minimizedNotifier.value;
                                        hiddenNotifier.value = false;
                                      }, icon: Icon(
                                    am.minimizedNotifier.value ? FluentIcons.maximize : FluentIcons.minimize,
                                    color: Colors.white,
                                    size: width * 0.01,
                                  )
                                  ),
                              ],
                            ),
                          ),

                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (values[0])
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  height: height * 0.15,
                  width: width,
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(
                    left: width * 0.01,
                    right: width * 0.01,
                  ),
                  margin: EdgeInsets.only(
                    bottom: height * 0.025,
                    left: width * 0.125,
                    right: width * 0.125,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Minimize/Maximize button
                      IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: () async {
                            am.minimizedNotifier.value = ! am.minimizedNotifier.value;
                            hiddenNotifier.value = false;
                            Future.delayed(const Duration(milliseconds: 250), (){
                              itemScrollController.jumpTo(
                                height * 0.11 * SettingsController.queue.indexOf(SettingsController.currentSongPath),
                              );
                            });
                          },
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(Colors.black.withOpacity(hiddenNotifier.value ? 0.5 : 0.0)),
                          ),
                          icon: Icon(
                            am.minimizedNotifier.value ?
                            FluentIcons.maximize :
                            FluentIcons.minimize, color: Colors.white,
                            size: width * 0.01,
                          )
                      ),
                      // Visibility Toggle
                      IconButton(
                        onPressed: (){
                          // debugPrint("pressed hiddenNotifier.value");
                          hiddenNotifier.value = !hiddenNotifier.value;
                        },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(Colors.black.withOpacity(hiddenNotifier.value ? 0.5 : 0.0)),
                        ),
                        icon: Icon(
                          hiddenNotifier.value ?
                          FluentIcons.show :
                          FluentIcons.hide,
                          color: Colors.white,
                          size: width * 0.01,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        }
    );
  }
}
