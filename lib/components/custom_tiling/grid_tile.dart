import 'package:flutter/material.dart';
import 'package:musicplayer/components/custom_text_scroll.dart';
import 'package:musicplayer/components/image_widget.dart';
import 'package:musicplayer/entities/abstract/abstract_collection.dart';
import 'package:musicplayer/entities/abstract/abstract_entity.dart';
import 'package:musicplayer/entities/song.dart';
import 'package:musicplayer/providers/audio_provider.dart';
import 'package:provider/provider.dart';

class CustomGridTile extends StatelessWidget {
  final Widget leftAction;
  final Widget mainAction;
  final Widget rightAction;
  final GestureTapCallback onTap;
  final GestureTapCallback onLongPress;
  final AbstractEntity entity;

  const CustomGridTile({
    super.key,
    required this.onTap,
    required this.onLongPress,
    required this.entity,
    this.leftAction = const SizedBox.shrink(),
    this.mainAction = const SizedBox.shrink(),
    this.rightAction = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var normalSize = height * 0.02;
    // debugPrint('CustomGridTile: ${entity.name}');
    // debugPrint('CustomGridTile: ${entity.runtimeType}');

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(width * 0.01),
          child: ImageWidget(
            path: entity is Song
                ? (entity as Song).path
                : (entity as AbstractCollection).songs[0].path,
            heroTag: entity is Song ? (entity as Song).path : entity.name,
            hoveredChild: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: width * 0.035,
                  height: width * 0.035,
                  child: leftAction,
                ),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.fill,
                    child: mainAction,
                  ),
                ),
                SizedBox(
                  width: width * 0.035,
                  height: width * 0.035,
                  child: rightAction,
                ),
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
                      stops: const [
                    0.0,
                    0.5,
                    1.0
                  ])),
              child: entity is Song
                  ? Consumer<AudioProvider>(
                      builder: (_, audioProvider, __) {
                        return CustomTextScroll(
                          text: entity.name,
                          style: TextStyle(
                            color: audioProvider.currentSong.path ==
                                (entity as Song).path ? Colors.blue : Colors.white,
                            fontSize: normalSize,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      },
                    )
                  : CustomTextScroll(
                      text: entity.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: normalSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
