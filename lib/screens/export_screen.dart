import 'dart:ui';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/screens/image_widget.dart';
import 'package:musicplayer/utils/hover_widget/stack_hover_widget.dart';
import 'package:musicplayer/repository/objectbox.g.dart';
import '../controller/data_controller.dart';
import '../controller/settings_controller.dart';
import '../domain/playlist_type.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  _ExportScreenState createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  List<int> selected = [];
  @override
  Widget build(BuildContext context) {
    final dc = DataController();
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    //var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    var query = DataController.playlistBox.query().order(PlaylistType_.name).build();
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
                    print("Back");
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    FluentIcons.arrow_left_16_filled,
                    size: height * 0.02,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Choose one or more playlists to export:",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: normalSize,
                      fontWeight: FontWeight.bold
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                    onPressed: (){
                      print("Export");
                      for(int i in selected){
                        if(i == 0){
                          PlaylistType queuePlaylist = PlaylistType();
                          queuePlaylist.name = "Current Queue";
                          queuePlaylist.paths = SettingsController.queue;
                          dc.exportPlaylist(queuePlaylist);
                        }
                        else{
                          var playlist = query.find()[i-1];
                          dc.exportPlaylist(playlist);
                        }
                      }
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Export",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: normalSize
                      ),
                    )
                ),
              ],
            ),
            SizedBox(
              height: height * 0.8,
              child: GridView.builder(
                padding: EdgeInsets.all(width * 0.01),
                itemCount: query.find().length + 8,
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  childAspectRatio: 0.8275,
                  maxCrossAxisExtent: width * 0.125,
                  crossAxisSpacing: width * 0.0125,
                  mainAxisSpacing: width * 0.0125,
                ),
                itemBuilder: (BuildContext context, int index) {
                  PlaylistType playlist = PlaylistType();
                  if(index > 0 && index <= query.find().length){
                    playlist = query.find()[index-1];
                  }
                  return index <= query.find().length ?
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        print("Tapped on $index");
                        setState(() {
                          selected.contains(index) ? selected.remove(index) : selected.add(index);
                        });
                      },
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(width * 0.01),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                if(index == 0)
                                  AspectRatio(
                                    aspectRatio: 1.0,
                                    child: StackHoverWidget(
                                      bottomWidget: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.black,
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: Image.asset("assets/current_queue.png").image,
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
                                  )
                                else
                                  ImageWidget(
                                    path: playlist.paths.first,
                                  ),
                                if(selected.contains(index))
                                  BackdropFilter(
                                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                    child: Container(
                                      alignment: Alignment.center,
                                      child: Icon(
                                        FluentIcons.checkmark_16_filled,
                                        size: height * 0.1,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),

                              ],
                            ),

                          ),
                          SizedBox(
                            height: height * 0.004,
                          ),
                          Text(
                            index == 0 ? "Current Queue" : playlist.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: smallSize,
                                fontWeight: FontWeight.normal
                            ),
                          )


                        ],
                      ),
                    ),
                  ) : SizedBox(
                    width: width * 0.125,
                    height: width * 0.125,
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