import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:musicplayer/components/custom_text_scroll.dart';
import 'package:musicplayer/components/image_widget.dart';
import 'package:musicplayer/entities/abstract/abstract_collection.dart';
import 'package:musicplayer/entities/abstract/abstract_entity.dart';
import 'package:musicplayer/entities/playlist.dart';
import 'package:musicplayer/entities/song.dart';
import 'package:musicplayer/providers/audio_provider.dart';
import 'package:musicplayer/utils/fluenticons/fluenticons.dart';
import 'package:provider/provider.dart';

class CustomGridTile extends StatelessWidget {
  final Widget leftAction;
  final Widget mainAction;
  final Widget rightAction;
  final GestureTapCallback onTap;
  final GestureTapCallback onLongPress;
  final bool isSelected;
  final AbstractEntity entity;

  const CustomGridTile({
    super.key,
    required this.onTap,
    required this.onLongPress,
    required this.entity,
    required this.isSelected,
    this.leftAction = const SizedBox.shrink(),
    this.mainAction = const SizedBox.shrink(),
    this.rightAction = const SizedBox.shrink(),
  });

  String _pathForImageWidget(AbstractEntity entity) {
    if (entity is Song) {
      return (entity).path;
    }
    if (entity is Playlist) {
      if (entity.name == 'Current Queue' && entity.indestructible) {
        return 'assets/current_queue.png';
      }
      if (entity.name == 'Create New Playlist' && entity.indestructible) {
        return 'assets/create_playlist.png';
      }
      if (entity.coverArt != null && entity.coverArt!.isNotEmpty) {
        return base64Encode(entity.coverArt!);
      }
      return (entity).pathsInOrder.isNotEmpty
            ? (entity).pathsInOrder.first
            : '';
    }
    if (entity is AbstractCollection) {
      return (entity as AbstractCollection).songs.isNotEmpty
          ? (entity as AbstractCollection).songs.first.path
          : '';
    }
    return '';
  }

  ImageWidgetType _getImageWidgetType(AbstractEntity entity) {
    if (entity is Playlist) {
      if (entity.name == 'Current Queue' && entity.indestructible) {
        return ImageWidgetType.asset;
      }
      if (entity.name == 'Create New Playlist' && entity.indestructible) {
        return ImageWidgetType.asset;
      }
      if (entity.coverArt != null && entity.coverArt!.isNotEmpty) {
        return ImageWidgetType.bytes;
      }
    }
    return ImageWidgetType.song;
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    var normalSize = height * 0.02;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Hero(
          tag: entity is Song
              ? (entity as Song).path
              : entity.name,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(width * 0.01),
            child: ImageWidget(
              path: _pathForImageWidget(entity),
              type: _getImageWidgetType(entity),
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
              child: isSelected
                  ? ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.4),
                    alignment: Alignment.center,
                    child:  Icon(
                      FluentIcons.check,
                      color: Colors.white,
                      size: height * 0.05,
                    ),
                  ),
                ),
              )
                  : Container(
                alignment: Alignment.bottomCenter,
                padding: EdgeInsets.only(
                  bottom: height * 0.005,
                ),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: FractionalOffset.center,
                        end: FractionalOffset.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.0),
                          Colors.black.withValues(alpha: 0.5),
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

      ),
    );
  }
}
