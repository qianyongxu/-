import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../models/material_model.dart';
import 'vision_glass_card.dart';

class ResponsiveMaterialGrid extends StatelessWidget {
  final List<MaterialModel> materials;
  final bool showRank;

  const ResponsiveMaterialGrid({required this.materials, this.showRank = false});

  @override
  Widget build(BuildContext context) {
    // Responsive column count
    int crossAxisCount = 2;
    double width = MediaQuery.of(context).size.width;
    if (width >= 900) {
      crossAxisCount = 4;
    } else if (width >= 600) {
      crossAxisCount = 3;
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
      sliver: AnimationLimiter(
        child: SliverMasonryGrid.count(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childCount: materials.length,
          itemBuilder: (context, index) {
            final material = materials[index];
            return AnimationConfiguration.staggeredGrid(
              position: index,
              duration: const Duration(milliseconds: 500),
              columnCount: crossAxisCount,
              child: ScaleAnimation(
                child: FadeInAnimation(
                  child: VisionGlassCard(material: material, index: index, showRank: showRank),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
