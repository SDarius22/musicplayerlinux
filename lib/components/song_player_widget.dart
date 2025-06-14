import 'dart:typed_data';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/components/animated_background.dart';
import 'package:musicplayer/components/player_tabs/details_tab.dart';
import 'package:musicplayer/components/player_tabs/lyrics_tab.dart';
import 'package:musicplayer/components/player_tabs/queue_tab.dart';
import 'package:musicplayer/providers/app_state_provider.dart';
import 'package:musicplayer/providers/audio_provider.dart';
import 'package:musicplayer/providers/slider_provider.dart';
import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class SongPlayerWidget extends StatefulWidget{
  const SongPlayerWidget({super.key});

  @override
  State<SongPlayerWidget> createState() => _SongPlayerWidgetState();
}


class _SongPlayerWidgetState extends State<SongPlayerWidget> with TickerProviderStateMixin {
  late AppStateProvider appStateProvider;

  ValueNotifier<bool> likedNotifier = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
    return Consumer<AudioProvider>(
      builder: (_, audioProvider, __) {
        if (audioProvider.queue.isEmpty) {
          debugPrint("Queue is empty, not showing player");
          return const SizedBox.shrink();
        }
        if (appStateProvider.itemScrollController.hasClients) {
          debugPrint("ItemScrollController has clients, animating to current index, index: ${audioProvider.currentIndex}");
          Future.delayed(const Duration(milliseconds: 250), () {
            appStateProvider.itemScrollController.jumpTo(height * 0.1 * audioProvider.previousIndex);
            appStateProvider.itemScrollController.animateTo(height * 0.1 * audioProvider.currentIndex, duration: const Duration(milliseconds: 250), curve: Curves.easeInOut);
          });
        }
        return SlidingUpPanel(
          minHeight: height * 0.1,
          maxHeight: height - appWindow.titleBarHeight,
          controller: appStateProvider.panelController,
          collapsed: _buildMinimizedPlayer(width, height, audioProvider),
          panel: _buildMaximizedPlayer(width, height, audioProvider),
          onPanelOpened: () {
            if (appStateProvider.itemScrollController.hasClients) {
              appStateProvider.itemScrollController.jumpTo(height * 0.1 * audioProvider.currentIndex);
            }
          },
        );
      },
    );


