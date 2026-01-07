import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/api_service.dart';
import '../models/material_model.dart';
import '../widgets/responsive_material_grid.dart';

class FeaturedListScreen extends StatefulWidget {
  final String title;
  final String? filterType; // e.g., 'new', 'trending', 'editors'

  const FeaturedListScreen({required this.title, this.filterType});

  @override
  _FeaturedListScreenState createState() => _FeaturedListScreenState();
}

class _FeaturedListScreenState extends State<FeaturedListScreen> {
  final _apiService = ApiService();
  late Future<List<MaterialModel>> _materials;

  @override
  void initState() {
    super.initState();
    // In a real app, you'd pass the filterType to the API
    // For now, we'll just fetch all materials or randomized ones
    _materials = _apiService.getMaterials();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.black, // Force black background to match MainScreen
      body: Stack(
        children: [
          // 1. Background Effects (Copied from MainScreen for consistency)
          Positioned(
            top: -100,
            left: -100,
            child: _buildAmbientOrb(Color(0xFF007AFF), 300),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: _buildAmbientOrb(Color(0xFFFF2D55), 300),
          ),
          // Blur Mesh
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          // 2. Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent, // Transparent to show orbs
                expandedHeight: kToolbarHeight,
                floating: true,
                pinned: false,
                leading: IconButton(
                  icon: Icon(
                    CupertinoIcons.back,
                    color: Colors.white,
                  ), // White icon
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Custom Header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${DateTime.now().year}年${DateTime.now().month}月 第${(DateTime.now().day / 7).ceil()}周榜单',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '综合搜索、下载、分享收藏等热度算法排名',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              FutureBuilder<List<MaterialModel>>(
                future: _materials,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 100),
                        child: Center(
                          child: CupertinoActivityIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          'Error loading data',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }

                  final data = snapshot.data ?? [];

                  // Use ResponsiveMaterialGrid for all types to maintain waterfall layout
                  return ResponsiveMaterialGrid(
                    materials: data,
                    showRank: widget.filterType == 'trending',
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmbientOrb(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.6),
      ),
    );
  }
}
