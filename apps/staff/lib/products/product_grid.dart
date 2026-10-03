import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Lays out product cards in rows that fit the space: at least 2 per row (even on a phone),
/// more when there is room. Each card grows a little so a row has no gap on the side.
/// The order picker and the Products page both use it, so they always look the same.
class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key, required this.itemCount, required this.itemBuilder});

  final int itemCount;
  final Widget Function(BuildContext context, int index, double cardWidth) itemBuilder;

  @override
  Widget build(BuildContext context) {
    // LayoutBuilder tells us how much width we have.
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final columns = math.max(2, ((constraints.maxWidth + spacing) / (150 + spacing)).floor());
        final cardWidth = (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [for (var i = 0; i < itemCount; i++) itemBuilder(context, i, cardWidth)],
        );
      },
    );
  }
}
