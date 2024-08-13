import 'package:collection/collection.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/utils/objectbox.g.dart';
import '../controller/controller.dart';
import '../domain/artist_type.dart';
import 'add_screen.dart';
import 'artist_screen.dart';
import 'image_widget.dart';

class Artists extends StatefulWidget{
  final Controller controller;
  const Artists({super.key, required this.controller});

  @override
  _ArtistsState createState() => _ArtistsState();
}


class _ArtistsState extends State<Artists>{
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var smallSize = height * 0.015;
    var query = widget.controller.artistBox.query().order(ArtistType_.name).build();
    return StreamBuilder<List<ArtistType>>(
      stream: widget.controller.artistBox.query().watch(triggerImmediately: true).map((query) => query.find()),
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
              ArtistType artist = ArtistType();
              if (index < query.find().length){
                artist = query.find()[index];
              }
              return index < query.find().length ?
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    //print(artist.name);
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ArtistScreen(controller: widget.controller, artist: artist)));
                  },
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(width * 0.01),
                        child: ImageWidget(
                          controller: widget.controller,
                          path: artist.songs.first.path,
                          heroTag: artist.name,
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
                                          builder: (context) => AddScreen(controller: widget.controller, songs: artist.songs)
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
                                  if(widget.controller.settings.playingSongsUnShuffled.equals(artist.songs) == false){
                                    widget.controller.updatePlaying(artist.songs, 0);
                                  }
                                  widget.controller.indexChange(artist.songs.first);
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
                        artist.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
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