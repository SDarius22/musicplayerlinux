import 'package:collection/collection.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/utils/hover_widget/hover_container.dart';
import '../controller/audio_player_controller.dart';
import '../controller/data_controller.dart';
import '../controller/settings_controller.dart';
import '../domain/song_type.dart';
import 'package:musicplayer/domain/playlist_type.dart';
import '../repository/objectbox.g.dart';
import 'add_screen.dart';
import 'image_widget.dart';

class PlaylistScreen extends StatefulWidget {
  final PlaylistType playlist;
  const PlaylistScreen({super.key, required this.playlist});

  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  ValueNotifier<bool> editMode = ValueNotifier<bool>(false);
  String featuredArtists = "";
  String duration = "0 seconds";
  ValueNotifier<List<SongType>> songs = ValueNotifier<List<SongType>>([]);


  @override
  void initState() {
    for (int i = 0; i < widget.playlist.paths.length; i++){
      SongType song = DataController.songBox.query(SongType_.path.equals(widget.playlist.paths[i])).build().findFirst();
       songs.value.add(song);
    }
    int totalDuration = 0;
    for (int i = 0; i <  songs.value.length; i++){
      totalDuration +=  songs.value[i].duration;
    }
    duration = " ${totalDuration ~/ 3600} hours, ${(totalDuration % 3600 ~/ 60)} minutes and ${(totalDuration % 60)} seconds";
    duration = duration.replaceAll(" 0 hours,", "");
    duration = duration.replaceAll(" 0 minutes and", "");
    var artistMap = <String, int>{};
    for (int i = 0; i <  songs.value.length; i++){
      artistMap.containsKey( songs.value[i].artists) ? artistMap[ songs.value[i].artists] = artistMap[ songs.value[i].artists]! + 1 : artistMap[ songs.value[i].artists] = 1;
    }
    var sortedMap = artistMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    for (int i = 0; i < 3 && i < sortedMap.length; i++){
      featuredArtists += sortedMap[i].key;
      if(i != 2 && i != sortedMap.length - 1){
        featuredArtists += ", ";
      }
    }
    if(sortedMap.length > 3){
      featuredArtists += " and ${sortedMap.length - 3} more";
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              onPressed: (){
                print("Back");
                Navigator.pop(context);
              },
              icon: Icon(
                FluentIcons.arrow_left_16_filled,
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
                                child: ImageWidget(
                                  path: widget.playlist.paths.first,
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
                            },
                            icon: Icon(
                              FluentIcons.play_12_filled,
                              color: Colors.white,
                              size: height * 0.025,
                            ),
                          ),

                          IconButton(
                            onPressed: (){
                              print("Add ${widget.playlist.name}");
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddScreen(songs: songs.value)
                                  )
                              );
                            },
                            icon: Icon(
                              FluentIcons.add_12_filled,
                              color: Colors.white,
                              size: height * 0.025,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              print("Delete ${widget.playlist.name}");
                              dc.deletePlaylist(widget.playlist);
                              Navigator.pop(context);
                            },
                            icon: Icon(
                              FluentIcons.delete_12_filled,
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
                      itemCount:  songs.value.length,
                      itemBuilder: (context, int index) {
                        //print("Building ${widget.playlist. songs.value[widget.playlist.order[index]].title}");
                        SongType song =  songs.value[index];
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
                                SettingsController.index = SettingsController.currentQueue.indexOf(widget.playlist.paths[index]);
                                await AudioPlayerController.playSong();
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
                        valueListenable: songs,
                        builder: (context, value2, child){
                          return ReorderableListView.builder(
                            key: const ValueKey("Edit List"),
                            padding: EdgeInsets.only(
                              right: width * 0.01,
                            ),
                            itemBuilder: (context, int index) {
                              //print("Building ${widget.playlist. songs.value[widget.playlist.order[index]].title}");
                              SongType song =  songs.value[index];
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
                                            buttons: IconButton(
                                              onPressed: (){
                                                songs.value.removeAt(index);
                                                songs.value = List.from(songs.value);
                                                widget.playlist.paths.removeAt(index);
                                              },
                                              icon: Icon(
                                                FluentIcons.delete_12_filled,
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
                              var temp2 =  songs.value.removeAt(oldIndex);
                              songs.value.insert(newIndex, temp2);
                              DataController.playlistBox.put(widget.playlist);
                            },
                          );
                        }
                    ),

                  );
                },
              ),
            ),
            ValueListenableBuilder(
                valueListenable: editMode,
                builder: (context, value, child){
                  return IconButton(
                    onPressed: (){
                      print("Edit ${widget.playlist.name}");
                      if(editMode.value == false){
                        editMode.value = true;
                      }
                      else{
                        editMode.value = false;
                        DataController.playlistBox.put(widget.playlist);
                      }
                    },
                    icon: Icon(
                      value ? FluentIcons.checkmark_12_filled : FluentIcons.edit_12_filled,
                      size: height * 0.02,
                      color: Colors.white,
                    ),
                  );
                }
            ),

          ],
        ),
      ),
    );
  }
}