import 'dart:async';

import 'package:musicplayer/components/custom_tiling/grid_component.dart';
import 'package:musicplayer/providers/app_state_provider.dart';
import 'package:musicplayer/providers/audio_provider.dart';
import 'package:musicplayer/providers/playlist_provider.dart';
import 'package:musicplayer/screens/playlist_screen.dart';
import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/entities/playlist.dart';
import 'package:provider/provider.dart';

class Playlists extends StatefulWidget{
  static Route<dynamic> route() {
    return PageRouteBuilder(
      settings: const RouteSettings(name: '/playlists'),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Playlists();
      },
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
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(
            top: height * 0.02,
            left: width * 0.01,
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
                              "Error loading playlists",
                              style: TextStyle(color: Colors.white, fontSize: smallSize),
                            ),
                          );
                        }
                        debugPrint("Playlists loaded: ${snapshot.data?.length ?? 0}");
                        return CustomScrollView(
                          slivers: [
                            SliverPadding(
                              padding: EdgeInsets.only(
                                left: width * 0.01,
                                right: width * 0.01,
                              ),
                              sliver: GridComponent(
                                items: snapshot.data ?? [],
                                isSelected: (entity) {
                                  // Placeholder for selection logic
                                  return false;
                                },
                                onTap: (entity) async {
                                  debugPrint("tapped ${entity.name}");
                                  debugPrint("Entity type: ${entity.runtimeType}");
                                  if (entity is Playlist) {
                                    // Navigate to album page
                                    debugPrint("Songs in playlist: ${entity.songs.length}");
                                    var appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
                                    appStateProvider.navigatorKey.currentState!.push(PlaylistScreen.route(playlist: entity));
                                  } else {
                                    debugPrint("Entity is not a Playlist");
                                  }
                                },
                                onLongPress: (entity) {
                                  debugPrint("long pressed ${entity.name}");
                                },
                                buildLeftAction: (entity) => IconButton(
                                  icon: Icon(FluentIcons.play, color: Colors.white, size: height * 0.025),
                                  onPressed: () async {
                                    debugPrint("Playing album ${entity.name}");
                                    if (entity is! Playlist) {
                                      debugPrint("Entity is not an Album");
                                      return;
                                    }
                                    Playlist playlist = entity;
                                    var audioProvider = Provider.of<AudioProvider>(context, listen: false);
                                    audioProvider.setQueue(playlist.pathsInOrder);
                                    await audioProvider.setCurrentIndex(playlist.pathsInOrder.first);
                                  },
                                ),
                                buildMainAction: (entity) => Icon(
                                  FluentIcons.open,
                                  color: Colors.white,
                                  size: height * 0.03,
                                ),
                                buildRightAction: (entity) => PopupMenuButton<String>(
                                  icon: Icon(
                                    FluentIcons.moreVertical,
                                    color: Colors.white,
                                    size: height * 0.03,
                                  ),
                                  onSelected: (String value){
                                    switch(value){
                                      case 'add':
                                      // debugPrint("Add $index");
                                      // Navigator.pushNamed(context, '/add', arguments: [song]);
                                        break;
                                      case 'playNext':
                                      //debugPrint("Play Next: $index");
                                      // dc.addNextToQueue([song.path]);
                                        break;
                                      case 'select':
                                      //debugPrint("Select $index");
                                      // if (DataController.selected.contains(song.path)){
                                      //   DataController.selected = List.from(DataController.selected)..remove(song.path);
                                      //   return;
                                      // }
                                      // DataController.selected = List.from(DataController.selected)..add(song.path);
                                        break;
                                    }
                                  },
                                  itemBuilder: (context){
                                    return [
                                      const PopupMenuItem<String>(
                                        value: 'add',
                                        child: Text("Add to Playlist"),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'playNext',
                                        child: Text("Play Next"),
                                      ),
                                      const PopupMenuItem<String>(
                                        value: 'select',
                                        child: Text("Select"),
                                      ),
                                    ];
                                  },
                                ),
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
      ),
    );
  }

}