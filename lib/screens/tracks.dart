import 'package:collection/collection.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/screens/add_screen.dart';
import 'package:musicplayer/screens/image_widget.dart';


import '../domain/metadata_type.dart';
import '../utils/objectbox.g.dart';
import '../controller/controller.dart';
import 'album_screen.dart';

class Tracks extends StatefulWidget{
  final Controller controller;
  const Tracks({super.key, required this.controller});

  @override
  _TracksState createState() => _TracksState();
}


class _TracksState extends State<Tracks>{
  int previousLength = 0;
  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var query = widget.controller.songBox.query().order(MetadataType_.title).build();
    // var boldSize = height * 0.025;
    // var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    return StreamBuilder<List<MetadataType>>(
      stream: widget.controller.songBox.query().order(MetadataType_.title).watch(triggerImmediately: true).map((query) => query.find()),
      builder: (context, snapshot){
        if(snapshot.hasData){
          return GridView.builder(
            padding: EdgeInsets.all(width * 0.01),
            itemCount: query.find().length + 7,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              childAspectRatio: 0.825,
              maxCrossAxisExtent: width * 0.125,
              crossAxisSpacing: width * 0.0125,
              mainAxisSpacing: width * 0.0125,
            ),
            itemBuilder: (BuildContext context, int index) {
              MetadataType song = MetadataType();
              if(index < query.find().length){
                song = query.find()[index];
              }
              return index < query.find().length?
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () async {
                    widget.controller.loadingNotifier.value = true;
                    //print("Playing ${widget.controller.indexNotifier.value}");
                    if (widget.controller.settings.playingSongs[widget.controller.indexNotifier.value].path != song.path) {
                      //print("path match");
                      if(widget.controller.settings.playingSongsUnShuffled.equals(query.find()) == false){
                        print("Updating playing songs");
                        widget.controller.updatePlaying(query.find());
                      }
                      await widget.controller.indexChange(song);
                    }
                    await widget.controller.playSong();
                    widget.controller.loadingNotifier.value = false;
                  },
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(width * 0.01),
                        child: ImageWidget(
                          controller: widget.controller,
                          path: song.path,
                          heroTag: "${song.path}+$index",
                          buttons: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: (){
                                  print("Add $index");
                                  Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation1, animation2) => AddScreen(controller: widget.controller, songs: [song]),
                                        transitionDuration: const Duration(milliseconds: 500),
                                        reverseTransitionDuration: const Duration(milliseconds: 500),
                                        transitionsBuilder: (context, animation1, animation2, child) {
                                          animation1 = CurvedAnimation(parent: animation1, curve: Curves.linear);
                                          return ScaleTransition(
                                            alignment: Alignment.center,
                                            scale: animation1,
                                            child: child,
                                          );
                                        },
                                      )
                                  );
                                },
                                padding: const EdgeInsets.all(0),
                                icon: Icon(
                                  FluentIcons.add_12_filled,
                                  color: Colors.white,
                                  size: height * 0.035,
                                ),
                              ),
                              ValueListenableBuilder(
                                valueListenable: widget.controller.playingNotifier,
                                builder: (context, value, child){
                                  return Icon(
                                    widget.controller.settings.playingSongs.isNotEmpty && widget.controller.settings.playingSongs[widget.controller.indexNotifier.value] == song && widget.controller.playingNotifier.value == true ?
                                    FluentIcons.pause_32_filled : FluentIcons.play_32_filled,
                                    size: height * 0.1,
                                    color: Colors.white,
                                  );
                                },
                              ),
                              IconButton(
                                onPressed: (){
                                  Navigator.push(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation1, animation2) => AlbumWidget(controller: widget.controller, album: widget.controller.albumBox.query(AlbumType_.name.equals(song.album)).build().find().first),
                                        transitionDuration: const Duration(milliseconds: 500),
                                        reverseTransitionDuration: const Duration(milliseconds: 500),
                                        transitionsBuilder: (context, animation1, animation2, child) {
                                          animation1 = CurvedAnimation(parent: animation1, curve: Curves.linear);
                                          return ScaleTransition(
                                            alignment: Alignment.center,
                                            scale: animation1,
                                            child: child,
                                          );
                                        },
                                      )
                                  );
                                },
                                padding: const EdgeInsets.all(0),
                                icon: Icon(
                                  FluentIcons.album_20_filled,
                                  color: Colors.white,
                                  size: height * 0.035,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: height * 0.004,
                      ),
                      ValueListenableBuilder(
                          valueListenable: widget.controller.indexNotifier,
                          builder: (context, value, child){
                            return Text(
                              song.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: widget.controller.settings.playingSongs.isNotEmpty && widget.controller.settings.playingSongs[widget.controller.indexNotifier.value] == song ? Colors.blue : Colors.white,
                                fontSize: smallSize,
                                fontWeight: FontWeight.normal,
                              ),
                            );
                          }
                      ),

                    ],
                  ),
                ),

              ) :
              SizedBox(
                height: width * 0.125,
                width: width * 0.125,
              );

            },
          );
        }
        else if(snapshot.hasError){
          return Center(
            child: Text(
              '${snapshot.error} occurred',
              style: const TextStyle(fontSize: 18),
            ),
          );
        }
        else if (snapshot.connectionState == ConnectionState.waiting){
          return const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          );
        }
        else{
          return const Center(
            child: Text(
              'No data',
              style: TextStyle(fontSize: 18),
            ),
          );
        }
      },
    );
  }

}