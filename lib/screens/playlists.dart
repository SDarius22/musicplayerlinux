import 'dart:async';

import 'package:musicplayer/components/custom_tiling/grid_component.dart';
import 'package:musicplayer/providers/app_state_provider.dart';
import 'package:musicplayer/providers/playlist_provider.dart';
import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/entities/playlist.dart';
import 'package:provider/provider.dart';

class Playlists extends StatefulWidget{
  static Route<dynamic> route() {
    return MaterialPageRoute(
      builder: (context) => const Playlists(),
      settings: const RouteSettings(name: '/playlists'),
    );
  }
  const Playlists({super.key});

  @override
  State<Playlists> createState() => _PlaylistsState();
}


class _PlaylistsState extends State<Playlists>{
  FocusNode searchNode = FocusNode();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
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
          child: Consumer<PlaylistProvider>(
            builder: (_, playlistProvider, __) {
              return Column(
                children: [
                  Container(
                    height: height * 0.05,
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
                                playlistProvider.setQuery(value);
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
                                  playlistProvider.setSortField(value);
                                },
                                tooltip: "Sort by",
                                itemBuilder: (context) => [
                                  PopupMenuItem(value: "Name", child: Text("Name")),
                                  PopupMenuItem(value: "Duration", child: Text("Duration")),
                                  PopupMenuItem(value: "Number of Songs", child: Text("Number of Songs")),
                                  PopupMenuItem(value: "Created At", child: Text("Created At")),
                                ],
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    playlistProvider.sortField,
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
                                icon: Icon(playlistProvider.isAscending ? FluentIcons.sortAscending : FluentIcons.sortDescending),
                                onPressed: () {
                                  playlistProvider.setFlag(!playlistProvider.isAscending);
                                  debugPrint("Sort order set to ${playlistProvider.isAscending}");
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
                        future: playlistProvider.playlistsFuture,
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
                                "Error loading albums",
                                style: TextStyle(color: Colors.white, fontSize: smallSize),
                              ),
                            );
                          }
                          debugPrint("Albums loaded: ${snapshot.data?.length ?? 0}");
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
                                    debugPrint("Entity type: ${entity.runtimeType}");
                                    if (entity is Playlist) {
                                      // Navigate to album page
                                      debugPrint("Songs in playlist: ${entity.songs.length}");
                                    } else {
                                      debugPrint("Entity is not a Playlist");
                                    }
                                  },
                                  onLongPress: (entity) {
                                    debugPrint("long pressed ${entity.name}");
                                  },
                                ),
                              ),
                            ],
                          );
                        }
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
    // return Container(
    //   padding: EdgeInsets.only(
    //     top: height * 0.02,
    //     left: width * 0.01,
    //     right: width * 0.01,
    //     bottom: height * 0.02,
    //   ),
    //   child: Column(
    //     children: [
    //       Container(
    //         height: height * 0.05,
    //         margin: EdgeInsets.only(
    //           left: width * 0.01,
    //           right: width * 0.01,
    //           bottom: height * 0.01,
    //         ),
    //         child: TextFormField(
    //           initialValue: '',
    //           focusNode: searchNode,
    //           onChanged: _onSearchChanged,
    //           cursorColor: Colors.white,
    //           style: TextStyle(
    //             color: Colors.white,
    //             fontSize: normalSize,
    //           ),
    //           decoration: InputDecoration(
    //               border: OutlineInputBorder(
    //                 borderRadius: BorderRadius.circular(width * 0.02),
    //                 borderSide: const BorderSide(
    //                   color: Colors.white,
    //                 ),
    //               ),
    //               contentPadding: EdgeInsets.only(
    //                 left: width * 0.01,
    //                 right: width * 0.01,
    //               ),
    //               floatingLabelBehavior: FloatingLabelBehavior.never,
    //               labelStyle: TextStyle(
    //                 color: Colors.white,
    //                 fontSize: smallSize,
    //               ),
    //               labelText: 'Search', suffixIcon: Icon(FluentIcons.search, color: Colors.white, size: height * 0.02,)
    //           ),
    //         ),
    //       ),
    //       Expanded(
    //         child: FutureBuilder(
    //             future: playlistsFuture,
    //             builder: (context, snapshot){
    //               if(snapshot.hasError){
    //                 return Center(
    //                   child: Column(
    //                     mainAxisAlignment: MainAxisAlignment.center,
    //                     children: [
    //                       Icon(
    //                         FluentIcons.error,
    //                         size: height * 0.1,
    //                         color: Colors.red,
    //                       ),
    //                       Text(
    //                         "Error loading playlists",
    //                         style: TextStyle(
    //                           color: Colors.white,
    //                           fontSize: smallSize,
    //                         ),
    //                       ),
    //                       ElevatedButton(
    //                         onPressed: (){
    //                           setState(() {});
    //                         },
    //                         child: Text(
    //                           "Retry",
    //                           style: TextStyle(
    //                             color: Colors.white,
    //                             fontSize: smallSize,
    //                           ),
    //                         ),
    //                       ),
    //                     ],
    //                   ),
    //                 );
    //               }
    //               else if(snapshot.hasData){
    //                 return GridView.builder(
    //                   padding: EdgeInsets.only(
    //                     left: width * 0.01,
    //                     right: width * 0.01,
    //                     top: height * 0.01,
    //                     bottom: width * 0.125,
    //                   ),
    //                   itemCount: snapshot.data!.length + 1,
    //                   gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
    //                     maxCrossAxisExtent: width * 0.125,
    //                     crossAxisSpacing: width * 0.0125,
    //                     mainAxisSpacing: width * 0.0125,
    //                   ),
    //                   itemBuilder: (BuildContext context, int index) {
    //                     Playlist playlist = Playlist();
    //                     if (index > 0){
    //                       playlist = snapshot.data![index-1];
    //                     }
    //                     return index == 0 ?
    //                     MouseRegion(
    //                       cursor: SystemMouseCursors.click,
    //                       child: GestureDetector(
    //                         onTap: (){
    //                           Navigator.pushNamed(context, '/create', arguments: [value]);
    //                         },
    //                         child:                               ClipRRect(
    //                           borderRadius: BorderRadius.circular(width * 0.01),
    //                           child: AspectRatio(
    //                             aspectRatio: 1.0,
    //                             child: StackHoverWidget(
    //                               bottomWidget: Container(
    //                                 decoration: BoxDecoration(
    //                                     color: Colors.black,
    //                                     image: DecorationImage(
    //                                       fit: BoxFit.cover,
    //                                       image: Image.asset("assets/create_playlist.png").image,
    //                                     )
    //                                 ),
    //                                 child: Container(
    //                                   alignment: Alignment.bottomCenter,
    //                                   padding: EdgeInsets.only(
    //                                     bottom: height * 0.005,
    //                                   ),
    //                                   decoration: BoxDecoration(
    //                                       gradient: LinearGradient(
    //                                           begin: FractionalOffset.center,
    //                                           end: FractionalOffset.bottomCenter,
    //                                           colors: [
    //                                             Colors.black.withOpacity(0.0),
    //                                             Colors.black.withOpacity(0.5),
    //                                             Colors.black,
    //                                           ],
    //                                           stops: const [0.0, 0.5, 1.0]
    //                                       )
    //                                   ),
    //                                   child: TextScroll(
    //                                     "Create a new playlist",
    //                                     mode: TextScrollMode.bouncing,
    //                                     velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
    //                                     style: TextStyle(
    //                                       color: Colors.white,
    //                                       fontSize: normalSize,
    //                                       fontWeight: FontWeight.bold,
    //                                     ),
    //                                     pauseOnBounce: const Duration(seconds: 2),
    //                                     delayBefore: const Duration(seconds: 2),
    //                                     pauseBetween: const Duration(seconds: 2),
    //                                   ),
    //                                 ),
    //                               ),
    //                               topWidget: ClipRRect(
    //                                 child: BackdropFilter(
    //                                   filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    //                                   child: Container(
    //                                     color: Colors.black.withOpacity(0.3),
    //                                     alignment: Alignment.center,
    //                                   ),
    //                                 ),
    //                               ),
    //                             ),
    //                           ),
    //                         ),
    //
    //                       ),
    //
    //                     ) :
    //                     MouseRegion(
    //                       cursor: SystemMouseCursors.click,
    //                       child: GestureDetector(
    //                         onTap: () {
    //                           //debugPrint(playlist.name);
    //                           Navigator.pushNamed(context, '/playlist', arguments: playlist);
    //                         },
    //                         child: Column(
    //                           children: [
    //                             ClipRRect(
    //                               borderRadius: BorderRadius.circular(width * 0.01),
    //                               child: ImageWidget(
    //                                 path: playlist.pathsInOrder.isNotEmpty ? playlist.pathsInOrder.first : '',
    //                                 heroTag: playlist.name,
    //                                 hoveredChild: Row(
    //                                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                                   crossAxisAlignment: CrossAxisAlignment.center,
    //                                   children: [
    //                                     Column(
    //                                       mainAxisAlignment: MainAxisAlignment.center,
    //                                       children: [
    //                                         SizedBox(
    //                                           width: width * 0.035,
    //                                           height: width * 0.035,
    //                                           child: IconButton(
    //                                             onPressed: (){
    //                                               debugPrint("Add $index");
    //                                               List<Song> songs = [];
    //                                               for (var path in playlist.pathsInOrder){
    //                                                 songs.add(DataController.songBox.query(Song_.path.equals(path)).build().findFirst());
    //                                               }
    //                                               Navigator.pushNamed(context, '/add', arguments: songs);
    //                                             },
    //                                             padding: const EdgeInsets.all(0),
    //                                             icon: Icon(
    //                                               FluentIcons.addSingle,
    //                                               color: Colors.white,
    //                                               size: height * 0.035,
    //                                             ),
    //                                           ),
    //                                         ),
    //                                         SizedBox(
    //                                           width: width * 0.035,
    //                                           height: width * 0.035,
    //                                           child: IconButton(
    //                                             onPressed: (){
    //                                               debugPrint("Play Next: $index");
    //                                               dc.addNextToQueue(playlist.pathsInOrder);
    //                                             },
    //                                             padding: const EdgeInsets.all(0),
    //                                             icon: Icon(
    //                                               FluentIcons.playNext2,
    //                                               color: Colors.white,
    //                                               size: height * 0.03,
    //                                             ),
    //                                           ),
    //                                         ),
    //                                       ],
    //                                     ),
    //                                     const Expanded(
    //                                       child: FittedBox(
    //                                         fit: BoxFit.fill,
    //                                         child: Icon(
    //                                           FluentIcons.open,
    //                                           color: Colors.white,
    //                                         ),
    //                                       ),
    //                                     ),
    //                                     Column(
    //                                       mainAxisAlignment: MainAxisAlignment.center,
    //                                       children: [
    //                                         SizedBox(
    //                                           width: width * 0.035,
    //                                           height: width * 0.035,
    //                                           child: IconButton(
    //                                             onPressed: () async {
    //                                               if(SettingsController.queue.equals(playlist.pathsInOrder) == false){
    //                                                 dc.updatePlaying(playlist.pathsInOrder, 0);
    //                                               }
    //                                               SettingsController.index = SettingsController.currentQueue.indexOf(playlist.pathsInOrder.first);
    //                                               await AppAudioHandler.play();
    //                                             },
    //                                             padding: const EdgeInsets.all(0),
    //                                             icon: Icon(
    //                                               FluentIcons.play,
    //                                               color: Colors.white,
    //                                               size: height * 0.035,
    //                                             ),
    //                                           ),
    //                                         ),
    //                                         ValueListenableBuilder(
    //                                           valueListenable: DataController.selectedPaths,
    //                                           builder: (context, value, child){
    //                                             bool isSelected = true;
    //                                             for (var path in playlist.pathsInOrder){
    //                                               if (!DataController.selected.contains(path)){
    //                                                 isSelected = false;
    //                                                 break;
    //                                               }
    //                                             }
    //                                             return SizedBox(
    //                                               width: width * 0.035,
    //                                               height: width * 0.035,
    //                                               child: IconButton(
    //                                                 onPressed: (){
    //                                                   debugPrint("Select $index");
    //                                                   if (isSelected){
    //                                                     DataController.selected = List.from(DataController.selected)..removeWhere((element) => playlist.pathsInOrder.contains(element));
    //                                                     return;
    //                                                   }
    //                                                   DataController.selected = List.from(DataController.selected)..addAll(playlist.pathsInOrder);
    //                                                 },
    //                                                 padding: const EdgeInsets.all(0),
    //                                                 icon: Icon(
    //                                                   isSelected ? FluentIcons.checkCircleOn : FluentIcons.checkCircleOff,
    //                                                   color: Colors.white,
    //                                                   size: height * 0.03,
    //                                                 ),
    //                                               ),
    //                                             );
    //                                           },
    //                                         ),
    //                                       ],
    //                                     )
    //                                   ],
    //                                 ),
    //                                 child: Container(
    //                                   alignment: Alignment.bottomCenter,
    //                                   padding: EdgeInsets.only(
    //                                     bottom: height * 0.005,
    //                                   ),
    //                                   decoration: BoxDecoration(
    //                                       gradient: LinearGradient(
    //                                           begin: FractionalOffset.center,
    //                                           end: FractionalOffset.bottomCenter,
    //                                           colors: [
    //                                             Colors.black.withOpacity(0.0),
    //                                             Colors.black.withOpacity(0.5),
    //                                             Colors.black,
    //                                           ],
    //                                           stops: const [0.0, 0.5, 1.0]
    //                                       )
    //                                   ),
    //                                   child: TextScroll(
    //                                     playlist.name,
    //                                     mode: TextScrollMode.bouncing,
    //                                     velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
    //                                     style: TextStyle(
    //                                       color: Colors.white,
    //                                       fontSize: normalSize,
    //                                       fontWeight: FontWeight.bold,
    //                                     ),
    //                                     pauseOnBounce: const Duration(seconds: 2),
    //                                     delayBefore: const Duration(seconds: 2),
    //                                     pauseBetween: const Duration(seconds: 2),
    //                                   ),
    //                                 ),
    //                               ),
    //                             ),
    //                           ],
    //                         ),
    //                       ),
    //
    //                     );
    //
    //                   },
    //                 );
    //               }
    //               else{
    //                 return const Center(
    //                   child: CircularProgressIndicator(
    //                     color: Colors.white,
    //                   ),
    //                 );
    //               }
    //             }
    //         ),
    //       ),
    //
    //     ],
    //   ),
    // );

  }

}