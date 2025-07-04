import 'package:musicplayer/components/custom_tiling/grid_component.dart';
import 'package:musicplayer/entities/album.dart';
import 'package:musicplayer/entities/song.dart';
import 'package:musicplayer/providers/albums_provider.dart';
import 'package:musicplayer/providers/app_state_provider.dart';
import 'package:musicplayer/providers/audio_provider.dart';
import 'package:musicplayer/providers/song_provider.dart';
import 'package:musicplayer/screens/add_screen.dart';
import 'package:musicplayer/screens/album_screen.dart';
import 'package:musicplayer/screens/track_screen.dart';
import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:provider/provider.dart';

class Tracks extends StatefulWidget{
  static Route<dynamic> route() {
    return PageRouteBuilder(
      settings: const RouteSettings(name: '/songs'),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Tracks();
      },
    );
  }

  const Tracks({super.key});

  @override
  State<Tracks> createState() => _TracksState();
}


class _TracksState extends State<Tracks>{
  ValueNotifier<List<Song>> selected = ValueNotifier<List<Song>>([]);
  FocusNode searchNode = FocusNode();
  Timer? _debounce;
  final TextEditingController _controller = TextEditingController();

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

    return Scaffold(
      body: Container(
          padding: EdgeInsets.only(
              top: height * 0.02,
              left: width * 0.01,
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
                          Expanded(
                            child: TextFormField(
                              controller: _controller,
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
                                labelText: 'Search',
                                suffixIcon: IconButton(
                                  onPressed: () {
                                    debugPrint("Clear search");
                                    _controller.clear();
                                    songProvider.setQuery('');
                                    searchNode.unfocus();
                                  },
                                  icon: Icon(
                                    FluentIcons.trash,
                                    color: Colors.white,
                                    size: height * 0.03,
                                  ),
                                ),
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
                                  sliver: ValueListenableBuilder(
                                    valueListenable: selected,
                                    builder: (context, value, child) {
                                      return GridComponent(
                                        items: snapshot.data ?? [],
                                        isSelected: (entity) {
                                          Song song = entity as Song;
                                          return selected.value.contains(song);
                                        },
                                        onTap: (entity) async {
                                          debugPrint("tapped ${entity.name}");
                                          Song song = entity as Song;

                                          if (selected.value.isNotEmpty) {
                                            if (selected.value.contains(song)) {
                                              selected.value = List<Song>.from(selected.value)..remove(song);
                                            } else {
                                              selected.value = List<Song>.from(selected.value)..add(song);
                                            }
                                            return;
                                          }

                                          var audioProvider = Provider.of<AudioProvider>(context, listen: false);
                                          try {
                                            if (audioProvider.currentSong.path != song.path) {
                                              List<String> songPaths = (snapshot.data as List<Song>).map((e) => e.path).toList();
                                              audioProvider.setQueue(songPaths);
                                              await audioProvider.setCurrentIndex(song.path);
                                            }
                                            else {
                                              if (audioProvider.playingNotifier.value == true) {
                                                await audioProvider.pause();
                                              }
                                              else {
                                                await audioProvider.play();
                                              }
                                            }
                                          }
                                          catch (e) {
                                            debugPrint(e.toString());
                                            List<String> songPaths = (snapshot.data as List<Song>).map((e) => e.path).toList();
                                            audioProvider.setQueue(songPaths);
                                            await audioProvider.setCurrentIndex(song.path);
                                          }
                                        },
                                        onLongPress: (entity) {
                                          debugPrint("long pressed ${entity.name}");
                                          Song song = entity as Song;
                                          if (selected.value.contains(song)) {
                                            selected.value = List<Song>.from(selected.value)..remove(song);
                                          } else {
                                            selected.value = List<Song>.from(selected.value)..add(song);
                                          }
                                        },
                                        buildLeftAction: (entity) {
                                          if (selected.value.contains(entity)) {
                                            return SizedBox.shrink();
                                          }
                                          return IconButton(
                                            tooltip: "Go to Album",
                                            onPressed: (){
                                              Song song = entity as Song;
                                              var albumProvider = Provider.of<AlbumProvider>(context, listen: false);
                                              Album? album = albumProvider.getAlbum(song.album);
                                              if (album == null) {
                                                debugPrint("Album not found for song: ${song.album}");
                                                return;
                                              }
                                              Navigator.push(
                                                context,
                                                AlbumScreen.route(album: album),
                                              );
                                            },
                                            padding: const EdgeInsets.all(0),
                                            icon: Icon(
                                              FluentIcons.album,
                                              color: Colors.white,
                                              size: height * 0.03,
                                            ),
                                          );
                                        },
                                        buildMainAction: (entity) {
                                          if (selected.value.contains(entity)) {
                                            return Icon(
                                              FluentIcons.checkCircleOn,
                                              color: Colors.white,
                                            );
                                          }
                                          if (selected.value.isNotEmpty) {
                                            return Icon(
                                              FluentIcons.checkCircleOff,
                                              color: Colors.white,
                                            );
                                          }
                                          return Consumer<AudioProvider>(
                                            builder: (_, audioProvider, __) {
                                              Song song = entity as Song;
                                              return ValueListenableBuilder(
                                                valueListenable: audioProvider.playingNotifier,
                                                builder: (context, isPlaying, child) {
                                                  return Icon(
                                                    audioProvider.currentSong.path == song.path && audioProvider.playingNotifier.value == true ?
                                                    FluentIcons.pause : FluentIcons.play,
                                                    color: Colors.white,
                                                  );
                                                },

                                              );
                                            },
                                          );
                                        },
                                        buildRightAction: (entity) {
                                          if (selected.value.contains(entity)) {
                                            return SizedBox.shrink();
                                          }
                                          return PopupMenuButton<String>(
                                            icon: Icon(
                                              FluentIcons.moreVertical,
                                              color: Colors.white,
                                              size: height * 0.03,
                                            ),
                                            onSelected: (String value){
                                              switch(value){
                                                case 'add':
                                                  var appState = Provider.of<AppStateProvider>(context, listen: false);
                                                  appState.navigatorKey.currentState?.push(AddScreen.route(songs: [entity as Song]));
                                                  break;
                                                case 'playNext':
                                                  var audioProvider = Provider.of<AudioProvider>(context, listen: false);
                                                  audioProvider.addNextToQueue((entity as Song).path);
                                                  break;
                                                case 'select':
                                                  debugPrint("Select ${entity.name}");
                                                  Song song = entity as Song;
                                                  if (selected.value.contains(entity)) {
                                                    selected.value = List<Song>.from(selected.value)..remove(song);
                                                  } else {
                                                    selected.value = List<Song>.from(selected.value)..add(song);
                                                  }
                                                  break;
                                                case 'details':
                                                  debugPrint("Details ${entity.name}");
                                                  var appState = Provider.of<AppStateProvider>(context, listen: false);
                                                  appState.navigatorKey.currentState?.push(TrackScreen.route(song: entity as Song));
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
                                                const PopupMenuItem<String>(
                                                  value: 'details',
                                                  child: Text("Track Details"),
                                                ),
                                              ];
                                            },
                                          );
                                        },
                                      );
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
              }
          )
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterFloat,
      floatingActionButton: ValueListenableBuilder(
        valueListenable: selected,
        builder: (context, value, child) {
          return Visibility(
            visible: value.isNotEmpty,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.1,
              height: MediaQuery.of(context).size.height * 0.05,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.1,
              ),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(30),
              ),
              foregroundDecoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextButton.icon(
                      icon: Icon(FluentIcons.add, color: Colors.white, size: MediaQuery.of(context).size.height * 0.02,),
                      label: Text(
                        "Add",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: normalSize,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      onPressed: () {
                        debugPrint("Add button pressed");
                        if (selected.value.isEmpty) {
                          return;
                        }
                        var appState = Provider.of<AppStateProvider>(context, listen: false);
                        appState.navigatorKey.currentState?.push(
                          AddScreen.route(songs: selected.value),
                        ).then((value) {
                          selected.value = [];
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              bottomLeft: Radius.circular(30),
                            )
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 1,
                    height: MediaQuery.of(context).size.height * 0.05,
                    color: Colors.grey,
                  ),
                  IconButton(
                    onPressed: () {
                      debugPrint("Delete button pressed");
                      if (selected.value.isEmpty) {
                        return;
                      }
                      selected.value = [];
                    },
                    icon: Icon(
                      FluentIcons.trash,
                      color: Colors.white,
                      size: MediaQuery.of(context).size.height * 0.02,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(30),
                            bottomRight: Radius.circular(30),
                          )
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

}