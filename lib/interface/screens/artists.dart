import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/controller/data_controller.dart';
import 'package:musicplayer/controller/settings_controller.dart';
import '../../controller/app_audio_handler.dart';
import '../../domain/artist_type.dart';
import '../../utils/fluenticons/fluenticons.dart';
import '../../utils/text_scroll/text_scroll.dart';
import '../widgets/image_widget.dart';

class Artists extends StatefulWidget{
  const Artists({super.key});

  @override
  State<Artists> createState() => _ArtistsState();
}


class _ArtistsState extends State<Artists>{
  FocusNode searchNode = FocusNode();

  Timer? _debounce;

  late Future<List<ArtistType>> artistsFuture;

  @override
  void initState(){
    super.initState();
    artistsFuture = DataController.getArtists('');
  }

  _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        artistsFuture = DataController.getArtists(query);
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
              future: artistsFuture,
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
                          "Error loading artists",
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
                      child: Text("No artists found.", style: TextStyle(color: Colors.white, fontSize: smallSize),),
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
                      maxCrossAxisExtent: width * 0.125,
                      crossAxisSpacing: width * 0.0125,
                      mainAxisSpacing: width * 0.0125,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      ArtistType artist = snapshot.data![index];
                      // print(artist.name);
                      return MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () {
                            //debugPrint(artist.name);
                            Navigator.pushNamed(context, '/artist', arguments: artist);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(width * 0.01),
                            child: ImageWidget(
                              path: artist.songs.first.path,
                              heroTag: artist.name,
                              hoveredChild: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: width * 0.035,
                                        height: width * 0.035,
                                        child: IconButton(
                                          onPressed: (){
                                            debugPrint("Add $index");
                                            Navigator.pushNamed(context, '/add', arguments: artist.songs);
                                          },
                                          padding: const EdgeInsets.all(0),
                                          icon: Icon(
                                            FluentIcons.addSingle,
                                            color: Colors.white,
                                            size: height * 0.035,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.035,
                                        height: width * 0.035,
                                        child: IconButton(
                                          onPressed: (){
                                            debugPrint("Play Next: $index");
                                            dc.addNextToQueue(artist.songs.map((e) => e.path).toList());
                                          },
                                          padding: const EdgeInsets.all(0),
                                          icon: Icon(
                                            FluentIcons.playNext2,
                                            color: Colors.white,
                                            size: height * 0.03,
                                          ),
                                        ),
                                      ),
                                    ],
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
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: width * 0.035,
                                        height: width * 0.035,
                                        child: IconButton(
                                          onPressed: () async {
                                            var songPaths = artist.songs.map((e) => e.path).toList();
                                            if(SettingsController.queue.equals(songPaths) == false){
                                              dc.updatePlaying(songPaths, 0);
                                            }
                                            SettingsController.index = SettingsController.currentQueue.indexOf(artist.songs.first.path);
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
                                      ValueListenableBuilder(
                                        valueListenable: DataController.selectedPaths,
                                        builder: (context, value, child){
                                          bool isSelected = true;
                                          for (var path in artist.songs.map((e) => e.path)){
                                            if (!DataController.selected.contains(path)){
                                              isSelected = false;
                                              break;
                                            }
                                          }
                                          return SizedBox(
                                            width: width * 0.035,
                                            height: width * 0.035,
                                            child: IconButton(
                                              onPressed: (){
                                                debugPrint("Select $index");
                                                if (isSelected){
                                                  DataController.selected = List.from(DataController.selected)..removeWhere((element) => artist.songs.map((e) => e.path).contains(element));
                                                  return;
                                                }
                                                DataController.selected = List.from(DataController.selected)..addAll(artist.songs.map((e) => e.path));
                                              },
                                              padding: const EdgeInsets.all(0),
                                              icon: Icon(
                                                isSelected ? FluentIcons.checkCircleOn : FluentIcons.checkCircleOff,
                                                color: Colors.white,
                                                size: height * 0.03,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              child: Container(
                                alignment: Alignment.bottomCenter,
                                padding: EdgeInsets.only(
                                  bottom: height * 0.005,
                                ),
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                        begin: FractionalOffset.center,
                                        end: FractionalOffset.bottomCenter,
                                        colors: [
                                          Colors.black.withOpacity(0.0),
                                          Colors.black.withOpacity(0.5),
                                          Colors.black,
                                        ],
                                        stops: const [0.0, 0.5, 1.0]
                                    )
                                ),
                                child: TextScroll(
                                  artist.name,
                                  mode: TextScrollMode.bouncing,
                                  velocity: const Velocity(pixelsPerSecond: Offset(20, 0)),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: normalSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  pauseOnBounce: const Duration(seconds: 2),
                                  delayBefore: const Duration(seconds: 2),
                                  pauseBetween: const Duration(seconds: 2),
                                ),
                              ),
                            ),
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