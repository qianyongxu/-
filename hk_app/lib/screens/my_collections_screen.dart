import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import '../models/material_model.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';
import '../widgets/responsive_material_grid.dart';
import '../l10n/app_localizations.dart';

class MyCollectionsScreen extends StatefulWidget {
  @override
  _MyCollectionsScreenState createState() => _MyCollectionsScreenState();
}

class _MyCollectionsScreenState extends State<MyCollectionsScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<MaterialModel>> _collections;

  @override
  void initState() {
    super.initState();
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id;
    if (userId != null) {
      _collections = _apiService.getFavorites(userId);
    } else {
      _collections = Future.value([]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Ambient Background (Matching Main Screen)
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF007AFF).withOpacity(0.6),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFF2D55).withOpacity(0.6),
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          CustomScrollView(
            physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                pinned: true,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(CupertinoIcons.back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: Text(
                  l10n.translate('my_collections'),
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              
              FutureBuilder<List<MaterialModel>>(
                future: _collections,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SliverToBoxAdapter(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        alignment: Alignment.center,
                        child: CupertinoActivityIndicator(color: Colors.white),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return SliverToBoxAdapter(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        alignment: Alignment.center,
                        child: Text(l10n.translate('load_failed'), style: TextStyle(color: Colors.white70)),
                      ),
                    );
                  } else if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                    return SliverToBoxAdapter(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.7,
                        alignment: Alignment.center,
                        child: Text(l10n.translate('no_data'), style: TextStyle(color: Colors.white70)),
                      ),
                    );
                  }

                  return ResponsiveMaterialGrid(materials: snapshot.data ?? []);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
