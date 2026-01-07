import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../services/api_service.dart';
import '../models/material_model.dart';
import '../widgets/responsive_material_grid.dart';
import '../l10n/app_localizations.dart';

class CategoryScreen extends StatefulWidget {
  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  int _selectedIndex = 0;
  final List<String> _types = [
    'brush',
    'palette',
    'font',
    'line',
    '3d',
    'gif',
    'texture',
    'illustration',
  ];

  @override
  Widget build(BuildContext context) {
    final List<String> _tabs = [
      AppLocalizations.of(context).translate('tab_brush'),
      AppLocalizations.of(context).translate('tab_palette'),
      AppLocalizations.of(context).translate('tab_font'),
      AppLocalizations.of(context).translate('tab_line'),
      AppLocalizations.of(context).translate('tab_3d'),
      AppLocalizations.of(context).translate('tab_gif'),
      AppLocalizations.of(context).translate('tab_texture'),
      AppLocalizations.of(context).translate('tab_illustration'),
    ];

    return Scaffold(
      backgroundColor: Colors.black, // Match other screens
      body: Stack(
        children: [
          // Background Effects
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
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          Row(
            children: [
              // Left Side Navigation
              Container(
                width: 80,
                padding: EdgeInsets.only(top: 60, bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                ),
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: _tabs.length,
                  itemBuilder: (context, index) {
                    final isSelected = _selectedIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 4,
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _getIconForIndex(index),
                              color: isSelected ? Colors.white : Colors.white54,
                              size: 24,
                            ),
                            SizedBox(height: 4),
                            Text(
                              _tabs[index],
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : Colors.white54,
                                fontSize: 11,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Right Side Content
              Expanded(
                child: MaterialList(
                  key: ValueKey(_selectedIndex),
                  type: _types[_selectedIndex],
                  categoryName: _tabs[_selectedIndex],
                ),
              ),
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

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return CupertinoIcons.paintbrush_fill;
      case 1:
        return CupertinoIcons.circle_grid_hex_fill;
      case 2:
        return CupertinoIcons.textformat;
      case 3:
        return CupertinoIcons.scribble;
      case 4:
        return CupertinoIcons.cube_box_fill;
      case 5:
        return CupertinoIcons.play_circle_fill;
      case 6:
        return CupertinoIcons.layers_alt_fill;
      case 7:
        return CupertinoIcons.photo_fill;
      default:
        return CupertinoIcons.square_fill;
    }
  }
}

class MaterialList extends StatefulWidget {
  final String type;
  final String categoryName;

  const MaterialList({Key? key, required this.type, required this.categoryName})
    : super(key: key);

  @override
  _MaterialListState createState() => _MaterialListState();
}

class _MaterialListState extends State<MaterialList> {
  final _apiService = ApiService();
  late Future<List<MaterialModel>> _materials;

  @override
  void initState() {
    super.initState();
    // Use 'category' parameter instead of 'type'
    _materials = _apiService.getMaterials(category: widget.type);
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: BouncingScrollPhysics(),
      slivers: [
        FutureBuilder<List<MaterialModel>>(
          future: _materials,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Center(child: CupertinoActivityIndicator()),
                ),
              );
            } else if (snapshot.hasError) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 100),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context).translate('load_failed'),
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
              );
            }

            final count = snapshot.data?.length ?? 0;

            return SliverMainAxisGroup(
              slivers: [
                SliverToBoxAdapter(
                  child: Container(
                    padding: EdgeInsets.fromLTRB(20, 60, 20, 10),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          widget.categoryName,
                          style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Colors.white, // White for dark mode
                            letterSpacing: -1,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '$count ${AppLocalizations.of(context).translate('count_materials')}',
                          style: TextStyle(fontSize: 14, color: Colors.white54),
                        ),
                      ],
                    ),
                  ),
                ),
                if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true))
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context).translate('no_data'),
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                  )
                else
                  ResponsiveMaterialGrid(materials: snapshot.data ?? []),
              ],
            );
          },
        ),
        SliverToBoxAdapter(child: SizedBox(height: 120)),
      ],
    );
  }
}
