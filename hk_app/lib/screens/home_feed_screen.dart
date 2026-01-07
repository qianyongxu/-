import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/material_model.dart';
import '../widgets/responsive_material_grid.dart';
import 'featured_list_screen.dart';
import 'influencer_list_screen.dart';
import '../l10n/app_localizations.dart';

class HomeFeedScreen extends StatefulWidget {
  @override
  _HomeFeedScreenState createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  final _apiService = ApiService();
  late Future<List<MaterialModel>> _materials;

  @override
  void initState() {
    super.initState();
    // Fetch all materials or featured ones
    _materials = _apiService.getMaterials();
  }

  void _navigateToFeatured(String title, String filterType) {
    if (filterType == 'influencer') {
      Navigator.push(
        context,
        CupertinoPageRoute(builder: (context) => const InfluencerListScreen()),
      );
    } else {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) =>
              FeaturedListScreen(title: title, filterType: filterType),
        ),
      );
    }
  }

  Widget _buildFeaturedCard(
    String title,
    String subtitle,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth > 600 ? 220 : 140;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: cardWidth,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(24), // Slightly smaller radius
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8), // Reduced padding
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20), // Smaller icon
            ),
            Spacer(),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18, // Slightly smaller font
                fontWeight: FontWeight.bold, // Bolder
                height: 1.1,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Safe Localization Access
    final l10n = AppLocalizations.of(context);

    return CustomScrollView(
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        // Sticky Header with SliverAppBar
        SliverAppBar(
          backgroundColor: Colors.transparent,
          pinned: false,
          floating: true,
          expandedHeight: 20.0, // Reduced height since title is gone
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: EdgeInsets.only(left: 24, bottom: 16),
          ),
        ),

        // Title
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              top: 4,
              bottom: 4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TODAY',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                Text(
                  '${DateTime.now().month}月${DateTime.now().day}日',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Featured Collections
        SliverToBoxAdapter(
          child: Container(
            height: 160,
            margin: EdgeInsets.only(top: 0, bottom: 10),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 12),
              children: [
                _buildFeaturedCard(
                  l10n.translate('trending_recommend'),
                  l10n.translate('weekly_popular'),
                  Colors.orange,
                  CupertinoIcons.flame_fill,
                  () => _navigateToFeatured(
                    l10n.translate('trending_recommend'),
                    'trending',
                  ),
                ),
                SizedBox(width: 16),
                _buildFeaturedCard(
                  l10n.translate('influencer_choice'),
                  l10n.translate('kol_recommend'),
                  Colors.pink,
                  CupertinoIcons.star_fill,
                  () => _navigateToFeatured(
                    l10n.translate('influencer_choice'),
                    'influencer',
                  ),
                ),
                SizedBox(width: 16),
                _buildFeaturedCard(
                  l10n.translate('new_arrivals'),
                  l10n.translate('designer_new'),
                  Colors.blue,
                  CupertinoIcons.sparkles,
                  () => _navigateToFeatured(
                    l10n.translate('new_arrivals'),
                    'new',
                  ),
                ),
              ],
            ),
          ),
        ),

        // Waterfall Grid
        FutureBuilder<List<MaterialModel>>(
          future: _materials,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CupertinoActivityIndicator(color: Colors.white),
                  ),
                ),
              );
            } else if (snapshot.hasError) {
              debugPrint('Load Error: ${snapshot.error}');
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      l10n.translate('load_failed'),
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              );
            }

            final List<MaterialModel> data = snapshot.data ?? [];
            if (data.isEmpty) {
              return SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      l10n.translate('no_data'),
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: EdgeInsets.only(bottom: 120),
              sliver: ResponsiveMaterialGrid(materials: data),
            );
          },
        ),
      ],
    );
  }
}