    // return MultiValueListenableBuilder(
    //     valueListenables: [am.minimizedNotifier, hiddenNotifier, AudioPlayerController.imageNotifier, SettingsController.lightColorNotifier],
    //     builder: (context, values, child){
    //       return Stack(
    //         alignment: Alignment.center,
    //         children: [
    //           IgnorePointer(
    //             ignoring: values[1],
    //             child: AnimatedContainer(
    //               duration: const Duration(milliseconds: 500),
    //               curve: Curves.linear,
    //               height: values[0] ? height * 0.15 : (MediaQuery.of(context).size.height - appWindow.titleBarHeight),
    //               width: width,
    //               alignment: values[0] ? Alignment.centerLeft : Alignment.center,
    //               padding: EdgeInsets.only(
    //                 top: values[0] ? 0 : height * 0.02,
    //                 bottom: values[0] ? 0 : height * 0.02,
    //                 left: values[0] ? width * 0.001 : width * 0.01,
    //                 right: values[0] ? width * 0.001 : width * 0.01,
    //               ),
    //               margin: values[0] ? EdgeInsets.only(
    //                 bottom: height * 0.025,
    //                 left: width * 0.125,
    //                 right: width * 0.125,
    //               ) : null,
    //               decoration: BoxDecoration(
    //                 color: values[0] ? SettingsController.darkColorNotifier.value.withOpacity(values[1] ? 0.0 : 1) : const Color(0xFF0E0E0E),
    //                 borderRadius: values[0] ? BorderRadius.circular(width * 0.2) : BorderRadius.circular(0),
    //               ),
    //               child: Wrap(
    //                 alignment: WrapAlignment.center,
    //                 crossAxisAlignment: values[0] ? WrapCrossAlignment.center : WrapCrossAlignment.start,
    //                 children: [
    //                   // Queue
    //                   if (!values[0])
    //                     AnimatedContainer(
    //                       duration: const Duration(milliseconds: 500),
    //                       curve: Curves.easeInOut,
    //                       height: width * 0.3,
    //                       width: width * 0.3,
    //                       color: Colors.transparent,
    //                       child: ListView.builder(
    //                         controller: itemScrollController,
    //                         itemCount: SettingsController.queue.length,
    //                         padding: EdgeInsets.only(
    //                             right: width * 0.01
    //                         ),
    //                         prototypeItem: ListTile(
    //                           dense: true,
    //                           visualDensity: const VisualDensity(vertical: 4),
    //                           contentPadding: EdgeInsets.symmetric(
    //                             horizontal: width * 0.005,
    //                             vertical: height * 0.01,
    //                           ),
    //                           leading: ClipRRect(
    //                             borderRadius: BorderRadius.circular(width * 0.005),
    //                             child: ImageWidget(
    //                               path: "",
    //                               heroTag: "prototype",
    //                               hoveredChild: IconButton(
    //                                 onPressed: () async {
    //                                 },
    //                                 icon: Icon(
    //                                   FluentIcons.trash,
    //                                   color: Colors.white,
    //                                   size: width * 0.0125,
    //                                 ),
    //                               ),
    //                             ),
    //                           ),
    //                           title: TextScroll(
    //                             "Loading...",
    //                             mode: TextScrollMode.bouncing,
    //                             velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
    //                             style: TextStyle(
    //                               color: Colors.white,
    //                               fontSize: normalSize,
    //                               fontWeight: FontWeight.bold,
    //                             ),
    //                             pauseOnBounce: const Duration(seconds: 2),
    //                             delayBefore: const Duration(seconds: 2),
    //                             pauseBetween: const Duration(seconds: 2),
    //                           ),
    //                           subtitle: TextScroll(
    //                             "Loading...",
    //                             mode: TextScrollMode.bouncing,
    //                             velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
    //                             style: TextStyle(
    //                               color: Colors.white,
    //                               fontSize: normalSize,
    //                               fontWeight: FontWeight.normal,
    //                             ),
    //                             pauseOnBounce: const Duration(seconds: 2),
    //                             delayBefore: const Duration(seconds: 2),
    //                             pauseBetween: const Duration(seconds: 2),
    //                           ),
    //                           trailing: Text(
    //                             "??:??",
    //                             style: TextStyle(
    //                               color: Colors.white,
    //                               fontSize: normalSize,
    //                             ),
    //                           ),
    //                         ),
    //                         itemBuilder: (context, int index) {
    //                           return Material(
    //                             type: MaterialType.transparency,
    //                             child: FutureBuilder(
    //                               future: Future.delayed(const Duration(milliseconds: 500), () async {
    //                                 return await DataController.getSong(SettingsController.queue[index]);
    //                               }),
    //                               builder: (context, snapshot){
    //                                 if (snapshot.hasData) {
    //                                   var song = snapshot.data ?? Song();
    //                                   return ListTile(
    //                                     dense: true,
    //                                     visualDensity: const VisualDensity(vertical: VisualDensity.maximumDensity),
    //                                     contentPadding: EdgeInsets.symmetric(
    //                                       horizontal: width * 0.005,
    //                                       vertical: height * 0.0125,
    //                                     ),
    //                                     onTap: () async {
    //                                       //debugPrint(SettingsController.playingSongsUnShuffled[index].title);
    //                                       //widget.controller.audioPlayer.stop();
    //                                       // DataController.indexChange(SettingsController.queue[index]);
    //                                       SettingsController.index = SettingsController.currentQueue.indexOf(SettingsController.queue[index]);
    //                                       await AppAudioHandler.play();
    //                                     },
    //                                     leading: ClipRRect(
    //                                       borderRadius: BorderRadius.circular(width * 0.005),
    //                                       child: ImageWidget(
    //                                         path: SettingsController.queue[index],
    //                                         heroTag: "${SettingsController.queue[index]} $index",
    //                                         hoveredChild: IconButton(
    //                                           onPressed: () async {
    //                                             debugPrint("Delete song from queue");
    //                                             await dc.removeFromQueue(SettingsController.queue[index]);
    //                                             setState(() {});
    //                                           },
    //                                           icon: Icon(
    //                                             FluentIcons.trash,
    //                                             color: Colors.white,
    //                                             size: width * 0.0125,
    //                                           ),
    //                                         ),
    //                                       ),
    //                                     ),
    //                                     title: TextScroll(
    //                                       song.title,
    //                                       mode: TextScrollMode.bouncing,
    //                                       velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
    //                                       style: TextStyle(
    //                                         color: SettingsController.currentSongPath != song.path ? Colors.white : Colors.blue,
    //                                         fontSize: normalSize,
    //                                         fontWeight: FontWeight.bold,
    //                                       ),
    //                                       pauseOnBounce: const Duration(seconds: 2),
    //                                       delayBefore: const Duration(seconds: 2),
    //                                       pauseBetween: const Duration(seconds: 2),
    //                                     ),
    //                                     subtitle: TextScroll(
    //                                       song.trackArtist,
    //                                       mode: TextScrollMode.bouncing,
    //                                       velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
    //                                       style: TextStyle(
    //                                         color: SettingsController.currentSongPath != song.path ? Colors.white : Colors.blue,
    //                                         fontSize: smallSize,
    //                                         fontWeight: FontWeight.normal,
    //                                       ),
    //                                       pauseOnBounce: const Duration(seconds: 2),
    //                                       delayBefore: const Duration(seconds: 2),
    //                                       pauseBetween: const Duration(seconds: 2),
    //                                     ),
    //                                     trailing: Text(
    //                                       "${song.duration ~/ 60}:${(song.duration % 60).toString().padLeft(2, '0')}",
    //                                       style: TextStyle(
    //                                         color: SettingsController.currentSongPath != song.path ? Colors.white : Colors.blue,
    //                                         fontSize: normalSize,
    //                                       ),
    //                                     ),
    //
    //
    //                                   );
    //                                 }
    //                                 else {
    //                                   return ListTile(
    //                                     dense: true,
    //                                     visualDensity: const VisualDensity(vertical: 4),
    //                                     contentPadding: EdgeInsets.symmetric(
    //                                       horizontal: width * 0.005,
    //                                       vertical: height * 0.01,
    //                                     ),
    //                                     onTap: () async {
    //                                       //debugPrint(SettingsController.playingSongsUnShuffled[index].title);
    //                                       //widget.controller.audioPlayer.stop();
    //                                       // DataController.indexChange(SettingsController.queue[index]);
    //                                       SettingsController.index = SettingsController.currentQueue.indexOf(SettingsController.queue[index]);
    //                                       await AppAudioHandler.play();
    //                                     },
    //                                     leading: ClipRRect(
    //                                       borderRadius: BorderRadius.circular(width * 0.005),
    //                                       child: ImageWidget(
    //                                         path: "",
    //                                         heroTag: "null $index",
    //                                         hoveredChild: IconButton(
    //                                           onPressed: () async {
    //                                             debugPrint("Delete song from queue");
    //                                             await dc.removeFromQueue(SettingsController.queue[index]);
    //                                             setState(() {});
    //                                           },
    //                                           icon: Icon(
    //                                             FluentIcons.trash,
    //                                             color: Colors.white,
    //                                             size: width * 0.0125,
    //                                           ),
    //                                         ),
    //                                       ),
    //                                     ),
    //                                     title: TextScroll(
    //                                       "Loading...",
    //                                       mode: TextScrollMode.bouncing,
    //                                       velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
    //                                       style: TextStyle(
    //                                         color: Colors.white,
    //                                         fontSize: normalSize,
    //                                         fontWeight: FontWeight.normal,
    //                                       ),
    //                                       pauseOnBounce: const Duration(seconds: 2),
    //                                       delayBefore: const Duration(seconds: 2),
    //                                       pauseBetween: const Duration(seconds: 2),
    //                                     ),
    //
    //
    //                                   );
    //                                 }
    //                               },
    //                             ),
    //                           );
    //                         },
    //                       ),
    //                     ),
    //
    //                   // Album Art
    //                   AnimatedContainer(
    //                     duration: const Duration(milliseconds: 500),
    //                     curve: Curves.easeInOut,
    //                     alignment: Alignment.center,
    //                     height: values[0]? height * 0.15 : width * 0.3,
    //                     width: values[0] ? height * 0.15 : width * 0.3,
    //                     child: AspectRatio(
    //                       aspectRatio: 1.0,
    //                       child: Container(
    //                         decoration: BoxDecoration(
    //                             shape: values[0] ? BoxShape.circle : BoxShape.rectangle,
    //                             color: Colors.black.withOpacity(values[1] ? 0.3 : 1),
    //                             borderRadius: values[0] ? null : BorderRadius.circular(width * 0.025),
    //                             image: DecorationImage(
    //                               opacity: values[1] ? 0.5 : 1,
    //                               fit: BoxFit.cover,
    //                               image: Image.memory(AudioPlayerController.image).image,
    //                             )
    //                         ),
    //                         child: Container(
    //                             alignment: Alignment.bottomCenter,
    //                             padding: EdgeInsets.only(
    //                               bottom: height * 0.01,
    //                             ),
    //                             decoration: BoxDecoration(
    //                                 shape: values[0] ? BoxShape.circle : BoxShape.rectangle,
    //                                 color: Colors.black.withOpacity(values[1] ? 0.3 : 1),
    //                                 borderRadius: values[0] ? null : BorderRadius.circular(width * 0.025),
    //                                 gradient: LinearGradient(
    //                                     begin: FractionalOffset.center,
    //                                     end: FractionalOffset.bottomCenter,
    //                                     colors: [
    //                                       Colors.black.withOpacity(0.0),
    //                                       Colors.black.withOpacity(0.75),
    //                                       Colors.black,
    //                                     ],
    //                                     stops: const [0.0, 0.5, 1.0]
    //                                 )
    //                             ),
    //                             child: Column(
    //                               mainAxisAlignment: MainAxisAlignment.end,
    //                               crossAxisAlignment: CrossAxisAlignment.center,
    //                               children: [
    //                                 TextScroll(
    //                                   audioProvider.currentSong.title,
    //                                   mode: TextScrollMode.bouncing,
    //                                   velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
    //                                   style: TextStyle(
    //                                     color: Colors.white,
    //                                     fontSize: values[0] ? normalSize: boldSize,
    //                                     fontWeight: FontWeight.bold,
    //                                   ),
    //                                   pauseOnBounce: const Duration(seconds: 2),
    //                                   delayBefore: const Duration(seconds: 2),
    //                                   pauseBetween: const Duration(seconds: 2),
    //                                 ),
    //                                 Row(
    //                                   mainAxisAlignment: MainAxisAlignment.center,
    //                                   children: [
    //                                     if (!values[0])
    //                                       SizedBox(
    //                                         width: width * 0.01,
    //                                       ),
    //                                     if (!values[0])
    //                                       Expanded(
    //                                         // width: width * 0.13,
    //                                         // alignment: Alignment.centerRight,
    //                                         child: TextButton.icon(
    //                                           onPressed:audioProvider.currentSong.albumArtist != "Unknown album artist" ? () {
    //                                             am.minimizedNotifier.value = true;
    //                                             am.navigatorKey.currentState!.pushNamed('/artist', arguments: DataController.artistBox.query(Artist_.name.equals(audioProvider.currentSong.albumArtist)).build().findFirst());
    //                                           } : null,
    //                                           icon: Icon(
    //                                             FluentIcons.open,
    //                                             color: Colors.white,
    //                                             size: smallSize,
    //                                           ),
    //                                           iconAlignment: IconAlignment.end,
    //                                           label: TextScroll(
    //                                             audioProvider.currentSong.trackArtist,
    //                                             mode: TextScrollMode.bouncing,
    //                                             velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
    //                                             style: TextStyle(
    //                                               color: Colors.white,
    //                                               fontSize: values[0] ? smallSize: normalSize,
    //                                               fontWeight: FontWeight.normal,
    //                                             ),
    //                                             pauseOnBounce: const Duration(seconds: 2),
    //                                             delayBefore: const Duration(seconds: 2),
    //                                             pauseBetween: const Duration(seconds: 2),
    //                                           ),
    //                                         ),
    //                                       )
    //                                     else
    //                                       TextScroll(
    //                                         audioProvider.currentSong.trackArtist,
    //                                         mode: TextScrollMode.bouncing,
    //                                         velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
    //                                         style: TextStyle(
    //                                           color: Colors.white,
    //                                           fontSize: values[0] ? smallSize: normalSize,
    //                                           fontWeight: FontWeight.normal,
    //                                         ),
    //                                         pauseOnBounce: const Duration(seconds: 2),
    //                                         delayBefore: const Duration(seconds: 2),
    //                                         pauseBetween: const Duration(seconds: 2),
    //                                       ),
    //                                     if (!values[0])
    //                                     Icon(
    //                                       FluentIcons.divider,
    //                                       color: Colors.white,
    //                                       size: normalSize,
    //                                     ),
    //                                     if (!values[0])
    //                                     Expanded(
    //                                       // width: width * 0.13,
    //                                       child: TextButton.icon(
    //                                         onPressed: () async {
    //                                           am.minimizedNotifier.value = true;
    //                                           am.navigatorKey.currentState!.pushNamed('/album', arguments:  DataController.albumBox.query(Album_.name.equals(audioProvider.currentSong.album)).build().findFirst());
    //                                         },
    //                                         icon: Icon(
    //                                           FluentIcons.open,
    //                                           color: Colors.white,
    //                                           size: smallSize,
    //                                         ),
    //                                         label: TextScroll(
    //                                           audioProvider.currentSong.album,
    //                                           mode: TextScrollMode.bouncing,
    //                                           velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
    //                                           style: TextStyle(
    //                                             color: Colors.white,
    //                                             fontSize: values[0] ? smallSize: normalSize,
    //                                             fontWeight: FontWeight.normal,
    //                                           ),
    //                                           pauseOnBounce: const Duration(seconds: 2),
    //                                           delayBefore: const Duration(seconds: 2),
    //                                           pauseBetween: const Duration(seconds: 2),
    //                                         ),
    //                                       ),
    //                                     ),
    //                                     if (!values[0])
    //                                       SizedBox(
    //                                         width: width * 0.01,
    //                                       ),
    //
    //                                   ],
    //                                 )
    //                               ],
    //                             )
    //                         ),
    //                       ),
    //                     ),
    //                   ),
    //
    //                   // Lyrics
    //                   if(!values[0])
    //                     FutureBuilder(
    //                       future: Future(() async {
    //                         try {
    //                           List<String> lyrics = await DataController.getLyrics(SettingsController.currentSongPath);
    //                           return lyrics;
    //                         } catch (e) {
    //                           debugPrint(e.toString());
    //                           return ["No lyrics found", "No lyrics found"];
    //                         }
    //                       }),
    //                       builder: (context, snapshot){
    //                         if(snapshot.hasData){
    //                           String plainLyric = snapshot.data![0];
    //                           var lyricModel = LyricsModelBuilder.create().bindLyricToMain(snapshot.data![1]).getModel();
    //                           return MultiValueListenableBuilder(
    //                               valueListenables: [SettingsController.sliderNotifier, SettingsController.playingNotifier],
    //                               builder: (context, value, child){
    //                                 return AnimatedContainer(
    //                                   duration: const Duration(milliseconds: 500),
    //                                   height: width * 0.3,
    //                                   width: width * 0.3,
    //                                   padding: EdgeInsets.symmetric(
    //                                     vertical: height * 0.01,
    //                                   ),
    //                                   child: LyricsReader(
    //                                     model: lyricModel,
    //                                     position: value[0],
    //                                     lyricUi: lyricUI,
    //                                     playing: SettingsController.playing,
    //                                     size: Size.infinite,
    //                                     padding: EdgeInsets.only(
    //                                       right: width * 0.01,
    //                                       left: width * 0.01,
    //                                     ),
    //                                     selectLineBuilder: (progress, confirm) {
    //                                       return Row(
    //                                         children: [
    //                                           Icon(FluentIcons.play, color: SettingsController.lightColorNotifier.value),
    //                                           Expanded(
    //                                             child: MouseRegion(
    //                                               cursor: SystemMouseCursors.click,
    //                                               child: GestureDetector(
    //                                                 onTap: () {
    //                                                   confirm.call();
    //                                                   setState(() {
    //                                                     AudioPlayerController.audioPlayer.seek(Duration(milliseconds: progress));
    //                                                   });
    //                                                 },
    //                                               ),
    //                                             ),
    //                                           ),
    //                                           Text(
    //                                             //progress.toString(),
    //                                             "${progress ~/ 1000 ~/ 60}:${(progress ~/ 1000 % 60).toString().padLeft(2, '0')}",
    //                                             style: TextStyle(color: SettingsController.lightColorNotifier.value),
    //                                           )
    //                                         ],
    //                                       );
    //                                     },
    //                                     emptyBuilder: () => plainLyric.contains("No lyrics") || plainLyric.contains("Searching")?
    //                                     Center(
    //                                         child: Text(
    //                                           plainLyric,
    //                                           style: TextStyle(
    //                                             color: Colors.white,
    //                                             fontSize: normalSize,
    //                                             fontWeight: FontWeight.normal,
    //                                           ),
    //                                         )
    //                                     ):
    //                                     ScrollConfiguration(
    //                                       behavior: ScrollConfiguration.of(context).copyWith(
    //                                         dragDevices: {
    //                                           PointerDeviceKind.touch,
    //                                           PointerDeviceKind.mouse,
    //                                         },
    //                                       ),
    //                                       child: SingleChildScrollView(
    //                                         scrollDirection: Axis.vertical,
    //                                         physics: const BouncingScrollPhysics(),
    //                                         child: SingleChildScrollView(
    //                                             scrollDirection: Axis.horizontal,
    //                                             child: Text(
    //                                               plainLyric,
    //                                               style: TextStyle(
    //                                                 color: Colors.white,
    //                                                 fontSize: normalSize,
    //                                                 fontWeight: FontWeight.normal,
    //                                               ),
    //                                             )
    //                                         ),
    //                                       ),
    //                                     ),
    //
    //                                   ),
    //                                 );
    //                               }
    //                           );
    //                         }
    //                         else {
    //                           return Center(
    //                               child: Text(
    //                                 "Searching for lyrics...",
    //                                 style: TextStyle(
    //                                   color: Colors.white,
    //                                   fontSize: normalSize,
    //                                   fontWeight: FontWeight.normal,
    //                                 ),
    //                               )
    //                           );
    //                         }
    //                       }
    //                     ),
    //
    //                   Column(
    //                     mainAxisAlignment: MainAxisAlignment.center,
    //                     crossAxisAlignment: CrossAxisAlignment.center,
    //                     children: [
    //                       if(values[0])
    //                         IgnorePointer(
    //                           ignoring: true,
    //                           child: AnimatedOpacity(
    //                             opacity: hiddenNotifier.value ? 0.0 : 1.0,
    //                             duration: const Duration(milliseconds: 500),
    //                             child: Container(
    //                               width: width * 0.635,
    //                               margin: EdgeInsets.only(
    //                                 top: height * 0.01,
    //                                 bottom: height * 0.01,
    //                               ),
    //                               alignment: Alignment.center,
    //                               child: FutureBuilder(
    //                                   future: Future(() async {
    //                                     try {
    //                                       List<String> lyrics = await DataController.getLyrics(SettingsController.currentSongPath);
    //                                       return lyrics;
    //                                     } catch (e) {
    //                                       debugPrint(e.toString());
    //                                       return ["No lyrics found", "No lyrics found"];
    //                                     }
    //                                   }),
    //                                   builder: (context, snapshot){
    //                                     if(snapshot.hasData){
    //                                       var lyricModel = LyricsModelBuilder.create().bindLyricToMain(snapshot.data![1]).getModel();
    //                                       if (lyricModel.lyrics.isNotEmpty) {
    //                                         return MultiValueListenableBuilder(
    //                                             valueListenables: [SettingsController.sliderNotifier, SettingsController.playingNotifier],
    //                                             builder: (context, value, child){
    //                                               return LyricsReader(
    //                                                 model: lyricModel,
    //                                                 position: value[0],
    //                                                 lyricUi: lyricUI,
    //                                                 playing: SettingsController.playing,
    //                                                 size: Size(width * 0.6, height * 0.021),
    //                                               );
    //                                             }
    //                                         );
    //                                       }
    //                                       else {
    //                                         return Text(
    //                                           "No lyrics found",
    //                                           style: TextStyle(
    //                                             color: Colors.white,
    //                                             fontSize: normalSize,
    //                                             fontWeight: FontWeight.normal,
    //                                           ),
    //                                         );
    //                                       }
    //                                     }
    //                                     else {
    //                                       return const SizedBox();
    //                                     }
    //                                   }
    //                               ),
    //                             ),
    //                           ),
    //                         ),
    //
    //                       if (!values[0])
    //                         SizedBox(
    //                           height: height * 0.03,
    //                           width: width,
    //                         ),
    //
    //                       // ProgressBar
    //                       MultiValueListenableBuilder(
    //                           valueListenables: [SettingsController.sliderNotifier, SettingsController.lightColorNotifier],
    //                           builder: (context, values, child){
    //                             return AnimatedContainer(
    //                               duration: const Duration(milliseconds: 500),
    //                               curve: Curves.easeInOut,
    //                               width:  am.minimizedNotifier.value ? width * 0.635 : width * 0.92,
    //                               padding: EdgeInsets.symmetric(
    //                                 horizontal: width * 0.02,
    //                                 vertical:  am.minimizedNotifier.value ? 0 : height * 0.05,
    //                               ),
    //                               alignment: Alignment.center,
    //                               child: FutureBuilder(
    //                                 future: DataController.getDuration(audioProvider.currentSong),
    //                                 builder: (context, snapshot){
    //                                   return ProgressBar(
    //                                     progress: Duration(milliseconds: values[0]),
    //                                     total: snapshot.hasData ? snapshot.data as Duration : Duration.zero,
    //                                     progressBarColor: values[1].withOpacity(hiddenNotifier.value ? 0.0 : 1.0),
    //                                     baseBarColor: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 0.24),
    //                                     bufferedBarColor: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 0.24),
    //                                     thumbColor: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1.0),
    //                                     barHeight: 4.0,
    //                                     thumbRadius: 7.0,
    //                                     timeLabelLocation:  TimeLabelLocation.sides,
    //                                     timeLabelTextStyle: TextStyle(
    //                                       color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1.0),
    //                                       fontSize: height * 0.02,
    //                                       fontWeight: FontWeight.normal,
    //                                     ),
    //                                     onSeek: (duration) {
    //                                       AudioPlayerController.audioPlayer.seek(duration);
    //                                     },
    //                                   );
    //                                 },
    //                               ),
    //                             );
    //                           }
    //                       ),
    //
    //                       if (!values[0])
    //                         SizedBox(
    //                           height: height * 0.01,
    //                           width: width,
    //                         ),
    //
    //                       // Player Controls - Previous, Play/Pause, Next
    //                       AnimatedContainer(
    //                         duration: const Duration(milliseconds: 500),
    //                         width:  am.minimizedNotifier.value ? width * 0.635 : width * 0.9,
    //                         child: Row(
    //                           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                           children: [
    //                             if (!values[0])
    //                               ValueListenableBuilder(
    //                                   valueListenable: likedNotifier,
    //                                   builder: (context, likedVal, child) {
    //                                     return IconButton(
    //                                         padding: const EdgeInsets.all(0),
    //                                         onPressed: () async {
    //                                           debugPrint("Liked");
    //                                           var currentSong = audioProvider.currentSong;
    //                                           await dc.updateLiked(currentSong);
    //                                           likedNotifier.value = !likedNotifier.value;
    //                                           if (currentSong.liked) {
    //                                             // am.showNotification("Added ${currentSong.title} to Favorites", 3000);
    //                                           }
    //                                           else {
    //                                             // am.showNotification("Removed ${currentSong.title} from Favorites", 3000);
    //                                           }
    //
    //                                         },
    //                                         icon: Icon(
    //                                             audioProvider.currentSong.liked ? FluentIcons.liked : FluentIcons.unliked,
    //                                             size: height * 0.025,
    //                                             color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1)
    //                                         )
    //                                     );
    //                                   }
    //                               ),
    //                             ValueListenableBuilder(
    //                                 valueListenable: SettingsController.shuffleNotifier,
    //                                 builder: (context, value, child){
    //                                   return IconButton(
    //                                     onPressed: () {
    //                                       SettingsController.shuffle = !SettingsController.shuffle;
    //                                     },
    //                                     icon:
    //                                     Icon(
    //                                         value == false ? FluentIcons.shuffleOff : FluentIcons.shuffleOn,
    //                                         size: height * 0.025,
    //                                         color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1)
    //                                     ),
    //                                   );
    //                                 }
    //                             ),
    //                             IconButton(
    //                               onPressed: () async {
    //                                 await AppAudioHandler.skipToPrevious();
    //                               },
    //                               icon: Icon(
    //                                 FluentIcons.previous,
    //                                 color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1.0),
    //                                 size: height * 0.025,
    //                               ),
    //                             ),
    //                             MultiValueListenableBuilder(
    //                                 valueListenables: [SettingsController.playingNotifier],
    //                                 builder: (context, value, child){
    //                                   return IconButton(
    //                                     onPressed: () async {
    //                                       //debugPrint("pressed pause play");
    //                                       if (SettingsController.playing) {
    //                                         await AppAudioHandler.pause();
    //                                       } else {
    //                                         await AppAudioHandler.play();
    //                                       }
    //                                     },
    //                                     icon: Icon(
    //                                       SettingsController.playing ?
    //                                       FluentIcons.pause :
    //                                       FluentIcons.play,
    //                                       color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1.0),
    //                                       size: height * 0.025,
    //                                     ),
    //                                   );
    //                                 }
    //                             ),
    //                             IconButton(
    //                               onPressed: () async {
    //                                 debugPrint("next");
    //                                 return await AppAudioHandler.skipToNext();
    //                               },
    //                               icon: Icon(
    //                                 FluentIcons.next,
    //                                 color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1.0),
    //                                 size: height * 0.025,
    //                               ),
    //                             ),
    //                             ValueListenableBuilder(
    //                                 valueListenable: SettingsController.repeatNotifier,
    //                                 builder: (context, value, child){
    //                                   return IconButton(
    //                                     onPressed: () {
    //                                       SettingsController.repeat = !SettingsController.repeat;
    //                                     },
    //                                     icon:
    //                                     Icon(
    //                                         value == false ? FluentIcons.repeatOff: FluentIcons.repeatOn,
    //                                         size: height * 0.025,
    //                                         color: Colors.white.withOpacity(hiddenNotifier.value ? 0.0 : 1.0)),
    //                                   );
    //                                 }
    //                             ),
    //                             if (!values[0])
    //                               IconButton(
    //                                   padding: const EdgeInsets.all(0),
    //                                   onPressed: (){
    //                                     am.minimizedNotifier.value = !am.minimizedNotifier.value;
    //                                     hiddenNotifier.value = false;
    //                                   }, icon: Icon(
    //                                 am.minimizedNotifier.value ? FluentIcons.maximize : FluentIcons.minimize,
    //                                 color: Colors.white,
    //                                 size: width * 0.01,
    //                               )
    //                               ),
    //                           ],
    //                         ),
    //                       ),
    //
    //                     ],
    //                   ),
    //                 ],
    //               ),
    //             ),
    //           ),
    //           if (values[0])
    //             AnimatedContainer(
    //               duration: const Duration(milliseconds: 500),
    //               curve: Curves.easeInOut,
    //               height: height * 0.15,
    //               width: width,
    //               alignment: Alignment.centerRight,
    //               padding: EdgeInsets.only(
    //                 left: width * 0.01,
    //                 right: width * 0.01,
    //               ),
    //               margin: EdgeInsets.only(
    //                 bottom: height * 0.025,
    //                 left: width * 0.125,
    //                 right: width * 0.125,
    //               ),
    //               child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 children: [
    //                   // Minimize/Maximize button
    //                   IconButton(
    //                       padding: const EdgeInsets.all(0),
    //                       onPressed: () async {
    //                         am.minimizedNotifier.value = ! am.minimizedNotifier.value;
    //                         hiddenNotifier.value = false;
    //                         Future.delayed(const Duration(milliseconds: 250), (){
    //                           final contentSize = itemScrollController.position.viewportDimension + itemScrollController.position.maxScrollExtent;
    //                           itemScrollController.jumpTo(
    //                             contentSize * (SettingsController.index / SettingsController.queue.length),
    //                           );
    //                         });
    //                       },
    //                       style: ButtonStyle(
    //                         backgroundColor: WidgetStateProperty.all(Colors.black.withOpacity(hiddenNotifier.value ? 0.5 : 0.0)),
    //                       ),
    //                       icon: Icon(
    //                         am.minimizedNotifier.value ?
    //                         FluentIcons.maximize :
    //                         FluentIcons.minimize, color: Colors.white,
    //                         size: width * 0.01,
    //                       )
    //                   ),
    //                   // Visibility Toggle
    //                   IconButton(
    //                     onPressed: (){
    //                       // debugPrint("pressed hiddenNotifier.value");
    //                       hiddenNotifier.value = !hiddenNotifier.value;
    //                     },
    //                     style: ButtonStyle(
    //                       backgroundColor: WidgetStateProperty.all(Colors.black.withOpacity(hiddenNotifier.value ? 0.5 : 0.0)),
    //                     ),
    //                     icon: Icon(
    //                       hiddenNotifier.value ?
    //                       FluentIcons.show :
    //                       FluentIcons.hide,
    //                       color: Colors.white,
    //                       size: width * 0.01,
    //                     ),
    //                   ),
    //                 ],
    //               ),
    //             ),
    //         ],
    //       );
    //     }
    // );
  }

  Widget _buildMinimizedPlayer(double width, double height, AudioProvider audioProvider){
    return AnimatedBackground(
      key: const Key("minimizedPlayer"),
      // duration: const Duration(milliseconds: 500),
      // curve: Curves.linear,
      height: height * 0.15,
      width: width,
      alignment: Alignment.centerLeft,
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //     begin: FractionalOffset.centerLeft,
      //     end: FractionalOffset.centerRight,
      //     colors: [
      //       appStateProvider.darkColor,
      //       Color(0xFF0E0E0E),
      //
      //     ],
      //   ),
      // ),
      padding: EdgeInsets.only(
        top: height * 0.01,
        bottom: height * 0.01,
        left: width * 0.05,
        right: width * 0.05,
      ),
      child: Row(
        children: [
          // Album Art
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: Alignment.center,
            height: height * 0.1,
            width: height * 0.1,
            child: AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                decoration: BoxDecoration(
                    shape: BoxShape.rectangle,
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(width * 0.01),
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      image: Image.memory(audioProvider.image ?? Uint8List(0)).image,
                    )
                ),
              ),
            ),
          ),

          AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width:  width * 0.3,
              child: _buildPlayerButtons(width, height)
          ),

          SizedBox(
            width: width * 0.5,
          ),

          // IgnorePointer(
          //   ignoring: true,
          //   child: AnimatedOpacity(
          //     opacity: hiddenNotifier.value ? 0.0 : 1.0,
          //     duration: const Duration(milliseconds: 500),
          //     child: Container(
          //       width: width * 0.635,
          //       margin: EdgeInsets.only(
          //         top: height * 0.01,
          //         bottom: height * 0.01,
          //       ),
          //       alignment: Alignment.center,
          //       child: FutureBuilder(
          //           future: Future(() async {
          //             try {
          //               // List<String> lyrics = await DataController.getLyrics(SettingsController.currentSongPath);
          //               List<String> lyrics = ["No lyrics found", "No lyrics found"];
          //               return lyrics;
          //             } catch (e) {
          //               debugPrint(e.toString());
          //               return ["No lyrics found", "No lyrics found"];
          //             }
          //           }),
          //           builder: (context, snapshot){
          //             if(snapshot.hasData){
          //               var lyricModel = LyricsModelBuilder.create().bindLyricToMain(snapshot.data![1]).getModel();
          //               if (lyricModel.lyrics.isNotEmpty) {
          //                 return MultiValueListenableBuilder(
          //                     valueListenables: [SettingsController.sliderNotifier, SettingsController.playingNotifier],
          //                     builder: (context, value, child){
          //                       return LyricsReader(
          //                         model: lyricModel,
          //                         position: value[0],
          //                         lyricUi: lyricUI,
          //                         playing: SettingsController.playing,
          //                         size: Size(width * 0.6, height * 0.021),
          //                       );
          //                     }
          //                 );
          //               }
          //               else {
          //                 return Text(
          //                   "No lyrics found",
          //                   style: TextStyle(
          //                     color: Colors.white,
          //                     fontSize: normalSize,
          //                     fontWeight: FontWeight.normal,
          //                   ),
          //                 );
          //               }
          //             }
          //             else {
          //               return const SizedBox();
          //             }
          //           }
          //       ),
          //     ),
          //   ),
          // ),
          IconButton(
              padding: const EdgeInsets.all(0),
              onPressed: () async {
                appStateProvider.panelController.open();
                // Future.delayed(const Duration(milliseconds: 250), (){
                //   final contentSize = itemScrollController.position.viewportDimension + itemScrollController.position.maxScrollExtent;
                //   itemScrollController.jumpTo(
                //     contentSize * (SettingsController.index / SettingsController.queue.length),
                //   );
                // });
              },
              icon: Icon(
                FluentIcons.maximize, color: Colors.white,
                size: width * 0.01,
              )
          ),
        ],
      ),
    );
  }

  Widget _buildMaximizedPlayer(double width, double height, AudioProvider audioProvider){
    return Container(
      key: const Key("maximizedPlayer"),
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.linear,
          height: MediaQuery.of(context).size.height - appWindow.titleBarHeight,
          width: width,
          alignment: Alignment.center,
          padding: EdgeInsets.only(
            top: height * 0.02,
            bottom: height * 0.02,
            left: width * 0.01,
            right: width * 0.01,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF0E0E0E),
          ),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              // Queue
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                height: width * 0.3,
                width: width * 0.3,
                // color: Colors.transparent,
                child: QueueTab(),
              ),

              // Album Art
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                alignment: Alignment.center,
                height: width * 0.3,
                width: width * 0.3,
                child: DetailsTab(),
              ),

              // Lyrics
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                height: width * 0.3,
                width: width * 0.3,
                // color: Colors.transparent,
                child: LyricsTab(),
              ),


              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: height * 0.03,
                    width: width,
                  ),

                  // ProgressBar
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                    width:  width * 0.92,
                    padding: EdgeInsets.symmetric(
                      horizontal: width * 0.02,
                      vertical:  height * 0.05,
                    ),
                    alignment: Alignment.center,
                    child: FutureBuilder(
                      future: audioProvider.getDuration(),
                      builder: (context, snapshot){
                        return Consumer<SliderProvider>(
                          builder: (_, sliderProvider, __){
                            return ProgressBar(
                              progress: Duration(milliseconds: sliderProvider.slider),
                              total: snapshot.hasData ? snapshot.data as Duration : Duration.zero,
                              progressBarColor: Colors.grey,
                              baseBarColor: Colors.white.withOpacity(0.24),
                              bufferedBarColor: Colors.white.withOpacity(0.24),
                              thumbColor: Colors.white,
                              barHeight: 4.0,
                              thumbRadius: 7.0,
                              timeLabelLocation:  TimeLabelLocation.sides,
                              timeLabelTextStyle: TextStyle(
                                color: Colors.white,
                                fontSize: height * 0.02,
                                fontWeight: FontWeight.normal,
                              ),
                              onSeek: (duration) {
                                audioProvider.seek(duration);
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                  SizedBox(
                    height: height * 0.01,
                    width: width,
                  ),

                  // Player Controls - Previous, Play/Pause, Next
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 500),
                    width: width * 0.9,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: () async {
                            debugPrint("Liked");
                            var currentSong = audioProvider.currentSong;
                            // await dc.updateLiked(currentSong); TODO
                            likedNotifier.value = !likedNotifier.value;
                            if (currentSong.liked) {
                              // am.showNotification("Added ${currentSong.title} to Favorites", 3000);
                            }
                            else {
                              // am.showNotification("Removed ${currentSong.title} from Favorites", 3000);
                            }
                          },
                          icon: Icon(
                              audioProvider.currentSong.liked ? FluentIcons.liked : FluentIcons.unliked,
                              size: height * 0.025,
                              color: Colors.white,
                          )
                        ),

                        SizedBox(
                          width: width * 0.5,
                          child: _buildPlayerButtons(width, height),
                        ),


                        IconButton(
                          padding: const EdgeInsets.all(0),
                          onPressed: (){
                            appStateProvider.panelController.close();
                          },
                          icon: Icon(FluentIcons.minimize,
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
    );
  }

  Widget _buildPlayerButtons(double width, double height){
    return Consumer<AudioProvider>(
      builder: (context, audioProvider, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              onPressed: () {
                audioProvider.setShuffle(!audioProvider.shuffle);
              },
              icon: Icon(
                  audioProvider.shuffle == false ? FluentIcons.shuffleOff : FluentIcons.shuffleOn,
                  size: height * 0.025,
                  color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () async {
                await audioProvider.skipToPrevious();
              },
              icon: Icon(
                FluentIcons.previous,
                color: Colors.white,
                size: height * 0.025,
              ),
            ),
            Consumer<SliderProvider>(
              builder: (_, sliderProvider, __) {
                return IconButton(
                  onPressed: () async {
                    //debugPrint("pressed pause play");
                    if (sliderProvider.playing) {
                      await audioProvider.pause();
                      appStateProvider.stopAnimation();
                    } else {
                      await audioProvider.play();
                      appStateProvider.startAnimation();
                    }
                  },
                  icon: Icon(
                    sliderProvider.playing ?
                    FluentIcons.pause :
                    FluentIcons.play,
                    color: Colors.white,
                    size: height * 0.025,
                  ),
                );
              },
            ),
            IconButton(
              onPressed: () async {
                debugPrint("next");
                return await audioProvider.skipToNext();
              },
              icon: Icon(
                FluentIcons.next,
                color: Colors.white,
                size: height * 0.025,
              ),
            ),
            IconButton(
              onPressed: () {
                audioProvider.setRepeat(!audioProvider.repeat);
              },
              icon:
              Icon(
                  audioProvider.repeat == false ? FluentIcons.repeatOff: FluentIcons.repeatOn,
                  size: height * 0.025,
                  color: Colors.white,
              )
            ),
          ],
        );
      }
    );

  }
}
