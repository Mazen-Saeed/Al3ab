import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import 'unit.dart';
import 'unit_tile.dart';

/// The Floor screen (home). For now: just the 12 sample tiles in a simple wrap,
/// to check how one tile looks in every state. Step 3 replaces this with the real grid.
class FloorScreen extends StatelessWidget {
  const FloorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final units = buildSampleUnits();

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.homeTitle)),
      body: SingleChildScrollView(
        padding: const EdgeInsetsDirectional.all(20),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final unit in units)
              SizedBox(
                width: 200,
                child: UnitTile(unit: unit, selected: unit.id == 'ps5-1'),
              ),
          ],
        ),
      ),
    );
  }
}
