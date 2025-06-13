import 'package:flutter/cupertino.dart';
import 'package:musicplayer/components/custom_tiling/grid_tile.dart';
import 'package:musicplayer/entities/abstract/abstract_entity.dart';

class GridComponent extends StatelessWidget {
  final List<AbstractEntity> items;
  final Function(AbstractEntity) onTap;
  final Function(AbstractEntity) onLongPress;
  final Widget? leftAction;
  final Widget? rightAction;
  final Widget? mainAction;

  const GridComponent({super.key, required this.items, required this.onTap, required this.onLongPress, this.leftAction, this.rightAction, this.mainAction});

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
          leftAction: leftAction ?? const SizedBox.shrink(),
          rightAction: rightAction ?? const SizedBox.shrink(),
          mainAction: mainAction ?? const SizedBox.shrink(),
        );
      },
    );
  }


}