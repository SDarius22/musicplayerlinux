import 'package:collection/collection.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/domain/album_type.dart';
import 'package:musicplayer/screens/add_screen.dart';
import 'package:musicplayer/screens/album_screen.dart';
import '../controller/controller.dart';
import '../utils/objectbox.g.dart';
import 'image_widget.dart';


class Albums extends StatefulWidget{
  final Controller controller;
  const Albums({super.key, required this.controller});

  @override
  _AlbumsState createState() => _AlbumsState();
}


class _AlbumsState extends State<Albums>{

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    // var boldSize = height * 0.025;
    // var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    var query = widget.controller.albumBox.query().order(AlbumType_.name).build();
    return StreamBuilder<List<AlbumType>>(
      stream: widget.controller.albumBox.query().watch(triggerImmediately: true).map((query) => query.find()),
      builder: (context, snapshot){
        if(snapshot.hasData){
          return GridView.builder(
            padding: EdgeInsets.all(width * 0.01),
            itemCount: query.find().length + 7,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              childAspectRatio: 0.825,
              maxCrossAxisExtent: width * 0.125,
              crossAxisSpacing: width * 0.0125,
              //mainAxisSpacing: width * 0.01,
            ),
            itemBuilder: (BuildContext context, int index) {
              AlbumType album = AlbumType();
              if (index < query.find().length){
                album = query.find()[index];
              }
              return index < query.find().length?
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation1, animation2) => AlbumWidget(controller: widget.controller, album: album),
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
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(width * 0.01),
                        child: ImageWidget(
                          controller: widget.controller,
                          path: album.songs.first.path,
                          heroTag: album.name,
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
                                        pageBuilder: (context, animation1, animation2) => AddScreen(controller: widget.controller, songs: album.songs),
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
                              Icon(
                                FluentIcons.open_16_filled,
                                size: height * 0.1,
                                color: Colors.white,
                              ),
                              IconButton(
                                onPressed: () async {
                                  if(widget.controller.settings.playingSongsUnShuffled.equals(album.songs) == false){
                                    widget.controller.updatePlaying(album.songs);
                                  }
                                  widget.controller.indexChange(album.songs.first);
                                  await widget.controller.playSong();
                                },
                                padding: const EdgeInsets.all(0),
                                icon: Icon(
                                  FluentIcons.play_12_filled,
                                  color: Colors.white,
                                  size: height * 0.035,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        height: width * 0.0025,
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