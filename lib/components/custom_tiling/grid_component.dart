import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/components/custom_tiling/grid_tile.dart';
import 'package:musicplayer/entities/abstract/abstract_entity.dart';

class GridComponent extends StatelessWidget {
  final List items;
  final Function(AbstractEntity) onTap;
  final Function(AbstractEntity) onLongPress;
  final bool Function(AbstractEntity) isSelected;
  final Widget Function(AbstractEntity)? buildLeftAction;
  final Widget Function(AbstractEntity)? buildMainAction;
  final Widget Function(AbstractEntity)? buildRightAction;
  final Widget Function()? buildExtraTile;

  const GridComponent({
    super.key,
    required this.items,
    required this.onTap,
    required this.onLongPress,
    required this.isSelected,
    this.buildLeftAction,
    this.buildMainAction,
    this.buildRightAction,
    this.buildExtraTile,
  });

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;

    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: width * 0.125,
        crossAxisSpacing: width * 0.0125,
        mainAxisSpacing: width * 0.0125,
      ),
      itemCount: items.length + (buildExtraTile != null ? 1 : 0),
      itemBuilder: (BuildContext context, int index) {
        if (buildExtraTile != null && index == 0) {
          return buildExtraTile!();
        }
        return CustomGridTile(
          onTap: () {
            onTap(items[index - (buildExtraTile != null ? 1 : 0)]);
          },
          onLongPress: () {
            onLongPress(items[index - (buildExtraTile != null ? 1 : 0)]);
          },
          entity: items[index - (buildExtraTile != null ? 1 : 0)],
          isSelected: isSelected(items[index - (buildExtraTile != null ? 1 : 0)]),
          leftAction: buildLeftAction != null
              ? buildLeftAction!(items[index - (buildExtraTile != null ? 1 : 0)])
              : const SizedBox.shrink(),
          rightAction: buildRightAction != null
              ? buildRightAction!(items[index - (buildExtraTile != null ? 1 : 0)])
              : const SizedBox.shrink(),
          mainAction: buildMainAction != null
              ? buildMainAction!(items[index - (buildExtraTile != null ? 1 : 0)])
              : const SizedBox.shrink(),
        );
      },
    );
  }


}