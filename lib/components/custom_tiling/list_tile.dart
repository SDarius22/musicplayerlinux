import 'package:flutter/material.dart';
import 'package:musicplayer/components/custom_text_scroll.dart';
import 'package:musicplayer/components/image_widget.dart';
import 'package:musicplayer/entities/abstract/abstract_collection.dart';
import 'package:musicplayer/entities/abstract/abstract_entity.dart';
import 'package:musicplayer/entities/song.dart';
import 'package:musicplayer/utils/hover_widget/hover_container.dart';

class CustomListTile extends StatelessWidget {
  final AbstractEntity entity;
  final Widget? leadingAction;
  final Widget? trailingAction;
  final GestureTapCallback onTap;
  final GestureLongPressCallback onLongPress;

  const CustomListTile({
    super.key,
    required this.entity,
    required this.onTap,
    required this.onLongPress,
    this.leadingAction = const SizedBox.shrink(),
    this.trailingAction = const SizedBox.shrink(),
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    var normalSize = height * 0.02;
    var smallSize = height * 0.015;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: HoverContainer(
          hoverColor: Theme.of(context).hoverColor,
          width: width * 0.3,
          margin: EdgeInsets.symmetric(
            vertical: height * 0.005,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: height * 0.07,
                margin: EdgeInsets.only(
                  right: height * 0.01,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: ImageWidget(
                    heroTag: entity.name,
                    path: entity is Song ? (entity as Song).path
                        : (entity as AbstractCollection).songs[0].path,
                    hoveredChild: leadingAction,
                  ),
                ),
              ),
              SizedBox(
                width: width * 0.15,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextScroll(
                        text: entity.name,
                        style: TextStyle(
                          fontSize: normalSize,
                        )
                    ),
                    if (entity is Song)
                      CustomTextScroll(
                        text: (entity as Song).trackArtist,
                        style: TextStyle(
                          fontSize: smallSize,
                        ),
                      ),
                  ],
                ),
              ),
              const Spacer(),
              if (entity is Song)
                Text (
                  "${(entity as Song).duration ~/ 60}:${((entity as Song).duration % 60).toString().padLeft(2, '0')}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              trailingAction!,
            ],
          ),
        ),
      )
    );
  }
}