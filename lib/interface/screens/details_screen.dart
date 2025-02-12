import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/controller/settings_controller.dart';
import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
import 'package:musicplayer/utils/hover_widget/hover_container.dart';
import '../../controller/app_audio_handler.dart';
import '../../controller/data_controller.dart';
import '../../controller/worker_controller.dart';
import '../../domain/song_type.dart';
import '../widgets/image_widget.dart';

class DetailsScreen extends StatefulWidget {
  final SongType song;
  const DetailsScreen({super.key, required this.song});

  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  @override
  Widget build(BuildContext context) {
    final dc = DataController();
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var boldSize = height * 0.025;
    var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    return Container(
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
                  Hero(
                    tag: widget.song.path,
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
                          future: WorkerController.getImage(widget.song.path),
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
                  ),
                  SizedBox(
                    height: height * 0.01,
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: () async {
                            dc.updatePlaying([widget.song.path], 0);
                            SettingsController.index = SettingsController.currentQueue.indexOf(widget.song.path);
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
                            debugPrint("Add ${widget.song.title}");
                            Navigator.pushNamed(context, '/add', arguments: [widget.song]);
                          },
                          icon: Icon(
                            FluentIcons.add,
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
              top: height * 0.1,
              bottom: height * 0.2,
              left: width * 0.02,
            ),
            child: Text("TBD")
          ),
          SizedBox(
            width: width * 0.02,
          ),
        ],
      ),
    );
  }
}