import 'package:flutter/material.dart';
import 'package:musicplayer/components/custom_tiling/list_component.dart';
import 'package:musicplayer/providers/audio_provider.dart';
import 'package:musicplayer/providers/song_provider.dart';
import 'package:provider/provider.dart';

class QueueTab extends StatelessWidget {
  QueueTab({super.key});
  final ScrollController itemScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return FutureBuilder(
        future: Future(() async {
        return Provider.of<SongProvider>(context, listen: false)
            .getSongsFromPaths(Provider.of<AudioProvider>(context, listen: false).queue,);
        }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text("Queue is empty"),
            );
          }
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.only(
                  right: width * 0.01,
                  left: width * 0.01,
                  top: height * 0.01,
                ),
                sliver: ListComponent(
                  items: snapshot.data ?? [],
                  itemExtent: height * 0.1,
                  onTap: (entity) {
                    debugPrint("Tapped on: ${entity.name}");
                    // audioProvider.play(entity);
                  },
                  onLongPress: (entity) {
                    debugPrint("Long pressed on: ${entity.name}");
                    // audioProvider.showContextMenu(entity);
                  },
                ),
              ),
            ],
          );
        }
    );
    // return Consumer<AudioProvider>(
    //   builder: (_, audioProvider, __) {
    //
    //     // return Scrollbar(
    //     //   controller: itemScrollController,
    //     //   thickness: 15.0,
    //     //   thumbVisibility: true,
    //     //   interactive: true,
    //     //   radius: const Radius.circular(10.0),
    //     //   child: ListView.builder(
    //     //     itemCount: audioProvider.queue.length,
    //     //     padding: EdgeInsets.only(
    //     //       right: width * 0.01,
    //     //     ),
    //     //     prototypeItem: CustomListTile(
    //     //       entity: ,
    //     //       onTap: () {
    //     //         debugPrint("Prototype item tapped");
    //     //       }
    //     //     ),
    //     //   ),
    //     //   // child: ListView.builder(
    //     //   //   // controller: itemScrollController,
    //     //   //   itemCount: audioProvider.queue.length,
    //     //   //   padding: EdgeInsets.only(
    //     //   //       right: width * 0.01
    //     //   //   ),
    //     //   //   prototypeItem: ListTile(
    //     //   //     dense: true,
    //     //   //     visualDensity: const VisualDensity(vertical: 4),
    //     //   //     contentPadding: EdgeInsets.symmetric(
    //     //   //       horizontal: width * 0.005,
    //     //   //       vertical: height * 0.01,
    //     //   //     ),
    //     //   //     leading: ClipRRect(
    //     //   //       borderRadius: BorderRadius.circular(width * 0.005),
    //     //   //       child: ImageWidget(
    //     //   //         path: "",
    //     //   //         heroTag: "prototype",
    //     //   //         hoveredChild: IconButton(
    //     //   //           onPressed: () async {
    //     //   //           },
    //     //   //           icon: Icon(
    //     //   //             FluentIcons.trash,
    //     //   //             color: Colors.white,
    //     //   //             size: width * 0.0125,
    //     //   //           ),
    //     //   //         ),
    //     //   //       ),
    //     //   //     ),
    //     //   //     title: TextScroll(
    //     //   //       "Loading...",
    //     //   //       mode: TextScrollMode.bouncing,
    //     //   //       velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
    //     //   //       style: TextStyle(
    //     //   //         color: Colors.white,
    //     //   //         fontSize: normalSize,
    //     //   //         fontWeight: FontWeight.bold,
    //     //   //       ),
    //     //   //       pauseOnBounce: const Duration(seconds: 2),
    //     //   //       delayBefore: const Duration(seconds: 2),
    //     //   //       pauseBetween: const Duration(seconds: 2),
    //     //   //     ),
    //     //   //     subtitle: TextScroll(
    //     //   //       "Loading...",
    //     //   //       mode: TextScrollMode.bouncing,
    //     //   //       velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
    //     //   //       style: TextStyle(
    //     //   //         color: Colors.white,
    //     //   //         fontSize: normalSize,
    //     //   //         fontWeight: FontWeight.normal,
    //     //   //       ),
    //     //   //       pauseOnBounce: const Duration(seconds: 2),
    //     //   //       delayBefore: const Duration(seconds: 2),
    //     //   //       pauseBetween: const Duration(seconds: 2),
    //     //   //     ),
    //     //   //     trailing: Text(
    //     //   //       "??:??",
    //     //   //       style: TextStyle(
    //     //   //         color: Colors.white,
    //     //   //         fontSize: normalSize,
    //     //   //       ),
    //     //   //     ),
    //     //   //   ),
    //     //   //   itemBuilder: (context, int index) {
    //     //   //     return Material(
    //     //   //       type: MaterialType.transparency,
    //     //   //       child: FutureBuilder(
    //     //   //         future: Future.delayed(const Duration(milliseconds: 500), () async {
    //     //   //           return await songProvider.getSong(audioProvider.queue[index]);
    //     //   //         }),
    //     //   //         builder: (context, snapshot){
    //     //   //           if (snapshot.hasData) {
    //     //   //             var song = snapshot.data ?? Song();
    //     //   //             return ListTile(
    //     //   //               dense: true,
    //     //   //               visualDensity: const VisualDensity(vertical: VisualDensity.maximumDensity),
    //     //   //               contentPadding: EdgeInsets.symmetric(
    //     //   //                 horizontal: width * 0.005,
    //     //   //                 vertical: height * 0.0125,
    //     //   //               ),
    //     //   //               onTap: () async {
    //     //   //                 //debugPrint(SettingsController.playingSongsUnShuffled[index].title);
    //     //   //                 //widget.controller.audioPlayer.stop();
    //     //   //                 // DataController.indexChange(audioProvider.audioSettings.queue[index]);
    //     //   //
    //     //   //                 //TODO
    //     //   //                 // audioProvider.audioSettings.index = SettingsController.currentQueue.indexOf(audioProvider.audioSettings.queue[index]);
    //     //   //                 // await AppAudioHandler.play();
    //     //   //               },
    //     //   //               leading: ClipRRect(
    //     //   //                 borderRadius: BorderRadius.circular(width * 0.005),
    //     //   //                 child: ImageWidget(
    //     //   //                   path: audioProvider.queue[index],
    //     //   //                   heroTag: "${audioProvider.queue[index]} $index",
    //     //   //                   hoveredChild: IconButton(
    //     //   //                     onPressed: () async {
    //     //   //                       debugPrint("Delete song from queue");
    //     //   //                       // await dc.removeFromQueue(audioProvider.audioSettings.queue[index]);
    //     //   //                       // setState(() {});
    //     //   //                     },
    //     //   //                     icon: Icon(
    //     //   //                       FluentIcons.trash,
    //     //   //                       color: Colors.white,
    //     //   //                       size: width * 0.0125,
    //     //   //                     ),
    //     //   //                   ),
    //     //   //                 ),
    //     //   //               ),
    //     //   //               title: TextScroll(
    //     //   //                 song.name,
    //     //   //                 mode: TextScrollMode.bouncing,
    //     //   //                 velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
    //     //   //                 style: TextStyle(
    //     //   //                   color: audioProvider.currentSong.path != song.path ? Colors.white : Colors.blue,
    //     //   //                   fontSize: normalSize,
    //     //   //                   fontWeight: FontWeight.bold,
    //     //   //                 ),
    //     //   //                 pauseOnBounce: const Duration(seconds: 2),
    //     //   //                 delayBefore: const Duration(seconds: 2),
    //     //   //                 pauseBetween: const Duration(seconds: 2),
    //     //   //               ),
    //     //   //               subtitle: TextScroll(
    //     //   //                 song.trackArtist,
    //     //   //                 mode: TextScrollMode.bouncing,
    //     //   //                 velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
    //     //   //                 style: TextStyle(
    //     //   //                   color: audioProvider.currentSong.path != song.path ? Colors.white : Colors.blue,
    //     //   //                   fontSize: smallSize,
    //     //   //                   fontWeight: FontWeight.normal,
    //     //   //                 ),
    //     //   //                 pauseOnBounce: const Duration(seconds: 2),
    //     //   //                 delayBefore: const Duration(seconds: 2),
    //     //   //                 pauseBetween: const Duration(seconds: 2),
    //     //   //               ),
    //     //   //               trailing: Text(
    //     //   //                 "${song.duration ~/ 60}:${(song.duration % 60).toString().padLeft(2, '0')}",
    //     //   //                 style: TextStyle(
    //     //   //                   color: audioProvider.currentSong.path != song.path ? Colors.white : Colors.blue,
    //     //   //                   fontSize: normalSize,
    //     //   //                 ),
    //     //   //               ),
    //     //   //
    //     //   //
    //     //   //             );
    //     //   //           }
    //     //   //           else {
    //     //   //             return ListTile(
    //     //   //               dense: true,
    //     //   //               visualDensity: const VisualDensity(vertical: 4),
    //     //   //               contentPadding: EdgeInsets.symmetric(
    //     //   //                 horizontal: width * 0.005,
    //     //   //                 vertical: height * 0.01,
    //     //   //               ),
    //     //   //               onTap: () async {
    //     //   //                 //debugPrint(SettingsController.playingSongsUnShuffled[index].title);
    //     //   //                 //widget.controller.audioPlayer.stop();
    //     //   //                 // DataController.indexChange(audioProvider.audioSettings.queue[index]);
    //     //   //                 //TODO
    //     //   //                 // audioProvider.index = audioProvider.audioSettings.queue.indexOf(audioProvider.audioSettings.queue[index]);
    //     //   //                 // await audioProvider.play();
    //     //   //               },
    //     //   //               leading: ClipRRect(
    //     //   //                 borderRadius: BorderRadius.circular(width * 0.005),
    //     //   //                 child: ImageWidget(
    //     //   //                   path: "",
    //     //   //                   heroTag: "null $index",
    //     //   //                   hoveredChild: IconButton(
    //     //   //                     onPressed: () async {
    //     //   //                       debugPrint("Delete song from queue");
    //     //   //                       // await dc.removeFromQueue(audioProvider.audioSettings.queue[index]);
    //     //   //                       // setState(() {});
    //     //   //                     },
    //     //   //                     icon: Icon(
    //     //   //                       FluentIcons.trash,
    //     //   //                       color: Colors.white,
    //     //   //                       size: width * 0.0125,
    //     //   //                     ),
    //     //   //                   ),
    //     //   //                 ),
    //     //   //               ),
    //     //   //               title: TextScroll(
    //     //   //                 "Loading...",
    //     //   //                 mode: TextScrollMode.bouncing,
    //     //   //                 velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
    //     //   //                 style: TextStyle(
    //     //   //                   color: Colors.white,
    //     //   //                   fontSize: normalSize,
    //     //   //                   fontWeight: FontWeight.normal,
    //     //   //                 ),
    //     //   //                 pauseOnBounce: const Duration(seconds: 2),
    //     //   //                 delayBefore: const Duration(seconds: 2),
    //     //   //                 pauseBetween: const Duration(seconds: 2),
    //     //   //               ),
    //     //   //
    //     //   //
    //     //   //             );
    //     //   //           }
    //     //   //         },
    //     //   //       ),
    //     //   //     );
    //     //   //   },
    //     //   // ),
    //     // );
    //   },
    // );
  }
}