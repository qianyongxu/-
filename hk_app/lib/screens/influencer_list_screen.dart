import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/api_service.dart';
import '../models/app_models.dart';
import 'package:url_launcher/url_launcher.dart';

class InfluencerListScreen extends StatefulWidget {
  const InfluencerListScreen({super.key});

  @override
  _InfluencerListScreenState createState() => _InfluencerListScreenState();
}

class _InfluencerListScreenState extends State<InfluencerListScreen> {
  final _apiService = ApiService();
  late Future<List<InfluencerPick>> _picks;

  @override
  void initState() {
    super.initState();
    _picks = _apiService.getInfluencerPicks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Effects
          Positioned(
            top: -100,
            right: -100,
            child: _buildAmbientOrb(Colors.pink, 300),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: _buildAmbientOrb(Colors.purple, 300),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                expandedHeight: 120.0,
                floating: false,
                pinned: true,
                leading: IconButton(
                  icon: const Icon(CupertinoIcons.back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: const FlexibleSpaceBar(
                  titlePadding: EdgeInsets.only(left: 16, bottom: 16),
                  title: Text(
                    '达人同款',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              FutureBuilder<List<InfluencerPick>>(
                future: _picks,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 100),
                        child: Center(
                          child: CupertinoActivityIndicator(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          'Error loading data',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }

                  final data = snapshot.data ?? [];
                  if (data.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          '暂无推荐',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final pick = data[index];
                        return _buildPickCard(pick);
                      }, childCount: data.length),
                    ),
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

  Widget _buildPickCard(InfluencerPick pick) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.network(
              pick.coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.grey.shade900,
                child: const Icon(Icons.broken_image, color: Colors.white24),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pick.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  pick.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _handleTap(pick),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        '查看详情',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(InfluencerPick pick) async {
    if (pick.targetType == 'link') {
      final uri = Uri.parse(pick.targetId);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } else {
      // Navigate to material detail?
      // For now show snackbar as we don't have direct material ID lookup without fetching all materials
      // In a real app, we would fetch the single material by ID
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opening Material: ${pick.targetId}')),
      );
    }
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
