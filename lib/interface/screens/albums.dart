import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/controller/data_controller.dart';
import 'package:musicplayer/controller/settings_controller.dart';
import 'package:musicplayer/domain/album_type.dart';
import 'package:musicplayer/interface/screens/add_screen.dart';
import 'package:musicplayer/interface/screens/album_screen.dart';
import '../../controller/app_audio_handler.dart';
import '../../utils/fluenticons/fluenticons.dart';
import '../widgets/image_widget.dart';


class Albums extends StatefulWidget{
  const Albums({super.key});

  @override
  State<Albums> createState() => _AlbumsState();
}


class _AlbumsState extends State<Albums>{
  FocusNode searchNode = FocusNode();

  Timer? _debounce;

  late Future<List<AlbumType>> albumsFuture;

  @override
  void initState(){
    super.initState();
    albumsFuture = DataController.getAlbums('');
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        albumsFuture = DataController.getAlbums(query);
      });
    });
  }


  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    final dc = DataController();
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // var boldSize = height * 0.025;
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
              future: albumsFuture,
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
                          "Error loading albums",
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
                  if (snapshot.data!.isEmpty){
                    return Center(
                      child: Text("No albums found.", style: TextStyle(color: Colors.white, fontSize: smallSize),),
                    );
                  }
                  return GridView.builder(
                    padding: EdgeInsets.only(
                      left: width * 0.01,
                      right: width * 0.01,
                      top: height * 0.01,
                      bottom: width * 0.125,
                    ),
                    itemCount: snapshot.data!.length,
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      childAspectRatio: 0.825,
                      maxCrossAxisExtent: width * 0.125,
                      crossAxisSpacing: width * 0.0125,
                      //mainAxisSpacing: width * 0.01,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      AlbumType album = snapshot.data![index];
                      return  MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => AlbumScreen(album: album))
                            );
                          },
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(width * 0.01),
                                child: ImageWidget(
                                  path: album.songs.first.path,
                                  heroTag: album.name,
                                  buttons: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: width * 0.035,
                                        child: IconButton(
                                          onPressed: (){
                                            debugPrint("Add $index");
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => AddScreen(songs: album.songs)
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
                                      const Expanded(
                                        child: FittedBox(
                                          fit: BoxFit.fill,
                                          child: Icon(
                                            FluentIcons.open,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.035,
                                        child: IconButton(
                                          onPressed: () async {
                                            var songPaths = album.songs.map((e) => e.path).toList();
                                            if(SettingsController.queue.equals(songPaths) == false){
                                              dc.updatePlaying(songPaths, 0);
                                            }
                                            SettingsController.index = SettingsController.currentQueue.indexOf(album.songs.first.path);
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
                                height: width * 0.005,
                              ),
                              Text(
                                album.name,
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