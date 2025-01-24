import 'dart:async';
import 'dart:ui';
import 'package:collection/collection.dart';
import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/controller/data_controller.dart';
import 'package:musicplayer/interface/widgets/image_widget.dart';
import 'package:musicplayer/interface/screens/playlist_screen.dart';
import '../../controller/app_audio_handler.dart';
import '../../controller/settings_controller.dart';
import '../../domain/song_type.dart';
import '../../domain/playlist_type.dart';
import '../../utils/hover_widget/stack_hover_widget.dart';
import '../../repository/objectbox.g.dart';
import 'add_screen.dart';
import 'create_screen.dart';

class Playlists extends StatefulWidget{
  const Playlists({super.key});

  @override
  State<Playlists> createState() => _PlaylistsState();
}


class _PlaylistsState extends State<Playlists>{
  FocusNode searchNode = FocusNode();
  String value = '';

  Timer? _debounce;

  late Future<List<PlaylistType>> playlistsFuture;

  @override
  void initState(){
    super.initState();
    playlistsFuture = DataController.getPlaylists('');
    Stream<Query> query = DataController.playlistBox.query().watch(triggerImmediately: true);
    query.listen((event) {
      setState(() {
        playlistsFuture = DataController.getPlaylists(value);
      });
    });

  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        value = query;
        playlistsFuture = DataController.getPlaylists(query);
      });
    });
  }


  @override
  void dispose() {
    _debounce?.cancel();
    searchNode.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final dc = DataController();
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    return Column(
      children: [
        Container(
          height: height * 0.05,
          margin: EdgeInsets.only(
            left: width * 0.01,
            right: width * 0.01,
            bottom: height * 0.01,
          ),
          child: TextFormField(
            initialValue: '',
            focusNode: searchNode,
            onChanged: _onSearchChanged,
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
                labelText: 'Search', suffixIcon: Icon(FluentIcons.search, color: Colors.white, size: height * 0.02,)
            ),
          ),
        ),
        Expanded(
          child: FutureBuilder(
              future: playlistsFuture,
              builder: (context, snapshot){
                if(snapshot.hasError){
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FluentIcons.error,
                          size: height * 0.1,
                          color: Colors.red,
                        ),
                        Text(
                          "Error loading playlists",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: smallSize,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: (){
                            setState(() {});
                          },
                          child: Text(
                            "Retry",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: smallSize,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                else if(snapshot.hasData){
                  return GridView.builder(
                    padding: EdgeInsets.only(
                      left: width * 0.01,
                      right: width * 0.01,
                      top: height * 0.01,
                      bottom: width * 0.125,
                    ),
                    itemCount: snapshot.data!.length + 1,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      childAspectRatio: 0.825,
                      maxCrossAxisExtent: width * 0.125,
                      crossAxisSpacing: width * 0.0125,
                      //mainAxisSpacing: width * 0.0125,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      PlaylistType playlist = PlaylistType();
                      if (index > 0){
                        playlist = snapshot.data![index-1];
                      }
                      return index == 0 ?
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CreateScreen( name: value,)));
                          },
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(width * 0.01),
                                child: AspectRatio(
                                  aspectRatio: 1.0,
                                  child: StackHoverWidget(
                                    bottomWidget: Container(
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: Image.asset("assets/create_playlist.png").image,
                                          )
                                      ),
                                    ),
                                    topWidget: ClipRRect(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                        child: Container(
                                          color: Colors.black.withOpacity(0.3),
                                          alignment: Alignment.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: height * 0.004,
                              ),
                              Text(
                                "Create a new playlist",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    height: 1,
                                    color: Colors.white,
                                    fontSize: smallSize,
                                    fontWeight: FontWeight.normal
                                ),
                              )
                            ],
                          ),

                        ),

                      ) :
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            //debugPrint(playlist.name);
                            Navigator.push(context, MaterialPageRoute(builder: (context) => PlaylistScreen(playlist: playlist)));
                          },
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(width * 0.01),
                                child: ImageWidget(
                                  path: playlist.paths.isNotEmpty ? playlist.paths.first : '',
                                  heroTag: playlist.name,
                                  buttons: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: width * 0.035,
                                        child: IconButton(
                                          onPressed: (){
                                            debugPrint("Add $index");
                                            List<SongType> songs = [];
                                            for (var path in playlist.paths){
                                              songs.add(DataController.songBox.query(SongType_.path.equals(path)).build().findFirst());
                                            }
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => AddScreen(songs: songs)
                                                )
                                            );
                                          },
                                          padding: const EdgeInsets.all(0),
                                          icon: Icon(
                                            FluentIcons.add,
                                            color: Colors.white,
                                            size: height * 0.035,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: FittedBox(
                                          fit: BoxFit.fill,
                                          child: Icon(
                                            FluentIcons.open,
                                            size: height * 0.1,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.035,
                                        child: IconButton(
                                          onPressed: () async {
                                            if(SettingsController.queue.equals(playlist.paths) == false){
                                              dc.updatePlaying(playlist.paths, 0);
                                            }
                                            SettingsController.index = SettingsController.currentQueue.indexOf(playlist.paths.first);
                                           await AppAudioHandler.play();
                                          },
                                          padding: const EdgeInsets.all(0),
                                          icon: Icon(
                                            FluentIcons.play,
                                            color: Colors.white,
                                            size: height * 0.035,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: height * 0.005,
                              ),
                              Text(
                                playlist.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  height: 1,
                                  color: Colors.white,
                                  fontSize: smallSize,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),

                      );

                    },
                  );
                }
                else{
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }
              }
          ),
        ),

      ],
    );

  }

}