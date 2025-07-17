import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:musicplayer/providers/audio_provider.dart';
import 'package:musicplayer/providers/lyrics_provider.dart';
import 'package:musicplayer/utils/lyric_reader/lyric_ui/lyric_ui.dart';
import 'package:musicplayer/utils/lyric_reader/lyric_ui/ui_netease.dart';
import 'package:musicplayer/utils/lyric_reader/lyrics_reader_widget.dart';
import 'package:musicplayer/utils/multivaluelistenablebuilder/mvlb.dart';
import 'package:provider/provider.dart';


class LyricsTab extends StatelessWidget {
  final bool oneLine;
  const LyricsTab({super.key, this.oneLine = false});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    var normalSize = height * 0.02;

    UINetease lyricUI = UINetease(
        defaultTextStyle: TextStyle(
          color: Colors.white,
          fontSize: MediaQuery.of(context).size.height * 0.022,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.75),
              offset: const Offset(1, 2),
              blurRadius: 4,
            ),
          ],
        ),
        defaultExtTextStyle: TextStyle(
          color: oneLine ? Colors.transparent : Colors.grey,
          fontSize: MediaQuery.of(context).size.height * 0.020,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: oneLine ? 0.0 : 0.75),
              offset: const Offset(1, 2),
              blurRadius: 4,
            ),
          ],
        ),
        otherMainTextStyle: TextStyle(
          color: oneLine ? Colors.transparent : Colors.grey,
          fontSize: MediaQuery.of(context).size.height * 0.020,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: oneLine ? 0.0 : 0.5),
              offset: const Offset(1, 2),
              blurRadius: 4,
            ),
          ],
        ),
        bias : 0.5,
        lineGap : 5,
        inlineGap : 5,
        highlightColor: Colors.blue, // SettingsController.lightColorNotifier.value,
        lyricAlign : LyricAlign.center,
        lyricBaseLine : LyricBaseLine.center,
        highlight : false
    );

    return Consumer<LyricsProvider>(
      builder: (_, lyricsProvider, __){
        var audioProvider = Provider.of<AudioProvider>(context, listen: false);
        return MultiValueListenableBuilder(
          valueListenables: [
            audioProvider.sliderNotifier,
            audioProvider.playingNotifier,
          ],
          builder: (context, values, child) {
            return LyricsReader(
                model: lyricsProvider.lyricsModelBuilder,
                position: values[0],
                lyricUi: lyricUI,
                playing: values[1],
                size: Size.infinite,
                padding: EdgeInsets.only(
                  right: width * 0.01,
                  left: width * 0.01,
                ),
                selectLineBuilder: oneLine ? null : (progress, confirm) {
                  return MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () async {
                        confirm.call();
                        audioProvider.seek(Duration(milliseconds: progress));
                      },
                    ),
                  );
                },
                emptyBuilder: oneLine ? null : () {
                  return lyricsProvider.unsyncedLyrics == "" ?
                  Center(
                    child: Text(
                      "No lyrics found",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: normalSize,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ) :
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
                            lyricsProvider.unsyncedLyrics,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: normalSize,
                              fontWeight: FontWeight.normal,
                            ),
                          )
                      ),
                    ),
                  );
                }
            );
          }
        );
      },
    );
  }
}