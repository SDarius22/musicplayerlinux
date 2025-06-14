import 'package:musicplayer/components/custom_tiling/grid_component.dart';
import 'package:musicplayer/entities/abstract/abstract_entity.dart';
import 'package:musicplayer/entities/song.dart';
import 'package:musicplayer/providers/app_state_provider.dart';
import 'package:musicplayer/providers/audio_provider.dart';
import 'package:musicplayer/providers/song_provider.dart';
import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';

class Tracks extends StatefulWidget{
  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (_) => const Tracks(),
      settings: const RouteSettings(name: '/tracks'),
    );
  }

  const Tracks({super.key});

  @override
  State<Tracks> createState() => _TracksState();
}


class _TracksState extends State<Tracks>{
  FocusNode searchNode = FocusNode();
  Timer? _debounce;

  late final AudioProvider audioProvider;

  @override
  void initState(){
    super.initState();
    audioProvider = Provider.of<AudioProvider>(context, listen: false);
  }


  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;

    return Consumer<AppStateProvider>(
      builder: (_, appStateProvider, __) {
        return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: EdgeInsets.only(
                top: height * 0.02,
                left: appStateProvider.isDrawerOpen ? width * 0.125 : width * 0.035,
                right: width * 0.01,
                bottom: height * 0.02
            ),
            child: Consumer<SongProvider>(
                builder: (context, songProvider, child) {
                  return Column(
                    children: [
                      Container(
                        height: height * 0.05,
                        width: width,
                        margin: EdgeInsets.only(
                          left: width * 0.01,
                          right: width * 0.01,
                          bottom: height * 0.01,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              style: ButtonStyle(
                                shape: WidgetStateProperty.all<CircleBorder>(
                                  const CircleBorder(
                                    side: BorderSide(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              icon: Icon(
                                appStateProvider.appSettings.gridView ? FluentIcons.gridView : FluentIcons.listView,
                                color: Colors.white,
                                size: height * 0.03,
                              ),
                              onPressed: (){
                                setState(() {
                                  appStateProvider.appSettings.gridView = !appStateProvider.appSettings.gridView;
                                });
                                debugPrint("Grid view set to ${appStateProvider.appSettings.gridView}");
                              },
                            ),
                            SizedBox(
                              width: width * 0.01,
                            ),
                            Expanded(
                              child: TextFormField(
                                initialValue: '',
                                focusNode: searchNode,
                                onChanged: (value) {
                                  if (_debounce?.isActive ?? false) _debounce?.cancel();
                                  _debounce = Timer(const Duration(milliseconds: 500), () {
                                    songProvider.setQuery(value);
                                  });
                                },
                                cursorColor: Colors.white,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: normalSize,
                                ),
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(width * 0.02),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                  contentPadding: EdgeInsets.only(
                                    left: width * 0.01,
                                    right: width * 0.01,
                                  ),
                                  floatingLabelBehavior: FloatingLabelBehavior.never,
                                  labelStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: smallSize,
                                  ),
                                  labelText: 'Search', suffixIcon: Icon(FluentIcons.search, color: Colors.white, size: height * 0.02,),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: width * 0.01,
                            ),
                            Container(
                              padding: EdgeInsets.only(
                                left: width * 0.01,
                                right: width * 0.01,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      songProvider.setSortField(value);
                                    },
                                    tooltip: "Sort by",
                                    itemBuilder: (context) => [
                                      PopupMenuItem(value: "Name", child: Text("Name")),
                                      PopupMenuItem(value: "Duration", child: Text("Duration")),
                                    ],
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Text(
                                        songProvider.sortField,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: smallSize,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: 1, // Divider thickness
                                    height: double.maxFinite, // Divider height
                                    margin: EdgeInsets.only(
                                      right: width * 0.01,
                                      left: width * 0.01,
                                    ),
                                    color: Colors.grey,
                                  ),
                                  IconButton(
                                    icon: Icon(songProvider.isAscending ? FluentIcons.sortAscending : FluentIcons.sortDescending),
                                    onPressed: () {
                                      songProvider.setFlag(!songProvider.isAscending);
                                      debugPrint("Sort order set to ${songProvider.isAscending}");
                                    },
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                        child: FutureBuilder(
                            future: songProvider.songsFuture,
                            builder: (context, snapshot){
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                              if (snapshot.hasError) {
                                debugPrint(snapshot.error.toString());
                                debugPrintStack();
                                return Center(
                                  child: Text(
                                    "Error loading songs",
                                    style: TextStyle(color: Colors.white, fontSize: smallSize),
                                  ),
                                );
                              }
                              debugPrint("Songs loaded: ${snapshot.data?.length ?? 0}");
                              return CustomScrollView(
                                slivers: [
                                  SliverPadding(
                                    padding: EdgeInsets.only(
                                      left: width * 0.01,
                                      right: width * 0.01,
                                    ),
                                    sliver: GridComponent(
                                      items: snapshot.data ?? [],
                                      onTap: (entity) async {
                                        debugPrint("tapped ${entity.name}");
                                        Song song = entity as Song;
                                        var audioProvider = Provider.of<AudioProvider>(context, listen: false);
                                        if (audioProvider.currentSong.path != song.path) {
                                          //debugPrint("path match");
                                          List<String> songPaths = (snapshot.data as List<Song>).map((e) => e.path).toList();
                                          audioProvider.setQueue(songPaths);
                                          audioProvider.setCurrentIndex(song.path);
                                          // if (SettingsController.queue.equals(songPaths) == false) {
                                          //   debugPrint("Updating playing songs");
                                          //   dc.updatePlaying(songPaths, index);
                                          // }
                                          // SettingsController.index = SettingsController.currentQueue.indexOf(song.path);
                                          await audioProvider.play();
                                        }
                                        else {
                                          if (audioProvider.playing == true) {
                                            await audioProvider.pause();
                                          }
                                          else {
                                            await audioProvider.play();
                                          }
                                        }
                                        try {

                                        }
                                        catch (e) {
                                          debugPrint(e.toString());
                                          // var songPaths = snapshot.data!.map((e) => e.path).toList();
                                          // dc.updatePlaying(songPaths, index);
                                          // SettingsController.index = index;
                                          // await AppAudioHandler.play();
                                        }
                                      },
                                      onLongPress: (entity) {
                                        debugPrint("long pressed ${entity.name}");
                                      },
                                    ),
                                    // sliver: SliverGrid.builder(
                                    //   gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                    //     maxCrossAxisExtent: width * 0.125,
                                    //     crossAxisSpacing: width * 0.0125,
                                    //     mainAxisSpacing: width * 0.0125,
                                    //   ),
                                    //   itemCount: snapshot.hasData ? snapshot.data!.length : 0,
                                    //   itemBuilder: (BuildContext context, int index) {
                                    //     if (index >= snapshot.data!.length) {
                                    //       return Container(
                                    //         height: height * 0.125,
                                    //         padding: EdgeInsets.symmetric(
                                    //           horizontal: width * 0.01,
                                    //           vertical: height * 0.01,
                                    //         ),
                                    //         child: snapshot.connectionState == ConnectionState.waiting ?
                                    //         Center(
                                    //           child: CircularProgressIndicator(),
                                    //         ) : Center(
                                    //           child: Text("No more songs to load"),
                                    //         ),
                                    //       );
                                    //     }
                                    //     Song song = snapshot.data![index];
                                    //     return MouseRegion(
                                    //       cursor: SystemMouseCursors.click,
                                    //       child: GestureDetector(
                                    //         onTap: () async {
                                    //           //debugPrint("Playing ${widget.controller.indexNotifier.value}");
                                    //           // try {
                                    //           //   if (SettingsController.currentSongPath != song.path) {
                                    //           //     //debugPrint("path match");
                                    //           //     var songPaths = snapshot.data!.map((e) => e.path).toList();
                                    //           //     if (SettingsController.queue.equals(songPaths) == false) {
                                    //           //       debugPrint("Updating playing songs");
                                    //           //       dc.updatePlaying(songPaths, index);
                                    //           //     }
                                    //           //     SettingsController.index = SettingsController.currentQueue.indexOf(song.path);
                                    //           //     await AppAudioHandler.play();
                                    //           //   }
                                    //           //   else {
                                    //           //     if (SettingsController.playing == true) {
                                    //           //       await AppAudioHandler.pause();
                                    //           //     }
                                    //           //     else {
                                    //           //       await AppAudioHandler.play();
                                    //           //     }
                                    //           //   }
                                    //           // }
                                    //           // catch (e) {
                                    //           //   debugPrint(e.toString());
                                    //           //   var songPaths = snapshot.data!.map((e) => e.path).toList();
                                    //           //   dc.updatePlaying(songPaths, index);
                                    //           //   SettingsController.index = index;
                                    //           //   await AppAudioHandler.play();
                                    //           // }
                                    //         },
                                    //         onLongPress: (){
                                    //           debugPrint("Select song $index");
                                    //           // DataController.selected = List.from(DataController.selected)..add(song.path);
                                    //         },
                                    //         child: ClipRRect(
                                    //           borderRadius: BorderRadius.circular(width * 0.01),
                                    //           child: ImageWidget(
                                    //             path: song.path,
                                    //             heroTag: song.path,
                                    //             hoveredChild: Row(
                                    //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    //               crossAxisAlignment: CrossAxisAlignment.center,
                                    //               children: [
                                    //                 SizedBox(
                                    //                   width: width * 0.035,
                                    //                   height: width * 0.035,
                                    //                   child: IconButton(
                                    //                     tooltip: "Go to Album",
                                    //                     onPressed: (){
                                    //                       // Navigator.pushNamed(context, '/album', arguments: DataController.albumBox.query(Album_.name.equals(song.album)).build().findFirst());
                                    //                     },
                                    //                     padding: const EdgeInsets.all(0),
                                    //                     icon: Icon(
                                    //                       FluentIcons.album,
                                    //                       color: Colors.white,
                                    //                       size: height * 0.03,
                                    //                     ),
                                    //                   ),
                                    //                 ),
                                    //                 Expanded(
                                    //                   child: Consumer<AudioProvider>(
                                    //                     builder: (_, audioProvider, __){
                                    //                       return FittedBox(
                                    //                         fit: BoxFit.fill,
                                    //                         child: Icon(
                                    //                           audioProvider.currentSong.path  == song.path && audioProvider.audioSettings.playing == true ?
                                    //                           FluentIcons.pause : FluentIcons.play,
                                    //                           color: Colors.white,
                                    //                         ),
                                    //                       );
                                    //                     },
                                    //                   ),
                                    //                 ),
                                    //                 SizedBox(
                                    //                   width: width * 0.035,
                                    //                   height: width * 0.035,
                                    //                   child: PopupMenuButton<String>(
                                    //                     icon: Icon(
                                    //                       FluentIcons.moreVertical,
                                    //                       color: Colors.white,
                                    //                       size: height * 0.03,
                                    //                     ),
                                    //                     onSelected: (String value){
                                    //                       switch(value){
                                    //                         case 'add':
                                    //                           debugPrint("Add $index");
                                    //                           Navigator.pushNamed(context, '/add', arguments: [song]);
                                    //                           break;
                                    //                         case 'playNext':
                                    //                           debugPrint("Play Next: $index");
                                    //                           // dc.addNextToQueue([song.path]);
                                    //                           break;
                                    //                         case 'select':
                                    //                           debugPrint("Select $index");
                                    //                           // if (DataController.selected.contains(song.path)){
                                    //                           //   DataController.selected = List.from(DataController.selected)..remove(song.path);
                                    //                           //   return;
                                    //                           // }
                                    //                           // DataController.selected = List.from(DataController.selected)..add(song.path);
                                    //                           break;
                                    //                         case 'details':
                                    //                           debugPrint("Details $index");
                                    //                           Navigator.pushNamed(context, '/track', arguments: song);
                                    //                           break;
                                    //                       }
                                    //                     },
                                    //                     itemBuilder: (context){
                                    //                       return [
                                    //                         const PopupMenuItem<String>(
                                    //                           value: 'add',
                                    //                           child: Text("Add to Playlist"),
                                    //                         ),
                                    //                         const PopupMenuItem<String>(
                                    //                           value: 'playNext',
                                    //                           child: Text("Play Next"),
                                    //                         ),
                                    //                         const PopupMenuItem<String>(
                                    //                           value: 'select',
                                    //                           child: Text("Select"),
                                    //                         ),
                                    //                         const PopupMenuItem<String>(
                                    //                           value: 'details',
                                    //                           child: Text("Track Details"),
                                    //                         ),
                                    //                       ];
                                    //                     },
                                    //                   ),
                                    //                 ),
                                    //               ],
                                    //             ),
                                    //             child: Container(
                                    //               alignment: Alignment.bottomCenter,
                                    //               padding: EdgeInsets.only(
                                    //                 bottom: height * 0.005,
                                    //               ),
                                    //               decoration: BoxDecoration(
                                    //                   gradient: LinearGradient(
                                    //                       begin: FractionalOffset.center,
                                    //                       end: FractionalOffset.bottomCenter,
                                    //                       colors: [
                                    //                         Colors.black.withOpacity(0.0),
                                    //                         Colors.black.withOpacity(0.5),
                                    //                         Colors.black,
                                    //                       ],
                                    //                       stops: const [0.0, 0.5, 1.0]
                                    //                   )
                                    //               ),
                                    //               child: Consumer<AudioProvider>(
                                    //                 builder: (_, audioProvider, __) {
                                    //                   return TextScroll(
                                    //                     song.name,
                                    //                     mode: TextScrollMode.bouncing,
                                    //                     velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
                                    //                     style: TextStyle(
                                    //                       color: audioProvider.currentSong.path == song.path ? Colors.blue : Colors.white,
                                    //                       fontSize: normalSize,
                                    //                       fontWeight: FontWeight.bold,
                                    //                     ),
                                    //                     pauseOnBounce: const Duration(seconds: 2),
                                    //                     delayBefore: const Duration(seconds: 2),
                                    //                     pauseBetween: const Duration(seconds: 2),
                                    //                   );
                                    //                 },
                                    //               ),
                                    //             ),
                                    //           ),
                                    //         ),
                                    //       ),
                                    //
                                    //     );
                                    //   },
                                    // ),
                                  ),
                                ],
                              );
                              // return GridView.builder(
                              //   padding: EdgeInsets.only(
                              //     left: width * 0.01,
                              //     right: width * 0.01,
                              //     top: height * 0.01,
                              //     bottom: width * 0.125,
                              //   ),
                              //   itemCount: songProvider.loadedSongs.length,
                              //   controller: songProvider.scrollController,
                              //   gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                              //     maxCrossAxisExtent: width * 0.125,
                              //     crossAxisSpacing: width * 0.0125,
                              //     mainAxisSpacing: width * 0.0125,
                              //   ),
                              //   itemBuilder: (BuildContext context, int index) {
                              //     if (index >= songProvider.loadedSongs.length) {
                              //       return Container(
                              //         height: height * 0.125,
                              //         padding: EdgeInsets.symmetric(
                              //           horizontal: width * 0.01,
                              //           vertical: height * 0.01,
                              //         ),
                              //         child: snapshot.connectionState == ConnectionState.waiting ?
                              //         Center(
                              //           child: CircularProgressIndicator(),
                              //         ) : Center(
                              //           child: Text("No more songs to load"),
                              //         ),
                              //       );
                              //     }
                              //     Song song = snapshot.data![index];
                              //     return MouseRegion(
                              //       cursor: SystemMouseCursors.click,
                              //       child: GestureDetector(
                              //         onTap: () async {
                              //           //debugPrint("Playing ${widget.controller.indexNotifier.value}");
                              //           // try {
                              //           //   if (SettingsController.currentSongPath != song.path) {
                              //           //     //debugPrint("path match");
                              //           //     var songPaths = snapshot.data!.map((e) => e.path).toList();
                              //           //     if (SettingsController.queue.equals(songPaths) == false) {
                              //           //       debugPrint("Updating playing songs");
                              //           //       dc.updatePlaying(songPaths, index);
                              //           //     }
                              //           //     SettingsController.index = SettingsController.currentQueue.indexOf(song.path);
                              //           //     await AppAudioHandler.play();
                              //           //   }
                              //           //   else {
                              //           //     if (SettingsController.playing == true) {
                              //           //       await AppAudioHandler.pause();
                              //           //     }
                              //           //     else {
                              //           //       await AppAudioHandler.play();
                              //           //     }
                              //           //   }
                              //           // }
                              //           // catch (e) {
                              //           //   debugPrint(e.toString());
                              //           //   var songPaths = snapshot.data!.map((e) => e.path).toList();
                              //           //   dc.updatePlaying(songPaths, index);
                              //           //   SettingsController.index = index;
                              //           //   await AppAudioHandler.play();
                              //           // }
                              //         },
                              //         onLongPress: (){
                              //           debugPrint("Select song $index");
                              //           // DataController.selected = List.from(DataController.selected)..add(song.path);
                              //         },
                              //         child: ClipRRect(
                              //           borderRadius: BorderRadius.circular(width * 0.01),
                              //           child: ImageWidget(
                              //             path: song.path,
                              //             heroTag: song.path,
                              //             hoveredChild: Row(
                              //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              //               crossAxisAlignment: CrossAxisAlignment.center,
                              //               children: [
                              //                 SizedBox(
                              //                   width: width * 0.035,
                              //                   height: width * 0.035,
                              //                   child: IconButton(
                              //                     tooltip: "Go to Album",
                              //                     onPressed: (){
                              //                       // Navigator.pushNamed(context, '/album', arguments: DataController.albumBox.query(Album_.name.equals(song.album)).build().findFirst());
                              //                     },
                              //                     padding: const EdgeInsets.all(0),
                              //                     icon: Icon(
                              //                       FluentIcons.album,
                              //                       color: Colors.white,
                              //                       size: height * 0.03,
                              //                     ),
                              //                   ),
                              //                 ),
                              //                 Expanded(
                              //                   child: Consumer<AudioProvider>(
                              //                     builder: (_, audioProvider, __){
                              //                       return FittedBox(
                              //                         fit: BoxFit.fill,
                              //                         child: Icon(
                              //                           audioProvider.currentSong.path  == song.path && audioProvider.audioSettings.playing == true ?
                              //                           FluentIcons.pause : FluentIcons.play,
                              //                           color: Colors.white,
                              //                         ),
                              //                       );
                              //                     },
                              //                   ),
                              //                 ),
                              //                 SizedBox(
                              //                   width: width * 0.035,
                              //                   height: width * 0.035,
                              //                   child: PopupMenuButton<String>(
                              //                     icon: Icon(
                              //                       FluentIcons.moreVertical,
                              //                       color: Colors.white,
                              //                       size: height * 0.03,
                              //                     ),
                              //                     onSelected: (String value){
                              //                       switch(value){
                              //                         case 'add':
                              //                           debugPrint("Add $index");
                              //                           Navigator.pushNamed(context, '/add', arguments: [song]);
                              //                           break;
                              //                         case 'playNext':
                              //                           debugPrint("Play Next: $index");
                              //                           // dc.addNextToQueue([song.path]);
                              //                           break;
                              //                         case 'select':
                              //                           debugPrint("Select $index");
                              //                           // if (DataController.selected.contains(song.path)){
                              //                           //   DataController.selected = List.from(DataController.selected)..remove(song.path);
                              //                           //   return;
                              //                           // }
                              //                           // DataController.selected = List.from(DataController.selected)..add(song.path);
                              //                           break;
                              //                         case 'details':
                              //                           debugPrint("Details $index");
                              //                           Navigator.pushNamed(context, '/track', arguments: song);
                              //                           break;
                              //                       }
                              //                     },
                              //                     itemBuilder: (context){
                              //                       return [
                              //                         const PopupMenuItem<String>(
                              //                           value: 'add',
                              //                           child: Text("Add to Playlist"),
                              //                         ),
                              //                         const PopupMenuItem<String>(
                              //                           value: 'playNext',
                              //                           child: Text("Play Next"),
                              //                         ),
                              //                         const PopupMenuItem<String>(
                              //                           value: 'select',
                              //                           child: Text("Select"),
                              //                         ),
                              //                         const PopupMenuItem<String>(
                              //                           value: 'details',
                              //                           child: Text("Track Details"),
                              //                         ),
                              //                       ];
                              //                     },
                              //                   ),
                              //                 ),
                              //               ],
                              //             ),
                              //             child: Container(
                              //               alignment: Alignment.bottomCenter,
                              //               padding: EdgeInsets.only(
                              //                 bottom: height * 0.005,
                              //               ),
                              //               decoration: BoxDecoration(
                              //                   gradient: LinearGradient(
                              //                       begin: FractionalOffset.center,
                              //                       end: FractionalOffset.bottomCenter,
                              //                       colors: [
                              //                         Colors.black.withOpacity(0.0),
                              //                         Colors.black.withOpacity(0.5),
                              //                         Colors.black,
                              //                       ],
                              //                       stops: const [0.0, 0.5, 1.0]
                              //                   )
                              //               ),
                              //               child: Consumer<AudioProvider>(
                              //                 builder: (_, audioProvider, __) {
                              //                   return TextScroll(
                              //                     song.title,
                              //                     mode: TextScrollMode.bouncing,
                              //                     velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
                              //                     style: TextStyle(
                              //                       color: audioProvider.currentSong.path == song.path ? Colors.blue : Colors.white,
                              //                       fontSize: normalSize,
                              //                       fontWeight: FontWeight.bold,
                              //                     ),
                              //                     pauseOnBounce: const Duration(seconds: 2),
                              //                     delayBefore: const Duration(seconds: 2),
                              //                     pauseBetween: const Duration(seconds: 2),
                              //                   );
                              //                 },
                              //               ),
                              //             ),
                              //           ),
                              //         ),
                              //       ),
                              //
                              //     );
                              //   },
                              // );
                            }
                        ),
                      ),
                    ],
                  );
                }
            )
        );
      },
    );
  }

}