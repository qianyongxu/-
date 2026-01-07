import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import '../models/material_model.dart';
import '../services/api_service.dart';
import '../widgets/responsive_material_grid.dart';
import '../l10n/app_localizations.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final ApiService _apiService = ApiService();

  List<MaterialModel> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    // Auto focus on search input
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_searchFocusNode);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _lastQuery = query;
    });

    try {
      final results = await _apiService.getMaterials(query: query);
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _searchResults = [];
      });
      // Optionally show error toast
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: Colors.black, // Match App Theme
      body: Stack(
        children: [
          // Background Gradient (Simplified version of MainScreen)
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF007AFF).withOpacity(0.4),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.black.withOpacity(0.5)),
          ),

          SafeArea(
            child: Column(
              children: [
                // Search Bar Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 0.5,
                            ),
                          ),
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            style: TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText:
                                  AppLocalizations.of(
                                        context,
                                      ).translate('search_hint') !=
                                      'search_hint'
                                  ? AppLocalizations.of(
                                      context,
                                    ).translate('search_hint')
                                  : '搜索素材...', // Fallback
                              hintStyle: TextStyle(color: Colors.white38),
                              prefixIcon: Icon(
                                CupertinoIcons.search,
                                color: Colors.white54,
                                size: 20,
                              ),
                              border: InputBorder.none,
                              isDense: true, // Reduce height
                              contentPadding: EdgeInsets.only(
                                top: 8,
                              ), // Adjust vertical alignment
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () {
                                        _searchController.clear();
                                        setState(() {
                                          _searchResults = [];
                                          _hasSearched = false;
                                        });
                                      },
                                      child: Icon(
                                        CupertinoIcons.clear_circled_solid,
                                        color: Colors.white38,
                                        size: 18,
                                      ),
                                    )
                                  : null,
                            ),
                            onSubmitted: _performSearch,
                            onChanged: (val) {
                              // Rebuild to show/hide clear button
                              setState(() {});
                            },
                            textInputAction: TextInputAction.search,
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Text(
                          AppLocalizations.of(context).translate('cancel'),
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content Area
                Expanded(
                  child: _isLoading
                      ? Center(
                          child: CupertinoActivityIndicator(
                            color: Colors.white,
                          ),
                        )
                      : _hasSearched && _searchResults.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.search,
                                size: 64,
                                color: Colors.white24,
                              ),
                              SizedBox(height: 16),
                              Text(
                                AppLocalizations.of(
                                          context,
                                        ).translate('no_results') !=
                                        'no_results'
                                    ? AppLocalizations.of(
                                        context,
                                      ).translate('no_results')
                                    : '未找到相关素材',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : !_hasSearched
                      ? _buildSearchSuggestions()
                      : CustomScrollView(
                          physics: BouncingScrollPhysics(),
                          slivers: [
                            ResponsiveMaterialGrid(materials: _searchResults),
                            SliverToBoxAdapter(child: SizedBox(height: 20)),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    // Removed popular search as requested
    return Container();
  }
}
