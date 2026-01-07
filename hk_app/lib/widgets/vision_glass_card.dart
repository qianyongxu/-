import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:animations/animations.dart';
import '../models/material_model.dart';
import '../screens/material_detail_screen.dart';

class VisionGlassCard extends StatefulWidget {
  final MaterialModel material;
  final int index;
  final bool showRank;

  const VisionGlassCard({
    required this.material,
    required this.index,
    this.showRank = false,
  });

  @override
  State<VisionGlassCard> createState() => _VisionGlassCardState();
}

class _VisionGlassCardState extends State<VisionGlassCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            opaque: false, // Critical for background blur
            barrierColor: Colors.black.withOpacity(
              0.01,
            ), // Keep it transparent, blur handled in screen
            pageBuilder: (context, animation, secondaryAnimation) =>
                MaterialDetailScreen(material: widget.material),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // Image with Hero
                AspectRatio(
                  aspectRatio: 1 / 1.3,
                  child: Container(
                    color: Colors.grey.shade800,
                    child: Hero(
                      tag: 'material_${widget.material.id}',
                      child: widget.material.thumbnail.isNotEmpty
                          ? Image.network(
                              widget.material.thumbnail,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Center(
                                    child: Icon(
                                      CupertinoIcons.photo,
                                      color: Colors.white.withOpacity(0.3),
                                      size: 40,
                                    ),
                                  ),
                            )
                          : Center(
                              child: Icon(
                                CupertinoIcons.photo,
                                color: Colors.white.withOpacity(0.3),
                                size: 40,
                              ),
                            ),
                    ),
                  ),
                ),

                // Rank Badge
                if (widget.showRank && widget.index < 3)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: widget.index == 0
                            ? const Color(0xFFFFD700) // Gold
                            : widget.index == 1
                            ? const Color(0xFFC0C0C0) // Silver
                            : const Color(0xFFCD7F32), // Bronze
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'TOP ${widget.index + 1}',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),

                // Gradient Overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(12, 40, 12, 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.material.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            decoration: TextDecoration.none,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
