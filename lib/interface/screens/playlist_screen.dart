import 'package:collection/collection.dart';
import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/utils/hover_widget/hover_container.dart';
import '../../controller/app_audio_handler.dart';
import '../../controller/data_controller.dart';
import '../../controller/settings_controller.dart';
import '../../controller/worker_controller.dart';
import '../../domain/song_type.dart';
import 'package:musicplayer/domain/playlist_type.dart';
import '../widgets/image_widget.dart';

class PlaylistScreen extends StatefulWidget {
  final PlaylistType playlist;
  const PlaylistScreen({super.key, required this.playlist});

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  ValueNotifier<bool> editMode = ValueNotifier<bool>(false);
  String featuredArtists = "";
  String duration = "0 seconds";
  ValueNotifier<bool> orderChanged = ValueNotifier<bool>(false);


  @override
  void initState() {
    int totalDuration = widget.playlist.duration;
    duration = " ${totalDuration ~/ 3600} hours, ${(totalDuration % 3600 ~/ 60)} minutes and ${(totalDuration % 60)} seconds";
    duration = duration.replaceAll(" 0 hours,", "");
    duration = duration.replaceAll(" 0 minutes and", "");

    List<Map<String, dynamic>> parsedArtists = widget.playlist.artistCount.map((entry) {
      List<String> parts = entry.split(' - ');
      String artist = parts[0];
      int count = int.parse(parts[1]);
      return {'artist': artist, 'count': count};
    }).toList();

    parsedArtists.sort((a, b) => b['count'].compareTo(a['count']));


    int totalArtists = parsedArtists.length;
    List topArtists = parsedArtists
        .take(3)
        .map((entry) => entry['artist'])
        .toList();

    if (totalArtists > 3) {
      int moreCount = totalArtists - 3;
      featuredArtists = '${topArtists.join(", ")} and $moreCount more';
    } else {
      featuredArtists = topArtists.join(", ");
    }
    if (featuredArtists == "") {
      featuredArtists = "Unknown";
    }

    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    final dc = DataController();
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var boldSize = height * 0.025;
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
        child: FutureBuilder(
          future: Future(() async {
            List<SongType> songs = [];
            for (var path in widget.playlist.paths) {
              var song = await DataController.getSong(path);
              songs.add(song);
            }
            return songs;
          }),
          builder: (contex, snapshot) {
            if (snapshot.hasData) {
              var songs = snapshot.data as List<SongType>;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          ValueListenableBuilder(
                              valueListenable: editMode,
                              builder: (context, value, child){
                                return Hero(
                                  tag: widget.playlist.name,
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    curve: Curves.easeInOut,
                                    height: height * 0.5,
                                    padding: EdgeInsets.only(
                                      bottom: height * 0.01,
                                    ),
                                    //color: Colors.red,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(width * 0.025),
                                      child: FutureBuilder(
                                        future: WorkerController.getImage(widget.playlist.paths.first),
                                        builder: (context, snapshot) {
                                          return AspectRatio(
                                            aspectRatio: 1.0,
                                            child: snapshot.hasData?
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.black,
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: Image.memory(snapshot.data!).image,
                                                ),
                                              ),
                                            ) :
                                            Container(
                                              decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: Image.asset('assets/bg.png', fit: BoxFit.cover,).image,
                                                  )
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                  ),
                                );

                              }
                          ),

                          ValueListenableBuilder(
                            valueListenable: editMode,
                            builder: (context, value, child){
                              return AnimatedSwitcher(
                                duration: const Duration(milliseconds: 500),
                                child: value == false ?
                                Text(
                                  widget.playlist.name,
                                  key: const ValueKey("Playlist Name"),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: boldSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ) :
                                SizedBox(
                                    key: const ValueKey("Playlist Name Edit"),
                                    width: width * 0.2,
                                    child: TextFormField(
                                      initialValue: widget.playlist.name,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        contentPadding: EdgeInsets.only(
                                          top: height * 0.008,
                                          bottom: height * 0.008,
                                          left: width * 0.01,
                                          right: width * 0.01,
                                        ),
                                        hintText: "Playlist Name",
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: normalSize,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(width * 0.005),
                                        ),
                                      ),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: normalSize,
                                      ),
                                      onChanged: (value){
                                        widget.playlist.name = value;
                                      },
                                    )
                                ),

                              );
                            },
                          ),

