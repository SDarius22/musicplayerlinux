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
    return GridView.builder(
      padding: EdgeInsets.only(
        left: width * 0.01,
        right: width * 0.01,
        top: height * 0.01,
        bottom: width * 0.125,
      ),
      itemCount: query.find().length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        childAspectRatio: 0.825,
        maxCrossAxisExtent: width * 0.125,
        crossAxisSpacing: width * 0.0125,
        //mainAxisSpacing: width * 0.01,
      ),
      itemBuilder: (BuildContext context, int index) {
        AlbumType album = query.find()[index];
        return  MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AlbumScreen(controller: widget.controller, album: album))
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
                                MaterialPageRoute(
                                    builder: (context) => AddScreen(controller: widget.controller, songs: album.songs)
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
                            var songPaths = album.songs.map((e) => e.path).toList();
                            if(widget.controller.settings.playingSongsUnShuffled.equals(songPaths) == false){
                              widget.controller.updatePlaying(songPaths, 0);
                            }
                            widget.controller.indexChange(songPaths.first);
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

}