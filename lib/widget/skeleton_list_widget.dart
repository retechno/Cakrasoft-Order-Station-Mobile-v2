import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ItemListSkeleton extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final double itemWidth;
  final EdgeInsetsGeometry itemPadding;
  final EdgeInsetsGeometry listPadding;
  final bool isHorizontal;

  ItemListSkeleton({
    required this.itemCount,
    this.itemHeight = 80,
    this.itemWidth = double.infinity,
    this.itemPadding = const EdgeInsets.all(10),
    this.listPadding = const EdgeInsets.all(10),
    this.isHorizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: listPadding,
      scrollDirection: isHorizontal ? Axis.horizontal : Axis.vertical,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: itemPadding,
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: itemHeight,
              width: itemWidth,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        );
      },
    );
  }
}