                          SizedBox(
                            height: height * 0.005,
                          ),
                          Text(
                            featuredArtists,
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
                            duration,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: smallSize,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          SizedBox(
                            height: height * 0.005,
                          ),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    if(SettingsController.queue.equals(widget.playlist.paths) == false){
                                      dc.updatePlaying(widget.playlist.paths, 0);
                                    }
                                    SettingsController.index = SettingsController.currentQueue.indexOf(widget.playlist.paths.first);
                                    await AppAudioHandler.play();
                                  },
                                  icon: Icon(
                                    FluentIcons.play,
                                    color: Colors.white,
                                    size: height * 0.025,
                                  ),
                                ),

                                IconButton(
                                  onPressed: (){
                                    debugPrint("Add ${widget.playlist.name}");
                                    Navigator.pushNamed(context, '/add', arguments: songs);
                                  },
                                  icon: Icon(
                                    FluentIcons.add,
                                    color: Colors.white,
                                    size: height * 0.025,
                                  ),
                                ),
                                if (widget.playlist.indestructible == false)
                                IconButton(
                                  onPressed: () {
                                    debugPrint("Delete ${widget.playlist.name}");
                                    dc.deletePlaylist(widget.playlist);
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(
                                    FluentIcons.trash,
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
                      left: width * 0.02,
                      top: height * 0.1,
                      bottom: height * 0.2,
                    ),
                    child: ValueListenableBuilder(
                      valueListenable: editMode,
                      builder: (context, value, child){
                        return AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          reverseDuration: const Duration(milliseconds: 500),
                          child: value == false ?
                          ListView.builder(
                            key: const ValueKey("Normal List"),
                            itemCount:  songs.length,
                            itemBuilder: (context, int index) {
                              //debugPrint("Building ${widget.playlist. songs.value[widget.playlist.order[index]].title}");
                              SongType song =  songs[index];
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                                height: height * 0.125,
                                padding: EdgeInsets.only(
                                  right: width * 0.01,
                                ),
                                child: MouseRegion(
                                  cursor: SystemMouseCursors.click,
                                  child: GestureDetector(
                                    behavior: HitTestBehavior.translucent,
                                    onTap: () async {
                                      if(SettingsController.queue.equals(widget.playlist.paths) == false){
                                        dc.updatePlaying(widget.playlist.paths, index);
                                      }
                                      SettingsController.index = SettingsController.currentQueue.indexOf(song.path);
                                      await AppAudioHandler.play();
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(width * 0.01),
                                      child: HoverContainer(
                                        hoverColor: const Color(0xFF242424),
                                        normalColor: const Color(0xFF0E0E0E),
                                        padding: EdgeInsets.only(
                                          left: width * 0.0075,
                                          right: width * 0.025,
                                          top: height * 0.0075,
                                          bottom: height * 0.0075,
                                        ),
                                        height: height * 0.125,
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(width * 0.01),
                                              child: ImageWidget(
                                                path: song.path,
                                                heroTag: song.path,
                                              ),
                                            ),
                                            SizedBox(
                                              width: width * 0.01,
                                            ),
                                            Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      song.title.toString().length > 60 ? "${song.title.toString().substring(0, 60)}..." : song.title.toString(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: normalSize,
                                                      )
                                                  ),
                                                  SizedBox(
                                                    height: height * 0.005,
                                                  ),
                                                  Text(
                                                      song.artists.toString().length > 60 ? "${song.artists.toString().substring(0, 60)}..." : song.artists.toString(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: smallSize,
                                                      )
                                                  ),
                                                ]
                                            ),
                                            const Spacer(),
                                            Text(
                                                song.duration == 0 ? "??:??" : "${song.duration ~/ 60}:${(song.duration % 60).toString().padLeft(2, '0')}",
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
                                ),
                              );
                            },
                          ) :
                          ValueListenableBuilder(
                              valueListenable: orderChanged,
                              builder: (context, value2, child){
                                return ReorderableListView.builder(
                                  key: const ValueKey("Edit List"),
                                  padding: EdgeInsets.only(
                                    right: width * 0.01,
                                  ),
                                  itemBuilder: (context, int index) {
                                    //debugPrint("Building ${widget.playlist. songs.value[widget.playlist.order[index]].title}");
                                    SongType song =  songs[index];
                                    return AnimatedContainer(
                                      key: Key('$index'),
                                      duration: const Duration(milliseconds: 500),
                                      curve: Curves.easeInOut,
                                      height: height * 0.125,
                                      child: Container(
                                        padding: EdgeInsets.only(
                                          left: width * 0.0075,
                                          right: width * 0.025,
                                          top: height * 0.0075,
                                          bottom: height * 0.0075,
                                        ),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(width * 0.01),
                                          color: const Color(0xFF0E0E0E),
                                        ),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                                borderRadius: BorderRadius.circular(width * 0.01),
                                                child: ImageWidget(
                                                  path: song.path,
                                                  heroTag: song.path,
                                                  hoveredChild: IconButton(
                                                    onPressed: (){
                                                      widget.playlist.paths.removeAt(index);
                                                      orderChanged.value = !orderChanged.value;
                                                    },
                                                    icon: Icon(
                                                      FluentIcons.trash,
                                                      color: Colors.white,
                                                      size: height * 0.02,
                                                    ),

                                                  ),
                                                )
                                            ),
                                            SizedBox(
                                              width: width * 0.01,
                                            ),
                                            Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                      song.title.toString().length > 60 ? "${song.title.toString().substring(0, 60)}..." : song.title.toString(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: normalSize,
                                                      )
                                                  ),
                                                  SizedBox(
                                                    height: height * 0.001,
                                                  ),
                                                  Text(song.artists.toString().length > 60 ? "${song.artists.toString().substring(0, 60)}..." : song.artists.toString(),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: smallSize,
                                                      )
                                                  ),
                                                ]
                                            ),
                                            const Spacer(),
                                            Text(
                                                song.duration == 0 ? "??:??" : "${song.duration ~/ 60}:${(song.duration % 60).toString().padLeft(2, '0')}",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: normalSize,
                                                )
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  itemCount: widget.playlist.paths.length,
                                  onReorder: (int oldIndex, int newIndex) {
                                    if (oldIndex < newIndex) {
                                      newIndex -= 1;
                                    }
                                    var temp = widget.playlist.paths.removeAt(oldIndex);
                                    widget.playlist.paths.insert(newIndex, temp);
                                    DataController.playlistBox.put(widget.playlist);
                                    orderChanged.value = !orderChanged.value;
                                  },
                                );
                              }
                          ),

                        );
                      },
                    ),
                  ),
                  if (widget.playlist.indestructible == false)
                  ValueListenableBuilder(
                      valueListenable: editMode,
                      builder: (context, value, child){
                        return IconButton(
                          onPressed: (){
                            debugPrint("Edit ${widget.playlist.name}");
                            if(editMode.value == false){
                              editMode.value = true;
                            }
                            else{
                              editMode.value = false;
                              DataController.playlistBox.put(widget.playlist);
                            }
                          },
                          icon: Icon(
                            value ? FluentIcons.editOff : FluentIcons.editOn,
                            size: height * 0.02,
                            color: Colors.white,
                          ),
                        );
                      }
                  ),

                ],
              );
            }
            else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            }
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        ),
      ),
    );
  }
}