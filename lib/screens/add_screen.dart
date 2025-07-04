import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/components/custom_tiling/grid_component.dart';
import 'package:musicplayer/providers/audio_provider.dart';
import 'package:musicplayer/providers/playlist_provider.dart';
import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
import 'package:musicplayer/entities/playlist.dart';
import 'package:musicplayer/entities/song.dart';
import 'package:provider/provider.dart';

class AddScreen extends StatefulWidget {
  static Route route({required List<Song> songs}) {
    return PageRouteBuilder(
      settings: const RouteSettings(name: '/add', arguments: List<Song>),
      pageBuilder: (context, animation, secondaryAnimation) {
        return AddScreen(songs: songs);
      },
    );
  }

  final List<Song> songs;
  const AddScreen({super.key, required this.songs});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  ValueNotifier<List<Playlist>> selected = ValueNotifier<List<Playlist>>([]);

  @override
  Widget build(BuildContext context) {
    //debugPrint(widget.songs.length);
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    //var boldSize = height * 0.025;
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                SizedBox(
                  width: width * 0.01,
                ),
                Text(
                  "Choose one or more playlists to add the selected songs to:",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: normalSize,
                      fontWeight: FontWeight.bold
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                    onPressed: (){
                      if (selected.value.isEmpty) {
                        BotToast.showText(
                          text: "Please select at least one playlist",
                        );
                        return;
                      }
                      debugPrint("Add to new playlist");
                      for(int i = 0; i < selected.value.length; i++){
                        Playlist playlist = selected.value[i];
                        if (playlist.indestructible && playlist.name == 'Current Queue') {
                          var audioProvider = Provider.of<AudioProvider>(context, listen: false);
                          audioProvider.addMultipleToQueue(widget.songs.map((song) => song.path).toList());
                        }
                        else {
                          var playlistProvider = Provider.of<PlaylistProvider>(context, listen: false);
                          playlistProvider.addSongsToPlaylist(playlist, widget.songs);
                        }
                      }
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Done",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: normalSize
                      ),
                    )
                ),

              ],
            ),
            Expanded(
              child: Consumer<PlaylistProvider>(
                builder: (_, playlistProvider, __){
                  return FutureBuilder(
                      future: Future(() => playlistProvider.getNormalPlaylists()),
                      builder: (context, snapshot) {
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
                        List<Playlist> items = snapshot.data ?? [];
                        Playlist queue = Playlist();
                        queue.name = "Current Queue";
                        var audioProvider = Provider.of<AudioProvider>(context, listen: false);
                        queue.pathsInOrder = audioProvider.queue;
                        queue.indestructible = true;
                        items.insert(0, queue);
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
                                      items: items,
                                      isSelected: (entity) {
                                        return selected.value.contains(entity as Playlist);
                                      },
                                      onTap: (entity) {
                                        debugPrint("Tapped on ${entity.name}");
                                        if (selected.value.contains(entity as Playlist)) {
                                          selected.value = List<Playlist>.from(selected.value)..remove(entity);
                                        } else {
                                          selected.value = List<Playlist>.from(selected.value)..add(entity);
                                        }
                                      },
                                      onLongPress: (entity) {
                                        debugPrint("Long pressed on ${entity.name}");
                                      },
                                    );
                                  },
                                ),
                              ),
                            ]
                        );
                      }
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}