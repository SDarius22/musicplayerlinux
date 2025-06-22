import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/components/custom_tiling/grid_tile.dart';
import 'package:musicplayer/entities/abstract/abstract_entity.dart';

class GridComponent extends StatelessWidget {
  final List items;
  final Function(AbstractEntity) onTap;
  final Function(AbstractEntity) onLongPress;
  final Widget Function(AbstractEntity)? buildLeftAction;
  final Widget Function(AbstractEntity)? buildMainAction;
  final Widget Function(AbstractEntity)? buildRightAction;

  const GridComponent({super.key, required this.items, required this.onTap, required this.onLongPress, this.buildLeftAction, this.buildMainAction, this.buildRightAction});

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: width * 0.125,
        crossAxisSpacing: width * 0.0125,
        mainAxisSpacing: width * 0.0125,
      ),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int index) {
        return CustomGridTile(
          onTap: () {
            onTap(items[index]);
          },
          onLongPress: () {
            onLongPress(items[index]);
          },
          entity: items[index],
          leftAction: buildLeftAction != null
              ? buildLeftAction!(items[index])
              : const SizedBox.shrink(),
          rightAction: buildRightAction != null
              ? buildRightAction!(items[index])
              : const SizedBox.shrink(),
          mainAction: buildMainAction != null
              ? buildMainAction!(items[index])
              : const SizedBox.shrink(),
        );
      },
    );
  }


}