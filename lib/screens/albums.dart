import 'dart:async';

import 'package:flutter/material.dart';
import 'package:musicplayer/components/custom_tiling/grid_component.dart';
import 'package:musicplayer/entities/album.dart';
import 'package:musicplayer/providers/albums_provider.dart';
import 'package:musicplayer/providers/app_state_provider.dart';
import 'package:musicplayer/providers/audio_provider.dart';
import 'package:musicplayer/screens/album_screen.dart';
import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
import 'package:provider/provider.dart';


class Albums extends StatefulWidget{
  static Route<dynamic> route() {
    return PageRouteBuilder(
      settings: const RouteSettings(name: '/albums'),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Albums();
      },
    );
  }
  const Albums({super.key});

  @override
  State<Albums> createState() => _AlbumsState();
}


class _AlbumsState extends State<Albums>{
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
        child: Consumer<AlbumProvider>(
          builder: (_, albumProvider, __) {
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
                              albumProvider.setQuery(value);
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
                                albumProvider.setSortField(value);
                              },
                              tooltip: "Sort by",
                              itemBuilder: (context) => [
                                PopupMenuItem(value: "Name", child: Text("Name")),
                                PopupMenuItem(value: "Duration", child: Text("Duration")),
                                PopupMenuItem(value: "Number of Songs", child: Text("Number of Songs")),
                              ],
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text(
                                  albumProvider.sortField,
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
                              icon: Icon(albumProvider.isAscending ? FluentIcons.sortAscending : FluentIcons.sortDescending),
                              onPressed: () {
                                albumProvider.setFlag(!albumProvider.isAscending);
                                debugPrint("Sort order set to ${albumProvider.isAscending}");
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
                      future: albumProvider.albumsFuture,
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
                                isSelected: (entity) {
                                  // This is a placeholder
                                  return false;
                                },
                                onTap: (entity) async {
                                  debugPrint("tapped ${entity.name}");
                                  debugPrint("Entity type: ${entity.runtimeType}");
                                  if (entity is Album) {
                                    // Navigate to album page
                                    debugPrint("Songs in album: ${entity.songs.length}");
                                    var appStateProvider = Provider.of<AppStateProvider>(context, listen: false);
                                    appStateProvider.navigatorKey.currentState!.push(AlbumScreen.route(album: entity));
                                  } else {
                                    debugPrint("Entity is not an Album");
                                  }
                                },
                                onLongPress: (entity) {
                                  debugPrint("long pressed ${entity.name}");
                                },
                                buildLeftAction: (entity) => IconButton(
                                  icon: Icon(FluentIcons.play, color: Colors.white, size: height * 0.025),
                                  onPressed: () async {
                                    debugPrint("Playing album ${entity.name}");
                                    if (entity is! Album) {
                                      debugPrint("Entity is not an Album");
                                      return;
                                    }
                                    Album album = entity;
                                    album.songs.sort((a, b) => a.trackNumber.compareTo(b.trackNumber));
                                    List<String> songPaths = album.songs.map((e) => e.path).toList();
                                    var audioProvider = Provider.of<AudioProvider>(context, listen: false);
                                    audioProvider.setQueue(songPaths);
                                    await audioProvider.setCurrentIndex(album.songs.first.path);
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