import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:ui';
import '../services/api_service.dart';
import '../models/app_models.dart';
import 'help_guide_detail_screen.dart';

class HelpGuideScreen extends StatefulWidget {
  const HelpGuideScreen({super.key});

  @override
  _HelpGuideScreenState createState() => _HelpGuideScreenState();
}

class _HelpGuideScreenState extends State<HelpGuideScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<HelpGuide>> _guidesFuture;

  @override
  void initState() {
    super.initState();
    _guidesFuture = _apiService.getHelpGuides();
  }

  @override
  Widget build(BuildContext context) {
     return Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
             // Background
             Positioned(
               top: -100, right: -100,
               child: _buildOrb(Colors.blue, 300),
             ),
             BackdropFilter(
               filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
               child: Container(color: Colors.black.withOpacity(0.5)),
             ),

             SafeArea(
               child: Column(
                 children: [
                    // NavBar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                           GestureDetector(
                             onTap: () => Navigator.pop(context),
                             child: Container(
                               padding: EdgeInsets.all(8),
                               decoration: BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
                               child: Icon(CupertinoIcons.back, color: Colors.white),
                             ),
                           ),
                           Expanded(child: Center(child: Text('帮助与指南', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))),
                           SizedBox(width: 40),
                        ],
                      ),
                    ),
                    Expanded(
                       child: FutureBuilder<List<HelpGuide>>(
                          future: _guidesFuture,
                          builder: (ctx, snapshot) {
                             if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CupertinoActivityIndicator(color: Colors.white));
                             if (snapshot.hasError) return Center(child: Text('加载失败', style: TextStyle(color: Colors.white54)));
                             final guides = snapshot.data ?? [];
                             if (guides.isEmpty) return Center(child: Text('暂无指南', style: TextStyle(color: Colors.white54)));
                             
                             return ListView.separated(
                                padding: EdgeInsets.all(16),
                                itemCount: guides.length,
                                separatorBuilder: (_, __) => SizedBox(height: 12),
                                itemBuilder: (ctx, index) {
                                   final guide = guides[index];
                                   return GestureDetector(
                                      onTap: () {
                                         Navigator.push(context, CupertinoPageRoute(builder: (_) => HelpGuideDetailScreen(guide: guide)));
                                      },
                                      child: Container(
                                         padding: EdgeInsets.all(16),
                                         decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                                         ),
                                         child: Row(
                                            children: [
                                               Container(
                                                  padding: EdgeInsets.all(10),
                                                  decoration: BoxDecoration(
                                                     color: Colors.blue.withOpacity(0.2),
                                                     borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Icon(CupertinoIcons.book_fill, color: Colors.blueAccent),
                                               ),
                                               SizedBox(width: 16),
                                               Expanded(
                                                  child: Text(guide.title, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                                               ),
                                               Icon(CupertinoIcons.chevron_right, color: Colors.white54, size: 20),
                                            ],
                                         ),
                                      ),
                                   );
                                }
                             );
                          }
                       ),
                    ),
                 ],
               ),
             ),
          ],
        ),
     );
  }

  Widget _buildOrb(Color color, double size) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color.withOpacity(0.4), shape: BoxShape.circle));
  }
}
