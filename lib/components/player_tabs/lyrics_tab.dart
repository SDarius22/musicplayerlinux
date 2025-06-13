import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:musicplayer/providers/audio_provider.dart';
import 'package:musicplayer/providers/slider_provider.dart';
import 'package:musicplayer/utils/lyric_reader/lyric_ui/lyric_ui.dart';
import 'package:musicplayer/utils/lyric_reader/lyric_ui/ui_netease.dart';
import 'package:musicplayer/utils/lyric_reader/lyrics_model_builder.dart';
import 'package:musicplayer/utils/lyric_reader/lyrics_reader_widget.dart';

import 'package:provider/provider.dart';

import '../../utils/fluenticons/fluenticons.dart' show FluentIcons;

class LyricsTab extends StatelessWidget {
  LyricsTab({super.key});

  final ScrollController itemScrollController = ScrollController();
  var lyricUI = UINetease(
      defaultTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      defaultExtTextStyle: const TextStyle(color: Colors.grey, fontSize: 16),
      otherMainTextStyle: const TextStyle(color: Colors.grey, fontSize: 20),
      bias : 0.5,
      lineGap : 5,
      inlineGap : 5,
      highlightColor: Colors.blue,
      lyricAlign : LyricAlign.CENTER,
      lyricBaseLine : LyricBaseLine.CENTER,
      highlight : false
  );


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    var normalSize = height * 0.02;

    lyricUI = UINetease(
        defaultTextStyle: TextStyle(color: Colors.white, fontSize: MediaQuery.of(context).size.height * 0.022),
        defaultExtTextStyle: TextStyle(color: Colors.grey, fontSize: MediaQuery.of(context).size.height * 0.020),
        otherMainTextStyle: TextStyle(color: Colors.grey, fontSize: MediaQuery.of(context).size.height * 0.020),
        bias : 0.5,
        lineGap : 5,
        inlineGap : 5,
        highlightColor: Colors.blue, // SettingsController.lightColorNotifier.value,
        lyricAlign : LyricAlign.CENTER,
        lyricBaseLine : LyricBaseLine.CENTER,
        highlight : false
    );

    return FutureBuilder(
      future: Future(() async {
        try {
          // List<String> lyrics = await DataController.getLyrics(SettingsController.currentSongPath);
          List<String> lyrics = ["No lyrics found", "No lyrics found"];
          return lyrics;
        } catch (e) {
          debugPrint(e.toString());
          return ["No lyrics found", "No lyrics found"];
        }
      }),
      builder: (context, snapshot){
        if(snapshot.hasData){
          String plainLyric = snapshot.data![0];
          var lyricModel = LyricsModelBuilder.create().bindLyricToMain(snapshot.data![1]).getModel();
          return Consumer<SliderProvider>(
            builder: (_, sliderProvider, __){
              return LyricsReader(
                model: lyricModel,
                position: sliderProvider.slider,
                lyricUi: lyricUI,
                playing: sliderProvider.playing,
                size: Size.infinite,
                padding: EdgeInsets.only(
                  right: width * 0.01,
                  left: width * 0.01,
                ),
                selectLineBuilder: (progress, confirm) {
                  return Row(
                    children: [
                      Icon(FluentIcons.play, color: Colors.blue), // SettingsController.lightColorNotifier.value),
                      Expanded(
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () async {
                              confirm.call();
                              sliderProvider.setSlider(progress);
                            },
                          ),
                        ),
                      ),
                      Text(
                        //progress.toString(),
                        "${progress ~/ 1000 ~/ 60}:${(progress ~/ 1000 % 60).toString().padLeft(2, '0')}",
                        style: TextStyle(color: Colors.blue, fontSize: normalSize), // SettingsController.lightColorNotifier.value, fontSize: normalSize
                      )
                    ],
                  );
                },
                emptyBuilder: () => plainLyric.contains("No lyrics") || plainLyric.contains("Searching")?
                Center(
                    child: Text(
                      plainLyric,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: normalSize,
                        fontWeight: FontWeight.normal,
                      ),
                    )
                ):
                ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    },
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Text(
                          plainLyric,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: normalSize,
                            fontWeight: FontWeight.normal,
                          ),
                        )
                    ),
                  ),
                ),

              );
            },
          );
        }
        else {
          return Center(
              child: Text(
                "Searching for lyrics...",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: normalSize,
                  fontWeight: FontWeight.normal,
                ),
              )
          );
        }
      }
    );
  }
}