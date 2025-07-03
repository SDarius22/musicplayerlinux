import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/components/custom_tiling/list_tile.dart';
import 'package:musicplayer/entities/abstract/abstract_entity.dart';

class ListComponent extends StatelessWidget {
  final List<AbstractEntity> items;
  final double itemExtent;
  final Function(AbstractEntity) onTap;
  final Function(AbstractEntity) onLongPress;
  final bool Function(AbstractEntity) isSelected;
  final Widget? leadingAction;
  final Widget? trailingAction;

  const ListComponent({
    super.key,
    required this.items,
    required this.itemExtent,
    required this.onTap,
    required this.onLongPress,
    required this.isSelected,
    this.leadingAction,
    this.trailingAction,
  });

  @override
  Widget build(BuildContext context) {
    return SliverFixedExtentList.builder(
      itemCount: items.length,
      itemExtent: itemExtent,
      itemBuilder: (BuildContext context, int index) {
        return CustomListTile(
          onTap: () {
            onTap(items[index]);
          },
          onLongPress: () {
            onLongPress(items[index]);
          },
          isSelected: isSelected(items[index]),
          entity: items[index],
          leadingAction: leadingAction ?? const SizedBox.shrink(),
          trailingAction: trailingAction ?? const SizedBox.shrink(),
        );
      },
    );
  }
}